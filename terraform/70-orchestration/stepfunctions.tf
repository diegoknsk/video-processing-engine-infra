# State Machine Step Functions (Storie-09; Storie-23: Map State).
# Definição carregada de state-machines/video-processing.asl.json (template com lambda_processor_arn e q_video_status_update_url).

resource "aws_sfn_state_machine" "video_processing" {
  count = var.enable_stepfunctions ? 1 : 0

  name     = "${var.prefix}-video-processing"
  role_arn = local.sfn_role_arn
  definition = templatefile("${path.module}/state-machines/video-processing.asl.json", {
    lambda_processor_arn      = var.lambda_processor_arn
    q_video_status_update_url = var.q_video_status_update_url
    context_map_item_value    = "$$.Map.Item.Value"
  })

  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.sfn[0].arn}:*"
    include_execution_data = true
    level                  = "ALL"
  }

  tags = var.common_tags
}
