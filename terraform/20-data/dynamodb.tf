# Tabela DynamoDB para metadados e status dos vídeos (Video Processing MVP).
# Tabela principal: PK = UserId, SK = VideoId → Query(PK=UserId) lista vídeos; GetItem(PK, SK) obtém um vídeo.
# GSI1: GSI1PK = VideoId, GSI1SK = UserId → Query(GSI1PK=VideoId) busca por VideoId (atualização de status/ZipS3Key/ErrorMessage).
# Atributos não-chave (Status, CreatedAt, UpdatedAt, ZipS3Key, ErrorMessage, UserId, VideoId) são definidos pela aplicação.

resource "aws_dynamodb_table" "videos" {
  name         = "${var.prefix}-videos"
  billing_mode = var.billing_mode

  hash_key  = "PK"
  range_key = "SK"

  attribute {
    name = "PK"
    type = "S"
  }

  attribute {
    name = "SK"
    type = "S"
  }

  attribute {
    name = "GSI1PK"
    type = "S"
  }

  attribute {
    name = "GSI1SK"
    type = "S"
  }

  global_secondary_index {
    name            = "GSI1"
    hash_key        = "GSI1PK"
    range_key       = "GSI1SK"
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
