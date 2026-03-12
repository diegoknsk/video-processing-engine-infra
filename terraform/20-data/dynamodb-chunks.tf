# Tabela DynamoDB para status individual de cada chunk de processamento de vídeo.
# pk = VIDEO#{videoId}, sk = CHUNK#{chunkIndex}. Permite calcular progresso por contagem de chunks concluídos.
# Atributos não-chave (videoId, chunkIndex, totalChunks, status, createdAt, updatedAt, errorMessage, TTL) definidos pela aplicação.

resource "aws_dynamodb_table" "video_chunks" {
  name         = "${var.prefix}-video-chunks"
  billing_mode = var.chunks_billing_mode
  hash_key     = "pk"
  range_key    = "sk"

  attribute {
    name = "pk"
    type = "S"
  }

  attribute {
    name = "sk"
    type = "S"
  }

  dynamic "ttl" {
    for_each = var.enable_chunks_ttl ? [1] : []
    content {
      attribute_name = var.chunks_ttl_attribute_name
      enabled        = true
    }
  }

  tags = merge(var.common_tags, {
    Name = "${var.prefix}-video-chunks"
  })
}
