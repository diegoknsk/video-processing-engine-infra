# Subtask 01: Variáveis do módulo e consumo de outputs (table, buckets, queues, topics, stepfunction)

## Descrição
Criar o arquivo `terraform/50-lambdas-shell/variables.tf` com as variáveis necessárias para o módulo: prefix, common_tags, runtime (parametrizável, default seguro), handler (placeholder), artifact_path (default artifacts/empty.zip), e variáveis para injeção nos recursos e env vars: table_name/table_arn, nomes ou ARNs dos buckets (videos, images, zip), URLs ou ARNs das filas (q-video-process, q-video-status-update, q-video-zip-finalize), ARNs dos tópicos (topic-video-submitted, topic-video-completed), step_function_arn (ou placeholder). Garantir que o módulo consuma os outputs dos módulos storage, data e messaging via variáveis de entrada (caller/root passa os valores).

## Passos de implementação
1. Criar `terraform/50-lambdas-shell/variables.tf` com variáveis obrigatórias ou com default: prefix, common_tags (do foundation).
2. Declarar variáveis de Lambda: runtime (string, default ex.: "python3.12"), handler (string, default "index.handler"), artifact_path (string, default "artifacts/empty.zip" ou path relativo ao root).
3. Declarar variáveis de integração: table_name (DynamoDB), videos_bucket_name/arn, images_bucket_name/arn, zip_bucket_name/arn, q_video_process_url, q_video_status_update_url, q_video_zip_finalize_url, topic_video_submitted_arn, topic_video_completed_arn, step_function_arn (opcional/placeholder); incluir description indicando origem (outputs de storage, data, messaging, orchestration).
4. Declarar variável opcional enable_status_update_consumer (bool, default = true) para decidir se LambdaVideoManagement é mapeada a q-video-status-update.
5. Garantir que nenhuma variável dependa de path absoluto ou módulo interno; consumo apenas via variáveis de entrada do caller.

## Formas de teste
1. Executar `terraform validate` em `terraform/50-lambdas-shell/` após criar variables.tf; validar que não há erro de variável não declarada em outros arquivos que referenciem var.table_name, etc.
2. Verificar que artifact_path tem default que aponta para artifacts/empty.zip (ou equivalente) e que runtime/handler têm default seguro.
3. Listar variáveis documentadas na story (table, buckets, queues, topics, stepfunction) e confirmar que estão declaradas em variables.tf.

## Critérios de aceite da subtask
- [ ] O arquivo `terraform/50-lambdas-shell/variables.tf` existe e declara prefix, common_tags, runtime (default seguro), handler (placeholder), artifact_path (default artifacts/empty.zip).
- [ ] Variáveis de integração (table, buckets, queues, topics, step_function_arn) estão declaradas para consumo dos módulos storage, data, messaging e orchestration; enable_status_update_consumer opcional declarada.
- [ ] Nenhuma referência quebrada ao caller; terraform validate passa.
