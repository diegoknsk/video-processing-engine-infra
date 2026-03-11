# Lambdas em casca: Auth, VideoManagement, VideoOrchestrator, VideoProcessor, VideoFinalizer, UpdateStatusVideo (Storie-18.1).
# Runtime e handler parametrizáveis; artefato empty.zip; variáveis de ambiente por função.
# SnapStart (var.snap_start_enabled) aplica-se apenas a auth, video_management, video_orchestrator, update_status_video. video_processor e video_finalizer nunca usam SnapStart (processamento pesado: vídeos/zip).

resource "aws_lambda_function" "auth" {
  function_name = "${var.prefix}-auth"
  role          = local.lambda_role_arn
  runtime       = var.runtime
  handler       = var.auth_handler
  filename      = var.artifact_path
  memory_size   = 512
  timeout       = 900
  publish       = true

  ephemeral_storage {
    size = 512
  }

  dynamic "snap_start" {
    for_each = var.snap_start_enabled ? [1] : []
    content {
      apply_on = "PublishedVersions"
    }
  }

  dynamic "timeouts" {
    for_each = var.snap_start_enabled ? [1] : []
    content {
      update = "25m"
    }
  }

  environment {
    variables = {
      LOG_LEVEL = "INFO"
    }
  }

  tags = var.common_tags

  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }
}

resource "aws_lambda_function" "video_management" {
  function_name = "${var.prefix}-video-management"
  role          = local.lambda_role_arn
  runtime       = var.runtime
  handler       = var.handler
  filename      = var.artifact_path
  memory_size   = 512
  timeout       = 900
  publish       = true

  ephemeral_storage {
    size = 512
  }

  dynamic "snap_start" {
    for_each = var.snap_start_enabled ? [1] : []
    content {
      apply_on = "PublishedVersions"
    }
  }

  dynamic "timeouts" {
    for_each = var.snap_start_enabled ? [1] : []
    content {
      update = "25m"
    }
  }

  environment {
    variables = {
      TABLE_NAME              = var.table_name
      VIDEOS_BUCKET           = var.videos_bucket_name
      QUEUE_STATUS_UPDATE_URL = var.q_video_status_update_url
    }
  }

  tags = var.common_tags

  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }
}

resource "aws_lambda_function" "video_orchestrator" {
  function_name = "${var.prefix}-video-orchestrator"
  role          = local.lambda_role_arn
  runtime       = var.runtime
  handler       = var.handler
  filename      = var.artifact_path
  memory_size   = 512
  timeout       = 900
  publish       = true

  ephemeral_storage {
    size = 512
  }

  dynamic "snap_start" {
    for_each = var.snap_start_enabled ? [1] : []
    content {
      apply_on = "PublishedVersions"
    }
  }

  dynamic "timeouts" {
    for_each = var.snap_start_enabled ? [1] : []
    content {
      update = "25m"
    }
  }

  environment {
    variables = {
      QUEUE_VIDEO_PROCESS_URL = var.q_video_process_url
      STEP_FUNCTION_ARN       = var.step_function_arn
    }
  }

  tags = var.common_tags

  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }
}

# Video Processor: sem SnapStart (configuração de teste para vídeos grandes; SnapStart não se aplica aqui).
resource "aws_lambda_function" "video_processor" {
  function_name = "${var.prefix}-video-processor"
  role          = local.lambda_role_arn
  runtime       = var.runtime
  handler       = var.handler
  filename      = var.artifact_path
  memory_size   = 3008
  timeout       = 900
  publish       = true

  ephemeral_storage {
    size = 8192
  }

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

  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }
}

# Video Finalizer: sem SnapStart; mesma configuração robusta do Processor (monta zip com todas as imagens, processo pesado).
resource "aws_lambda_function" "video_finalizer" {
  function_name = "${var.prefix}-video-finalizer"
  role          = local.lambda_role_arn
  runtime       = var.runtime
  handler       = var.handler
  filename      = var.artifact_path
  memory_size   = 3008
  timeout       = 900
  publish       = true

  ephemeral_storage {
    size = 8192
  }

  environment {
    variables = {
      TABLE_NAME                = var.table_name
      IMAGES_BUCKET             = var.images_bucket_name
      ZIP_BUCKET                = var.zip_bucket_name
      TOPIC_VIDEO_COMPLETED_ARN = var.topic_video_completed_arn
    }
  }

  tags = var.common_tags

  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }
}

resource "aws_lambda_function" "update_status_video" {
  function_name = "${var.prefix}-update-status-video"
  role          = local.lambda_role_arn
  runtime       = var.runtime
  handler       = var.handler
  filename      = var.artifact_path
  memory_size   = 512
  timeout       = 900
  publish       = true

  ephemeral_storage {
    size = 512
  }

  dynamic "snap_start" {
    for_each = var.snap_start_enabled ? [1] : []
    content {
      apply_on = "PublishedVersions"
    }
  }

  dynamic "timeouts" {
    for_each = var.snap_start_enabled ? [1] : []
    content {
      update = "25m"
    }
  }

  environment {
    variables = {
      TABLE_NAME              = var.table_name
      QUEUE_STATUS_UPDATE_URL = var.q_video_status_update_url
    }
  }

  tags = var.common_tags

  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }
}
