# Tabela DynamoDB para metadados e status dos vídeos (Video Processing MVP).
# Tabela principal: pk = USER#{userId}, sk = VIDEO#{videoId} → Query(pk=USER#{userId}) lista vídeos; GetItem(pk, sk) obtém um vídeo.
# GSI1: gsi1pk = VIDEO#{videoId}, gsi1sk = USER#{userId} → Query(gsi1pk=VIDEO#{videoId}) busca por VideoId (atualização de status/ZipS3Key/ErrorMessage).
# Atributos não-chave (status, createdAt, updatedAt, zipS3Key, errorMessage, userId, videoId) são definidos pela aplicação.

resource "aws_dynamodb_table" "videos" {
  name         = "${var.prefix}-videos"
  billing_mode = var.billing_mode

  key_schema {
    attribute_name = "pk"
    key_type       = "HASH"
  }
  key_schema {
    attribute_name = "sk"
    key_type       = "RANGE"
  }

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
    projection_type = "ALL"

    key_schema {
      attribute_name = "gsi1pk"
      key_type       = "HASH"
    }
    key_schema {
      attribute_name = "gsi1sk"
      key_type       = "RANGE"
    }
  }

  ttl {
    enabled        = var.enable_ttl
    attribute_name = var.ttl_attribute_name
  }

  tags = merge(var.common_tags, {
    Name = "${var.prefix}-videos"
  })
}
