terraform fmt
terraform validate  
terraform plan -var-file="env\dev\terraform.tfvars"
terraform apply -auto-approve  -var-file="env\dev\terraform.tfvars"
terraform output queue_arns 