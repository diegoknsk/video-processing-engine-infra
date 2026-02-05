# Subtask 02: Filas principais e DLQs (q-video-process, q-video-status-update, q-video-zip-finalize)

## Descrição
Criar os seis recursos `aws_sqs_queue` no módulo `terraform/30-messaging`: três filas principais (q-video-process, q-video-status-update, q-video-zip-finalize) e três DLQs (dlq-video-process, dlq-video-status-update, dlq-video-zip-finalize), com nomes derivados do prefix, tags e parâmetros de visibility_timeout e message_retention via variáveis. Redrive policy será adicionada na Subtask 03; nesta subtask apenas as filas e DLQs.

## Passos de implementação
1. Criar arquivo `terraform/30-messaging/sqs.tf` (ou adicionar ao main.tf) com três recursos `aws_sqs_queue` para as **DLQs** primeiro (para referência na redrive_policy depois): dlq-video-process, dlq-video-status-update, dlq-video-zip-finalize; name = "${var.prefix}-dlq-video-process" (e equivalentes), tags = var.common_tags, message_retention_seconds = var.dlq_message_retention_seconds (ou default 1209600).
2. Criar três recursos `aws_sqs_queue` para as **filas principais**: q-video-process, q-video-status-update, q-video-zip-finalize; name = "${var.prefix}-q-video-process" (e equivalentes), tags = var.common_tags, visibility_timeout_seconds = var.visibility_timeout_seconds, message_retention_seconds = var.message_retention_seconds.
3. Garantir que não haja recurso aws_lambda_*, event_source_mapping nem aws_sns_topic_subscription (SNS→SQS) nesta story; apenas aws_sqs_queue.
4. Verificar que providers.tf ou configuração do módulo exista (provider AWS); consumo de prefix e common_tags via variáveis.

## Formas de teste
1. Executar `terraform plan` em `terraform/30-messaging/` passando prefix, common_tags e variáveis SQS e verificar que o plano lista criação das 6 filas (3 principais + 3 DLQs); sem Lambda nem event mapping.
2. Buscar em `terraform/30-messaging/*.tf` por "aws_lambda" e "event_source_mapping" e confirmar que não há recursos Lambda/event mapping no escopo desta story.
3. Confirmar que nomes das filas usam var.prefix e que visibility_timeout_seconds e message_retention_seconds vêm de variáveis.

## Critérios de aceite da subtask
- [ ] Existem seis recursos aws_sqs_queue: três filas principais (q-video-process, q-video-status-update, q-video-zip-finalize) e três DLQs (dlq-video-process, dlq-video-status-update, dlq-video-zip-finalize), com nomes usando var.prefix e tags = var.common_tags.
- [ ] Filas principais usam visibility_timeout_seconds e message_retention_seconds de variáveis; DLQs usam message_retention_seconds (var.dlq_message_retention_seconds ou default).
- [ ] Nenhuma Lambda nem event mapping criada; terraform validate e plan (com variáveis) passam.
