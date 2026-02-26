# Lambdas em casca: Auth, VideoManagement, VideoOrchestrator, VideoProcessor, VideoFinalizer, UpdateStatusVideo (Storie-18.1).
# Runtime e handler parametrizáveis; artefato empty.zip; variáveis de ambiente por função.

resource "aws_lambda_function" "auth" {
  function_name = "${var.prefix}-auth"
  role          = var.lab_role_arn
  runtime       = var.runtime
  handler       = var.auth_handler
  filename      = var.artifact_path
  timeout       = 900

  environment {
    variables = {
      LOG_LEVEL = "INFO"
    }
  }

  tags = var.common_tags
}

resource "aws_lambda_function" "video_management" {
  function_name = "${var.prefix}-video-management"
  role          = var.lab_role_arn
  runtime       = var.runtime
  handler       = var.handler
  filename      = var.artifact_path
  timeout       = 900

  environment {
    variables = {
      TABLE_NAME              = var.table_name
      VIDEOS_BUCKET           = var.videos_bucket_name
      QUEUE_STATUS_UPDATE_URL = var.q_video_status_update_url
    }
  }

  tags = var.common_tags
}

resource "aws_lambda_function" "video_orchestrator" {
  function_name = "${var.prefix}-video-orchestrator"
  role          = var.lab_role_arn
  runtime       = var.runtime
  handler       = var.handler
  filename      = var.artifact_path
  timeout       = 900

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
  role          = var.lab_role_arn
  runtime       = var.runtime
  handler       = var.handler
  filename      = var.artifact_path
  timeout       = 900

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
  role          = var.lab_role_arn
  runtime       = var.runtime
  handler       = var.handler
  filename      = var.artifact_path
  timeout       = 900

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

resource "aws_lambda_function" "update_status_video" {
  function_name = "${var.prefix}-update-status-video"
  role          = var.lab_role_arn
  runtime       = var.runtime
  handler       = var.handler
  filename      = var.artifact_path
  timeout       = 900

  environment {
    variables = {
      TABLE_NAME              = var.table_name
      QUEUE_STATUS_UPDATE_URL = var.q_video_status_update_url
    }
  }

  tags = var.common_tags
}
