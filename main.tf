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


resource "aws_sqs_queue_policy" "sh_queue_policy" {
  count     = length(var.resource_group_name)
  queue_url = aws_sqs_queue.sh_queue[count.index].url
  policy = jsonencode({
    Id = "QueuePolicy",
    Statement = [
      {
        Sid    = "kraken-sqs-sid",
        Effect = "Allow",
        Principal = {
          AWS = "*"
        },
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:SendMessage",
        ],
        Resource = aws_sqs_queue.sh_queue[count.index].arn
      },
    ]
  })
}


resource "aws_sqs_queue_policy" "sh_queue_dl_policy" {
  count     = length(var.resource_group_name)
  queue_url = aws_sqs_queue.sh_dl_queue[count.index].url
  policy = jsonencode({
    Id = "DLQueuePolicy",
    Statement = [
      {
        Sid    = "kraken-sqs-dl-sid",
        Effect = "Allow",
        Principal = {
          AWS = "*"
        },
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage"
        ],
        Resource = aws_sqs_queue.sh_dl_queue[count.index].arn
      },
    ]
  })
}

variable "resource_group_name" {
  description = "Queue Names meant to be created by default TD: Read from a data file"
  type        = list(string)
  default     = ["kraken-q-p1", "kraken-q-p2"]
}
