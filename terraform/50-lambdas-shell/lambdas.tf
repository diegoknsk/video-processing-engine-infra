# Cinco Lambdas em casca: Auth, VideoManagement, VideoOrchestrator, VideoProcessor, VideoFinalizer.
# Runtime e handler parametrizáveis; artefato empty.zip; variáveis de ambiente por função.

resource "aws_lambda_function" "auth" {
  function_name = "${var.prefix}-auth"
  role          = aws_iam_role.lambda_auth.arn
  runtime       = var.runtime
  handler       = var.handler
  filename      = var.artifact_path

  environment {
    variables = {
      LOG_LEVEL = "INFO"
    }
  }

  tags = var.common_tags
}

resource "aws_lambda_function" "video_management" {
  function_name = "${var.prefix}-video-management"
  role          = aws_iam_role.lambda_video_management.arn
  runtime       = var.runtime
  handler       = var.handler
  filename      = var.artifact_path

  environment {
    variables = {
      TABLE_NAME                = var.table_name
      VIDEOS_BUCKET             = var.videos_bucket_name
      TOPIC_VIDEO_SUBMITTED_ARN = var.topic_video_submitted_arn
      QUEUE_STATUS_UPDATE_URL   = var.q_video_status_update_url
    }
  }

  tags = var.common_tags
}

resource "aws_lambda_function" "video_orchestrator" {
  function_name = "${var.prefix}-video-orchestrator"
  role          = aws_iam_role.lambda_video_orchestrator.arn
  runtime       = var.runtime
  handler       = var.handler
  filename      = var.artifact_path

  environment {
    variables = {
      QUEUE_VIDEO_PROCESS_URL = var.q_video_process_url
      STEP_FUNCTION_ARN       = var.step_function_arn
    }
  }

  tags = var.common_tags
}

resource "aws_lambda_function" "video_processor" {
  function_name = "${var.prefix}-video-processor"
  role          = aws_iam_role.lambda_video_processor.arn
  runtime       = var.runtime
  handler       = var.handler
  filename      = var.artifact_path

  environment {
    variables = {
      TABLE_NAME              = var.table_name
      VIDEOS_BUCKET           = var.videos_bucket_name
      IMAGES_BUCKET           = var.images_bucket_name
      QUEUE_STATUS_UPDATE_URL = var.q_video_status_update_url
      QUEUE_ZIP_FINALIZE_URL  = var.q_video_zip_finalize_url
    }
  }

  tags = var.common_tags
}

resource "aws_lambda_function" "video_finalizer" {
  function_name = "${var.prefix}-video-finalizer"
  role          = aws_iam_role.lambda_video_finalizer.arn
  runtime       = var.runtime
  handler       = var.handler
  filename      = var.artifact_path

  environment {
    variables = {
      TABLE_NAME                = var.table_name
      IMAGES_BUCKET             = var.images_bucket_name
      ZIP_BUCKET                = var.zip_bucket_name
      TOPIC_VIDEO_COMPLETED_ARN = var.topic_video_completed_arn
    }
  }

  tags = var.common_tags
}
