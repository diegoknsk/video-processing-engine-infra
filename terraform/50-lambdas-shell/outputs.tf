# Outputs: nomes, ARNs das Lambdas e ARNs das roles para consumo por API Gateway, pipelines, etc.

output "lambda_auth_name" {
  description = "Nome da Lambda Auth."
  value       = aws_lambda_function.auth.function_name
}

output "lambda_auth_arn" {
  description = "ARN da Lambda Auth."
  value       = aws_lambda_function.auth.arn
}

output "lambda_auth_role_arn" {
  description = "ARN da role IAM da Lambda Auth (Lab Role quando em AWS Academy)."
  value       = var.lab_role_arn
}

output "lambda_video_management_name" {
  description = "Nome da Lambda Video Management."
  value       = aws_lambda_function.video_management.function_name
}

output "lambda_video_management_arn" {
  description = "ARN da Lambda Video Management."
  value       = aws_lambda_function.video_management.arn
}

output "lambda_video_management_role_arn" {
  description = "ARN da role IAM da Lambda Video Management (Lab Role quando em AWS Academy)."
  value       = var.lab_role_arn
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
  description = "ARN da role IAM da Lambda Video Orchestrator (Lab Role quando em AWS Academy)."
  value       = var.lab_role_arn
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
  description = "ARN da role IAM da Lambda Video Processor (Lab Role quando em AWS Academy)."
  value       = var.lab_role_arn
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
  description = "ARN da role IAM da Lambda Video Finalizer (Lab Role quando em AWS Academy)."
  value       = var.lab_role_arn
}
