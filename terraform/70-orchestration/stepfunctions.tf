# State Machine Step Functions: ProcessVideo (Lambda) → Finalização (SQS ou Lambda) → Success.
# Estrutura preparada para evolução com Map State (Subtask-04, Storie-09).

locals {
  # Nome do próximo estado após ProcessVideo: conforme finalization_mode.
  next_after_process = var.finalization_mode == "sqs" ? "FinalizeSqs" : "FinalizeLambda"

  # Definição da state machine em JSON. ProcessVideo repassa o input à Lambda Processor;
  # Finalize envia para SQS (q-video-zip-finalize) ou invoca Lambda Finalizer.
  sfn_definition = jsonencode({
    Comment = "Video processing: Processor then finalization (SQS or Lambda). Storie-09."
    StartAt = "ProcessVideo"
    States = {
      ProcessVideo = {
        Type     = "Task"
        Resource = "arn:aws:states:::lambda:invoke"
        Arguments = {
          "FunctionName" = var.lambda_processor_arn
          "Payload" = {
            "videoId.$"    = "$.videoId"
            "userId.$"     = "$.userId"
            "s3Bucket.$"   = "$.s3Bucket"
            "s3VideoKey.$" = "$.s3VideoKey"
            "requestId.$"  = "$.requestId"
          }
        }
        ResultSelector = {
          "Payload.$" = "$.Payload"
        }
        ResultPath = "$.processorResult"
        Next       = local.next_after_process
      }

      # Modo SQS: envia mensagem para q-video-zip-finalize (Finalizer consome pela fila).
      FinalizeSqs = {
        Type     = "Task"
        Resource = "arn:aws:states:::sqs:sendMessage"
        Arguments = {
          "QueueUrl"      = var.q_video_zip_finalize_url
          "MessageBody.$" = "States.JsonToString($.processorResult.Payload)"
        }
        ResultPath = "$.finalizeResult"
        Next       = "Success"
      }

      # Modo Lambda: invoca diretamente a Lambda Video Finalizer.
      FinalizeLambda = {
        Type     = "Task"
        Resource = "arn:aws:states:::lambda:invoke"
        Arguments = {
          "FunctionName" = var.lambda_finalizer_arn
          "Payload.$"    = "$.processorResult.Payload"
        }
        ResultSelector = {
          "Payload.$" = "$.Payload"
        }
        ResultPath = "$.finalizeResult"
        Next       = "Success"
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
