# Outputs de convenção para consumo pelos demais módulos (10-storage, 20-data, 30-messaging, etc.).

output "account_id" {
  description = "ID da conta AWS."
  value       = data.aws_caller_identity.current.account_id
}

output "region" {
  description = "Região AWS."
  value       = var.region
}

output "prefix" {
  description = "Prefixo de naming: video-processing-engine-{environment}."
  value       = local.naming_prefix
}

output "common_tags" {
  description = "Tags padrão (Project, Environment, ManagedBy, Owner) para aplicar nos recursos."
  value       = local.common_tags
}
