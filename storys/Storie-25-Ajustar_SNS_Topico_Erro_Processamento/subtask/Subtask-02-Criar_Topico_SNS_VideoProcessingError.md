# Subtask-02: Criar tópico SNS topic-video-processing-error no módulo 30-messaging

## Descrição
Adicionar o novo recurso `aws_sns_topic.topic_video_processing_error` e a subscription de e-mail correspondente (com feature flag) em `terraform/30-messaging/sns.tf`. O tópico é dedicado exclusivamente para notificações de erros no processamento de vídeo.

## Arquivos Afetados
- `terraform/30-messaging/sns.tf`

## Nome do Tópico
```
${var.prefix}-topic-video-processing-error
```

Resource Terraform: `aws_sns_topic.topic_video_processing_error`

## Passos de Implementação

1. **Adicionar o recurso do tópico** em `terraform/30-messaging/sns.tf`:

```hcl
resource "aws_sns_topic" "topic_video_processing_error" {
  name = "${var.prefix}-topic-video-processing-error"
  tags = var.common_tags
}
```

2. **Adicionar a subscription de e-mail** com feature flag (depende das variáveis criadas na Subtask-03):

```hcl
resource "aws_sns_topic_subscription" "error_email" {
  count     = var.enable_email_subscription_error && var.email_endpoint_error != null && var.email_endpoint_error != "" ? 1 : 0
  topic_arn = aws_sns_topic.topic_video_processing_error.arn
  protocol  = "email"
  endpoint  = var.email_endpoint_error
}
```

3. **Atualizar o comentário de cabeçalho** do arquivo para refletir o novo estado (remover referências a `topic_video_completed`; incluir referência ao novo tópico de erro).

4. **Executar `terraform fmt`** no diretório `terraform/30-messaging/`.

## Formas de Teste

1. Verificar que o bloco `aws_sns_topic "topic_video_processing_error"` existe em `sns.tf` com nome correto `${var.prefix}-topic-video-processing-error` e tags via `var.common_tags`.
2. Verificar que `aws_sns_topic_subscription "error_email"` usa `count` com feature flag `var.enable_email_subscription_error`.
3. Executar `terraform validate` no módulo `30-messaging` após Subtask-01, Subtask-02 e Subtask-03 concluídas: deve retornar "The configuration is valid."

## Critérios de Aceite
- [ ] Recurso `aws_sns_topic "topic_video_processing_error"` existe em `sns.tf` com nome `${var.prefix}-topic-video-processing-error` e `tags = var.common_tags`
- [ ] Recurso `aws_sns_topic_subscription "error_email"` existe com `count` baseado em `var.enable_email_subscription_error` e `var.email_endpoint_error`
- [ ] Nenhum ARN hardcoded no bloco do tópico ou da subscription
- [ ] `terraform fmt` não reporta diff de formatação em `sns.tf`
