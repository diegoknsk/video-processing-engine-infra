# Outputs do módulo 30-messaging — SNS (Storie-05; Storie-18.1) e SQS (Storie-06).

# --- SNS: ARNs dos tópicos ---
output "topic_video_completed_arn" {
  description = "ARN do tópico SNS topic-video-completed (evento de processamento concluído)."
  value       = aws_sns_topic.topic_video_completed.arn
}

# --- SQS: URLs e ARNs das filas principais e DLQs ---
output "q_video_process_url" {
  description = "URL da fila q-video-process (consumida pela Lambda Video Orchestrator)."
  value       = aws_sqs_queue.q_video_process.url
}

output "q_video_process_arn" {
  description = "ARN da fila q-video-process."
  value       = aws_sqs_queue.q_video_process.arn
}

output "dlq_video_process_url" {
  description = "URL da DLQ dlq-video-process (caixa de falhas)."
  value       = aws_sqs_queue.dlq_video_process.url
}

output "dlq_video_process_arn" {
  description = "ARN da DLQ dlq-video-process."
  value       = aws_sqs_queue.dlq_video_process.arn
}

output "q_video_status_update_url" {
  description = "URL da fila q-video-status-update (atualização de status)."
  value       = aws_sqs_queue.q_video_status_update.url
}

output "q_video_status_update_arn" {
  description = "ARN da fila q-video-status-update."
  value       = aws_sqs_queue.q_video_status_update.arn
}

output "dlq_video_status_update_url" {
  description = "URL da DLQ dlq-video-status-update."
  value       = aws_sqs_queue.dlq_video_status_update.url
}

output "dlq_video_status_update_arn" {
  description = "ARN da DLQ dlq-video-status-update."
  value       = aws_sqs_queue.dlq_video_status_update.arn
}

output "q_video_zip_finalize_url" {
  description = "URL da fila q-video-zip-finalize (consumida pela Lambda Video Finalizer)."
  value       = aws_sqs_queue.q_video_zip_finalize.url
}

output "q_video_zip_finalize_arn" {
  description = "ARN da fila q-video-zip-finalize."
  value       = aws_sqs_queue.q_video_zip_finalize.arn
}

output "dlq_video_zip_finalize_url" {
  description = "URL da DLQ dlq-video-zip-finalize."
  value       = aws_sqs_queue.dlq_video_zip_finalize.url
}

output "dlq_video_zip_finalize_arn" {
  description = "ARN da DLQ dlq-video-zip-finalize."
  value       = aws_sqs_queue.dlq_video_zip_finalize.arn
}
