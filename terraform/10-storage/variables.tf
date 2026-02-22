# Variáveis do módulo 10-storage. Prefix e tags vêm do foundation (caller passa).
# Nenhuma credencial ou ARN hardcoded.

variable "prefix" {
  description = "Prefixo de naming do foundation (ex.: video-processing-engine-{env})."
  type        = string
}

variable "common_tags" {
  description = "Tags padrão do foundation (Project, Environment, ManagedBy, Owner)."
  type        = map(string)
}

variable "region" {
  description = "Região AWS onde os buckets serão criados."
  type        = string
  default     = "us-east-1"
}

variable "enable_versioning" {
  description = "Habilita versionamento nos buckets S3."
  type        = bool
  default     = false
}

variable "retention_days" {
  description = "Dias para expirar objetos antigos via lifecycle; 0 ou null desabilita expiração."
  type        = number
  default     = null
}

variable "enable_lifecycle_expiration" {
  description = "Habilita regra de lifecycle para expiração quando retention_days > 0."
  type        = bool
  default     = true
}

variable "environment" {
  description = "Ambiente para tags/naming consistente com foundation (opcional)."
  type        = string
  default     = null
}
