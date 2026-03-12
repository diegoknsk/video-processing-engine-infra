# Subtask-03: Atualizar variáveis e outputs do módulo 30-messaging

## Descrição
Remover de `terraform/30-messaging/variables.tf` as variáveis ligadas ao tópico `topic_video_completed` (subscriptions de e-mail e Lambda) e adicionar as novas variáveis para o tópico de erro. Remover de `terraform/30-messaging/outputs.tf` o output `topic_video_completed_arn` e adicionar o output `topic_video_processing_error_arn`.

## Arquivos Afetados
- `terraform/30-messaging/variables.tf`
- `terraform/30-messaging/outputs.tf`

## Passos de Implementação

### variables.tf

1. **Remover** os seguintes blocos de `variables.tf`:
   - `variable "enable_email_subscription_completed"`
   - `variable "email_endpoint"`
   - `variable "enable_lambda_subscription_completed"`
   - `variable "lambda_subscription_arn"`

2. **Adicionar** as novas variáveis para o tópico de erro:

```hcl
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
```

3. **Atualizar o comentário de cabeçalho** do arquivo para refletir o novo estado.

### outputs.tf

4. **Remover** o bloco de output `topic_video_completed_arn` de `outputs.tf`.

5. **Adicionar** o novo output:

```hcl
output "topic_video_processing_error_arn" {
  description = "ARN do tópico SNS topic-video-processing-error (notificação de erros de processamento)."
  value       = aws_sns_topic.topic_video_processing_error.arn
}
```

6. **Executar `terraform fmt`** no diretório `terraform/30-messaging/`.

## Formas de Teste

1. Verificar que nenhuma das quatro variáveis removidas existe em `variables.tf`.
2. Verificar que `variable "enable_email_subscription_error"` e `variable "email_endpoint_error"` existem em `variables.tf` com `default` correto.
3. Verificar que `output "topic_video_completed_arn"` não existe em `outputs.tf`.
4. Verificar que `output "topic_video_processing_error_arn"` existe em `outputs.tf` referenciando `aws_sns_topic.topic_video_processing_error.arn`.
5. Executar `terraform validate` no módulo `30-messaging` com Subtask-01, 02 e 03 concluídas: deve retornar "The configuration is valid."

## Critérios de Aceite
- [ ] Variáveis `enable_email_subscription_completed`, `email_endpoint`, `enable_lambda_subscription_completed` e `lambda_subscription_arn` removidas de `variables.tf`
- [ ] Variáveis `enable_email_subscription_error` (bool, default false) e `email_endpoint_error` (string, default null) adicionadas em `variables.tf`
- [ ] Output `topic_video_completed_arn` removido de `outputs.tf`
- [ ] Output `topic_video_processing_error_arn` adicionado em `outputs.tf` com valor `aws_sns_topic.topic_video_processing_error.arn`
- [ ] `terraform validate` no módulo `30-messaging` retorna "The configuration is valid." após Subtask-01, 02 e 03 concluídas
- [ ] `terraform fmt` não reporta diff em nenhum dos dois arquivos
