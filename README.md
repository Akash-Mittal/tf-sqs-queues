# tf-sqs-queues
Terraform module that is used to create some AWS SQS queues and the IAM policies used to consume from and write to them.


# Terraform AWS SQS Queues Module

## Overview

This Terraform module **sqs_queues** creates **AWS SQS queues** with **Dead Letter Queues (DLQs)** and the necessary **IAM policies** to consume and write to the queues.  

## Features  

- Creates **SQS Queues** based on the provided queue names.  
- Attaches **Dead Letter Queues (DLQs)** for each queue.  
- Generates **IAM policies** for consuming and writing messages.  
- (Optional) Creates **IAM roles** to assume the policies.  

## Compatibility  

- **Terraform Version:** 1.0.0+  
- **AWS Provider Version:** 3.48.0+  

---

## Usage  

### Basic Example  

```hcl
module "sqs" {
  source      = "./sqs_queues"
  queue_names = ["priority-10", "priority-100"]
}
