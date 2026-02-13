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

# --- Lab Role (AWS Academy): role existente para Lambdas e Step Functions; evita iam:CreateRole ---
variable "lab_role_arn" {
  description = "ARN da role existente (ex.: LabRole) usada por Lambdas e Step Functions. Obrigatório em AWS Academy (sem iam:CreateRole). Ex.: arn:aws:iam::ACCOUNT_ID:role/LabRole"
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

# --- Integração upload concluído (Storie-07) ---
variable "trigger_mode" {
  description = "Modo do evento upload concluído: s3_event (S3 notifica SNS) ou api_publish (Lambda publica no SNS)."
  type        = string
  default     = "api_publish"
}

# --- Lambdas (50-lambdas-shell, Storie-08) ---
variable "lambda_runtime" {
  description = "Runtime das Lambdas (ex.: dotnet10)."
  type        = string
  default     = "dotnet10"
}

variable "lambda_handler" {
  description = "Handler placeholder das Lambdas. Para .NET: Assembly::Namespace.Class::Method."
  type        = string
  default     = "Lambda::Lambda.Function::FunctionHandler"
}

variable "step_function_arn" {
  description = "ARN da Step Function (módulo 70-orchestration); preencher com output step_machine_arn após primeiro apply (Lambda Orchestrator usa para StartExecution)."
  type        = string
  default     = ""
}

# --- Orchestration (70-orchestration, Storie-09) ---
variable "enable_stepfunctions" {
  description = "Habilita criação da State Machine Step Functions e recursos do módulo 70-orchestration."
  type        = bool
  default     = true
}

variable "orchestration_log_retention_days" {
  description = "Retenção em dias do log group CloudWatch da Step Functions."
  type        = number
  default     = 14
}

variable "finalization_mode" {
  description = "Finalização do fluxo: sqs = mensagem em q-video-zip-finalize; lambda = invocar Lambda Finalizer diretamente."
  type        = string
  default     = "sqs"
}

variable "enable_status_update_consumer" {
  description = "Mapeia Lambda Video Management à fila q-video-status-update quando true."
  type        = bool
  default     = true
}

# --- API Gateway (60-api, Storie-10) ---
variable "enable_api_authorizer" {
  description = "Habilita JWT authorizer Cognito na API Gateway. Quando false ou quando 40-auth não existir, rotas ficam acessíveis sem token (bootstrap)."
  type        = bool
  default     = false
}

variable "cognito_issuer_url" {
  description = "URL do issuer do Cognito User Pool (output do módulo 40-auth). Obrigatório quando enable_api_authorizer = true."
  type        = string
  default     = null
}

variable "cognito_audience" {
  description = "Audience do JWT Cognito (ex.: client ID do App Client). Output do módulo 40-auth. List quando múltiplos clients."
  type        = list(string)
  default     = null
}

variable "api_stage_name" {
  description = "Nome do stage da API Gateway (ex.: dev)."
  type        = string
  default     = "dev"
}

# --- Auth / Cognito (40-auth, Storie-15: modo dev e usuário inicial) ---
variable "auth_auto_verified_attributes" {
  description = "Atributos verificados pelo Cognito. Use [] em dev para não exigir confirmação de email."
  type        = list(string)
  default     = [] # Modo dev: sem confirmação de email por padrão
}

variable "auth_create_initial_user" {
  description = "Cria usuário inicial no User Pool (apenas dev/lab). Requer auth_initial_user_email e auth_initial_user_password."
  type        = bool
  default     = false
}

variable "auth_initial_user_email" {
  description = "Email do usuário inicial quando auth_create_initial_user = true. Não commitar em tfvars versionado."
  type        = string
  default     = null
}

variable "auth_initial_user_password" {
  description = "Senha do usuário inicial (apenas dev/lab). Usar tfvars não versionado ou TF_VAR_auth_initial_user_password."
  type        = string
  default     = null
  sensitive   = true
}

variable "auth_initial_user_name" {
  description = "Nome do usuário inicial quando auth_create_initial_user = true."
  type        = string
  default     = "DevUser"
}

# Política de senha do Cognito (repassada ao 40-auth; modo dev com senha facilitada por padrão)
variable "auth_password_min_length" {
  description = "Comprimento mínimo da senha no User Pool. Em dev pode usar 6."
  type        = number
  default     = 6 # Modo dev: senha mínima de 6 dígitos por padrão
}

variable "auth_password_require_symbols" {
  description = "Exigir símbolo na senha. Em dev pode usar false para senha simples."
  type        = bool
  default     = false # Modo dev: não exige símbolos por padrão
}
