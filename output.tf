#############################OUTPUT##############################################
output "queue_arns" {
  value       = [aws_sqs_queue.sh_queue[*].arn, aws_sqs_queue.sh_dl_queue[*].arn]
  description = "ARNs of the created SQS queues"
}


output "consume_policy_arn" {
  value       = []
  description = ""
}

output "write_policy_arn" {
  value       = []
  description = ""
}
