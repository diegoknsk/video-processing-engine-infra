# Outputs para consumo por outros módulos (Lambdas, API).

output "table_name" {
  description = "Nome da tabela DynamoDB de vídeos."
  value       = aws_dynamodb_table.videos.name
}

output "table_arn" {
  description = "ARN da tabela DynamoDB de vídeos."
  value       = aws_dynamodb_table.videos.arn
}

output "gsi1_name" {
  description = "Nome do GSI1 (consulta por VideoId)."
  value       = "GSI1"
}

output "gsi_names" {
  description = "Lista dos nomes dos GSIs da tabela."
  value       = [for gsi in aws_dynamodb_table.videos.global_secondary_index : gsi.name]
}
