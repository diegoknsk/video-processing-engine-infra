# Subtask 04: README – ordem recomendada, variáveis importantes, outputs/contratos

## Descrição
Completar o README.md com: (1) **Ordem recomendada** de execução: 1) provisionar infra (apply deste repo), 2) deploy dos repositórios de Lambdas (fora deste repo), 3) smoke tests; documentar que este repo não faz deploy de código das Lambdas. (2) **Variáveis importantes:** enable_stepfunctions, enable_authorizer, log_retention_days/retention_days, trigger_mode, finalization_mode; onde são usadas e impacto. (3) **Outputs/contratos consumidos pelos outros repos:** tabela ou lista com Lambdas (ARNs, nomes, role ARNs), API URL, Cognito (user_pool_id, client_id, issuer, jwks_url), DynamoDB (table_name, table_arn), S3 (buckets), SQS (queue URLs/ARNs), SNS (topic ARNs), Step Functions (state_machine_arn); para cada um: módulo origem e quem consome.

## Passos de implementação
1. Adicionar ao README seção **"Ordem recomendada"**: (1) Provisionar infra: executar terraform apply neste repositório (local ou GitHub Actions) para criar todos os recursos AWS. (2) Deploy dos repositórios de Lambdas: cada Lambda tem seu próprio repo (video-processing-engine-auth-lambda, etc.); fazer deploy do código das Lambdas nesses repos (fora deste repo de infra). (3) Smoke tests: validar que a API responde, que o fluxo de upload e processamento funciona. Deixar explícito que este repo cria apenas a "casca" das Lambdas e a infra; não faz deploy de código de aplicação.
2. Adicionar seção **"Variáveis importantes"**: tabela ou lista com enable_stepfunctions (70-orchestration; habilita/desabilita Step Functions), enable_authorizer (60-api; habilita JWT authorizer Cognito), log_retention_days/retention_days (foundation, observability, orchestration; retenção de logs), trigger_mode (10-storage, 30-messaging; s3_event vs api_publish), finalization_mode (70-orchestration; sqs vs lambda); descrição breve e impacto.
3. Adicionar seção **"Outputs e contratos para outros repositórios"**: tabela com colunas Consumidor, Output/Contrato, Módulo origem. Linhas: Lambdas (ARNs, role ARNs, nomes) ← 50-lambdas-shell; Frontend/API client (API invoke URL) ← 60-api; Auth/Login (user_pool_id, client_id, issuer, jwks_url) ← 40-auth; Lambdas DynamoDB (table_name, table_arn) ← 20-data; Lambdas S3 (bucket names/ARNs videos, images, zip) ← 10-storage; Lambdas SQS (queue URLs/ARNs) ← 30-messaging; Lambdas SNS (topic ARNs) ← 30-messaging; Orchestrator Lambda (state_machine_arn) ← 70-orchestration. Garantir que os repos de aplicação saibam o que consumir.
4. Revisar consistência com os módulos existentes (nomes de outputs podem variar); ajustar tabela se necessário.

## Formas de teste
1. Ler o README e confirmar que a ordem recomendada (1 infra, 2 deploy Lambdas, 3 smoke tests) está clara e que está documentado que deploy de Lambdas é fora deste repo.
2. Verificar que as variáveis importantes listadas (enable_stepfunctions, enable_authorizer, retention_days, etc.) estão documentadas com onde são usadas e impacto.
3. Verificar que a tabela de outputs/contratos cobre Lambdas, API URL, Cognito, DynamoDB, buckets, queues, topics, SFN; módulo origem indicado; consumidor indicado.

## Critérios de aceite da subtask
- [ ] README contém ordem recomendada: 1) provisionar infra, 2) deploy dos repos de Lambdas (fora deste repo), 3) smoke tests; documento explicita que este repo não faz deploy de código das Lambdas.
- [ ] README documenta variáveis importantes (enable_stepfunctions, enable_authorizer, retention_days, trigger_mode, finalization_mode) com onde são usadas e impacto.
- [ ] README lista outputs/contratos consumidos pelos outros repos (Lambdas, API URL, Cognito, DynamoDB, buckets, queues, topics, SFN) com módulo origem e consumidor.
