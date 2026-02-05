# Log group dedicado para Step Functions; retenção configurável para controle de custo e compliance.

resource "aws_cloudwatch_log_group" "sfn" {
  count = var.enable_stepfunctions ? 1 : 0

  name              = "/aws/stepfunctions/${var.prefix}-video-processing"
  retention_in_days = var.log_retention_days
  tags              = var.common_tags
}
