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

# --- SNS: subscription topic-video-processing-error (alertas de erro) ---
variable "enable_email_subscription_error" {
  description = "Habilita subscription de e-mail no topic-video-processing-error para alertas de erro."
  type        = bool
  default     = false
}

variable "email_endpoint_error" {
  description = "E-mail para alerta de erro quando enable_email_subscription_error = true; vazio ou null desabilita."
  type        = string
  default     = null
}

# --- SQS: parâmetros essenciais para resiliência e DLQ (Storie-06) ---
variable "visibility_timeout_seconds" {
  description = "Tempo de visibilidade da mensagem após recebimento (segundos); deve ser >= timeout das Lambdas consumidoras (900s); AWS recomenda 6x o timeout para retries."
  type        = number
  default     = 960
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
