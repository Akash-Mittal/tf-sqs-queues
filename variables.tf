
variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "aws_profile" {
  type        = string
  description = "AWS profile"
}

variable "resource_group_name" {
  description = "Queue Names meant to be created by default TD: Read from a data file"
  type        = list(string)
  default     = ["kraken-q-priority-1", "kraken-q-priority-10"]
}


variable "dlq_delay_seconds" {
  type        = number
  description = "Delay seconds for the dead-letter queues"
  default     = 10
}

variable "dlq_visibility_timeout_seconds" {
  type        = number
  description = "Visibility timeout seconds for the dead-letter queues"
  default     = 30
}

variable "dlq_max_message_size" {
  type        = number
  description = "Maximum message size for the dead-letter queues (in bytes)"
  default     = 2048
}

variable "dlq_message_retention_seconds" {
  type        = number
  description = "Message retention seconds for the dead-letter queues"
  default     = 86400
}

variable "dlq_receive_wait_time_seconds" {
  type        = number
  description = "Receive wait time seconds for the dead-letter queues"
  default     = 2
}

variable "dlq_sqs_managed_sse_enabled" {
  type        = bool
  description = "Whether SQS managed server-side encryption is enabled for the dead-letter queues"
  default     = true
}
