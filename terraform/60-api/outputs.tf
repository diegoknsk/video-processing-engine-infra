# Outputs do módulo 60-api para consumo pelo root (pipelines, frontend, documentação).

output "api_id" {
  description = "ID da API Gateway HTTP API."
  value       = aws_apigatewayv2_api.main.id
}

output "api_invoke_url" {
  description = "URL de invocação da API (stage). Ex.: https://{api_id}.execute-api.{region}.amazonaws.com/{stage_name}"
  value       = aws_apigatewayv2_stage.dev.invoke_url
}

output "api_execution_arn" {
  description = "ARN de execução da API (útil para permissores e integrações)."
  value       = aws_apigatewayv2_api.main.execution_arn
}
