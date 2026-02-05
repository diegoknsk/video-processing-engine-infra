# Módulo 30-messaging — Parte SQS (Storie-06).
# Três pares fila + DLQ; redrive_policy em todas as filas principais.
# Redrive policy garante que mensagens com falha repetida vão para a DLQ (caixa de falhas),
# evitando perda e permitindo inspeção/retry. Nenhuma Lambda nem event mapping nesta story.

# --- DLQs (criadas primeiro para referência na redrive_policy) ---
resource "aws_sqs_queue" "dlq_video_process" {
  name                      = "${var.prefix}-dlq-video-process"
  message_retention_seconds  = var.dlq_message_retention_seconds
  tags                      = var.common_tags
}

resource "aws_sqs_queue" "dlq_video_status_update" {
  name                      = "${var.prefix}-dlq-video-status-update"
  message_retention_seconds  = var.dlq_message_retention_seconds
  tags                      = var.common_tags
}

resource "aws_sqs_queue" "dlq_video_zip_finalize" {
  name                      = "${var.prefix}-dlq-video-zip-finalize"
  message_retention_seconds  = var.dlq_message_retention_seconds
  tags                      = var.common_tags
}

# --- Filas principais (com redrive_policy apontando para a DLQ correspondente) ---
resource "aws_sqs_queue" "q_video_process" {
  name                       = "${var.prefix}-q-video-process"
  visibility_timeout_seconds = var.visibility_timeout_seconds
  message_retention_seconds   = var.message_retention_seconds
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq_video_process.arn
    maxReceiveCount     = var.max_receive_count
  })
  tags = var.common_tags
}

resource "aws_sqs_queue" "q_video_status_update" {
  name                       = "${var.prefix}-q-video-status-update"
  visibility_timeout_seconds  = var.visibility_timeout_seconds
  message_retention_seconds  = var.message_retention_seconds
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq_video_status_update.arn
    maxReceiveCount     = var.max_receive_count
  })
  tags = var.common_tags
}

resource "aws_sqs_queue" "q_video_zip_finalize" {
  name                       = "${var.prefix}-q-video-zip-finalize"
  visibility_timeout_seconds = var.visibility_timeout_seconds
  message_retention_seconds   = var.message_retention_seconds
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq_video_zip_finalize.arn
    maxReceiveCount     = var.max_receive_count
  })
  tags = var.common_tags
}
