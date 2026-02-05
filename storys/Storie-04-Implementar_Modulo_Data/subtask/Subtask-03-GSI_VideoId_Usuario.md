# Subtask 03: GSI1 (GSI1PK/GSI1SK) para consulta por VideoId e listagem por usuário

## Descrição
Adicionar um GSI à tabela DynamoDB com partition key GSI1PK e sort key GSI1SK, de forma que: (1) a tabela principal permita consulta por usuário (PK=UserId, SK=VideoId) e (2) o GSI permita buscar por VideoId (GSI1PK=VideoId, GSI1SK=UserId ou CreatedAt). Declarar os atributos GSI1PK e GSI1SK no recurso da tabela e configurar o bloco global_secondary_index.

## Passos de implementação
1. No recurso aws_dynamodb_table, declarar attribute { name = "GSI1PK", type = "S" } e attribute { name = "GSI1SK", type = "S" } (ou type = "N" se GSI1SK for CreatedAt numérico); garantir que todos os atributos usados em chaves estejam declarados.
2. Adicionar bloco global_secondary_index com name (ex.: "GSI1" ou "ByVideoId"), hash_key = "GSI1PK", range_key = "GSI1SK", projection_type = "ALL" (ou KEYS_ONLY/INCLUDE conforme decisão).
3. Documentar no código ou README: tabela principal → Query(PK=UserId) lista vídeos do usuário; GetItem(PK=UserId, SK=VideoId) obtém um vídeo; GSI1 → Query(GSI1PK=VideoId) obtém registro por VideoId para atualização de status/ZipS3Key/ErrorMessage.
4. Garantir que read_capacity e write_capacity do GSI não sejam obrigatórios quando billing_mode = PAY_PER_REQUEST (DynamoDB aplica pay-per-request ao GSI automaticamente nesse caso).

## Formas de teste
1. Executar `terraform plan` em `terraform/20-data/` e verificar que o plano inclui um global_secondary_index com GSI1PK e GSI1SK; sem erro de atributo faltando.
2. Verificar na documentação AWS que GSI com billing_mode PAY_PER_REQUEST não exige capacity; validar que o recurso não declara read/write capacity no GSI quando billing_mode é PAY_PER_REQUEST.
3. Ler README ou comentários e confirmar que o pattern PK/SK e GSI está descrito (consulta por usuário e por VideoId).

## Critérios de aceite da subtask
- [ ] A tabela DynamoDB possui 1 GSI com hash_key GSI1PK e range_key GSI1SK; atributos GSI1PK e GSI1SK declarados.
- [ ] O GSI permite consulta por VideoId (GSI1PK=VideoId) e a tabela principal permite consulta por usuário (PK=UserId, SK=VideoId).
- [ ] terraform validate e plan passam; documentação do pattern de acesso (tabela principal + GSI) presente no código ou README.
