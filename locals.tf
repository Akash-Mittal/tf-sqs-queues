locals {
  all_queue_arns = flatten([aws_sqs_queue.sh_queue[*].arn, aws_sqs_queue.sh_dl_queue[*].arn])
  all_queue_urls = flatten([aws_sqs_queue.sh_queue[*].id, aws_sqs_queue.sh_dl_queue[*].id])

  main_queue_arns = flatten([aws_sqs_queue.sh_queue[*].arn])
  dl_queue_arns   = flatten([aws_sqs_queue.sh_dl_queue[*].arn])
}
