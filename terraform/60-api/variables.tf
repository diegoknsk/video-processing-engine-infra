# Variáveis do módulo 60-api (API Gateway HTTP API).
# Consumo via caller (root): prefix e common_tags do foundation; ARNs do 50-lambdas-shell; Cognito do 40-auth quando authorizer habilitado.

variable "prefix" {
  description = "Prefixo de naming do foundation (ex.: video-processing-engine-dev)."
  type        = string
}

variable "common_tags" {
  description = "Tags padrão do foundation (Project, Environment, ManagedBy, Owner)."
  type        = map(string)
}

# --- Integração Lambdas (outputs do módulo 50-lambdas-shell) ---
variable "lambda_auth_arn" {
  description = "ARN da Lambda Auth (output lambda_auth_arn do módulo 50-lambdas-shell)."
  type        = string
}

variable "lambda_video_management_arn" {
  description = "ARN da Lambda Video Management (output lambda_video_management_arn do módulo 50-lambdas-shell)."
  type        = string
}

# --- JWT Authorizer (Cognito — outputs do módulo 40-auth quando existir) ---
variable "enable_authorizer" {
  description = "Habilita JWT authorizer do Cognito. Quando false, rotas ficam acessíveis sem token (bootstrap). Quando 40-auth não existir, manter false."
  type        = bool
  default     = false
}

variable "cognito_issuer_url" {
  description = "URL do issuer do Cognito User Pool (output do módulo 40-auth). Ex.: https://cognito-idp.{region}.amazonaws.com/{userPoolId}"
  type        = string
  default     = null
}

variable "cognito_audience" {
  description = "Audience do JWT (ex.: client ID do App Client Cognito). Output do módulo 40-auth. Pode ser list quando múltiplos clients."
  type        = list(string)
  default     = null
}

# --- Stage ---
variable "stage_name" {
  description = "Nome do stage da API (ex.: dev)."
  type        = string
  default     = "dev"
}
