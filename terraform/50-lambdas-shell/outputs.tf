# Outputs: nomes, ARNs das Lambdas e ARNs das roles para consumo por API Gateway, pipelines, etc.

output "lambda_auth_name" {
  description = "Nome da Lambda Auth."
  value       = aws_lambda_function.auth.function_name
}

output "lambda_auth_arn" {
  description = "ARN da Lambda Auth."
  value       = aws_lambda_function.auth.arn
}

output "lambda_auth_qualified_arn" {
  description = "Qualified ARN da Lambda Auth (versão publicada, para SnapStart via API Gateway)."
  value       = aws_lambda_function.auth.qualified_arn
}

output "lambda_auth_role_arn" {
  description = "ARN da role IAM das Lambdas."
  value       = local.lambda_role_arn
}

output "lambda_video_management_name" {
  description = "Nome da Lambda Video Management."
  value       = aws_lambda_function.video_management.function_name
}

output "lambda_video_management_arn" {
  description = "ARN da Lambda Video Management."
  value       = aws_lambda_function.video_management.arn
}

output "lambda_video_management_qualified_arn" {
  description = "Qualified ARN da Lambda Video Management (versão publicada, para SnapStart via API Gateway)."
  value       = aws_lambda_function.video_management.qualified_arn
}

output "lambda_video_management_role_arn" {
  description = "ARN da role IAM das Lambdas."
  value       = local.lambda_role_arn
}

output "lambda_video_orchestrator_name" {
  description = "Nome da Lambda Video Orchestrator."
  value       = aws_lambda_function.video_orchestrator.function_name
}

output "lambda_video_orchestrator_arn" {
  description = "ARN da Lambda Video Orchestrator."
  value       = aws_lambda_function.video_orchestrator.arn
}

output "lambda_video_orchestrator_role_arn" {
  description = "ARN da role IAM das Lambdas."
  value       = local.lambda_role_arn
}

output "lambda_video_processor_name" {
  description = "Nome da Lambda Video Processor."
  value       = aws_lambda_function.video_processor.function_name
}

output "lambda_video_processor_arn" {
  description = "ARN da Lambda Video Processor."
  value       = aws_lambda_function.video_processor.arn
}

output "lambda_video_processor_role_arn" {
  description = "ARN da role IAM das Lambdas."
  value       = local.lambda_role_arn
}

output "lambda_video_finalizer_name" {
  description = "Nome da Lambda Video Finalizer."
  value       = aws_lambda_function.video_finalizer.function_name
}

output "lambda_video_finalizer_arn" {
  description = "ARN da Lambda Video Finalizer."
  value       = aws_lambda_function.video_finalizer.arn
}

output "lambda_video_finalizer_role_arn" {
  description = "ARN da role IAM das Lambdas."
  value       = local.lambda_role_arn
}

output "lambda_update_status_video_name" {
  description = "Nome da Lambda LambdaUpdateStatusVideo (responsável exclusiva por atualizar status)."
  value       = aws_lambda_function.update_status_video.function_name
}

output "lambda_update_status_video_arn" {
  description = "ARN da Lambda LambdaUpdateStatusVideo."
  value       = aws_lambda_function.update_status_video.arn
}
