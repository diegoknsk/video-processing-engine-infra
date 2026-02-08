# Subtask 05: Outputs (state machine ARN, log group name) e documentação do payload

## Descrição
Criar ou atualizar `terraform/70-orchestration/outputs.tf` expondo o ARN da State Machine e o nome (ou ARN) do log group da SFN. Documentar no README do módulo o **payload padrão de entrada e saída** da State Machine (videoId, userId, s3Bucket, s3VideoKey na entrada; videoId, userId, status, imagesPrefix, zipS3Key na saída), conforme definido na story, para que a aplicação (Orchestrator, Processor, Finalizer) respeite o contrato.

## Passos de implementação
1. Criar `terraform/70-orchestration/outputs.tf` com outputs: state_machine_arn (value = aws_sfn_state_machine.video_processing[0].arn quando count > 0; ou value = try(aws_sfn_state_machine.video_processing[0].arn, "") para evitar erro quando enable_stepfunctions = false), log_group_name (value = aws_cloudwatch_log_group.sfn[0].name ou equivalente). Garantir que os outputs referenciem apenas recursos existentes e tratem count = 0 (enable_stepfunctions = false) para não quebrar o plano.
2. Criar ou atualizar `terraform/70-orchestration/README.md` com seção "Payload padrão (entrada/saída)": **Entrada:** videoId, userId, s3Bucket, s3VideoKey, requestId (opcional) — o que a Lambda Video Orchestrator deve enviar ao StartExecution. **Saída:** videoId, userId, status, imagesPrefix (opcional), zipS3Key (opcional) — contrato ao concluir com sucesso; em finalization_mode = "sqs" a saída da execução pode não incluir zipS3Key (Finalizer preenche depois). Incluir exemplo em JSON se útil.
3. Incluir referência ao desenho (contexto arquitetural) e à decisão de finalização (finalization_mode = "sqs" | "lambda"); evolução para Map State (estrutura preparada).
4. Verificar que nenhum output referencia recurso inexistente quando enable_stepfunctions = false; usar try() ou count para evitar erro.

## Formas de teste
1. Executar `terraform plan` com enable_stepfunctions = true e verificar que os outputs state_machine_arn e log_group_name aparecem no plano sem erro.
2. Executar `terraform plan` com enable_stepfunctions = false e verificar que os outputs não quebram (retornam string vazia ou o recurso não existe e o output usa try/count).
3. Ler o README e confirmar que o payload de entrada e saída está documentado conforme a story (videoId, userId, s3Bucket, s3VideoKey; status, imagesPrefix, zipS3Key).

## Critérios de aceite da subtask
- [ ] outputs.tf expõe state_machine_arn e log_group_name; quando enable_stepfunctions = false, outputs não quebram (try/count ou condicional).
- [ ] README documenta o payload padrão de entrada (videoId, userId, s3Bucket, s3VideoKey, requestId opcional) e saída (videoId, userId, status, imagesPrefix, zipS3Key opcional) conforme story.
- [ ] Referência ao desenho e a finalization_mode; documentação suficiente para a aplicação respeitar o contrato; terraform plan passa.
