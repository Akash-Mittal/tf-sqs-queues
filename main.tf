terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region  = "eu-north-1"
  profile = "default"
}

resource "aws_sqs_queue" "sh_dl_queue" {
  name                       = "${var.resource_group_name[count.index]}-dlq"
  count                      = length(var.resource_group_name)
  delay_seconds              = 10
  visibility_timeout_seconds = 30
  max_message_size           = 2048
  message_retention_seconds  = 86400
  receive_wait_time_seconds  = 2
  sqs_managed_sse_enabled    = true
}

resource "aws_sqs_queue" "sh_queue" {
  name                       = var.resource_group_name[count.index]
  count                      = length(var.resource_group_name)
  delay_seconds              = 10
  visibility_timeout_seconds = 30
  max_message_size           = 2048
  message_retention_seconds  = 86400
  receive_wait_time_seconds  = 2
  sqs_managed_sse_enabled    = true
  redrive_policy = jsonencode({
    # deadLetterTargetArn = "${var.resource_group_name[count.index]}-dlq"
    deadLetterTargetArn = aws_sqs_queue.sh_dl_queue[count.index].arn
    maxReceiveCount     = 4
  })
}




locals {
  all_queue_arns  = flatten([aws_sqs_queue.sh_queue[*].arn, aws_sqs_queue.sh_dl_queue[*].arn])
  main_queue_arns = flatten([aws_sqs_queue.sh_queue[*].arn])
  dl_queue_arns   = flatten([aws_sqs_queue.sh_dl_queue[*].arn])
}


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





variable "resource_group_name" {
  description = "Queue Names meant to be created by default TD: Read from a data file"
  type        = list(string)
  default     = ["kraken-q-priority-1", "kraken-q-priority-2"]
}

output "queue_arns" {
  value       = [aws_sqs_queue.sh_queue[*].arn, aws_sqs_queue.sh_dl_queue[*].arn]
  description = "ARNs of the created SQS queues"
}
