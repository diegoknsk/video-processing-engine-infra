# Variáveis do módulo 70-orchestration. Consumo via caller (root); ARNs/URLs dos módulos lambdas e messaging.

variable "prefix" {
  description = "Prefixo de naming do foundation (ex.: video-processing-engine-dev)."
  type        = string
}

variable "common_tags" {
  description = "Tags padrão do foundation (Project, Environment, ManagedBy, Owner)."
  type        = map(string)
}

variable "enable_stepfunctions" {
  description = "Habilita criação da state machine, log group e IAM da SFN; false desabilita o módulo."
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Retenção em dias do log group CloudWatch da Step Functions."
  type        = number
  default     = 14
}

variable "finalization_mode" {
  description = "Finalização: sqs = enviar mensagem para q-video-zip-finalize; lambda = invocar Lambda Video Finalizer diretamente."
  type        = string
  default     = "sqs"
}

# --- Integração: outputs dos módulos 50-lambdas-shell e 30-messaging ---
variable "lambda_processor_arn" {
  description = "ARN da Lambda Video Processor (output do módulo 50-lambdas-shell)."
  type        = string
}

variable "lambda_finalizer_arn" {
  description = "ARN da Lambda Video Finalizer (output do módulo 50-lambdas-shell)."
  type        = string
}

variable "q_video_zip_finalize_arn" {
  description = "ARN da fila q-video-zip-finalize (output do módulo 30-messaging); obrigatório quando finalization_mode = sqs."
  type        = string
  default     = null
}

variable "q_video_zip_finalize_url" {
  description = "URL da fila q-video-zip-finalize (para Parameters.QueueUrl na state machine); obrigatório quando finalization_mode = sqs."
  type        = string
  default     = null
}

# --- Lab Role (AWS Academy): não criar IAM role para SFN; usar role existente ---
variable "lab_role_arn" {
  description = "ARN da role existente (LabRole) usada pela State Machine. Obrigatório quando o Terraform não tem iam:CreateRole (ex.: AWS Academy). A role deve permitir states.amazonaws.com no trust policy."
  type        = string
}
