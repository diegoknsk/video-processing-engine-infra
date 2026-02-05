# Variáveis do módulo 30-messaging. Prefix e tags vêm do foundation (caller passa).
# Parte SNS (Storie-05) e SQS (Storie-06). Nenhuma credencial ou ARN hardcoded.
# SQS não é criada na Storie-05; subscriptions SQS aos tópicos na story de integração.

# --- Foundation (obrigatórios) ---
variable "prefix" {
  description = "Prefixo de naming do foundation (ex.: video-processing-engine-{env})."
  type        = string
}

variable "common_tags" {
  description = "Tags padrão do foundation (Project, Environment, ManagedBy, Owner)."
  type        = map(string)
}

# --- SNS: subscription topic-video-completed (ativo agora = email; preparado para depois = Lambda) ---
variable "enable_email_subscription_completed" {
  description = "Ativo agora: habilita subscription email no topic-video-completed para notificação."
  type        = bool
  default     = false
}

variable "email_endpoint" {
  description = "E-mail para notificação quando enable_email_subscription_completed = true; vazio ou null desabilita."
  type        = string
  default     = null
}

variable "enable_lambda_subscription_completed" {
  description = "Preparado para depois: placeholder para subscription Lambda no topic-video-completed."
  type        = bool
  default     = false
}

variable "lambda_subscription_arn" {
  description = "ARN da Lambda para subscription no topic-video-completed; usado quando enable_lambda_subscription_completed = true (futuro)."
  type        = string
  default     = null
}

# --- SQS: parâmetros essenciais para resiliência e DLQ (Storie-06) ---
variable "visibility_timeout_seconds" {
  description = "Tempo de visibilidade da mensagem após recebimento (segundos); tempo para processar sem ficar visível para outros consumidores."
  type        = number
  default     = 300
}

variable "message_retention_seconds" {
  description = "Retenção de mensagens na fila principal (segundos). Ex.: 345600 = 4 dias."
  type        = number
  default     = 345600
}

variable "max_receive_count" {
  description = "Número de tentativas antes de enviar mensagem à DLQ (redrive_policy)."
  type        = number
  default     = 3
}

variable "dlq_message_retention_seconds" {
  description = "Retenção na DLQ (segundos) para inspeção de falhas. Ex.: 1209600 = 14 dias."
  type        = number
  default     = 1209600
}
