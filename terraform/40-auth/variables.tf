# Variáveis do módulo 40-auth (Cognito User Pool e App Client).
# Consumo via caller (root): prefix e common_tags do foundation.

variable "prefix" {
  description = "Prefixo de naming do foundation (ex.: video-processing-engine-dev)."
  type        = string
}

variable "common_tags" {
  description = "Tags padrão do foundation (Project, Environment, ManagedBy, Owner)."
  type        = map(string)
}

# --- Política de senha (User Pool) ---
variable "password_min_length" {
  description = "Comprimento mínimo da senha no User Pool."
  type        = number
  default     = 8
}

variable "password_require_uppercase" {
  description = "Exigir pelo menos uma letra maiúscula na senha."
  type        = bool
  default     = true
}

variable "password_require_lowercase" {
  description = "Exigir pelo menos uma letra minúscula na senha."
  type        = bool
  default     = true
}

variable "password_require_numbers" {
  description = "Exigir pelo menos um número na senha."
  type        = bool
  default     = true
}

variable "password_require_symbols" {
  description = "Exigir pelo menos um símbolo na senha."
  type        = bool
  default     = true
}

# --- Validade dos tokens (App Client). Unidades: access/id em horas, refresh em dias ---
variable "access_token_validity" {
  description = "Validade do access token em horas (mín. 1, máx. 24)."
  type        = number
  default     = 1
}

variable "id_token_validity" {
  description = "Validade do ID token em horas (mín. 1, máx. 24)."
  type        = number
  default     = 1
}

variable "refresh_token_validity" {
  description = "Validade do refresh token em dias (mín. 1, máx. 3650)."
  type        = number
  default     = 30
}

# --- Região (opcional: usada para construir issuer e jwks_url; se null, usa data.aws_region) ---
variable "region" {
  description = "Região AWS para construir issuer e jwks_url. Se null, usa a região do provider (data.aws_region)."
  type        = string
  default     = null
}
