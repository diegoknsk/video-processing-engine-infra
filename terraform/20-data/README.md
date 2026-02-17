# Módulo 20-data (DynamoDB Vídeos)

Provisiona uma tabela DynamoDB para rastrear vídeos e estado do processamento (status, datas, zipS3Key, errorMessage, userId, videoId). Consome prefix e tags do módulo 00-foundation; não cria recursos IAM.

## Modelo de dados

### Schema DynamoDB

- **Partition Key (HASH):** `pk` (String) — identifica a partição; formato: `USER#{userId}`
- **Sort Key (RANGE):** `sk` (String) — identifica o item dentro da partição; formato: `VIDEO#{videoId}`
- **Attributes:** `videoId`, `userId`, `status`, `createdAt`, `updatedAt`, `zipS3Key`, `errorMessage`, `TTL` (opcional)

### GSI1 (Global Secondary Index)

- **Hash Key:** `gsi1pk` — formato: `VIDEO#{videoId}`
- **Range Key:** `gsi1sk` — formato: `USER#{userId}`
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

1. **Idempotência:** `UpdateItem` com `ConditionExpression: "attribute_exists(pk)"` garante que item existe antes de atualizar; previne criação acidental durante retry de Lambda.
2. **Paralelismo:** Escritas em diferentes `pk` (usuários) não competem por throughput; processamento de vídeos de usuários diferentes é 100% paralelo.
3. **Query eficiente:** `Query(pk = USER#{userId})` retorna todos os vídeos de um usuário em uma única operação; suporta paginação (LastEvaluatedKey).
4. **GSI para acesso por videoId:** Lambda/API pode buscar vídeo sem saber o userId (ex.: worker recebe apenas videoId de Step Functions).
5. **Single-table design ready:** Padrão pk/sk preparado para expansão (ex.: `sk = VIDEO#{videoId}#FRAME#{frameId}` para denormalização futura).

## Decisões técnicas

### Billing Mode

- **Configuração:** `billing_mode = var.billing_mode` (padrão: `PAY_PER_REQUEST`)
- **Justificativa:** PAY_PER_REQUEST elimina capacity planning; ideal para carga variável (hackathon/MVP); custo baseado em uso real.

### Point-in-Time Recovery (PITR)

- **Configuração:** Não habilitado por padrão (AWS default)
- **Justificativa:** Ambiente hackathon/MVP com dados efêmeros não requer PITR; PITR adiciona ~20% de custo ao storage. Para produção: adicionar variável `var.enable_pitr`.

### Time To Live (TTL)

- **Configuração:** `enable_ttl = var.enable_ttl` (padrão: `false`), `ttl_attribute_name = var.ttl_attribute_name` (padrão: `"TTL"`)
- **Justificativa:** TTL permite expiração automática de itens (ex.: remover vídeos processados após 30 dias); atributo `TTL` deve ser numérico (epoch seconds).

### Tags

- **Configuração:** `tags = merge(var.common_tags, { Name = "${var.prefix}-videos" })`
- **Justificativa:** `common_tags` herda tags do foundation (`Environment`, `Project`, `ManagedBy`); facilita cost tracking.

### GSI Projection

- **Configuração:** `projection_type = "ALL"`
- **Justificativa:** Projeta todos os atributos no GSI; acesso completo via GSI sem consulta adicional à tabela principal.

## Exemplos de operações DynamoDB

### 1. Criar item (PutItem)

```javascript
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
  ConditionExpression: 'attribute_not_exists(pk)'
};
await dynamodb.putItem(params).promise();
```

### 2. Atualizar status (UpdateItem idempotente)

```javascript
const params = {
  TableName: process.env.TABLE_NAME,
  Key: { pk: `USER#${userId}`, sk: `VIDEO#${videoId}` },
  UpdateExpression: 'SET #status = :status, updatedAt = :updatedAt, zipS3Key = :zipS3Key',
  ExpressionAttributeNames: { '#status': 'status' },
  ExpressionAttributeValues: {
    ':status': 'COMPLETED',
    ':updatedAt': new Date().toISOString(),
    ':zipS3Key': `s3://bucket/processed/${videoId}.zip`
  },
  ConditionExpression: 'attribute_exists(pk)',
  ReturnValues: 'ALL_NEW'
};
await dynamodb.updateItem(params).promise();
```

### 3. Consultar por usuário (Query tabela principal)

```javascript
const params = {
  TableName: process.env.TABLE_NAME,
  KeyConditionExpression: 'pk = :pk AND begins_with(sk, :prefix)',
  ExpressionAttributeValues: { ':pk': `USER#${userId}`, ':prefix': 'VIDEO#' },
  Limit: 20,
  ScanIndexForward: false
};
const result = await dynamodb.query(params).promise();
```

### 4. Buscar por videoId (Query GSI)

```javascript
const params = {
  TableName: process.env.TABLE_NAME,
  IndexName: 'GSI1',
  KeyConditionExpression: 'gsi1pk = :gsi1pk',
  ExpressionAttributeValues: { ':gsi1pk': `VIDEO#${videoId}` }
};
const result = await dynamodb.query(params).promise();
```

### 5. GetItem (acesso direto por pk/sk)

```javascript
const params = {
  TableName: process.env.TABLE_NAME,
  Key: { pk: `USER#${userId}`, sk: `VIDEO#${videoId}` }
};
const result = await dynamodb.getItem(params).promise();
```

## Variáveis

| Variável | Tipo | Obrigatório | Default | Descrição |
|----------|------|-------------|---------|-----------|
| `prefix` | string | sim | - | Prefixo de naming do foundation (ex.: `video-processing-engine-dev`). |
| `common_tags` | map(string) | sim | - | Tags padrão do foundation. |
| `enable_ttl` | bool | não | `false` | Habilita TTL na tabela. |
| `ttl_attribute_name` | string | não | `TTL` | Nome do atributo TTL (epoch em segundos). |
| `billing_mode` | string | não | `PAY_PER_REQUEST` | PAY_PER_REQUEST ou PROVISIONED. |
| `environment` | string | não | `null` | Ambiente (opcional). |

## Outputs

| Output | Descrição | Uso |
|--------|-----------|-----|
| `table_name` | Nome da tabela DynamoDB | Lambda: `process.env.TABLE_NAME` |
| `table_arn` | ARN da tabela | IAM policies (dynamodb:PutItem, dynamodb:Query) |
| `gsi1_name` | Nome do GSI1 | Lambda: `IndexName: "GSI1"` |
| `gsi_names` | Lista dos nomes dos GSIs | Lambda: `IndexName: gsi_names[0]` |

## Uso

```hcl
module "data" {
  source = "./20-data"

  prefix      = module.foundation.prefix
  common_tags  = module.foundation.common_tags

  enable_ttl         = false
  ttl_attribute_name = "TTL"
  billing_mode       = "PAY_PER_REQUEST"
}
```

## Comandos úteis

```bash
# Descrever tabela (validar schema)
aws dynamodb describe-table --table-name <table_name>

# Query por usuário
aws dynamodb query \
  --table-name <table_name> \
  --key-condition-expression "pk = :pk" \
  --expression-attribute-values '{":pk":{"S":"USER#user123"}}'
```

## Estratégia de migração (recriação de tabela)

Alteração de `hash_key`/`range_key` força recriação da tabela (destroy + create). Em ambiente hackathon, recriação é aceitável; dados são efêmeros. Downtime esperado: ~2-5 minutos. Código Lambda deve usar `pk`/`sk` e `gsi1pk`/`gsi1sk` após o apply.
