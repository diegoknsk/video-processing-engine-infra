# IAM roles e políticas por Lambda (least privilege). Uma role por função; políticas granulares (sem s3:*, dynamodb:*).

locals {
  log_group_arn_auth             = "arn:aws:logs:${local.region}:${local.account_id}:log-group:/aws/lambda/${var.prefix}-auth:*"
  log_group_arn_video_management = "arn:aws:logs:${local.region}:${local.account_id}:log-group:/aws/lambda/${var.prefix}-video-management:*"
  log_group_arn_orchestrator     = "arn:aws:logs:${local.region}:${local.account_id}:log-group:/aws/lambda/${var.prefix}-video-orchestrator:*"
  log_group_arn_processor        = "arn:aws:logs:${local.region}:${local.account_id}:log-group:/aws/lambda/${var.prefix}-video-processor:*"
  log_group_arn_finalizer        = "arn:aws:logs:${local.region}:${local.account_id}:log-group:/aws/lambda/${var.prefix}-video-finalizer:*"
}

# --- Lambda Auth: apenas CloudWatch Logs ---
resource "aws_iam_role" "lambda_auth" {
  name = "${var.prefix}-lambda-auth-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
  tags = var.common_tags
}

resource "aws_iam_role_policy" "lambda_auth_logs" {
  name = "cloudwatch-logs"
  role = aws_iam_role.lambda_auth.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Resource = [local.log_group_arn_auth]
    }]
  })
}

# --- Lambda Video Management: Logs, S3 videos, DynamoDB, SQS status-update, SNS topic-video-submitted ---
resource "aws_iam_role" "lambda_video_management" {
  name = "${var.prefix}-lambda-video-management-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
  tags = var.common_tags
}

resource "aws_iam_role_policy" "lambda_video_management" {
  name = "least-privilege"
  role = aws_iam_role.lambda_video_management.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = [local.log_group_arn_video_management]
      },
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject", "s3:GetObject"]
        Resource = ["${var.videos_bucket_arn}", "${var.videos_bucket_arn}/*"]
      },
      {
        Effect   = "Allow"
        Action   = ["dynamodb:PutItem", "dynamodb:GetItem", "dynamodb:UpdateItem"]
        Resource = [var.table_arn]
      },
      {
        Effect   = "Allow"
        Action   = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
        Resource = [var.q_video_status_update_arn]
      },
      {
        Effect   = "Allow"
        Action   = ["sns:Publish"]
        Resource = [var.topic_video_submitted_arn]
      }
    ]
  })
}

# --- Lambda Video Orchestrator: Logs, SQS q-video-process, Step Functions StartExecution ---
resource "aws_iam_role" "lambda_video_orchestrator" {
  name = "${var.prefix}-lambda-video-orchestrator-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
  tags = var.common_tags
}

resource "aws_iam_role_policy" "lambda_video_orchestrator" {
  name = "least-privilege"
  role = aws_iam_role.lambda_video_orchestrator.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = [local.log_group_arn_orchestrator]
      },
      {
        Effect   = "Allow"
        Action   = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
        Resource = [var.q_video_process_arn]
      },
      {
        Effect   = "Allow"
        Action   = ["states:StartExecution"]
        Resource = [var.step_function_arn != "" ? var.step_function_arn : "arn:aws:states:${local.region}:${local.account_id}:stateMachine:${var.prefix}-*"]
      }
    ]
  })
}

# --- Lambda Video Processor: Logs, S3 videos/images, DynamoDB, SQS SendMessage status-update e zip-finalize ---
resource "aws_iam_role" "lambda_video_processor" {
  name = "${var.prefix}-lambda-video-processor-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
  tags = var.common_tags
}

resource "aws_iam_role_policy" "lambda_video_processor" {
  name = "least-privilege"
  role = aws_iam_role.lambda_video_processor.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = [local.log_group_arn_processor]
      },
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = ["${var.videos_bucket_arn}/*"]
      },
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject"]
        Resource = ["${var.images_bucket_arn}/*"]
      },
      {
        Effect   = "Allow"
        Action   = ["dynamodb:UpdateItem"]
        Resource = [var.table_arn]
      },
      {
        Effect   = "Allow"
        Action   = ["sqs:SendMessage"]
        Resource = [var.q_video_status_update_arn, var.q_video_zip_finalize_arn]
      }
    ]
  })
}

# --- Lambda Video Finalizer: Logs, S3 images/zip, DynamoDB, SQS q-video-zip-finalize, SNS topic-video-completed ---
resource "aws_iam_role" "lambda_video_finalizer" {
  name = "${var.prefix}-lambda-video-finalizer-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
  tags = var.common_tags
}

resource "aws_iam_role_policy" "lambda_video_finalizer" {
  name = "least-privilege"
  role = aws_iam_role.lambda_video_finalizer.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = [local.log_group_arn_finalizer]
      },
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = ["${var.images_bucket_arn}/*"]
      },
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject"]
        Resource = ["${var.zip_bucket_arn}", "${var.zip_bucket_arn}/*"]
      },
      {
        Effect   = "Allow"
        Action   = ["dynamodb:UpdateItem"]
        Resource = [var.table_arn]
      },
      {
        Effect   = "Allow"
        Action   = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
        Resource = [var.q_video_zip_finalize_arn]
      },
      {
        Effect   = "Allow"
        Action   = ["sns:Publish"]
        Resource = [var.topic_video_completed_arn]
      }
    ]
  })
}
