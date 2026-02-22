# Subtask-05: Migrar Event Source Mapping q-video-process para LambdaVideoDispatcher

## Descrição
Remover do arquivo `terraform/50-lambdas-shell/event_source_mapping.tf` os recursos que mapeiam `q-video-process` para a Lambda atual (conforme estado deployado — pode ser `LambdaVideoOrchestrator` no código ou `LambdaVideoManagement` no estado deployado), e criar o novo mapeamento `q-video-process → LambdaVideoDispatcher` com `aws_lambda_permission` e `aws_lambda_event_source_mapping`.

> **Atenção:** A remoção e criação devem ocorrer no **mesmo `terraform apply`** para minimizar a janela sem consumer na fila.

---

## Passos de Implementação

1. **Identificar os recursos atuais de mapeamento para `q-video-process` em `event_source_mapping.tf`**

   Ler `terraform/50-lambdas-shell/event_source_mapping.tf`. Os recursos a remover são:
   - `aws_lambda_permission.sqs_invoke_orchestrator` (statement_id = "AllowExecutionFromSQS", source_arn = q_video_process_arn)
   - `aws_lambda_event_source_mapping.orchestrator_q_video_process` (event_source_arn = q_video_process_arn, function = video_orchestrator)

   > **Nota:** Se o estado deployado divergir do código e o mapeamento apontar para `video_management`, os recursos a remover serão os equivalentes para `video_management`. Em qualquer caso, **o critério é:** nenhum mapeamento ativo de `q-video-process` deve existir exceto o novo para `video_dispatcher`.

2. **Remover os blocos dos recursos identificados**

   Deletar completamente de `event_source_mapping.tf`:
   - O bloco `resource "aws_lambda_permission" "sqs_invoke_orchestrator"` (ou `sqs_invoke_video_management` se for esse o estado)
   - O bloco `resource "aws_lambda_event_source_mapping" "orchestrator_q_video_process"` (ou equivalente)

   Manter intactos os mapeamentos de `q-video-zip-finalize` e `q-video-status-update` — eles não são alterados por esta story.

3. **Criar `aws_lambda_permission` para a nova Lambda**

   Adicionar ao final de `event_source_mapping.tf`:

   ```hcl
   # --- q-video-process → LambdaVideoDispatcher ---
   resource "aws_lambda_permission" "sqs_invoke_video_dispatcher" {
     statement_id  = "AllowExecutionFromSQS"
     action        = "lambda:InvokeFunction"
     function_name = aws_lambda_function.video_dispatcher.function_name
     principal     = "sqs.amazonaws.com"
     source_arn    = var.q_video_process_arn
   }
   ```

4. **Criar `aws_lambda_event_source_mapping` para a nova Lambda**

   ```hcl
   resource "aws_lambda_event_source_mapping" "video_dispatcher_q_video_process" {
     event_source_arn = var.q_video_process_arn
     function_name    = aws_lambda_function.video_dispatcher.function_name
     batch_size       = 1
   }
   ```

   - `batch_size = 1`: Consistente com os demais mapeamentos do projeto; processa uma mensagem por invocação.
   - `event_source_arn`: Usa `var.q_video_process_arn` — variável já existente no módulo.

5. **Verificar que `aws_lambda_function.video_dispatcher` já existe**

   O recurso `aws_lambda_function.video_dispatcher` deve ter sido criado na Subtask-04. O `event_source_mapping.tf` referencia `aws_lambda_function.video_dispatcher.function_name` — confirmar que a referência é válida.

---

## Formas de Teste

1. **`terraform plan` (antes do apply):**
   - Deve mostrar como `# will be destroyed`: `aws_lambda_permission.sqs_invoke_orchestrator` e `aws_lambda_event_source_mapping.orchestrator_q_video_process`.
   - Deve mostrar como `+ will be created`: `aws_lambda_permission.sqs_invoke_video_dispatcher` e `aws_lambda_event_source_mapping.video_dispatcher_q_video_process`.
   - Confirmar que `aws_lambda_event_source_mapping.finalizer_q_video_zip_finalize` e `aws_lambda_event_source_mapping.video_management_q_video_status_update` **não** aparecem como alterados.

2. **`terraform apply` + invocação da fila:**
   - Após o apply, fazer upload de teste em `videos/<userId>/<videoId>/original`.
   - Aguardar a mensagem chegar em `q-video-process` (Subtask-02).
   - Verificar no CloudWatch Logs o grupo `/aws/lambda/<prefix>-video-dispatcher` — deve aparecer um log de invocação.
   - A Lambda casca falhará (código placeholder = `empty.zip`), mas o **log de invocação** confirmará que o trigger funcionou.

3. **Confirmar que `LambdaVideoManagement` NÃO é mais invocada por esta fila:**
   - Verificar no CloudWatch Logs de `/aws/lambda/<prefix>-video-management` — não deve aparecer invocação oriunda de `q-video-process` após o apply.

4. **Verificar no console AWS Lambda → Event source mappings:**
   - `<prefix>-video-dispatcher` deve ter um event source mapping para `q-video-process` com status `Enabled`.
   - `<prefix>-video-orchestrator` (ou `video-management`) **não** deve ter event source mapping para `q-video-process`.

---

## Critérios de Aceite

- [ ] Recursos `aws_lambda_permission.sqs_invoke_orchestrator` e `aws_lambda_event_source_mapping.orchestrator_q_video_process` removidos de `event_source_mapping.tf`
- [ ] Recursos `aws_lambda_permission.sqs_invoke_video_dispatcher` e `aws_lambda_event_source_mapping.video_dispatcher_q_video_process` adicionados
- [ ] `terraform plan` mostra a remoção dos recursos antigos e criação dos novos em um mesmo apply
- [ ] Mapeamentos de `q-video-zip-finalize` e `q-video-status-update` não são alterados
- [ ] Após `terraform apply`, a Lambda `LambdaVideoDispatcher` aparece como consumer ativo de `q-video-process` no console AWS
- [ ] Logs do grupo `/aws/lambda/<prefix>-video-dispatcher` mostram invocação após mensagem na fila
- [ ] `LambdaVideoManagement` **não** tem event source mapping ativo para `q-video-process` (confirmado no console)
