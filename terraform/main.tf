# Root Terraform — invocação dos módulos.
# Ordem implícita: foundation primeiro; storage e demais consomem prefix/common_tags do foundation.
# Módulos 20-data a 70-orchestration: incluir aqui quando implementados (Stories 04 a 12).

# --- Foundation (convenções, tags, prefix, account_id) ---
module "foundation" {
  source = "./00-foundation"

  project_name                = var.project_name
  environment                 = var.environment
  region                      = var.region
  owner                       = var.owner
  retention_days              = var.retention_days
  enable_cloudwatch_retention = var.enable_cloudwatch_retention
}

# --- Storage (buckets S3: vídeos, imagens, zip) ---
module "storage" {
  source = "./10-storage"

  prefix                      = module.foundation.prefix
  common_tags                 = module.foundation.common_tags
  region                      = module.foundation.region
  environment                 = var.environment
  enable_versioning           = var.enable_versioning
  retention_days              = var.retention_days
  enable_lifecycle_expiration = var.enable_lifecycle_expiration
}

# --- Data (DynamoDB vídeos/processamento) ---
module "data" {
  source = "./20-data"

  prefix      = module.foundation.prefix
  common_tags = module.foundation.common_tags
}

# --- Messaging (SNS + SQS) ---
module "messaging" {
  source = "./30-messaging"

  prefix      = module.foundation.prefix
  common_tags = module.foundation.common_tags

  enable_email_subscription_completed  = var.enable_email_subscription_completed
  email_endpoint                      = var.email_endpoint
  enable_lambda_subscription_completed = var.enable_lambda_subscription_completed
  lambda_subscription_arn              = var.lambda_subscription_arn

  visibility_timeout_seconds    = var.visibility_timeout_seconds
  message_retention_seconds    = var.message_retention_seconds
  max_receive_count            = var.max_receive_count
  dlq_message_retention_seconds = var.dlq_message_retention_seconds
}

# --- Demais módulos: incluir quando implementados ---
# module "auth"       { source = "./40-auth";       prefix = module.foundation.prefix; common_tags = module.foundation.common_tags; ... }
# module "lambdas"    { source = "./50-lambdas-shell"; ... }
# module "api"        { source = "./60-api"; ... }
# module "orchestration" { source = "./70-orchestration"; ... }
