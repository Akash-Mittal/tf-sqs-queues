# terraform destroy  -var="aws_region=eu-north-1" -var="aws_profile=default"

terraform fmt
terraform validate  
terraform plan -var='queue_names=["kraken-queue-1", "kraken-queue-10"]' -var="aws_region=eu-north-1" -var="aws_profile=default"
terraform apply -auto-approve -var='queue_names=["kraken-queue-1", "kraken-queue-10"]' -var="aws_region=eu-north-1" -var="aws_profile=default"
terraform output queue_arns 
