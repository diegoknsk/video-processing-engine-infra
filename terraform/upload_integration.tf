# Integração upload concluído (Storie-07; Storie-18: S3 direto para SQS).
# Fluxo atual (Storie-18): S3 bucket videos notifica diretamente a fila q-video-process (prefix "videos/", suffix "original");
# queue policy e bucket notification definidos abaixo. Recursos SNS do fluxo anterior foram removidos.

# --- SQS queue policy: permite que o bucket S3 videos publique na fila q-video-process ---
resource "aws_sqs_queue_policy" "q_video_process_allow_s3" {
  queue_url = module.messaging.q_video_process_url

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowS3Publish"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action   = "sqs:SendMessage"
        Resource = module.messaging.q_video_process_arn
        Condition = {
          ArnLike = {
            "aws:SourceArn" = module.storage.videos_bucket_arn
          }
        }
      }
    ]
  })
}

# --- S3 bucket notification: bucket videos → SQS q-video-process (direto) ---
resource "aws_s3_bucket_notification" "videos_to_sqs" {
  depends_on = [aws_sqs_queue_policy.q_video_process_allow_s3]

  bucket = module.storage.videos_bucket_name

  queue {
    queue_arn     = module.messaging.q_video_process_arn
    events        = ["s3:ObjectCreated:Put", "s3:ObjectCreated:CompleteMultipartUpload"]
    filter_prefix = "videos/"
    filter_suffix = "original"
  }
}
