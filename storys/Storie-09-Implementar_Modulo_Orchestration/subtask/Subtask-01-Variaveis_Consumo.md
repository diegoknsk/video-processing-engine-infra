# Subtask 01: Variáveis do módulo e consumo de ARNs (Processor, Finalizer, queue)

## Descrição
Criar o arquivo `terraform/70-orchestration/variables.tf` com as variáveis necessárias para o módulo: prefix, common_tags, enable_stepfunctions, log_retention_days, finalization_mode ("sqs" | "lambda"), lambda_processor_arn, lambda_finalizer_arn e q_video_zip_finalize_arn (ou URL) para consumo dos módulos 50-lambdas-shell e 30-messaging. Garantir que o módulo receba os ARNs/URLs por variáveis de entrada (caller/root passa os valores).

## Passos de implementação
1. Criar `terraform/70-orchestration/variables.tf` com variáveis obrigatórias ou com default: prefix, common_tags (do foundation).
2. Declarar variáveis de controle: enable_stepfunctions (bool, default = true), log_retention_days (number, default ex.: 14), finalization_mode (string, default = "sqs", description: "sqs = enviar para q-video-zip-finalize; lambda = invocar LambdaVideoFinalizer").
3. Declarar variáveis de integração: lambda_processor_arn (string, ARN da Lambda Video Processor), lambda_finalizer_arn (string, ARN da Lambda Video Finalizer), q_video_zip_finalize_arn (string, ARN da fila q-video-zip-finalize; obrigatório quando finalization_mode = "sqs"). Incluir description indicando origem (outputs de lambdas-shell e messaging).
4. Garantir que nenhuma variável dependa de path absoluto ou módulo interno; consumo apenas via variáveis de entrada do caller.
5. Documentar em comment ou README que o caller deve passar lambda_processor_arn, lambda_finalizer_arn e, quando finalization_mode = "sqs", q_video_zip_finalize_arn.

## Formas de teste
1. Executar `terraform validate` em `terraform/70-orchestration/` após criar variables.tf; validar que não há erro de variável não declarada em outros arquivos que referenciem var.lambda_processor_arn, etc.
2. Verificar que finalization_mode aceita "sqs" e "lambda" e que enable_stepfunctions é bool.
3. Listar variáveis documentadas na story (enable_stepfunctions, log_retention_days, finalization_mode, lambda_processor_arn, lambda_finalizer_arn, q_video_zip_finalize_arn) e confirmar que estão declaradas em variables.tf.

## Critérios de aceite da subtask
- [ ] O arquivo `terraform/70-orchestration/variables.tf` existe e declara prefix, common_tags, enable_stepfunctions, log_retention_days, finalization_mode, lambda_processor_arn, lambda_finalizer_arn, q_video_zip_finalize_arn.
- [ ] finalization_mode tem default "sqs"; enable_stepfunctions tem default true; nenhuma referência quebrada ao caller; terraform validate passa.
