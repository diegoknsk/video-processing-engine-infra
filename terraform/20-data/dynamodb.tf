# Tabela DynamoDB para metadados e status dos vídeos (Video Processing MVP).
# Tabela principal: pk = USER#{userId}, sk = VIDEO#{videoId} → Query(pk=USER#{userId}) lista vídeos; GetItem(pk, sk) obtém um vídeo.
# GSI1: gsi1pk = VIDEO#{videoId}, gsi1sk = USER#{userId} → Query(gsi1pk=VIDEO#{videoId}) busca por VideoId (atualização de status/ZipS3Key/ErrorMessage).
# Atributos não-chave (status, createdAt, updatedAt, zipS3Key, errorMessage, userId, videoId) são definidos pela aplicação.

resource "aws_dynamodb_table" "videos" {
  name         = "${var.prefix}-videos"
  billing_mode = var.billing_mode

  hash_key  = "pk"
  range_key = "sk"

  attribute {
    name = "pk"
    type = "S"
  }

  attribute {
    name = "sk"
    type = "S"
  }

  attribute {
    name = "gsi1pk"
    type = "S"
  }

  attribute {
    name = "gsi1sk"
    type = "S"
  }

  global_secondary_index {
    name            = "GSI1"
    hash_key        = "gsi1pk"
    range_key       = "gsi1sk"
    projection_type = "ALL"
  }

  ttl {
    enabled        = var.enable_ttl
    attribute_name = var.ttl_attribute_name
  }

  tags = merge(var.common_tags, {
    Name = "${var.prefix}-videos"
  })
}
