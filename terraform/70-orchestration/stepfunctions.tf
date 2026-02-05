# State Machine Step Functions (Storie-09).
# Definição mínima (placeholder) para criar o recurso; fluxo completo (ProcessVideo → Finalize SQS/Lambda)
# será preenchido e testado depois — ver Storie-09 e decisão JSONPath vs JSONata (Parameters vs Arguments).

locals {
  sfn_definition = jsonencode({
    Comment = "Placeholder: video processing. Definicao completa (Lambda Processor + Finalize) a preencher depois."
    StartAt = "Placeholder"
    States = {
      Placeholder = {
        Type = "Pass"
        Parameters = {
          "message" = "Placeholder - substituir pela definicao completa (ProcessVideo, FinalizeSqs/FinalizeLambda)."
        }
        Next = "Success"
      }
      Success = {
        Type = "Succeed"
      }
    }
  })
}

resource "aws_sfn_state_machine" "video_processing" {
  count = var.enable_stepfunctions ? 1 : 0

  name       = "${var.prefix}-video-processing"
  role_arn   = var.lab_role_arn
  definition = local.sfn_definition

  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.sfn[0].arn}:*"
    include_execution_data = true
    level                  = "ALL"
  }

  tags = var.common_tags
}
