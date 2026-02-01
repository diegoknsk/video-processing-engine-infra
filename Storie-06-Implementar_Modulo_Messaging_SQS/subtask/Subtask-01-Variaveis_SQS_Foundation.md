# Subtask 01: Variáveis SQS (visibility, retention, maxReceiveCount) e consumo do foundation

## Descrição
Criar ou atualizar o arquivo `terraform/30-messaging/variables.tf` com as variáveis necessárias para a parte SQS: prefix e common_tags (consumo do foundation, já podem existir da Storie-05), visibility_timeout_seconds, message_retention_seconds, max_receive_count e opcionalmente dlq_message_retention_seconds. Garantir que o módulo receba prefix e common_tags por variáveis de entrada e que os parâmetros essenciais das filas sejam configuráveis.

## Passos de implementação
1. Se o módulo 30-messaging já tiver variables.tf (Storie-05), adicionar as variáveis SQS; caso contrário, criar variables.tf com prefix e common_tags (obrigatórios) e todas as variáveis SQS.
2. Declarar variáveis: `visibility_timeout_seconds` (number, default ex.: 300), `message_retention_seconds` (number, default ex.: 345600), `max_receive_count` (number, default ex.: 3), `dlq_message_retention_seconds` (number, default ex.: 1209600 ou null); incluir description em cada uma (visibility timeout, retenção na fila principal, tentativas antes de DLQ, retenção na DLQ).
3. Garantir que o módulo não dependa de path absoluto ou module "foundation" sem que o caller forneça as variáveis; consumo apenas via variáveis de entrada.
4. Documentar em comment ou description que visibility_timeout, retention e maxReceiveCount são os parâmetros essenciais para resiliência e DLQ.

## Formas de teste
1. Executar `terraform validate` em `terraform/30-messaging/` após atualizar variables.tf; validar que não há erro de variável não declarada em arquivos que referenciem var.visibility_timeout_seconds, etc.
2. Verificar que não existe referência quebrada ao foundation; prefix e common_tags disponíveis por variável.
3. Listar variáveis documentadas na story (visibility_timeout_seconds, message_retention_seconds, max_receive_count, dlq_message_retention_seconds) e confirmar que estão declaradas em variables.tf.

## Critérios de aceite da subtask
- [ ] O arquivo `terraform/30-messaging/variables.tf` declara ou já contém prefix e common_tags; declara visibility_timeout_seconds, message_retention_seconds, max_receive_count e opcionalmente dlq_message_retention_seconds com default.
- [ ] Parâmetros essenciais (visibility, retention, maxReceiveCount) estão parametrizados; nenhuma referência quebrada ao foundation; terraform validate passa.
