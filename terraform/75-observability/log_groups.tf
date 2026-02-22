# Log groups para observabilidade base; retenção configurável; apenas CloudWatch (sem ferramentas pagas).
# Nomes alinhados às funções do 50-lambdas-shell: /aws/lambda/{function_name}.
# Aplicar este módulo antes ou junto do 50-lambdas-shell para que os log groups existam antes das Lambdas.

resource "aws_cloudwatch_log_group" "lambda_auth" {
  name              = "/aws/lambda/${var.prefix}-auth"
  retention_in_days = var.log_retention_days
  tags              = var.common_tags
}

resource "aws_cloudwatch_log_group" "lambda_video_management" {
  name              = "/aws/lambda/${var.prefix}-video-management"
  retention_in_days = var.log_retention_days
  tags              = var.common_tags
}

resource "aws_cloudwatch_log_group" "lambda_video_orchestrator" {
  name              = "/aws/lambda/${var.prefix}-video-orchestrator"
  retention_in_days = var.log_retention_days
  tags              = var.common_tags
}

resource "aws_cloudwatch_log_group" "lambda_video_processor" {
  name              = "/aws/lambda/${var.prefix}-video-processor"
  retention_in_days = var.log_retention_days
  tags              = var.common_tags
}

resource "aws_cloudwatch_log_group" "lambda_video_finalizer" {
  name              = "/aws/lambda/${var.prefix}-video-finalizer"
  retention_in_days = var.log_retention_days
  tags              = var.common_tags
}

resource "aws_cloudwatch_log_group" "lambda_video_dispatcher" {
  name              = "/aws/lambda/${var.prefix}-video-dispatcher"
  retention_in_days = var.log_retention_days
  tags              = var.common_tags
}
