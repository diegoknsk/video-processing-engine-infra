# Integração upload concluído (Storie-07) — orquestrada no root para evitar dependência circular.
# Quando trigger_mode = "s3_event": S3 videos notifica SNS topic-video-submitted ao criar objeto.
# Responsabilidades: evento do bucket (storage); policy do tópico (messaging); recursos no root.

# --- S3 bucket notification: bucket videos → SNS topic-video-submitted ---
resource "aws_s3_bucket_notification" "videos_to_sns" {
  count = var.trigger_mode == "s3_event" ? 1 : 0

  bucket = module.storage.videos_bucket_name

  topic {
    topic_arn = module.messaging.topic_video_submitted_arn
    events    = ["s3:ObjectCreated:*"]
  }
}

# --- SNS topic policy: permite que o bucket videos publique no tópico ---
resource "aws_sns_topic_policy" "topic_video_submitted_s3" {
  count = var.trigger_mode == "s3_event" ? 1 : 0

  arn = module.messaging.topic_video_submitted_arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowS3Publish"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = module.messaging.topic_video_submitted_arn
        Condition = {
          ArnLike = {
            "aws:SourceArn" = module.storage.videos_bucket_arn
          }
        }
      }
    ]
  })
}
