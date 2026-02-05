# Backend S3 (opcional). Infrarules: backend sempre S3, state locking com DynamoDB.
#
# Configuração parcial: bucket, key, region, dynamodb_table e encrypt devem ser
# fornecidos via -backend-config=backend.hcl ou -backend-config key=value.
# Exemplo backend.hcl:
#   bucket         = "meu-bucket-state"
#   key            = "video-processing-engine/terraform.tfstate"
#   region         = "us-east-1"
#   dynamodb_table = "terraform-state-lock"
#   encrypt        = true
#
# Execução local sem backend remoto: terraform init -backend=false
# CI/CD: configurar backend com bucket e tabela DynamoDB existentes.
terraform {
  backend "s3" {
    # Partial: configure via -backend-config=backend.hcl
  }
}
