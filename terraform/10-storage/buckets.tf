# Três buckets S3: videos (upload), images (frames), zip (resultado final).
# Block Public Access e SSE-S3 habilitados; versioning e lifecycle configuráveis.

# --- Bucket videos (upload pelo usuário) ---
resource "aws_s3_bucket" "videos" {
  bucket = "${var.prefix}-videos"

  tags = merge(var.common_tags, {
    Name = "${var.prefix}-videos"
  })
}

resource "aws_s3_bucket_public_access_block" "videos" {
  bucket = aws_s3_bucket.videos.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "videos" {
  bucket = aws_s3_bucket.videos.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "videos" {
  bucket = aws_s3_bucket.videos.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "videos" {
  count = var.enable_lifecycle_expiration && coalesce(var.retention_days, 0) > 0 ? 1 : 0

  bucket = aws_s3_bucket.videos.id

  rule {
    id     = "expire-old-objects"
    status = "Enabled"

    filter {}

    expiration {
      days = coalesce(var.retention_days, 0)
    }
  }
}

# --- Bucket images (frames extraídos) ---
resource "aws_s3_bucket" "images" {
  bucket = "${var.prefix}-images"

  tags = merge(var.common_tags, {
    Name = "${var.prefix}-images"
  })
}

resource "aws_s3_bucket_public_access_block" "images" {
  bucket = aws_s3_bucket.images.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "images" {
  bucket = aws_s3_bucket.images.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "images" {
  bucket = aws_s3_bucket.images.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "images" {
  count = var.enable_lifecycle_expiration && coalesce(var.retention_days, 0) > 0 ? 1 : 0

  bucket = aws_s3_bucket.images.id

  rule {
    id     = "expire-old-objects"
    status = "Enabled"

    filter {}

    expiration {
      days = coalesce(var.retention_days, 0)
    }
  }
}

# --- Bucket zip (resultado final) ---
resource "aws_s3_bucket" "zip" {
  bucket = "${var.prefix}-zip"

  tags = merge(var.common_tags, {
    Name = "${var.prefix}-zip"
  })
}

resource "aws_s3_bucket_public_access_block" "zip" {
  bucket = aws_s3_bucket.zip.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "zip" {
  bucket = aws_s3_bucket.zip.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "zip" {
  bucket = aws_s3_bucket.zip.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "zip" {
  count = var.enable_lifecycle_expiration && coalesce(var.retention_days, 0) > 0 ? 1 : 0

  bucket = aws_s3_bucket.zip.id

  rule {
    id     = "expire-old-objects"
    status = "Enabled"

    filter {}

    expiration {
      days = coalesce(var.retention_days, 0)
    }
  }
}
