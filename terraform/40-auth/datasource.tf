# Data source para região AWS (construção de issuer e jwks_url quando var.region for null).

data "aws_region" "current" {}

locals {
  region = coalesce(var.region, data.aws_region.current.id)
}
