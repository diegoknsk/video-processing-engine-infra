# Storie-04: Implementar Módulo Terraform 20-Data (DynamoDB Vídeos/Processamento)

## Status
- **Estado:** ✅ Concluída
- **Data de Conclusão:** 05/02/2025

## Descrição
Como desenvolvedor de infraestrutura, quero que o módulo `terraform/20-data` provisione uma tabela DynamoDB para rastrear vídeos e estado do processamento (status, datas, ZipS3Key, ErrorMessage, UserId, VideoId), com um GSI para consulta por VideoId e listagem por usuário, para suportar o fluxo do Processador Video MVP conforme contexto arquitetural, consumindo prefix/tags do foundation e sem criar IAM.

## Objetivo
Criar o módulo `terraform/20-data` com uma tabela DynamoDB contendo: chaves PK/SK; atributos Status, CreatedAt, UpdatedAt, ZipS3Key, ErrorMessage, UserId, VideoId; um GSI (GSI1PK/GSI1SK) para buscar por VideoId e listar por usuário; TTL opcional via variável. Somente DynamoDB (sem IAM). Outputs: table name, table arn, GSI names. A story documenta o pattern PK/SK e como ele atende consulta por usuário e por VideoId.

## Escopo Técnico
- Tecnologias: Terraform >= 1.0, AWS Provider (~> 5.0)
- Arquivos afetados:
  - `terraform/20-data/variables.tf`
  - `terraform/20-data/main.tf` ou `dynamodb.tf` (aws_dynamodb_table)
  - `terraform/20-data/outputs.tf`
  - `terraform/20-data/README.md` (pattern PK/SK e variáveis)
- Componentes/Recursos: aws_dynamodb_table com hash_key (PK), range_key (SK), atributos, 1 GSI (GSI1PK, GSI1SK), ttl opcional; nenhum aws_iam_*.
- Pacotes/Dependências: Nenhum; consumo de prefix/common_tags do foundation via variáveis.

## Dependências e Riscos (para estimativa)
- Dependências: Storie-02 (00-foundation) concluída; Storie-03 (10-storage) independente (não obrigatória para esta story).
- Riscos/Pré-condições: Definir schema de PK/SK e GSI de forma que aplicações (Lambdas) usem o mesmo padrão; IAM para Lambdas acessarem a tabela fica em story dedicada.

## Modelo de execução (root único)
O diretório `terraform/20-data/` é um **módulo** consumido pelo **root** em `terraform/` (Storie-02-Parte2). O root passa prefix e common_tags do module.foundation. Init/plan/apply são executados uma vez em `terraform/`; validar com `terraform plan` no root.

---

## Pattern PK/SK e Consultas

### Modelo de dados (mínimo)
- **PK (Partition Key):** identifica a partição; usado para consultas por usuário.
- **SK (Sort Key):** ordenação dentro da partição; usado para item único por vídeo.
- **Atributos:** Status, CreatedAt, UpdatedAt, ZipS3Key, ErrorMessage, UserId, VideoId.

### Escolha do pattern (documentação para implementação)
- **Tabela principal (acesso por usuário):**
  - **PK = UserId** (ex.: `USER#<userId>`)
  - **SK = VideoId** (ex.: `VIDEO#<videoId>` ou `VIDEO#<videoId>#<createdAt>` para ordenação por data)
  - **Consulta por usuário:** `Query(PK = UserId)` → lista todos os vídeos do usuário (e opcionalmente ordena por SK).
  - **Obter um vídeo do usuário:** `GetItem(PK = UserId, SK = VideoId)`.

- **GSI1 (acesso por VideoId):**
  - **GSI1PK = VideoId** (ex.: `VIDEO#<videoId>`)
  - **GSI1SK = UserId** (ex.: `USER#<userId>`) ou CreatedAt para ordenação
  - **Consulta por VideoId:** `Query(GSI1PK = VideoId)` → obtém o registro do vídeo (usado pelo processador, finalizador e API para atualizar status/ZipS3Key/ErrorMessage).
  - **Listar por usuário** já é atendido pela tabela principal (PK=UserId); o GSI permite “buscar por VideoId” sem saber o UserId.

### Resumo dos acessos
| Acesso | Onde | Chave |
|--------|------|--------|
| Listar vídeos de um usuário | Tabela principal | Query PK = UserId |
| Obter um vídeo (UserId + VideoId) | Tabela principal | GetItem PK = UserId, SK = VideoId |
| Buscar por VideoId (atualizar status, ZipS3Key, etc.) | GSI1 | Query GSI1PK = VideoId |

A aplicação (Lambdas) deve persistir UserId e VideoId nos atributos e usar PK=UserId, SK=VideoId na tabela principal; e GSI1PK=VideoId, GSI1SK=UserId no GSI, para que ambos os padrões funcionem.

---

## Variáveis do Módulo
- **prefix** (string, obrigatório): prefixo de naming do foundation (ex.: `video-processing-engine-dev`).
- **common_tags** (map, obrigatório): tags do foundation.
- **enable_ttl** (bool, opcional, default = false): habilita TTL na tabela.
- **ttl_attribute_name** (string, opcional, default = "TTL"): nome do atributo TTL (campo numérico epoch em segundos).
- **billing_mode** (string, opcional): PAY_PER_REQUEST ou PROVISIONED; default PAY_PER_REQUEST para simplicidade.
- **environment** (string, opcional): para tags/naming.

## Decisões Técnicas
- **Somente DynamoDB:** nenhum recurso IAM neste módulo; políticas de acesso à tabela na story de Lambdas/IAM.
- **Naming:** nome da tabela ex.: `{prefix}-videos` ou `{prefix}-video-processing`.
- **GSI:** um único GSI (GSI1) com projection ALL (ou KEYS_ONLY/INCLUDE conforme necessidade); nomes GSI1PK, GSI1SK documentados para consumo pelas Lambdas.
- **TTL:** opcional; quando enable_ttl = true, definir attribute ttl com nome configurável (ex.: TTL).

## Subtasks
- [x] [Subtask 01: Variáveis do módulo e consumo de prefix/tags do foundation](./subtask/Subtask-01-Variaveis_Consumo_Foundation.md)
- [x] [Subtask 02: Tabela DynamoDB com PK, SK e atributos (sem GSI ainda)](./subtask/Subtask-02-Tabela_DynamoDB_Base.md)
- [x] [Subtask 03: GSI1 (GSI1PK/GSI1SK) para consulta por VideoId e listagem por usuário](./subtask/Subtask-03-GSI_VideoId_Usuario.md)
- [x] [Subtask 04: TTL opcional e outputs (table name, arn, GSI names)](./subtask/Subtask-04-TTL_Outputs.md)
- [x] [Subtask 05: Documentação do pattern PK/SK e validação (terraform plan)](./subtask/Subtask-05-Documentacao_Validacao.md)

## Critérios de Aceite da História
- [x] O módulo `terraform/20-data` cria uma tabela DynamoDB com PK e SK; atributos Status, CreatedAt, UpdatedAt, ZipS3Key, ErrorMessage, UserId, VideoId (definidos como non-key attributes ou via application); schema de chaves PK/SK documentado
- [x] Existe 1 GSI com GSI1PK e GSI1SK que permite buscar por VideoId e suporta listagem por usuário (tabela principal com PK=UserId, SK=VideoId; GSI com GSI1PK=VideoId)
- [x] TTL é opcional e ativável por variável (ex.: enable_ttl); nome do atributo TTL configurável
- [x] Somente DynamoDB no módulo (nenhum recurso IAM)
- [x] Outputs: table name, table arn, GSI names (ex.: gsi1_name ou lista de nomes de GSI)
- [x] A story explica o pattern de PK/SK e como atende consulta por usuário (Query PK=UserId) e por VideoId (Query GSI1PK=VideoId)
- [x] Consumo de prefix e common_tags do foundation; terraform plan no root (`terraform/`) sem referências quebradas

## Checklist de Conclusão
- [x] Arquivos .tf do 20-data criados; nenhum aws_iam_* no módulo
- [x] terraform init e terraform validate no root (`terraform/`) com sucesso (módulo 20-data invocado pelo root)
- [x] terraform plan no root com variáveis em envs/dev.tfvars inclui 20-data e não apresenta erros de referência
- [x] README ou story documenta PK/SK, GSI e variáveis
