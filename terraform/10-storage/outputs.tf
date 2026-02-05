# Outputs para consumo por outros módulos (Lambdas, API, integração S3 notifications).

output "videos_bucket_name" {
  description = "Nome do bucket S3 de vídeos (upload)."
  value       = aws_s3_bucket.videos.id
}

output "videos_bucket_arn" {
  description = "ARN do bucket S3 de vídeos."
  value       = aws_s3_bucket.videos.arn
}

output "images_bucket_name" {
  description = "Nome do bucket S3 de imagens (frames)."
  value       = aws_s3_bucket.images.id
}

output "images_bucket_arn" {
  description = "ARN do bucket S3 de imagens."
  value       = aws_s3_bucket.images.arn
}

output "zip_bucket_name" {
  description = "Nome do bucket S3 de zip (resultado final)."
  value       = aws_s3_bucket.zip.id
}

output "zip_bucket_arn" {
  description = "ARN do bucket S3 de zip."
  value       = aws_s3_bucket.zip.arn
}
