# IAM role para execução da State Machine Step Functions.
# Criada quando var.lab_role_arn é null (conta AWS regular com iam:CreateRole).
# Em AWS Academy: definir lab_role_arn para usar a LabRole existente e esta role não é criada.

locals {
  use_lab_role_sfn = var.lab_role_arn != null && var.lab_role_arn != ""
  sfn_role_arn = local.use_lab_role_sfn ? var.lab_role_arn : (
    var.enable_stepfunctions ? aws_iam_role.sfn_exec[0].arn : null
  )
}

resource "aws_iam_role" "sfn_exec" {
  count = !local.use_lab_role_sfn && var.enable_stepfunctions ? 1 : 0

  name = "${var.prefix}-sfn-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "states.amazonaws.com" }
    }]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy" "sfn_exec" {
  count = !local.use_lab_role_sfn && var.enable_stepfunctions ? 1 : 0

  name = "${var.prefix}-sfn-exec-policy"
  role = aws_iam_role.sfn_exec[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "LambdaInvoke"
        Effect = "Allow"
        Action = ["lambda:InvokeFunction"]
        Resource = [
          var.lambda_processor_arn,
          var.lambda_finalizer_arn,
          var.lambda_update_status_arn,
        ]
      },
      {
        Sid      = "SQSSend"
        Effect   = "Allow"
        Action   = ["sqs:SendMessage"]
        Resource = ["*"]
      },
      {
        Sid      = "SNSPublishError"
        Effect   = "Allow"
        Action   = ["sns:Publish"]
        Resource = [var.topic_video_processing_error_arn]
      },
      {
        Sid    = "CloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogDelivery", "logs:GetLogDelivery", "logs:UpdateLogDelivery",
          "logs:DeleteLogDelivery", "logs:ListLogDeliveries",
          "logs:PutLogEvents", "logs:PutResourcePolicy",
          "logs:DescribeResourcePolicies", "logs:DescribeLogGroups"
        ]
        Resource = ["*"]
      },
    ]
  })
}
