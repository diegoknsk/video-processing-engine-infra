# Variáveis do módulo 75-observability. Observabilidade base com CloudWatch Logs apenas.
# Prefix já inclui environment (ex.: video-processing-engine-dev).

variable "prefix" {
  description = "Prefixo de naming do foundation (contém environment; ex.: video-processing-engine-dev)."
  type        = string
}

variable "common_tags" {
  description = "Tags padrão do foundation (Project, Environment, ManagedBy, Owner)."
  type        = map(string)
}

variable "log_retention_days" {
  description = "Variável global de retenção em dias para todos os log groups (Lambdas); reter por X dias. Alinhar ao mesmo valor usado no 70-orchestration (SFN) para consistência."
  type        = number
  default     = 14
}
