# IAM role para execução das Lambdas.
# Criada quando var.lab_role_arn é null (conta AWS regular com iam:CreateRole).
# Em AWS Academy: definir lab_role_arn para usar a LabRole existente e esta role não é criada.

locals {
  use_lab_role_lambda = var.lab_role_arn != null && var.lab_role_arn != ""
  lambda_role_arn     = local.use_lab_role_lambda ? var.lab_role_arn : aws_iam_role.lambda_exec[0].arn
}

resource "aws_iam_role" "lambda_exec" {
  count = local.use_lab_role_lambda ? 0 : 1

  name = "${var.prefix}-lambda-exec-role"

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

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  count      = local.use_lab_role_lambda ? 0 : 1
  role       = aws_iam_role.lambda_exec[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_app" {
  count = local.use_lab_role_lambda ? 0 : 1

  name = "${var.prefix}-lambda-app-policy"
  role = aws_iam_role.lambda_exec[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3Access"
        Effect = "Allow"
        Action = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject", "s3:ListBucket"]
        Resource = [
          var.videos_bucket_arn, "${var.videos_bucket_arn}/*",
          var.images_bucket_arn, "${var.images_bucket_arn}/*",
          var.zip_bucket_arn, "${var.zip_bucket_arn}/*",
        ]
      },
      {
        Sid    = "DynamoDBAccess"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:UpdateItem",
          "dynamodb:DeleteItem", "dynamodb:Query", "dynamodb:Scan",
          "dynamodb:BatchWriteItem"
        ]
        Resource = [
          var.table_arn, "${var.table_arn}/index/*",
          var.chunks_table_arn, "${var.chunks_table_arn}/index/*"
        ]
      },
      {
        Sid    = "SQSAccess"
        Effect = "Allow"
        Action = [
          "sqs:SendMessage", "sqs:ReceiveMessage",
          "sqs:DeleteMessage", "sqs:GetQueueAttributes"
        ]
        Resource = [
          var.q_video_process_arn,
          var.q_video_status_update_arn,
          var.q_video_zip_finalize_arn,
        ]
      },
      {
        Sid      = "StepFunctions"
        Effect   = "Allow"
        Action   = ["states:StartExecution"]
        Resource = ["*"]
      },
      {
        Sid      = "CognitoAccess"
        Effect   = "Allow"
        Action   = ["cognito-idp:*"]
        Resource = ["*"]
      },
    ]
  })
}
