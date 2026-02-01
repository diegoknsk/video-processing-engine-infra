# Subtask 03: Recursos Lambda (casca) com runtime, handler, empty.zip e env vars

## Descrição
Criar os 5 recursos aws_lambda_function no módulo `terraform/50-lambdas-shell`: LambdaAuth, LambdaVideoManagement, LambdaVideoOrchestrator, LambdaVideoProcessor, LambdaVideoFinalizer. Cada uma com runtime = var.runtime (parametrizável, default seguro), handler = var.handler (placeholder), filename = var.artifact_path (artifacts/empty.zip), role = aws_iam_role.xxx.arn; variáveis de ambiente por Lambda conforme tabela da story (TABLE_NAME, buckets, queue URLs, topic ARNs, step_function_arn). Não implementar lógica de aplicação; apenas a casca para deploy posterior do código pelos repositórios de aplicação.

## Passos de implementação
1. Criar arquivo `terraform/50-lambdas-shell/lambdas.tf` (ou um arquivo por Lambda) com 5 recursos aws_lambda_function: function_name = "${var.prefix}-auth" (e equivalentes para management, orchestrator, processor, finalizer), runtime = var.runtime, handler = var.handler, filename = var.artifact_path (ou file(var.artifact_path)), role = aws_iam_role.lambda_xxx.arn.
2. Para cada Lambda, adicionar bloco environment { variables = { ... } } com as variáveis de ambiente necessárias: LambdaAuth (ex.: LOG_LEVEL); VideoManagement (TABLE_NAME, VIDEOS_BUCKET, TOPIC_VIDEO_SUBMITTED_ARN, QUEUE_STATUS_UPDATE_URL se consumer); Orchestrator (QUEUE_VIDEO_PROCESS_URL, STEP_FUNCTION_ARN); Processor (TABLE_NAME, VIDEOS_BUCKET, IMAGES_BUCKET, QUEUE_STATUS_UPDATE_URL, QUEUE_ZIP_FINALIZE_URL); Finalizer (TABLE_NAME, IMAGES_BUCKET, ZIP_BUCKET, TOPIC_VIDEO_COMPLETED_ARN). Valores vindos de var.* (table_name, videos_bucket_name, etc.).
3. Garantir que artifact_path aponte para artifacts/empty.zip (path relativo ao contexto de execução do Terraform ou absoluto via var); o arquivo deve existir (Storie-01).
4. Não incluir segredos em texto plano nas variáveis de ambiente; usar referência a Secret Manager ou variável de pipeline em story futura se necessário.

## Formas de teste
1. Executar `terraform plan` em 50-lambdas-shell com variáveis preenchidas (incluindo artifact_path = "artifacts/empty.zip") e verificar que o plano lista criação das 5 Lambdas com runtime, handler e environment preenchidos.
2. Verificar que cada Lambda referencia a role IAM correta (criada na Subtask 02) e que as env vars estão alinhadas à tabela da story.
3. Confirmar que nenhuma Lambda usa código inline (filename aponta para zip); artifact_path tem default seguro.

## Critérios de aceite da subtask
- [ ] Existem 5 recursos aws_lambda_function (Auth, VideoManagement, VideoOrchestrator, VideoProcessor, VideoFinalizer) com runtime = var.runtime, handler = var.handler, filename = var.artifact_path (empty.zip), role = role correspondente.
- [ ] Variáveis de ambiente por Lambda incluem table, buckets, queue urls, topic arns e stepfunction arn conforme tabela da story; valores de var.*.
- [ ] Nenhum segredo em texto plano nas env vars; terraform validate e plan (com artifact_path válido) passam.
