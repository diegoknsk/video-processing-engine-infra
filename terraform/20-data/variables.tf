# Variáveis do módulo 20-data. Prefix e tags vêm do foundation (caller passa).
# Nenhuma credencial ou ARN hardcoded.

variable "prefix" {
  description = "Prefixo de naming do foundation (ex.: video-processing-engine-{env})."
  type        = string
}

variable "common_tags" {
  description = "Tags padrão do foundation (Project, Environment, ManagedBy, Owner)."
  type        = map(string)
}

variable "enable_ttl" {
  description = "Habilita TTL na tabela DynamoDB."
  type        = bool
  default     = false
}

variable "ttl_attribute_name" {
  description = "Nome do atributo TTL (campo numérico epoch em segundos)."
  type        = string
  default     = "TTL"
}

variable "billing_mode" {
  description = "Modo de cobrança: PAY_PER_REQUEST ou PROVISIONED."
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "environment" {
  description = "Ambiente para tags/naming consistente com foundation (opcional)."
  type        = string
  default     = null
}

# --- Tabela de chunks (status por chunk de vídeo) ---

variable "chunks_billing_mode" {
  description = "Billing mode da tabela de chunks (PAY_PER_REQUEST ou PROVISIONED)."
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "enable_chunks_ttl" {
  description = "Habilita TTL na tabela de chunks."
  type        = bool
  default     = false
}

variable "chunks_ttl_attribute_name" {
  description = "Nome do atributo TTL na tabela de chunks (número epoch seconds)."
  type        = string
  default     = "TTL"
}
