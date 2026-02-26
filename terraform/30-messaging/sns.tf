# Módulo 30-messaging — Parte SNS (Storie-05; Storie-18.1: topic-video-submitted removido).
# Tópico: topic-video-completed.
# Subscriptions: email (ativo agora) e Lambda (preparado para depois) no topic-video-completed.

# --- Tópicos SNS ---
resource "aws_sns_topic" "topic_video_completed" {
  name = "${var.prefix}-topic-video-completed"
  tags = var.common_tags
}

# --- Subscriptions no topic-video-completed (nenhuma no topic-video-submitted; SQS em outra story) ---
# Ativo agora: email para notificação
resource "aws_sns_topic_subscription" "completed_email" {
  count     = var.enable_email_subscription_completed && var.email_endpoint != null && var.email_endpoint != "" ? 1 : 0
  topic_arn = aws_sns_topic.topic_video_completed.arn
  protocol  = "email"
  endpoint  = var.email_endpoint
}

# Preparado para depois: Lambda placeholder
resource "aws_sns_topic_subscription" "completed_lambda" {
  count     = var.enable_lambda_subscription_completed && var.lambda_subscription_arn != null && var.lambda_subscription_arn != "" ? 1 : 0
  topic_arn = aws_sns_topic.topic_video_completed.arn
  protocol  = "lambda"
  endpoint  = var.lambda_subscription_arn
}
