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

# --- Messaging (30-messaging: SNS + SQS) ---
variable "enable_email_subscription_completed" {
  description = "Habilita subscription email no topic-video-completed (SNS)."
  type        = bool
  default     = false
}

variable "email_endpoint" {
  description = "E-mail para notificação no topic-video-completed quando enable_email_subscription_completed = true."
  type        = string
  default     = null
}

variable "enable_lambda_subscription_completed" {
  description = "Placeholder: habilita subscription Lambda no topic-video-completed (preparado para depois)."
  type        = bool
  default     = false
}

variable "lambda_subscription_arn" {
  description = "ARN da Lambda para subscription no topic-video-completed (quando enable_lambda_subscription_completed = true)."
  type        = string
  default     = null
}

variable "visibility_timeout_seconds" {
  description = "SQS: tempo de visibilidade da mensagem após recebimento (segundos)."
  type        = number
  default     = 300
}

variable "message_retention_seconds" {
  description = "SQS: retenção de mensagens na fila principal (segundos)."
  type        = number
  default     = 345600
}

variable "max_receive_count" {
  description = "SQS: tentativas antes de enviar mensagem à DLQ."
  type        = number
  default     = 3
}

variable "dlq_message_retention_seconds" {
  description = "SQS: retenção na DLQ (segundos)."
  type        = number
  default     = 1209600
}
