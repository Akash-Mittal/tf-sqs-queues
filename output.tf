#############################OUTPUT##############################################
output "queue_arns" {
  value       = [aws_sqs_queue.sh_queue[*].arn, aws_sqs_queue.sh_dl_queue[*].arn]
  description = "______________ARNs of the created SQS queues____________________"
}


output "consume_policy_arn" {
  value       = aws_iam_policy.consume_policy.arn
  description = "==================The ARN of the IAM policy for consuming messages===================="
}

output "write_policy_arn" {
  value       = aws_iam_policy.write_policy.arn
  description = "**************The ARN of the IAM policy for write messages***************"

}

