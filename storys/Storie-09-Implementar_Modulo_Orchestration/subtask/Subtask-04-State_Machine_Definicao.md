# Subtask 04: State Machine inicial simples e estrutura para Map State

## Descrição
Criar o recurso aws_sfn_state_machine no módulo `terraform/70-orchestration` com definição inicial **simples e sequencial**: Start → Invoke LambdaVideoProcessor → Finalização (estado que envia mensagem para q-video-zip-finalize quando finalization_mode = "sqs" ou invoca LambdaVideoFinalizer quando finalization_mode = "lambda") → End. A estrutura da definição deve estar **preparada para evolução para Map State** (fan-out): estados nomeados, pass-through de payload (input/output), de forma que em story futura seja possível inserir um Map State sem quebrar o contrato de entrada/saída. A State Machine deve ser criada apenas quando enable_stepfunctions = true e deve usar o log group e a role IAM criados nas subtasks anteriores.

## Passos de implementação
1. Criar arquivo `terraform/70-orchestration/stepfunctions.tf` (ou main.tf) com recurso aws_sfn_state_machine: name = "${var.prefix}-video-processing" (ou equivalente), role_arn = aws_iam_role.sfn.arn, definition (JSON ou templatefile) com fluxo: Start → Process (Task: Invoke LambdaVideoProcessor, passando input) → Finalize (Task: SQS SendMessage ou Lambda Invoke conforme finalization_mode) → End. Condicionar a state machine a var.enable_stepfunctions (count = var.enable_stepfunctions ? 1 : 0).
2. Na definição, usar estados nomeados (ex.: "Process", "Finalize") e pass-through de payload: o input da execução (videoId, userId, s3Bucket, s3VideoKey) deve ser repassado ao Processor; o output do Processor pode ser repassado ao estado Finalize. A estrutura deve permitir futura inserção de um Map State (ex.: estado "Process" que itera sobre uma lista ou que chama um subfluxo Map).
3. Configurar logging_configuration do aws_sfn_state_machine: log_destination = aws_cloudwatch_log_group.sfn.arn (ou equivalente), include_execution_data opcional, level opcional.
4. Garantir que a definição seja válida em JSON (ou HCL) e que os ARNs (Processor, Finalizer, queue) venham de variáveis (var.lambda_processor_arn, var.lambda_finalizer_arn, var.q_video_zip_finalize_arn). Para finalization_mode, usar definição condicional (duas definições ou templatefile com variável) para escolher entre estado SQS SendMessage e estado Lambda Invoke.
5. Documentar no README: "State Machine inicial simples (1 processor); estrutura preparada para Map State (fan-out) em evolução futura; payload de entrada/saída conforme story."

## Formas de teste
1. Executar `terraform plan` com enable_stepfunctions = true, finalization_mode = "sqs" e variáveis de ARNs preenchidas; verificar que o plano inclui aws_sfn_state_machine com definição que contém estado de invocação do Processor e estado de envio para SQS (q-video-zip-finalize).
2. Executar `terraform plan` com finalization_mode = "lambda"; verificar que a definição contém estado de invocação do Processor e estado de invocação da Lambda Finalizer (não SQS).
3. Validar que a definição JSON/HCL é sintaticamente válida e que os estados têm nomes que permitem evolução (Process, Finalize); referências a payload ($$.StateMachine, $.videoId, etc.) alinhadas ao payload padrão da story.

## Critérios de aceite da subtask
- [ ] Existe aws_sfn_state_machine com definição inicial simples: sequencial, 1 processor (Invoke LambdaVideoProcessor), depois finalização (SQS ou Lambda conforme finalization_mode), depois End.
- [ ] Estrutura preparada para Map State: estados nomeados, pass-through de payload; documentado que evolução futura pode inserir Map State sem quebrar contrato.
- [ ] State machine criada apenas quando enable_stepfunctions = true; usa log group e role IAM do módulo; logging_configuration configurado; terraform validate e plan passam.
