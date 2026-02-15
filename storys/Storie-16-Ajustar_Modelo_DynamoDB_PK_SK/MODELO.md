# 🗂️ Modelo de Dados DynamoDB - Antes e Depois

## 📊 Estrutura da Tabela

### ❌ ANTES (Incorreto)

```
┌─────────────────────────────────────────────────────────────────┐
│ Tabela: video-processing-engine-dev-videos                      │
├─────────────────────────────────────────────────────────────────┤
│ Partition Key (HASH): PK  (String) ← ❌ maiúscula              │
│ Sort Key (RANGE):      SK  (String) ← ❌ maiúscula              │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ GSI1: Busca por VideoId                                         │
├─────────────────────────────────────────────────────────────────┤
│ Partition Key: GSI1PK (String) ← ❌ maiúscula                   │
│ Sort Key:      GSI1SK (String) ← ❌ maiúscula                   │
│ Projection:    ALL                                              │
└─────────────────────────────────────────────────────────────────┘
```

**Exemplo de Item:**
```json
{
  "PK": "USER#a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "SK": "VIDEO#v9z8y7x6-w5u4-3210-zyxw-vu9876543210",
  "videoId": "v9z8y7x6-w5u4-3210-zyxw-vu9876543210",
  "userId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "status": "COMPLETED",
  "createdAt": "2026-02-14T10:00:00Z",
  "updatedAt": "2026-02-14T10:05:00Z",
  "zipS3Key": "s3://bucket/processed/video.zip",
  "GSI1PK": "VIDEO#v9z8y7x6-w5u4-3210-zyxw-vu9876543210",
  "GSI1SK": "USER#a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```

---

### ✅ DEPOIS (Correto - Opção A: Consistência Total)

```
┌─────────────────────────────────────────────────────────────────┐
│ Tabela: video-processing-engine-dev-videos                      │
├─────────────────────────────────────────────────────────────────┤
│ Partition Key (HASH): pk  (String) ← ✅ minúscula              │
│ Sort Key (RANGE):      sk  (String) ← ✅ minúscula              │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ GSI1: Busca por VideoId                                         │
├─────────────────────────────────────────────────────────────────┤
│ Partition Key: gsi1pk (String) ← ✅ minúscula                   │
│ Sort Key:      gsi1sk (String) ← ✅ minúscula                   │
│ Projection:    ALL                                              │
└─────────────────────────────────────────────────────────────────┘
```

**Exemplo de Item:**
```json
{
  "pk": "USER#a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "sk": "VIDEO#v9z8y7x6-w5u4-3210-zyxw-vu9876543210",
  "videoId": "v9z8y7x6-w5u4-3210-zyxw-vu9876543210",
  "userId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "status": "COMPLETED",
  "createdAt": "2026-02-14T10:00:00Z",
  "updatedAt": "2026-02-14T10:05:00Z",
  "zipS3Key": "s3://bucket/processed/video.zip",
  "gsi1pk": "VIDEO#v9z8y7x6-w5u4-3210-zyxw-vu9876543210",
  "gsi1sk": "USER#a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```

---

### ✅ DEPOIS (Correto - Opção B: Mudança Mínima)

```
┌─────────────────────────────────────────────────────────────────┐
│ Tabela: video-processing-engine-dev-videos                      │
├─────────────────────────────────────────────────────────────────┤
│ Partition Key (HASH): pk  (String) ← ✅ minúscula              │
│ Sort Key (RANGE):      sk  (String) ← ✅ minúscula              │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ GSI1: Busca por VideoId                                         │
├─────────────────────────────────────────────────────────────────┤
│ Partition Key: GSI1PK (String) ← ⚠️ maiúscula (mantido)        │
│ Sort Key:      GSI1SK (String) ← ⚠️ maiúscula (mantido)        │
│ Projection:    ALL                                              │
└─────────────────────────────────────────────────────────────────┘
```

**Exemplo de Item:**
```json
{
  "pk": "USER#a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "sk": "VIDEO#v9z8y7x6-w5u4-3210-zyxw-vu9876543210",
  "videoId": "v9z8y7x6-w5u4-3210-zyxw-vu9876543210",
  "userId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "status": "COMPLETED",
  "createdAt": "2026-02-14T10:00:00Z",
  "updatedAt": "2026-02-14T10:05:00Z",
  "zipS3Key": "s3://bucket/processed/video.zip",
  "GSI1PK": "VIDEO#v9z8y7x6-w5u4-3210-zyxw-vu9876543210",
  "GSI1SK": "USER#a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```

---

## 🔍 Padrões de Acesso

### 1️⃣ Listar vídeos de um usuário (Tabela Principal)

**ANTES:**
```javascript
// Query com PK (maiúscula)
const params = {
  TableName: 'video-processing-engine-dev-videos',
  KeyConditionExpression: 'PK = :pk',  // ❌
  ExpressionAttributeValues: {
    ':pk': 'USER#user123'
  }
};
```

**DEPOIS:**
```javascript
// Query com pk (minúscula)
const params = {
  TableName: 'video-processing-engine-dev-videos',
  KeyConditionExpression: 'pk = :pk',  // ✅
  ExpressionAttributeValues: {
    ':pk': 'USER#user123'
  }
};
```

---

### 2️⃣ Obter vídeo específico (GetItem)

**ANTES:**
```javascript
// GetItem com PK/SK (maiúsculas)
const params = {
  TableName: 'video-processing-engine-dev-videos',
  Key: {
    PK: 'USER#user123',   // ❌
    SK: 'VIDEO#video456'  // ❌
  }
};
```

**DEPOIS:**
```javascript
// GetItem com pk/sk (minúsculas)
const params = {
  TableName: 'video-processing-engine-dev-videos',
  Key: {
    pk: 'USER#user123',   // ✅
    sk: 'VIDEO#video456'  // ✅
  }
};
```

---

### 3️⃣ Buscar por videoId (Query GSI)

**ANTES:**
```javascript
// Query GSI com GSI1PK (maiúscula)
const params = {
  TableName: 'video-processing-engine-dev-videos',
  IndexName: 'GSI1',
  KeyConditionExpression: 'GSI1PK = :gsi1pk',  // ❌
  ExpressionAttributeValues: {
    ':gsi1pk': 'VIDEO#video456'
  }
};
```

**DEPOIS (Opção A):**
```javascript
// Query GSI com gsi1pk (minúscula)
const params = {
  TableName: 'video-processing-engine-dev-videos',
  IndexName: 'GSI1',
  KeyConditionExpression: 'gsi1pk = :gsi1pk',  // ✅
  ExpressionAttributeValues: {
    ':gsi1pk': 'VIDEO#video456'
  }
};
```

**DEPOIS (Opção B):**
```javascript
// Query GSI com GSI1PK (maiúscula mantida)
const params = {
  TableName: 'video-processing-engine-dev-videos',
  IndexName: 'GSI1',
  KeyConditionExpression: 'GSI1PK = :gsi1pk',  // ⚠️ mantido
  ExpressionAttributeValues: {
    ':gsi1pk': 'VIDEO#video456'
  }
};
```

---

### 4️⃣ Atualizar status (UpdateItem)

**ANTES:**
```javascript
// UpdateItem com PK/SK (maiúsculas)
const params = {
  TableName: 'video-processing-engine-dev-videos',
  Key: {
    PK: 'USER#user123',   // ❌
    SK: 'VIDEO#video456'  // ❌
  },
  UpdateExpression: 'SET #status = :status',
  ExpressionAttributeNames: { '#status': 'status' },
  ExpressionAttributeValues: { ':status': 'COMPLETED' },
  ConditionExpression: 'attribute_exists(PK)'  // ❌
};
```

**DEPOIS:**
```javascript
// UpdateItem com pk/sk (minúsculas)
const params = {
  TableName: 'video-processing-engine-dev-videos',
  Key: {
    pk: 'USER#user123',   // ✅
    sk: 'VIDEO#video456'  // ✅
  },
  UpdateExpression: 'SET #status = :status',
  ExpressionAttributeNames: { '#status': 'status' },
  ExpressionAttributeValues: { ':status': 'COMPLETED' },
  ConditionExpression: 'attribute_exists(pk)'  // ✅
};
```

---

## 🎯 Benefícios do Novo Modelo

### 1. Nomenclatura Consistente
- ✅ Segue padrão moderno (single-table design)
- ✅ Minúsculas para chaves (convenção comum em DynamoDB)
- ✅ Prefixos claros: `USER#`, `VIDEO#`

### 2. Idempotência
```javascript
// ConditionExpression garante que item existe antes de atualizar
ConditionExpression: 'attribute_exists(pk)'
// Previne criação acidental durante retry de Lambda
```

### 3. Paralelismo
```
Usuário A → pk: USER#A → Partição A → Throughput independente
Usuário B → pk: USER#B → Partição B → Throughput independente
Usuário C → pk: USER#C → Partição C → Throughput independente
```
- ✅ Processamento paralelo de vídeos de usuários diferentes
- ✅ Sem throttling entre partições

### 4. Query Eficiente
```javascript
// Query por usuário (tabela principal)
Query(pk = "USER#user123") → retorna TODOS os vídeos do usuário

// Query por videoId (GSI)
Query(gsi1pk = "VIDEO#video456") → retorna item do vídeo
```

### 5. Single-Table Design Ready
```
pk: USER#{userId}
sk: VIDEO#{videoId}           ← vídeo
sk: VIDEO#{videoId}#FRAME#{frameId}  ← frame (expansão futura)
sk: VIDEO#{videoId}#METADATA  ← metadados (expansão futura)
```

---

## 📋 Checklist de Ajuste em Código Lambda

Se você tem código Lambda que usa DynamoDB, verifique:

- [ ] `PK` → `pk` (todas as ocorrências)
- [ ] `SK` → `sk` (todas as ocorrências)
- [ ] `GSI1PK` → `gsi1pk` ou mantido (conforme decisão)
- [ ] `GSI1SK` → `gsi1sk` ou mantido (conforme decisão)
- [ ] `attribute_exists(PK)` → `attribute_exists(pk)`
- [ ] Variáveis de ambiente (se usadas para nomes de chaves)
- [ ] Testes unitários (mocks com PK/SK)
- [ ] Testes de integração (chamadas reais ao DynamoDB)

---

## 🚀 Próximos Passos

1. **Subtask 01:** Analisar impacto (buscar `PK`, `SK`, `GSI1PK`, `GSI1SK` no código Lambda)
2. **Subtask 02:** Ajustar schema Terraform (`pk`, `sk`)
3. **Subtask 03:** Ajustar GSI (decidir Opção A ou B)
4. **Subtask 04:** Documentar modelo no README
5. **Subtask 05:** Executar `terraform apply` e validar com `describe-table`

---

**Referência:** `story.md` para detalhes completos.
