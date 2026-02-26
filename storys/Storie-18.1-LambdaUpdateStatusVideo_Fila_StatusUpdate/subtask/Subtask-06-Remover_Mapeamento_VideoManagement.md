# Subtask 06: Remover event source mapping q-video-status-update do LambdaVideoManagement

## Descrição
Remover de `terraform/50-lambdas-shell/event_source_mapping.tf` os blocos condicionais `aws_lambda_permission.sqs_invoke_video_management` e `aws_lambda_event_source_mapping.video_management_q_video_status_update` (controlados por `count = var.enable_status_update_consumer ? 1 : 0`). O `LambdaVideoManagement` deixa de consumir `q-video-status-update`; essa responsabilidade passa para `LambdaUpdateStatusVideo` (Subtask 05).

## Contexto — blocos a remover em `event_source_mapping.tf`

```hcl
# --- q-video-status-update → LambdaVideoManagement (quando enable_status_update_consumer) ---
resource "aws_lambda_permission" "sqs_invoke_video_management" {
  count = var.enable_status_update_consumer ? 1 : 0
  ...
}

resource "aws_lambda_event_source_mapping" "video_management_q_video_status_update" {
  count = var.enable_status_update_consumer ? 1 : 0
  ...
}
```

## Passos de implementação

1. Em `terraform/50-lambdas-shell/event_source_mapping.tf`: remover completamente os dois blocos acima, incluindo o comentário de seção que os precede.

2. Executar `terraform fmt -recursive` no diretório `terraform/50-lambdas-shell/`.

> **Atenção:** Se o state tiver esses recursos provisionados (índice `[0]`, pois `enable_status_update_consumer` tinha default `true`), o `terraform plan` mostrará `-` destroy. Isso é esperado. Executar junto com a Subtask 05 para não deixar a fila sem consumer.

## Formas de teste

1. `terraform validate` no módulo `50-lambdas-shell` — confirmar "Success! The configuration is valid."
2. `terraform plan` — confirmar que o plan mostra `-` destroy para:
   - `aws_lambda_permission.sqs_invoke_video_management[0]`
   - `aws_lambda_event_source_mapping.video_management_q_video_status_update[0]`
3. Após `terraform apply`, verificar no AWS Console (Lambda → `video-management` → Configuration → Triggers) que a fila `q-video-status-update` **não** aparece mais.

## Critérios de aceite

- [ ] Blocos `sqs_invoke_video_management` e `video_management_q_video_status_update` ausentes de `event_source_mapping.tf`
- [ ] Nenhuma referência residual a `enable_status_update_consumer` permanece em `event_source_mapping.tf`
- [ ] `terraform validate` passa sem erros
- [ ] `terraform plan` mostra a destruição dos recursos condicionais (ou confirma que não existiam se `enable_status_update_consumer` estava `false`)
