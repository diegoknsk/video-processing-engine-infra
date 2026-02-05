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

# --- Data (DynamoDB vídeos) ---
output "dynamodb_table_name" {
  description = "Nome da tabela DynamoDB de vídeos."
  value       = module.data.table_name
}

output "dynamodb_table_arn" {
  description = "ARN da tabela DynamoDB de vídeos."
  value       = module.data.table_arn
}

output "dynamodb_gsi1_name" {
  description = "Nome do GSI1 (consulta por VideoId)."
  value       = module.data.gsi1_name
}

# --- Orchestration (Step Functions — Storie-09) ---
output "step_machine_arn" {
  description = "ARN da State Machine Step Functions (video processing). Usar em step_function_arn (tfvars) para a Lambda Orchestrator invocar StartExecution."
  value       = module.orchestration.state_machine_arn
}

output "step_machine_log_group_name" {
  description = "Nome do log group CloudWatch da Step Functions."
  value       = module.orchestration.log_group_name
}

# --- API Gateway HTTP API (Storie-10) ---
output "api_invoke_url" {
  description = "URL de invocação da API Gateway (stage). Ex.: https://{api_id}.execute-api.{region}.amazonaws.com/dev"
  value       = module.api.api_invoke_url
}

output "api_id" {
  description = "ID da API Gateway HTTP API."
  value       = module.api.api_id
}
