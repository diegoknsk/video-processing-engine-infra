# Subtask 02: Criar event source mapping q-video-process para LambdaVideoOrchestrator

## Descrição
Adicionar no arquivo `terraform/50-lambdas-shell/event_source_mapping.tf` o `aws_lambda_permission` e o `aws_lambda_event_source_mapping` que conectam a fila `q-video-process` à Lambda `LambdaVideoOrchestrator`. Isso garante que, quando o S3 publica um evento na fila (após upload), o orquestrador seja invocado diretamente. Esta subtask deve ser executada no mesmo apply que a Subtask 01 para evitar janela sem consumer.

## Passos de implementação

1. Em `terraform/50-lambdas-shell/event_source_mapping.tf`, adicionar após a remoção dos blocos do dispatcher (Subtask 01):

```hcl
# --- q-video-process → LambdaVideoOrchestrator (Storie-18.1) ---
resource "aws_lambda_permission" "sqs_invoke_orchestrator" {
  statement_id  = "AllowExecutionFromSQS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.video_orchestrator.function_name
  principal     = "sqs.amazonaws.com"
  source_arn    = var.q_video_process_arn
}

resource "aws_lambda_event_source_mapping" "orchestrator_q_video_process" {
  event_source_arn = var.q_video_process_arn
  function_name    = aws_lambda_function.video_orchestrator.function_name
  batch_size       = 1
}
```

2. Verificar que `var.q_video_process_arn` já está declarado em `variables.tf` (foi adicionado em stories anteriores) — não criar variável duplicada.

3. Executar `terraform fmt -recursive` no diretório `terraform/50-lambdas-shell/`.

## Formas de teste

1. `terraform validate` no módulo `50-lambdas-shell` — confirmar "Success! The configuration is valid."
2. `terraform plan` no root — confirmar que o plan mostra:
   - `+ aws_lambda_permission.sqs_invoke_orchestrator`
   - `+ aws_lambda_event_source_mapping.orchestrator_q_video_process`
3. Após `terraform apply`, verificar no AWS Console (Lambda → `video-orchestrator` → Configuration → Triggers) que a fila `q-video-process` aparece como trigger ativo.

## Critérios de aceite

- [ ] `aws_lambda_permission.sqs_invoke_orchestrator` adicionado com `principal = "sqs.amazonaws.com"` e `source_arn = var.q_video_process_arn`
- [ ] `aws_lambda_event_source_mapping.orchestrator_q_video_process` adicionado com `batch_size = 1` referenciando `aws_lambda_function.video_orchestrator`
- [ ] `terraform validate` passa sem erros
- [ ] `terraform plan` mostra ambos os recursos como `+ create`
- [ ] Nenhuma variável nova criada desnecessariamente (reutilizar `var.q_video_process_arn` existente)
