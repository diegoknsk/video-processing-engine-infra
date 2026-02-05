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

# --- Demais módulos: incluir quando implementados ---
# module "data"       { source = "./20-data";       prefix = module.foundation.prefix; common_tags = module.foundation.common_tags; ... }
# module "messaging"  { source = "./30-messaging";  prefix = module.foundation.prefix; common_tags = module.foundation.common_tags; ... }
# module "auth"       { source = "./40-auth";       prefix = module.foundation.prefix; common_tags = module.foundation.common_tags; ... }
# module "lambdas"    { source = "./50-lambdas-shell"; ... }
# module "api"        { source = "./60-api"; ... }
# module "orchestration" { source = "./70-orchestration"; ... }
