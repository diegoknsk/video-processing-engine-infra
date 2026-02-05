# Variáveis globais do root — repassadas aos módulos (foundation, storage, etc.).
# Nenhuma credencial ou ARN hardcoded.

variable "project_name" {
  description = "Nome do projeto (ex.: video-processing-engine)."
  type        = string
  default     = "video-processing-engine"
}

variable "environment" {
  description = "Ambiente (ex.: dev, staging, prod)."
  type        = string
  default     = "dev"
}

variable "region" {
  description = "Região AWS onde os recursos serão criados."
  type        = string
  default     = "us-east-1"
}

variable "owner" {
  description = "Responsável ou equipe dona do projeto (para tags)."
  type        = string
}

variable "retention_days" {
  description = "Dias de retenção para logs/métricas e lifecycle S3 (opcional)."
  type        = number
  default     = null
}

variable "enable_cloudwatch_retention" {
  description = "Habilita configuração de retenção em log groups CloudWatch (foundation)."
  type        = bool
  default     = true
}

variable "enable_versioning" {
  description = "Habilita versionamento nos buckets S3 (storage)."
  type        = bool
  default     = false
}

variable "enable_lifecycle_expiration" {
  description = "Habilita regra de lifecycle para expiração quando retention_days > 0 (storage)."
  type        = bool
  default     = true
}
