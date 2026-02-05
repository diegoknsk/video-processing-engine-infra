# Subtask 04: Event source mappings (Orchestrator, Finalizer, status-update)

## Descrição
Implementar os event source mappings alinhados ao desenho: (1) LambdaVideoOrchestrator acionada pela fila SQS q-video-process; (2) LambdaVideoFinalizer acionada pela fila SQS q-video-zip-finalize; (3) estratégia para q-video-status-update: preferir mapear LambdaVideoManagement como consumer (enable_status_update_consumer = true) ou documentar consumo futuro (false). Criar aws_lambda_event_source_mapping e, quando necessário, aws_lambda_permission para permitir que SQS invoque a Lambda.

## Passos de implementação
1. Criar arquivo `terraform/50-lambdas-shell/event_source_mapping.tf` com recurso aws_lambda_event_source_mapping para Orchestrator: event_source_arn = var.q_video_process_arn (ou equivalente da fila q-video-process), function_name = aws_lambda_function.orchestrator.function_name, batch_size opcional (ex.: 1 ou 10).
2. Adicionar aws_lambda_event_source_mapping para Finalizer: event_source_arn = var.q_video_zip_finalize_arn, function_name = aws_lambda_function.finalizer.function_name.
3. Adicionar aws_lambda_event_source_mapping para VideoManagement → q-video-status-update condicionado a var.enable_status_update_consumer: quando true, criar mapping event_source_arn = var.q_video_status_update_arn, function_name = aws_lambda_function.video_management.function_name; quando false, não criar (documentar no README que a fila será consumida depois).
4. Garantir que a fila SQS possa invocar a Lambda: criar aws_lambda_permission para cada mapping (principal = sqs.amazonaws.com, source_arn = queue_arn) ou verificar que o provider Terraform cria a permissão ao criar event_source_mapping (conforme documentação AWS/Terraform). Se necessário, policy na fila SQS permitindo Lambda; normalmente o event source mapping cria a permissão na Lambda.
5. Documentar no README: Orchestrator ← q-video-process; Finalizer ← q-video-zip-finalize; VideoManagement ← q-video-status-update (se enable_status_update_consumer) ou "consumo futuro".

## Formas de teste
1. Executar `terraform plan` com enable_status_update_consumer = true e variáveis de filas preenchidas; verificar que o plano inclui 3 event source mappings (Orchestrator, Finalizer, VideoManagement).
2. Executar `terraform plan` com enable_status_update_consumer = false; verificar que apenas 2 event source mappings (Orchestrator, Finalizer) são criados.
3. Verificar que cada event_source_mapping referencia a Lambda e a fila SQS corretas; nenhuma Lambda invocada por evento fora do desenho.

## Critérios de aceite da subtask
- [ ] Event source mapping q-video-process → LambdaVideoOrchestrator implementado; q-video-zip-finalize → LambdaVideoFinalizer implementado.
- [ ] Estratégia q-video-status-update implementada: mapeamento para LambdaVideoManagement quando enable_status_update_consumer = true; quando false, não criar mapping e documentar consumo futuro.
- [ ] Permissão para SQS invocar Lambda garantida (aws_lambda_permission ou equivalente); terraform validate e plan passam.
