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
  region = "eu-north-1"
  #   shared_config_files      = ["/Path/to/.aws/config"]
  #   shared_credentials_files = ["/Path/to/.aws/credentials"]
  profile = "default"
}

# resource "aws_sqs_queue" "sh_queue" {
#   name                       = "sh-example-queue"
#   delay_seconds              = 10
#   visibility_timeout_seconds = 30
#   max_message_size           = 2048
#   message_retention_seconds  = 86400
#   receive_wait_time_seconds  = 2
#   sqs_managed_sse_enabled    = true
# }

resource "aws_sqs_queue" "sh_queue" {
  name                       = each.value
  delay_seconds              = 10
  visibility_timeout_seconds = 30
  max_message_size           = 2048
  message_retention_seconds  = 86400
  receive_wait_time_seconds  = 2
  sqs_managed_sse_enabled    = true
  for_each                   = toset(var.resource_group_name) // convert list to set and iterate over it
}

variable "resource_group_name" {
  description = "Default resource group name that the network will be created in."
  type        = list(string)
  default     = ["asd-rg", "asd2-rg"]

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