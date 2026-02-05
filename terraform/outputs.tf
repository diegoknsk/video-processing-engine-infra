# Outputs do root — reexportados para CI/CD, pipelines e outros repositórios.
# Consumidores: workflows GitHub Actions, documentação, módulos futuros.

# --- Foundation ---
output "prefix" {
  description = "Prefixo de naming (video-processing-engine-{environment})."
  value       = module.foundation.prefix
}

output "common_tags" {
  description = "Tags padrão para recursos (Project, Environment, ManagedBy, Owner)."
  value       = module.foundation.common_tags
}

output "account_id" {
  description = "ID da conta AWS."
  value       = module.foundation.account_id
}

output "region" {
  description = "Região AWS."
  value       = module.foundation.region
}

# --- Storage (buckets S3) ---
output "videos_bucket_name" {
  description = "Nome do bucket S3 de vídeos (upload)."
  value       = module.storage.videos_bucket_name
}

output "videos_bucket_arn" {
  description = "ARN do bucket S3 de vídeos."
  value       = module.storage.videos_bucket_arn
}

output "images_bucket_name" {
  description = "Nome do bucket S3 de imagens (frames)."
  value       = module.storage.images_bucket_name
}

output "images_bucket_arn" {
  description = "ARN do bucket S3 de imagens."
  value       = module.storage.images_bucket_arn
}

output "zip_bucket_name" {
  description = "Nome do bucket S3 de zip (resultado final)."
  value       = module.storage.zip_bucket_name
}

output "zip_bucket_arn" {
  description = "ARN do bucket S3 de zip."
  value       = module.storage.zip_bucket_arn
}
