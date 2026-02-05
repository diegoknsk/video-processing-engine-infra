# Subtask 05: Documentação do pattern PK/SK e validação (terraform plan)

## Descrição
Documentar no README do módulo `terraform/20-data` (ou em docs) o pattern de PK/SK e como a tabela principal e o GSI atendem às consultas por usuário e por VideoId. Garantir que terraform init, terraform validate e terraform plan executem sem referências quebradas.

## Passos de implementação
1. Criar ou atualizar `terraform/20-data/README.md` com seção "Modelo de dados e acessos" descrevendo: (a) Tabela principal: PK = UserId, SK = VideoId; Query(PK=UserId) → listar vídeos do usuário; GetItem(PK=UserId, SK=VideoId) → obter um vídeo. (b) GSI1: GSI1PK = VideoId, GSI1SK = UserId (ou CreatedAt); Query(GSI1PK=VideoId) → buscar registro por VideoId (para atualização de status, ZipS3Key, ErrorMessage). Incluir tabela resumo dos acessos (opcional).
2. Documentar variáveis do módulo (prefix, common_tags, enable_ttl, ttl_attribute_name, billing_mode) e outputs (table_name, table_arn, gsi_names); decisão "somente DynamoDB, sem IAM".
3. Executar `terraform init` (com -backend=false se aplicável) e `terraform fmt -recursive` em `terraform/20-data/`; executar `terraform validate` e corrigir até "Success! The configuration is valid."
4. Executar `terraform plan` passando prefix e common_tags (via -var ou tfvars) e verificar que não há erro de referência quebrada (variáveis obrigatórias fornecidas, recursos referenciados existem).
5. Documentar como o caller deve passar prefix e common_tags (ex.: do output do módulo 00-foundation).

## Formas de teste
1. Ler o README e confirmar que o pattern PK/SK está explicado e que consulta por usuário (tabela principal) e por VideoId (GSI1) estão documentadas.
2. Rodar `terraform validate` em terraform/20-data/ e confirmar "Success! The configuration is valid."
3. Rodar `terraform plan -var="prefix=video-processing-engine-dev" -var='common_tags={}'` (ou tfvars) e verificar que o plano mostra a tabela DynamoDB, GSI e outputs sem erros.

## Critérios de aceite da subtask
- [ ] README (ou documentação na story) explica o pattern de PK/SK e como atende consulta por usuário (Query PK=UserId) e por VideoId (Query GSI1PK=VideoId).
- [ ] terraform init, terraform validate e terraform plan no módulo 20-data executam sem referências quebradas.
- [ ] Variáveis e outputs do módulo documentados; decisão "somente DynamoDB, sem IAM" registrada.
