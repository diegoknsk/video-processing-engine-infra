# Subtask 05: Adicionar event source mapping q-video-status-update para LambdaUpdateStatusVideo

## Descrição
Adicionar no arquivo `terraform/50-lambdas-shell/event_source_mapping.tf` o `aws_lambda_permission` e o `aws_lambda_event_source_mapping` que conectam a fila `q-video-status-update` à nova Lambda `LambdaUpdateStatusVideo`. Esta subtask depende da Subtask 04 (Lambda criada) e deve ser executada no mesmo apply que a Subtask 06 (remoção do mapeamento antigo) para evitar janela sem consumer.

## Passos de implementação

1. Em `terraform/50-lambdas-shell/event_source_mapping.tf`, adicionar ao final:

```hcl
# --- q-video-status-update → LambdaUpdateStatusVideo (Storie-18.1) ---
resource "aws_lambda_permission" "sqs_invoke_update_status_video" {
  statement_id  = "AllowExecutionFromSQS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update_status_video.function_name
  principal     = "sqs.amazonaws.com"
  source_arn    = var.q_video_status_update_arn
}

resource "aws_lambda_event_source_mapping" "update_status_video_q_video_status_update" {
  event_source_arn = var.q_video_status_update_arn
  function_name    = aws_lambda_function.update_status_video.function_name
  batch_size       = 1
}
```

2. Verificar que `var.q_video_status_update_arn` já está declarado em `variables.tf`.

3. Executar `terraform fmt -recursive` no diretório `terraform/50-lambdas-shell/`.

## Formas de teste

1. `terraform validate` no módulo `50-lambdas-shell` — confirmar "Success! The configuration is valid."
2. `terraform plan` — confirmar que o plan mostra:
   - `+ aws_lambda_permission.sqs_invoke_update_status_video`
   - `+ aws_lambda_event_source_mapping.update_status_video_q_video_status_update`
3. Após `terraform apply`, verificar no AWS Console (Lambda → `update-status-video` → Configuration → Triggers) que a fila `q-video-status-update` aparece como trigger ativo.

## Critérios de aceite

- [ ] `aws_lambda_permission.sqs_invoke_update_status_video` adicionado com `principal = "sqs.amazonaws.com"` e `source_arn = var.q_video_status_update_arn`
- [ ] `aws_lambda_event_source_mapping.update_status_video_q_video_status_update` adicionado com `batch_size = 1` e referência correta à `aws_lambda_function.update_status_video`
- [ ] `terraform validate` passa sem erros
- [ ] `terraform plan` mostra ambos os recursos como `+ create`
