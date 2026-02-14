# Variáveis do módulo 50-lambdas-shell. Consumo via caller (root) a partir dos módulos storage, data, messaging, orchestration.

variable "prefix" {
  description = "Prefixo de naming do foundation (ex.: video-processing-engine-dev)."
  type        = string
}

variable "common_tags" {
  description = "Tags padrão do foundation (Project, Environment, ManagedBy, Owner)."
  type        = map(string)
}

variable "runtime" {
  description = "Runtime das Lambdas (ex.: dotnet10, dotnet8, python3.12)."
  type        = string
  default     = "dotnet10"
}

variable "handler" {
  description = "Handler placeholder; aplicação substitui no deploy. Para .NET: Assembly::Namespace.Class::Method."
  type        = string
  default     = "Lambda::Lambda.Function::FunctionHandler"
}

variable "auth_handler" {
  description = "Handler da Lambda de autenticação. Para .NET: Assembly::Namespace.Class::Method."
  type        = string
  default     = "VideoProcessing.Auth.Api"
}

variable "artifact_path" {
  description = "Caminho do zip da casca (ex.: artifacts/empty.zip). Caller deve passar path válido (ex.: path.root/artifacts/empty.zip)."
  type        = string
  default     = "artifacts/empty.zip"
}

# --- DynamoDB (módulo data) ---
variable "table_name" {
  description = "Nome da tabela DynamoDB de vídeos (output do módulo data)."
  type        = string
}

variable "table_arn" {
  description = "ARN da tabela DynamoDB (output do módulo data)."
  type        = string
}

# --- S3 (módulo storage) ---
variable "videos_bucket_name" {
  description = "Nome do bucket S3 de vídeos (output do módulo storage)."
  type        = string
}

variable "videos_bucket_arn" {
  description = "ARN do bucket S3 de vídeos (output do módulo storage)."
  type        = string
}

variable "images_bucket_name" {
  description = "Nome do bucket S3 de imagens (output do módulo storage)."
  type        = string
}

variable "images_bucket_arn" {
  description = "ARN do bucket S3 de imagens (output do módulo storage)."
  type        = string
}

variable "zip_bucket_name" {
  description = "Nome do bucket S3 de zip (output do módulo storage)."
  type        = string
}

variable "zip_bucket_arn" {
  description = "ARN do bucket S3 de zip (output do módulo storage)."
  type        = string
}

# --- SQS (módulo messaging) ---
variable "q_video_process_url" {
  description = "URL da fila q-video-process (output do módulo messaging)."
  type        = string
}

variable "q_video_process_arn" {
  description = "ARN da fila q-video-process (output do módulo messaging)."
  type        = string
}

variable "q_video_status_update_url" {
  description = "URL da fila q-video-status-update (output do módulo messaging)."
  type        = string
}

variable "q_video_status_update_arn" {
  description = "ARN da fila q-video-status-update (output do módulo messaging)."
  type        = string
}

variable "q_video_zip_finalize_url" {
  description = "URL da fila q-video-zip-finalize (output do módulo messaging)."
  type        = string
}

variable "q_video_zip_finalize_arn" {
  description = "ARN da fila q-video-zip-finalize (output do módulo messaging)."
  type        = string
}

# --- SNS (módulo messaging) ---
variable "topic_video_submitted_arn" {
  description = "ARN do tópico SNS topic-video-submitted (output do módulo messaging)."
  type        = string
}

variable "topic_video_completed_arn" {
  description = "ARN do tópico SNS topic-video-completed (output do módulo messaging)."
  type        = string
}

# --- Step Functions (módulo 70-orchestration; placeholder se ainda não existir) ---
variable "step_function_arn" {
  description = "ARN da Step Function de orquestração (output do módulo 70-orchestration ou placeholder)."
  type        = string
  default     = ""
}

variable "enable_status_update_consumer" {
  description = "Se true, mapeia LambdaVideoManagement à fila q-video-status-update; se false, consumo futuro."
  type        = bool
  default     = true
}

# --- Lab Role (AWS Academy): não criar IAM roles; usar role existente ---
variable "lab_role_arn" {
  description = "ARN da role existente (LabRole) assumida por todas as Lambdas. Obrigatório quando o executor do Terraform não tem iam:CreateRole (ex.: AWS Academy)."
  type        = string
}
