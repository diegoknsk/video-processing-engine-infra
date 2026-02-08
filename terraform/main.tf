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

  # trigger_mode e topic_video_submitted_arn: usados pelo root em upload_integration.tf quando s3_event
  trigger_mode              = var.trigger_mode
  topic_video_submitted_arn = null
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

  # trigger_mode e videos_bucket_arn: usados pelo root em upload_integration.tf quando s3_event
  trigger_mode      = var.trigger_mode
  videos_bucket_arn = null

  enable_email_subscription_completed  = var.enable_email_subscription_completed
  email_endpoint                       = var.email_endpoint
  enable_lambda_subscription_completed = var.enable_lambda_subscription_completed
  lambda_subscription_arn              = var.lambda_subscription_arn

  visibility_timeout_seconds    = var.visibility_timeout_seconds
  message_retention_seconds     = var.message_retention_seconds
  max_receive_count             = var.max_receive_count
  dlq_message_retention_seconds = var.dlq_message_retention_seconds
}

# --- Observabilidade base — Log Groups CloudWatch para as 5 Lambdas (Storie-12) ---
module "observability" {
  source = "./75-observability"

  prefix             = module.foundation.prefix
  common_tags        = module.foundation.common_tags
  log_retention_days = var.orchestration_log_retention_days
}

# --- Lambdas shell (Storie-08) ---
module "lambdas" {
  source = "./50-lambdas-shell"

  prefix      = module.foundation.prefix
  common_tags = module.foundation.common_tags

  runtime       = var.lambda_runtime
  handler       = var.lambda_handler
  artifact_path = "${path.module}/../artifacts/empty.zip"

  table_name = module.data.table_name
  table_arn  = module.data.table_arn

  videos_bucket_name = module.storage.videos_bucket_name
  videos_bucket_arn  = module.storage.videos_bucket_arn
  images_bucket_name = module.storage.images_bucket_name
  images_bucket_arn  = module.storage.images_bucket_arn
  zip_bucket_name    = module.storage.zip_bucket_name
  zip_bucket_arn     = module.storage.zip_bucket_arn

  q_video_process_url       = module.messaging.q_video_process_url
  q_video_process_arn       = module.messaging.q_video_process_arn
  q_video_status_update_url = module.messaging.q_video_status_update_url
  q_video_status_update_arn = module.messaging.q_video_status_update_arn
  q_video_zip_finalize_url  = module.messaging.q_video_zip_finalize_url
  q_video_zip_finalize_arn  = module.messaging.q_video_zip_finalize_arn

  topic_video_submitted_arn = module.messaging.topic_video_submitted_arn
  topic_video_completed_arn = module.messaging.topic_video_completed_arn

  step_function_arn             = var.step_function_arn
  enable_status_update_consumer = var.enable_status_update_consumer

  lab_role_arn = var.lab_role_arn
}

# --- Orchestration (Step Functions — Storie-09) ---
module "orchestration" {
  source = "./70-orchestration"

  prefix      = module.foundation.prefix
  common_tags = module.foundation.common_tags

  enable_stepfunctions = var.enable_stepfunctions
  log_retention_days   = var.orchestration_log_retention_days
  finalization_mode    = var.finalization_mode

  lambda_processor_arn = module.lambdas.lambda_video_processor_arn
  lambda_finalizer_arn = module.lambdas.lambda_video_finalizer_arn

  q_video_zip_finalize_arn = module.messaging.q_video_zip_finalize_arn
  q_video_zip_finalize_url = module.messaging.q_video_zip_finalize_url

  lab_role_arn = var.lab_role_arn
}

# --- Auth (Cognito User Pool e App Client — Storie-11; Storie-15: modo dev e usuário inicial) ---
module "auth" {
  source = "./40-auth"

  prefix      = module.foundation.prefix
  common_tags = module.foundation.common_tags
  region      = module.foundation.region

  auto_verified_attributes = var.auth_auto_verified_attributes
  create_initial_user      = var.auth_create_initial_user
  initial_user_email       = var.auth_initial_user_email
  initial_user_password    = var.auth_initial_user_password
  initial_user_name        = var.auth_initial_user_name

  password_min_length      = coalesce(var.auth_password_min_length, 6)
  password_require_symbols = coalesce(var.auth_password_require_symbols, false)
}

# --- API Gateway HTTP API (Storie-10) ---
module "api" {
  source = "./60-api"

  prefix      = module.foundation.prefix
  common_tags = module.foundation.common_tags

  lambda_auth_arn             = module.lambdas.lambda_auth_arn
  lambda_video_management_arn = module.lambdas.lambda_video_management_arn

  enable_authorizer  = var.enable_api_authorizer
  cognito_issuer_url = module.auth.issuer
  cognito_audience   = [module.auth.client_id]
  stage_name         = var.api_stage_name
}
