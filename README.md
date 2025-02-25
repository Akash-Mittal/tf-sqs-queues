```markdown
# Terraform SQS Queue Module

This Terraform module creates SQS queues and their corresponding dead-letter queues (DLQs), along with IAM policies for consuming and sending messages.

## Module Input

*   `queue_names`: A list of queue names (strings).  This is the primary input and is **required**.

    *   Default: `["default-queue"]`

## Module Functionality

The module performs the following actions:

1.  **Queue Creation:** Creates SQS queues for each name provided in the `queue_names` list.

2.  **Dead-Letter Queue Creation:** For each created queue, it creates a corresponding dead-letter queue (DLQ) with the same name suffixed by `-dlq`.

3.  **DLQ Attachment:** Attaches each DLQ to its corresponding main queue using the `redrive_policy` attribute.

4.  **IAM Policy - Consume:** Creates an IAM policy (`consume_policy`) that allows `sqs:ReceiveMessage` and `sqs:DeleteMessage` actions on *all* created queues (including DLQs).

5.  **IAM Policy - Send:** Creates an IAM policy (`write_policy`) that allows `sqs:SendMessage` actions on the *main* (non-dead-letter) queues.

## Module Output

*   `queue_arns`: A list of ARNs for all created queues (main and DLQ).
*   `consume_policy_arn`: The ARN of the IAM policy allowing `sqs:ReceiveMessage` and `sqs:DeleteMessage`.
*   `write_policy_arn`: The ARN of the IAM policy allowing `sqs:SendMessage`.
*   `consume_role_arn` (Extra Credit): The ARN of the IAM role associated with the consume policy (if `create_roles` is true).
*   `write_role_arn` (Extra Credit): The ARN of the IAM role associated with the write policy (if `create_roles` is true).

## Usage

```terraform
module "sqs_module" {
  source = "path/to/your/module"  # Replace with the path to your module

  queue_names = ["priority-10", "priority-100", "important-queue"] #Example

  # Optional variables with defaults
  # ... (other variables can be set here)

}

output "queue_arns" {
 value = module.sqs_module.queue_arns
}

output "consume_policy_arn" {
 value = module.sqs_module.consume_policy_arn
}

output "write_policy_arn" {
 value = module.sqs_module.write_policy_arn
}

output "consume_role_arn" {
 value = module.sqs_module.consume_role_arn
}

output "write_role_arn" {
 value = module.sqs_module.write_role_arn
}
```

## Example

Given `queue_names = ["priority-10", "priority-100"]`, the module will create:

*   `priority-10`
*   `priority-10-dlq`
*   `priority-100`
*   `priority-100-dlq`

And the `consume_policy` will grant receive and delete permissions on all four queues, while the `write_policy` will grant send permissions only on `priority-10` and `priority-100`.

## Terraform Version

This module is compatible with Terraform 1.0.0 and later.

## AWS Provider Version

This module requires the AWS provider version 3.48.0 or later.

## Extra Credit: IAM Roles

The module includes a boolean variable `create_roles` (default: `false`).  If set to `true`, the module will also create two IAM roles:

*   `consume_role`: Associated with the `consume_policy`.
*   `write_role`: Associated with the `write_policy`.

These roles will be configured to allow anyone in the current AWS account to assume them.  The ARNs of these roles will be available in the module outputs `consume_role_arn` and `write_role_arn`.

To enable role creation:

```terraform
module "sqs_module" {
  # ... other inputs

  create_roles = true
}
```

**Important:** Setting `create_roles = true` will create roles that can be assumed by *anyone* in your AWS account.  In a production environment, you should **restrict** the `assume_role_policy` to only the specific entities (users, roles, services) that should be allowed to assume these roles.  You can do this by modifying the `assume_role_policy` within the module's Terraform configuration.

## Author

Akash Mittal

## License

Apache 2.0

```
