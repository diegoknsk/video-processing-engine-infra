# State Machine Step Functions (Storie-09; Storie-23: Map State).
# Definição: Map (fan-out chunks via Lambda video-processor) → PrepareUpdateMessage → Update Status (SQS q-video-status-update) → Success.

locals {
  sfn_definition = jsonencode({
    Comment = "Video processing: Map state (chunks) → Update Status (SQS) → Success."
    StartAt = "Map"
    States = {
      Map = {
        Type      = "Map"
        ItemsPath = "$.chunks"
        ItemSelector = {
          "contractVersion.$" = "$.contractVersion"
          "videoId.$"         = "$.videoId"
          "userId.$"          = "$.userId"
          "s3BucketVideo.$"   = "$.s3BucketVideo"
          "s3KeyVideo.$"      = "$.s3KeyVideo"
          "output.$"          = "$.output"
          "chunk.$"           = "$$.Map.Item.Value"
        }
        ItemProcessor = {
          ProcessorConfig = {
            Mode = "INLINE"
          }
          StartAt = "Processor Video"
          States = {
            "Processor Video" = {
              Type       = "Task"
              Resource   = "arn:aws:states:::lambda:invoke"
              OutputPath = "$.Payload"
              Parameters = {
                FunctionName = "${var.lambda_processor_arn}:$LATEST"
              }
              Retry = [
                {
                  ErrorEquals     = ["Lambda.ServiceException", "Lambda.AWSLambdaException", "Lambda.SdkClientException", "Lambda.TooManyRequestsException"]
                  IntervalSeconds = 1
                  MaxAttempts     = 3
                  BackoffRate     = 2
                  JitterStrategy  = "FULL"
                }
              ]
              End = true
            }
          }
        }
        ResultPath = "$.chunkResults"
        Next       = "PrepareUpdateMessage"
      }

      PrepareUpdateMessage = {
        Type = "Pass"
        Parameters = {
          messageBody = {
            "videoId.$"        = "$.videoId"
            "userId.$"         = "$.userId"
            "status"           = 2
            "progressPercent"  = 100
            "s3BucketFrames.$" = "$.output.framesBucket"
            "framesPrefix.$"   = "$.output.framesBasePrefix"
          }
        }
        Next = "Update Status"
      }

      "Update Status" = {
        Type     = "Task"
        Resource = "arn:aws:states:::sqs:sendMessage"
        Parameters = {
          QueueUrl        = var.q_video_status_update_url
          "MessageBody.$" = "States.JsonToString($.messageBody)"
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
