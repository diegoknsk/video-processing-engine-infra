# Versão e provider AWS (convenção alinhada ao 00-foundation e 10-storage).
# O provider é herdado do root; required_providers declara a dependência.
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
