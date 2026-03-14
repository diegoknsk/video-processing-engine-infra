# State Machine Step Functions (Storie-09; Storie-23: Map State; Storie-26: definição estática).
# Definição carregada diretamente de video-processing.asl.json (sem templatefile — ARNs fixos no JSON).

resource "aws_sfn_state_machine" "video_processing" {
  count = var.enable_stepfunctions ? 1 : 0

  name       = "${var.prefix}-video-processing"
  role_arn   = local.sfn_role_arn
  definition = file("${path.module}/video-processing.asl.json")

  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.sfn[0].arn}:*"
    include_execution_data = true
    level                  = "ALL"
  }

  tags = var.common_tags
}
