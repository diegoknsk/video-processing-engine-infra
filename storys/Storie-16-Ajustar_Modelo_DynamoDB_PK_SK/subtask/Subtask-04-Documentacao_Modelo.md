# Subtask 04: Documentação do modelo pk/sk (README, padrões USER#/VIDEO#, exemplos)

## Descrição
Atualizar o arquivo `terraform/20-data/README.md` para documentar o modelo de dados correto da tabela DynamoDB: nomenclatura de chaves (`pk`/`sk`), padrão de valores (`USER#{userId}`, `VIDEO#{videoId}`), padrões de acesso (Query, GetItem, UpdateItem condicional), vantagens do modelo e exemplos de operações. Incluir justificativas para decisões técnicas (billing_mode, PITR, TTL) e orientações para consumo por Lambdas e aplicações.

## Contexto
O README atual documenta o modelo com `PK`/`SK` (maiúsculas) e não detalha o padrão de valores (ex.: `USER#{userId}`). A atualização deve:
- Refletir nomenclatura correta (`pk`/`sk`)
- Documentar formato de item esperado (JSON example)
- Explicar padrões de acesso e casos de uso
- Justificar vantagens do modelo (idempotência, paralelismo, single-table design)
- Fornecer exemplos de operações DynamoDB (Query, GetItem, UpdateItem)

## Passos de implementação

### 1. Atualizar seção "Modelo de dados" no README

Adicionar/substituir seção:

```markdown
## Modelo de dados

### Schema DynamoDB
- **Partition Key (HASH):** `pk` (String) — identifica a partição; formato: `USER#{userId}`
- **Sort Key (RANGE):** `sk` (String) — identifica o item dentro da partição; formato: `VIDEO#{videoId}`
- **Attributes:** `videoId`, `userId`, `status`, `createdAt`, `updatedAt`, `zipS3Key`, `errorMessage`, `TTL` (opcional)

### GSI1 (Global Secondary Index)
- **Hash Key:** `gsi1pk` (ou `GSI1PK` — conforme decisão Subtask 03) — formato: `VIDEO#{videoId}`
- **Range Key:** `gsi1sk` (ou `GSI1SK`) — formato: `USER#{userId}` (ou timestamp para ordenação)
- **Projection:** ALL (todos os atributos)
- **Uso:** Query por `videoId` sem saber `userId` (ex.: Lambda Processor atualiza status de vídeo)

### Formato de item (exemplo)
```json
{
  "pk": "USER#a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "sk": "VIDEO#v9z8y7x6-w5u4-3210-zyxw-vu9876543210",
  "videoId": "v9z8y7x6-w5u4-3210-zyxw-vu9876543210",
  "userId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "status": "PROCESSING",
  "createdAt": "2026-02-14T10:00:00Z",
  "updatedAt": "2026-02-14T10:05:00Z",
  "zipS3Key": "s3://bucket/uploads/processed/video.zip",
  "errorMessage": null,
  "TTL": 1738656000,
  "gsi1pk": "VIDEO#v9z8y7x6-w5u4-3210-zyxw-vu9876543210",
  "gsi1sk": "USER#a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```

### Padrões de acesso

| Operação | Tabela/GSI | Chave | Comando DynamoDB | Caso de uso |
|----------|------------|-------|------------------|-------------|
| Listar vídeos de um usuário | Tabela principal | `pk = USER#{userId}` | `Query(KeyConditionExpression: "pk = :pk")` | API: GET /users/{userId}/videos |
| Obter vídeo específico | Tabela principal | `pk = USER#{userId}, sk = VIDEO#{videoId}` | `GetItem(Key: { pk, sk })` | API: GET /users/{userId}/videos/{videoId} |
| Atualizar status (idempotente) | Tabela principal | `pk = USER#{userId}, sk = VIDEO#{videoId}` | `UpdateItem(Key: { pk, sk }, ConditionExpression: "attribute_exists(pk)")` | Lambda: atualiza status após processamento |
| Buscar vídeo por videoId | GSI1 | `gsi1pk = VIDEO#{videoId}` | `Query(IndexName: "GSI1", KeyConditionExpression: "gsi1pk = :gsi1pk")` | Lambda: recebe videoId de Step Functions, atualiza status sem saber userId |
| Listar vídeos por prefixo | Tabela principal | `pk = USER#{userId}, begins_with(sk, "VIDEO#")` | `Query(KeyConditionExpression: "pk = :pk AND begins_with(sk, :prefix)")` | Filtro: listar vídeos (vs. outros tipos de item no futuro) |

### Vantagens do modelo

1. **Idempotência:**
   - `UpdateItem` com `ConditionExpression: "attribute_exists(pk)"` garante que item existe antes de atualizar
   - Previne criação acidental de itens durante update (ex.: Lambda retry)

2. **Paralelismo:**
   - Escritas em diferentes `pk` (usuários) não competem por throughput
   - Processamento de vídeos de usuários diferentes é 100% paralelo (sem throttling entre partições)

3. **Query eficiente:**
   - `Query(pk = USER#{userId})` retorna todos os vídeos de um usuário em uma única operação
   - Suporta paginação (LastEvaluatedKey) para usuários com muitos vídeos

4. **GSI para acesso por videoId:**
   - Lambda/API pode buscar vídeo sem saber o userId (ex.: worker recebe apenas videoId de Step Functions)
   - GSI permite acesso flexível sem impacto na tabela principal

5. **Single-table design ready:**
   - Padrão pk/sk preparado para expansão (ex.: `sk = VIDEO#{videoId}#FRAME#{frameId}` para denormalização futura)
   - Uso de prefixos (`USER#`, `VIDEO#`) permite múltiplos tipos de entidade na mesma tabela (se necessário no futuro)

6. **Compatível com DynamoDB Streams:**
   - Mudanças de status podem gerar eventos (ex.: `status: PROCESSING → COMPLETED` dispara notificação)
```

---

### 2. Atualizar seção "Decisões Técnicas" no README

Adicionar/substituir seção:

```markdown
## Decisões Técnicas

### Billing Mode
- **Configuração:** `billing_mode = var.billing_mode` (padrão: `PAY_PER_REQUEST`)
- **Justificativa:** 
  - PAY_PER_REQUEST (on-demand) elimina necessidade de capacity planning (RCU/WCU)
  - Ideal para carga variável (hackathon/MVP) e ambientes de desenvolvimento
  - Custo baseado em uso real (requests); econômico em baixo volume
  - Migração futura para PROVISIONED é possível se carga se tornar previsível

### Point-in-Time Recovery (PITR)
- **Configuração:** Não habilitado por padrão (AWS default)
- **Justificativa:**
  - Ambiente de hackathon/MVP com dados efêmeros não requer PITR
  - PITR adiciona ~20% de custo ao storage
  - Para produção: adicionar variável `var.enable_pitr` e habilitar via `point_in_time_recovery { enabled = var.enable_pitr }`
  - Backup manual (snapshot) pode ser feito via AWS CLI/Console se necessário

### Time To Live (TTL)
- **Configuração:** `enable_ttl = var.enable_ttl` (padrão: `false`), `ttl_attribute_name = var.ttl_attribute_name` (padrão: `"TTL"`)
- **Justificativa:**
  - TTL permite expiração automática de itens (ex.: remover vídeos processados após 30 dias)
  - Não tem custo adicional (DynamoDB remove itens expirados automaticamente)
  - Atributo `TTL` deve ser numérico (epoch seconds); exemplo: `TTL = 1738656000` (expira em 2025-02-04)
  - Ideal para cleanup de dados temporários (ex.: vídeos de teste, logs antigos)

### Tags
- **Configuração:** `tags = merge(var.common_tags, { Name = "${var.prefix}-videos" })`
- **Justificativa:**
  - `common_tags` herda tags do módulo foundation (`Environment`, `Project`, `ManagedBy`)
  - Tag `Name` facilita identificação no Console AWS
  - Tags permitem cost tracking por projeto/ambiente

### GSI Projection
- **Configuração:** `projection_type = "ALL"`
- **Justificativa:**
  - Projeta todos os atributos do item no GSI (acesso completo via GSI sem consulta adicional à tabela principal)
  - Alternativas: `KEYS_ONLY` (apenas chaves; menor storage) ou `INCLUDE` (lista específica de atributos)
  - Para MVP, priorizar simplicidade (ALL) sobre otimização de storage (KEYS_ONLY)
```

---

### 3. Adicionar seção "Exemplos de operações" no README

```markdown
## Exemplos de operações DynamoDB

### 1. Criar item (PutItem)
```javascript
// Lambda: criar registro de vídeo ao receber evento de upload
const params = {
  TableName: process.env.TABLE_NAME,
  Item: {
    pk: `USER#${userId}`,
    sk: `VIDEO#${videoId}`,
    videoId: videoId,
    userId: userId,
    status: 'PENDING',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
    zipS3Key: null,
    errorMessage: null,
    gsi1pk: `VIDEO#${videoId}`,
    gsi1sk: `USER#${userId}`
  },
  ConditionExpression: 'attribute_not_exists(pk)'  // previne sobrescrita
};

await dynamodb.putItem(params).promise();
```

### 2. Atualizar status (UpdateItem idempotente)
```javascript
// Lambda: atualiza status após processamento
const params = {
  TableName: process.env.TABLE_NAME,
  Key: {
    pk: `USER#${userId}`,
    sk: `VIDEO#${videoId}`
  },
  UpdateExpression: 'SET #status = :status, updatedAt = :updatedAt, zipS3Key = :zipS3Key',
  ExpressionAttributeNames: {
    '#status': 'status'
  },
  ExpressionAttributeValues: {
    ':status': 'COMPLETED',
    ':updatedAt': new Date().toISOString(),
    ':zipS3Key': `s3://bucket/processed/${videoId}.zip`
  },
  ConditionExpression: 'attribute_exists(pk)',  // garante que item existe
  ReturnValues: 'ALL_NEW'
};

await dynamodb.updateItem(params).promise();
```

### 3. Consultar por usuário (Query tabela principal)
```javascript
// API: GET /users/{userId}/videos
const params = {
  TableName: process.env.TABLE_NAME,
  KeyConditionExpression: 'pk = :pk AND begins_with(sk, :prefix)',
  ExpressionAttributeValues: {
    ':pk': `USER#${userId}`,
    ':prefix': 'VIDEO#'
  },
  Limit: 20,  // paginação
  ScanIndexForward: false  // ordem decrescente (mais recentes primeiro)
};

const result = await dynamodb.query(params).promise();
// result.Items: array de vídeos do usuário
// result.LastEvaluatedKey: token de paginação (se houver mais resultados)
```

### 4. Buscar por videoId (Query GSI)
```javascript
// Lambda: recebe videoId de Step Functions, atualiza status sem saber userId
const params = {
  TableName: process.env.TABLE_NAME,
  IndexName: 'GSI1',
  KeyConditionExpression: 'gsi1pk = :gsi1pk',
  ExpressionAttributeValues: {
    ':gsi1pk': `VIDEO#${videoId}`
  }
};

const result = await dynamodb.query(params).promise();
// result.Items[0]: item do vídeo (inclui pk, sk, userId, status, etc.)
```

### 5. GetItem (acesso direto por pk/sk)
```javascript
// API: GET /users/{userId}/videos/{videoId}
const params = {
  TableName: process.env.TABLE_NAME,
  Key: {
    pk: `USER#${userId}`,
    sk: `VIDEO#${videoId}`
  }
};

const result = await dynamodb.getItem(params).promise();
// result.Item: objeto do vídeo (ou undefined se não existir)
```
```

---

### 4. Atualizar seção "Outputs" (se necessário)

Garantir que outputs estão documentados:

```markdown
## Outputs

| Output | Descrição | Uso |
|--------|-----------|-----|
| `table_name` | Nome da tabela DynamoDB | Lambda: `process.env.TABLE_NAME` |
| `table_arn` | ARN da tabela | IAM policies (ex.: `dynamodb:PutItem`, `dynamodb:Query`) |
| `gsi_names` | Lista de nomes de GSI | Lambda: `IndexName: gsi_names[0]` (ou hardcode "GSI1") |
```

---

## Formas de teste
1. **Revisão de conteúdo:**
   - Verificar que README não referencia `PK`/`SK` (maiúsculas) em exemplos ou descrições
   - Verificar que todos os exemplos usam `pk`/`sk` (minúsculas) e padrão `USER#`/`VIDEO#`
   - Verificar que nomenclatura de GSI está consistente com decisão da Subtask 03

2. **Validação de formato:**
   - README deve estar em Markdown válido (headings, code blocks, tables)
   - Exemplos de código devem estar em blocos de código com syntax highlighting (```javascript)

3. **Verificação de completude:**
   - README deve cobrir: schema, formato de item, padrões de acesso, vantagens, decisões técnicas, exemplos de operações, outputs
   - README deve responder perguntas comuns: "Como listar vídeos de um usuário?", "Como buscar por videoId?", "Por que pk/sk ao invés de PK/SK?"

## Critérios de aceite da subtask
- [ ] `terraform/20-data/README.md` atualizado com nomenclatura `pk`/`sk` (minúsculas)
- [ ] Seção "Modelo de dados" documenta schema, formato de item (JSON example) e padrões de acesso (tabela com casos de uso)
- [ ] Seção "Vantagens do modelo" justifica escolha de pk/sk (idempotência, paralelismo, Query eficiente, GSI, single-table design)
- [ ] Seção "Decisões Técnicas" justifica billing_mode, PITR, TTL, tags, GSI projection
- [ ] Seção "Exemplos de operações" fornece código JavaScript (AWS SDK v2 ou v3) para PutItem, UpdateItem, Query (tabela principal), Query (GSI), GetItem
- [ ] Nomenclatura de GSI consistente com decisão da Subtask 03 (minúsculas ou maiúsculas)
- [ ] README não contém referências a `PK`/`SK` (maiúsculas) em exemplos ou descrições (exceto se mencionar schema antigo para comparação)
- [ ] README está formatado corretamente (Markdown válido, code blocks, tables)

## Exemplo de estrutura do README (para referência)

```markdown
# Módulo 20-data (DynamoDB Vídeos)

Provisiona uma tabela DynamoDB para rastrear vídeos e estado do processamento. Consome prefix e tags do módulo 00-foundation; não cria recursos IAM.

## Modelo de dados
(Seção descrita acima)

## Padrões de acesso
(Tabela descrita acima)

## Vantagens do modelo
(Lista descrita acima)

## Decisões Técnicas
(Seção descrita acima)

## Variáveis

| Variável | Tipo | Padrão | Descrição |
|----------|------|--------|-----------|
| `prefix` | string | obrigatório | Prefixo de naming (do foundation) |
| `common_tags` | map | obrigatório | Tags comuns (do foundation) |
| `billing_mode` | string | `"PAY_PER_REQUEST"` | Modo de cobrança (PAY_PER_REQUEST ou PROVISIONED) |
| `enable_ttl` | bool | `false` | Habilita TTL na tabela |
| `ttl_attribute_name` | string | `"TTL"` | Nome do atributo TTL |

## Outputs
(Tabela descrita acima)

## Exemplos de operações DynamoDB
(Código JavaScript descrito acima)

## Uso

```hcl
module "data" {
  source = "./20-data"

  prefix       = module.foundation.prefix
  common_tags  = module.foundation.common_tags
  billing_mode = "PAY_PER_REQUEST"
  enable_ttl   = false
}
```

## Comandos úteis

```bash
# Descrever tabela (validar schema)
aws dynamodb describe-table --table-name <table_name>

# Listar itens (scan - cuidado em produção!)
aws dynamodb scan --table-name <table_name> --max-items 10

# Query por usuário
aws dynamodb query \
  --table-name <table_name> \
  --key-condition-expression "pk = :pk" \
  --expression-attribute-values '{":pk":{"S":"USER#user123"}}'
```
```

---

## Notas importantes
- **Compatibilidade:** exemplos de código devem usar AWS SDK v2 ou v3 (especificar versão ou fornecer ambos)
- **Ambiente:** exemplos assumem `process.env.TABLE_NAME` injetado por Terraform via variável de ambiente Lambda
- **Segurança:** não incluir exemplos com credenciais hardcoded ou dados sensíveis
- **Manutenibilidade:** README deve ser atualizado sempre que schema ou padrões de acesso mudarem
