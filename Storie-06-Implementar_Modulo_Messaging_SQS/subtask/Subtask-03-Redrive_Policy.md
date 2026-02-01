# Subtask 03: Redrive policy em todas as filas principais

## Descrição
Configurar redrive_policy em cada uma das três filas principais (q-video-process, q-video-status-update, q-video-zip-finalize), apontando para a DLQ correspondente e usando max_receive_count da variável var.max_receive_count. Assim, após N falhas de processamento, a mensagem é enviada à DLQ (caixa de falhas); nenhuma fila principal deve ficar sem redrive policy.

## Passos de implementação
1. Em cada recurso aws_sqs_queue das **filas principais** (q-video-process, q-video-status-update, q-video-zip-finalize), adicionar bloco `redrive_policy` com: dead_letter_queue_arn = aws_sqs_queue.dlq_xxx.arn, max_receive_count = var.max_receive_count. Referenciar a DLQ correta para cada fila (dlq-video-process para q-video-process, etc.).
2. Garantir que as DLQs sejam criadas antes das filas principais no código (ou usar referência implícita; Terraform resolve dependências). Não configurar redrive_policy nas DLQs (são destino final).
3. Documentar em comentário no código ou README: "Redrive policy garante que mensagens com falha repetida vão para a DLQ (caixa de falhas), evitando perda e permitindo inspeção/retry."
4. Verificar na documentação AWS que redrive_policy exige que a DLQ exista e que a fila principal tenha permissão (policy) para enviar à DLQ; o provider Terraform aws_sqs_queue com redrive_policy geralmente lida com isso; se necessário, policy na DLQ para permitir receive da fila principal (conforme provider).

## Formas de teste
1. Executar `terraform plan` em `terraform/30-messaging/` e verificar que cada fila principal (q-video-process, q-video-status-update, q-video-zip-finalize) possui redrive_policy com dead_letter_queue_arn da DLQ correspondente e max_receive_count = var.max_receive_count.
2. Verificar que as três DLQs não possuem redrive_policy (ou que não referenciam outra fila).
3. Confirmar que max_receive_count é referenciado de var.max_receive_count e não hardcoded.

## Critérios de aceite da subtask
- [ ] As três filas principais possuem redrive_policy configurada, com dead_letter_queue_arn apontando para a DLQ correspondente (dlq-video-process, dlq-video-status-update, dlq-video-zip-finalize).
- [ ] max_receive_count é definido por variável (var.max_receive_count); nenhum valor fixo para max_receive_count.
- [ ] DLQs não possuem redrive_policy; terraform validate e plan passam.
