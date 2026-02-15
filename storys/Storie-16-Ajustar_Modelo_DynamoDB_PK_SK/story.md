# Storie-16: Ajustar Modelo DynamoDB para Padrão pk/sk (Video Management)

## Status
- **Estado:** 🔄 Em Progresso
- **Data de Criação:** 14/02/2026

## Descrição
Como desenvolvedor de infraestrutura, quero ajustar a tabela DynamoDB do módulo `terraform/20-data` para o padrão correto de nomenclatura de chaves (pk/sk minúsculas) e documentar o modelo de dados esperado (pk: USER#{userId}, sk: VIDEO#{videoId}), para suportar operações idempotentes, processamento paralelo com múltiplos writers e consultas otimizadas por partition key e sort key, conforme contexto arquitetural do Video Processing Engine MVP.

## Objetivo
Ajustar o recurso `aws_dynamodb_table` do módulo `terraform/20-data` para usar:
- **Partition Key (HASH):** `pk` (string, minúscula) — padrão: `USER#{userId}`
- **Sort Key (RANGE):** `sk` (string, minúscula) — padrão: `VIDEO#{videoId}`

Atualizar GSI para usar nomenclatura consistente (ex.: `gsi1pk`/`gsi1sk` ou manter maiúsculas para GSI se necessário). Documentar modelo de item esperado, padrões de acesso (Query, GetItem, UpdateItem condicional) e justificar decisões de configuração (billing_mode, PITR, TTL). Analisar impacto de recriação da tabela (destruir/recriar) e definir estratégia de migração para ambiente de hackathon.

## Escopo Técnico
- **Tecnologias:** Terraform >= 1.0, AWS Provider (~> 5.0), AWS DynamoDB
- **Arquivos afetados:**
  - `terraform/20-data/dynamodb.tf` (ajuste de hash_key, range_key, attributes, GSI)
  - `terraform/20-data/README.md` (documentação do modelo pk/sk, padrões USER#/VIDEO#)
  - `terraform/20-data/variables.tf` (opcional: novas variáveis para PITR, billing_mode)
  - Possivelmente: código de Lambdas (se referências diretas a PK/SK — verificar impacto)
- **Componentes/Recursos:** 
  - `aws_dynamodb_table.videos` (alteração de schema)
  - Global Secondary Index (GSI1) — ajuste de nomenclatura
  - Outputs (table_name, arn, gsi_name) — sem alteração
- **Pacotes/Dependências:** Nenhum; ajuste de schema DynamoDB e documentação.

## Dependências e Riscos (para estimativa)
- **Dependências:** 
  - Storie-04 (implementação inicial do módulo 20-data) concluída
  - Verificar stories 08 (Lambdas) e 09 (Orchestration) para identificar referências ao schema atual (PK/SK)
- **Riscos/Pré-condições:**
  - **Alteração de chaves primárias em DynamoDB força recriação da tabela** (destruir + recriar)
  - **Perda de dados:** se tabela contém dados de produção/staging, necessário plano de backup/migração
  - **Hackathon:** assumimos que é ambiente efêmero; recriação da tabela é aceitável
  - **Impacto em Lambdas/aplicações:** ajuste de código para usar `pk`/`sk` ao invés de `PK`/`SK` (verificar se há hardcoded)
  - **Tempo de apply:** recriação de tabela DynamoDB pode levar alguns minutos (sem conteúdo é rápido)

## Modelo Esperado

### Schema DynamoDB (nomenclatura correta)
```
hash_key  = "pk"   (Partition Key, tipo String)
range_key = "sk"   (Sort Key, tipo String)
```

### Formato de item (padrão aplicação)
```json
{
  "pk": "USER#<userId>",         // Partition Key: identifica o usuário (partição)
  "sk": "VIDEO#<videoId>",       // Sort Key: identifica o vídeo (ordenação)
  "videoId": "<uuid>",           // Atributo: ID do vídeo (para GSI)
  "userId": "<uuid>",            // Atributo: ID do usuário (para GSI)
  "status": "PENDING|PROCESSING|COMPLETED|FAILED",
  "createdAt": "2026-02-14T10:00:00Z",
  "updatedAt": "2026-02-14T10:05:00Z",
  "zipS3Key": "s3://bucket/path/to/video.zip",
  "errorMessage": "erro descritivo (se aplicável)",
  "TTL": 1234567890  // opcional: expiration timestamp (epoch seconds)
}
```

### Padrões de acesso suportados
| Operação | Tabela/GSI | Chave | Caso de uso |
|----------|------------|-------|-------------|
| **Query por usuário** | Tabela principal | `pk = USER#{userId}` | Listar todos os vídeos de um usuário (API paginada) |
| **GetItem específico** | Tabela principal | `pk = USER#{userId}, sk = VIDEO#{videoId}` | Obter um vídeo específico (status, zipS3Key, etc.) |
| **UpdateItem condicional** | Tabela principal | `pk = USER#{userId}, sk = VIDEO#{videoId}` | Atualizar status de forma idempotente (ex.: condition_expression = "attribute_exists(pk)") |
| **Query por videoId** | GSI1 | `gsi1pk = VIDEO#{videoId}` | Buscar por videoId sem saber userId (processador, finalizador, API) |
| **Processamento paralelo** | Tabela principal | Multiple `pk` | Múltiplos writers (Lambdas) em partições diferentes não conflitam |

### Vantagens do modelo pk/sk
1. **Idempotência:** operações de escrita podem verificar existência de item (`attribute_exists(pk)`) antes de criar/atualizar
2. **Paralelismo:** escritas em diferentes `pk` (usuários) não sofrem throttling entre si
3. **Query eficiente:** Query por `pk` retorna todos os vídeos de um usuário; suporta `begins_with(sk, "VIDEO#")` para filtros
4. **GSI para acesso por videoId:** permite Lambda/API buscar vídeo sem saber o userId
5. **Padrão single-table design:** pronto para expansão (ex.: `sk = VIDEO#<videoId>#FRAME#<frameId>` para denormalização futura)

---

## Decisões Técnicas (a serem analisadas/documentadas na Story)

### 1. Billing Mode
- **Opção A (atual):** `PAY_PER_REQUEST` (on-demand) — simplicidade, sem preocupação com capacity planning; ideal para hackathon/MVP com carga variável
- **Opção B:** `PROVISIONED` — requer definição de RCU/WCU; mais econômico em cargas previsíveis; requer tuning
- **Recomendação:** manter `PAY_PER_REQUEST` para MVP; variável `var.billing_mode` já permite mudança futura

### 2. Point-in-Time Recovery (PITR)
- **PITR habilitado:** permite restaurar tabela para qualquer ponto nos últimos 35 dias; custo adicional (~20% do storage)
- **PITR desabilitado:** sem backup automático; requer snapshot manual se necessário
- **Contexto hackathon:** PITR não é crítico (dados efêmeros); pode adicionar variável `var.enable_pitr` (default = false) para ativar em ambientes críticos

### 3. Time To Live (TTL)
- **TTL já implementado (var.enable_ttl):** atributo `TTL` (numérico, epoch seconds) permite expiração automática de itens (ex.: remover vídeos processados após 30 dias)
- **Decisão:** manter implementação atual; atualizar documentação para usar `pk`/`sk` no exemplo

### 4. Tags obrigatórias
- **Atual:** usa `var.common_tags` (do foundation) + tag `Name`
- **Decisão:** manter padrão; garantir que `common_tags` inclua `Environment`, `Project`, `ManagedBy = "Terraform"`

### 5. Outputs necessários
- **Atual:** `table_name`, `table_arn`, `gsi_names` (lista)
- **Decisão:** manter outputs atuais; suficientes para consumo por Lambdas e pipelines

### 6. Impacto de recriação (estratégia de migração)
- **Terraform:** alteração de `hash_key`/`range_key` força `ForceNew = true` (destroy + create)
- **Impacto em hackathon:** ambiente efêmero; aceitável destruir e recriar; dados não persistem entre execuções
- **Estratégia:**
  1. Revisar código de Lambdas para identificar referências a `PK`/`SK` (grep/busca)
  2. Ajustar código Lambda para usar `pk`/`sk` (se necessário)
  3. Executar `terraform plan` no root para confirmar recriação (destroy + create)
  4. Executar `terraform apply` no root
  5. Validar com `aws dynamodb describe-table` que schema está correto
- **Downtime:** tabela será destruída e recriada; aplicação deve tolerar erro temporário (retry logic)

---

## Nomenclatura GSI (decisão a ser tomada)

### Opção A: GSI com minúsculas (consistência total)
```hcl
attribute { name = "gsi1pk", type = "S" }
attribute { name = "gsi1sk", type = "S" }
global_secondary_index {
  name      = "GSI1"
  hash_key  = "gsi1pk"
  range_key = "gsi1sk"
}
```
- **Padrão de item:** `gsi1pk = VIDEO#{videoId}`, `gsi1sk = USER#{userId}`
- **Vantagem:** nomenclatura consistente com pk/sk
- **Desvantagem:** mudança maior (mais ajustes no código Lambda)

### Opção B: GSI mantém maiúsculas (mudança mínima)
```hcl
attribute { name = "GSI1PK", type = "S" }
attribute { name = "GSI1SK", type = "S" }
global_secondary_index {
  name      = "GSI1"
  hash_key  = "GSI1PK"
  range_key = "GSI1SK"
}
```
- **Padrão de item:** `GSI1PK = VIDEO#{videoId}`, `GSI1SK = USER#{userId}`
- **Vantagem:** menor impacto no código Lambda (apenas pk/sk mudam)
- **Desvantagem:** inconsistência de nomenclatura (pk/sk minúsculas, GSI maiúsculas)

### Recomendação (a ser validada na Story)
- **Opção A (consistência total):** preferível se código Lambda ainda não está hardcoded ou é fácil ajustar
- **Opção B (mudança mínima):** se código Lambda já usa `GSI1PK`/`GSI1SK` e ajuste é complexo
- **Decisão final:** analisar código Lambda na Subtask 01 antes de escolher

---

## Subtasks
- [x] [Subtask 01: Análise de impacto (código Lambdas, referências PK/SK/GSI)](./subtask/Subtask-01-Analise_Impacto.md)
- [x] [Subtask 02: Ajuste de schema DynamoDB (pk/sk, attributes, naming)](./subtask/Subtask-02-Ajuste_Schema_DynamoDB.md)
- [x] [Subtask 03: Atualização de GSI (decisão maiúsculas/minúsculas, attributes)](./subtask/Subtask-03-Atualizacao_GSI.md)
- [x] [Subtask 04: Documentação do modelo pk/sk (README, padrões USER#/VIDEO#, exemplos de Query/GetItem/UpdateItem)](./subtask/Subtask-04-Documentacao_Modelo.md)
- [ ] [Subtask 05: Validação e execução (terraform plan, análise de recriação, terraform apply, describe-table)](./subtask/Subtask-05-Validacao_Execucao.md)

---

## Critérios de Aceite da História
- [x] Tabela DynamoDB usa `hash_key = "pk"` e `range_key = "sk"` (minúsculas)
- [x] Attributes declarados: `pk` (S), `sk` (S), `gsi1pk` (S), `gsi1sk` (S) — Opção A (consistência total)
- [x] README atualizado com modelo de item esperado (pk: USER#{userId}, sk: VIDEO#{videoId})
- [x] README documenta padrões de acesso: Query por usuário, GetItem específico, UpdateItem condicional, Query por videoId (GSI)
- [x] README justifica decisões: billing_mode (PAY_PER_REQUEST), PITR (opcional via var), TTL (existente), tags (common_tags)
- [x] Outputs mantidos: `table_name`, `table_arn`, `gsi_names` (sem alteração)
- [ ] `terraform plan` no root (`terraform/`) mostra destroy + create da tabela (recriação esperada) — executar com credenciais AWS
- [ ] `terraform validate` no root passa sem erros — executar com credenciais AWS
- [x] Código Lambda ajustado (se necessário) para usar `pk`/`sk` ao invés de `PK`/`SK` (verificado na Subtask 01 — código em repo externo)
- [x] Documentação explica estratégia de migração (recriação em hackathon é aceitável)

---

## Checklist de Conclusão
- [x] Código Lambda revisado — em repo externo; ajuste documentado em IMPACTO.md
- [x] `terraform/20-data/dynamodb.tf` atualizado com `hash_key = "pk"`, `range_key = "sk"`
- [x] GSI atualizado (gsi1pk/gsi1sk — Opção A)
- [x] `terraform/20-data/README.md` documentado com modelo pk/sk, padrões USER#/VIDEO#, exemplos de acesso
- [ ] `terraform init` e `terraform validate` no root (`terraform/`) com sucesso — requer credenciais AWS
- [ ] `terraform plan` no root mostra recriação da tabela (destroy + create)
- [ ] `terraform apply` executado (se aprovado pelo time/aluno)
- [ ] `aws dynamodb describe-table --table-name <nome-tabela>` confirma schema correto (pk/sk)
- [x] Documentação de migração/impacto incluída no README e IMPACTO.md

---

---

## Rastreamento (dev tracking)
- **Início:** dia 14/02/2026 (sessão iniciada)
- **Fim:** —
- **Tempo total de desenvolvimento:** —

---

## Resumo Executivo da Story

Esta story ajusta a tabela DynamoDB do módulo `terraform/20-data` para o modelo correto de nomenclatura de chaves (`pk`/`sk` em minúsculas, com padrões `USER#{userId}` e `VIDEO#{videoId}`), documentando vantagens do modelo (idempotência, paralelismo, Query eficiente, single-table design) e justificando decisões técnicas (billing_mode, PITR, TTL).

### Contexto
- **Problema:** Tabela atual usa `PK`/`SK` (maiúsculas); especificação pede `pk`/`sk` (minúsculas)
- **Solução:** Ajustar schema DynamoDB para nomenclatura correta; alteração força recriação de tabela (destroy + create)
- **Impacto:** Downtime de ~2-5 minutos; dados perdidos (aceitável em hackathon); código Lambda pode precisar ajuste

### Decisões técnicas documentadas
1. **Billing mode:** manter PAY_PER_REQUEST (simplicidade, carga variável)
2. **PITR:** não habilitar por padrão (hackathon, dados efêmeros)
3. **TTL:** manter implementação existente (opcional via variável)
4. **GSI:** decidir nomenclatura (minúsculas para consistência ou maiúsculas para menor impacto)
5. **Recriação:** estratégia documentada (ordem de execução, validação)

### Entregas
- Schema DynamoDB ajustado (`pk`/`sk`)
- GSI atualizado (nomenclatura definida)
- README completo (modelo, padrões de acesso, vantagens, exemplos de operações)
- Plano de migração documentado (análise de impacto, estratégia de execução)
- Validação pós-deploy (describe-table, testes funcionais)
