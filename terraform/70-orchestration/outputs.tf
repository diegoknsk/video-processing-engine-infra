# Outputs do módulo 70-orchestration — consumo pelo root e pelo módulo 50-lambdas-shell (step_function_arn).

output "state_machine_arn" {
  description = "ARN da State Machine Step Functions (video processing). Vazio quando enable_stepfunctions = false."
  value       = var.enable_stepfunctions ? aws_sfn_state_machine.video_processing[0].arn : ""
}

output "state_machine_name" {
  description = "Nome da State Machine (para StartExecution e referências)."
  value       = var.enable_stepfunctions ? aws_sfn_state_machine.video_processing[0].name : ""
}

output "log_group_name" {
  description = "Nome do log group CloudWatch dedicado à Step Functions (retenção configurável)."
  value       = var.enable_stepfunctions ? aws_cloudwatch_log_group.sfn[0].name : ""
}
