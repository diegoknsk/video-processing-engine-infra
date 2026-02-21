    
erraform fmt -recursive
terraform validate
terraform plan -var-file envs\dev.tfvars