# Módulo 30-messaging — Parte SNS.
# Tópico: topic-video-processing-error (notificação de erros de processamento).
# Subscriptions: email (feature flag) no topic-video-processing-error.

# --- Tópico SNS de erro ---
resource "aws_sns_topic" "topic_video_processing_error" {
  name = "${var.prefix}-topic-video-processing-error"
  tags = var.common_tags
}

# --- Subscription email no topic-video-processing-error ---
resource "aws_sns_topic_subscription" "error_email" {
  count     = var.enable_email_subscription_error && var.email_endpoint_error != null && var.email_endpoint_error != "" ? 1 : 0
  topic_arn = aws_sns_topic.topic_video_processing_error.arn
  protocol  = "email"
  endpoint  = var.email_endpoint_error
}
