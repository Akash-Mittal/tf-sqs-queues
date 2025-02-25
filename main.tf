
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

resource "aws_sqs_queue" "sh_queue" {
  name                       = var.queue_names[count.index]
  count                      = length(var.queue_names)
  delay_seconds              = var.dlq_delay_seconds
  visibility_timeout_seconds = var.dlq_visibility_timeout_seconds
  max_message_size           = var.dlq_max_message_size
  message_retention_seconds  = var.dlq_message_retention_seconds
  receive_wait_time_seconds  = var.dlq_receive_wait_time_seconds
  sqs_managed_sse_enabled    = var.dlq_sqs_managed_sse_enabled
  redrive_policy = jsonencode({
    # deadLetterTargetArn = "${var.queue_names[count.index]}-dlq"
    deadLetterTargetArn = aws_sqs_queue.sh_dl_queue[count.index].arn
    maxReceiveCount     = 4
  })
}

resource "aws_sqs_queue" "sh_dl_queue" {
  name                       = "${var.queue_names[count.index]}-dlq"
  count                      = length(var.queue_names)
  delay_seconds              = var.dlq_delay_seconds
  visibility_timeout_seconds = var.dlq_visibility_timeout_seconds
  max_message_size           = var.dlq_max_message_size
  message_retention_seconds  = var.dlq_message_retention_seconds
  receive_wait_time_seconds  = var.dlq_receive_wait_time_seconds
  sqs_managed_sse_enabled    = var.dlq_sqs_managed_sse_enabled
}



########################### Consume Policy #############################
data "aws_iam_policy_document" "consume_policy_document" {
  statement {
    sid    = "AllowSQSReceiveAndDelete"
    effect = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
    ]
    resources = local.all_queue_arns
  }
}


resource "aws_iam_policy" "consume_policy" {
  name   = "ConsumePolicy"
  policy = data.aws_iam_policy_document.consume_policy_document.json
}


resource "aws_iam_role" "sqs_consumer_role" {
  name = "sqs_consumer_role"
  assume_role_policy = jsonencode({
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sqs_consumer_policy_attachment" {
  role       = aws_iam_role.sqs_consumer_role.name
  policy_arn = aws_iam_policy.consume_policy.arn
}


########################### Write Policy #############################
data "aws_iam_policy_document" "write_policy_document" {
  statement {
    sid    = "AllowSendMessage"
    effect = "Allow"
    actions = [
      "sqs:SendMessage",
    ]
    resources = local.main_queue_arns
  }
}


resource "aws_iam_policy" "write_policy" {
  name   = "WritePolicy"
  policy = data.aws_iam_policy_document.write_policy_document.json
}


resource "aws_iam_role" "sqs_write_role" {
  name = "sqs_write_role"
  assume_role_policy = jsonencode({
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sqs_write_policy_attachment" {
  role       = aws_iam_role.sqs_write_role.name
  policy_arn = aws_iam_policy.write_policy.arn
}
