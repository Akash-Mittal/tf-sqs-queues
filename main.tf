terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
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

variable "resource_group_name" {
  description = "Default resource group name that the network will be created in."
  type        = list(string)
  default     = ["kraken-q-p1", "kraken-q-p2"]

}



# data "aws_iam_policy_document" "sh_sqs_policy" {
#   statement {
#     sid    = "shsqsstatement"
#     effect = "Allow"

#     principals {
#       type        = "AWS"
#       identifiers = ["*"]
#     }

#     actions = [
#       "sqs:SendMessage",
#       "sqs:ReceiveMessage"
#     ]
#     resources = [
#       aws_sqs_queue.sh_queue.arn
#     ]
#   }
# }

# resource "aws_sqs_queue_policy" "sh_sqs_policy" {
#   queue_url = aws_sqs_queue.sh_queue.id
#   policy    = data.aws_iam_policy_document.sh_sqs_policy.json
# }
