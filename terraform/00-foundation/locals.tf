# Convenção de naming: prefixo video-processing-engine-{environment} para todos os recursos
# (buckets, filas, tabelas, tópicos, etc.). Garantir unicidade por ambiente.
#
# Tags padrão aplicadas a todos os recursos suportados (infrarules).
locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = var.owner
  }
  # Prefixo para nomes de recursos: video-processing-engine-{environment}
  naming_prefix = "video-processing-engine-${var.environment}"
}
