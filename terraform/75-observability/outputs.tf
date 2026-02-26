# Outputs dos log groups (referência para pipelines ou documentação).

output "log_group_lambda_auth" {
  description = "Nome do log group da Lambda Auth."
  value       = aws_cloudwatch_log_group.lambda_auth.name
}

output "log_group_lambda_video_management" {
  description = "Nome do log group da Lambda Video Management."
  value       = aws_cloudwatch_log_group.lambda_video_management.name
}

output "log_group_lambda_video_orchestrator" {
  description = "Nome do log group da Lambda Video Orchestrator."
  value       = aws_cloudwatch_log_group.lambda_video_orchestrator.name
}

output "log_group_lambda_video_processor" {
  description = "Nome do log group da Lambda Video Processor."
  value       = aws_cloudwatch_log_group.lambda_video_processor.name
}

output "log_group_lambda_video_finalizer" {
  description = "Nome do log group da Lambda Video Finalizer."
  value       = aws_cloudwatch_log_group.lambda_video_finalizer.name
}

output "log_group_lambda_update_status_video" {
  description = "Nome do log group da Lambda UpdateStatusVideo."
  value       = aws_cloudwatch_log_group.lambda_update_status_video.name
}
