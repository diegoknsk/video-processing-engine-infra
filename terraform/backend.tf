# Backend S3 único do root (state de todos os módulos).
# State locking com DynamoDB recomendado para equipe e CI/CD (opcional).
#
# Override via -backend-config=backend.hcl ou -backend-config key=value se necessário.
# Execução local sem backend remoto: terraform init -backend=false
terraform {
  backend "s3" {
    bucket  = "godz-hackaton-bucket"
    key     = "terraform/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
    # dynamodb_table = "terraform-state-lock"  # descomente para state locking
  }
}
