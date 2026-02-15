# 📋 Story 16: Ajuste DynamoDB pk/sk - Resumo Visual

## 🎯 Objetivo
Ajustar tabela DynamoDB para usar `pk`/`sk` (minúsculas) ao invés de `PK`/`SK` (maiúsculas), com padrão `USER#{userId}` e `VIDEO#{videoId}`.

---

## 📊 Estado Atual vs. Estado Desejado

### ❌ Estado Atual (Incorreto)
```json
{
  "PK": "USER#user123",        // ❌ maiúscula
  "SK": "VIDEO#video456",      // ❌ maiúscula
  "GSI1PK": "VIDEO#video456",  // ❌ maiúscula
  "GSI1SK": "USER#user123"     // ❌ maiúscula
}
```

**Schema Atual:**
- `hash_key = "PK"` (maiúscula)
- `range_key = "SK"` (maiúscula)

---

### ✅ Estado Desejado (Correto)

**Opção A: Consistência total (minúsculas)**
```json
{
  "pk": "USER#user123",        // ✅ minúscula
  "sk": "VIDEO#video456",      // ✅ minúscula
  "gsi1pk": "VIDEO#video456",  // ✅ minúscula
  "gsi1sk": "USER#user123"     // ✅ minúscula
}
```

**Opção B: Mudança mínima**
```json
{
  "pk": "USER#user123",        // ✅ minúscula
  "sk": "VIDEO#video456",      // ✅ minúscula
  "GSI1PK": "VIDEO#video456",  // ⚠️ maiúscula (mantido)
  "GSI1SK": "USER#user123"     // ⚠️ maiúscula (mantido)
}
```

**Schema Desejado:**
- `hash_key = "pk"` (minúscula)
- `range_key = "sk"` (minúscula)

---

## 🔄 Fluxo de Implementação

```
┌─────────────────────────────────────────────────────────────┐
│ Subtask 01: Análise de Impacto                             │
│ • Buscar referências a PK/SK no código Lambda               │
│ • Decidir nomenclatura de GSI (minúsculas ou maiúsculas)    │
│ • Documentar estratégia de migração                         │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│ Subtask 02: Ajuste de Schema (tabela principal)            │
│ • Ajustar hash_key/range_key para pk/sk                     │
│ • Atualizar attributes (pk, sk)                             │
│ • Validar com terraform validate                            │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│ Subtask 03: Atualização de GSI                             │
│ • Ajustar GSI conforme decisão (Opção A ou B)               │
│ • Atualizar attributes do GSI                               │
│ • Validar com terraform plan                                │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│ Subtask 04: Documentação                                    │
│ • Atualizar README com modelo pk/sk                         │
│ • Documentar padrões USER#/VIDEO#                           │
│ • Adicionar exemplos de operações DynamoDB                  │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│ Subtask 05: Validação e Execução                           │
│ • terraform plan → revisar recriação de tabela              │
│ • terraform apply → executar mudanças                       │
│ • aws dynamodb describe-table → validar schema             │
│ • Testes funcionais (PutItem, GetItem, Query)               │
└─────────────────────────────────────────────────────────────┘
```

---

## ⚠️ Impacto e Riscos

### 🔴 CRÍTICO: Recriação de Tabela
- ⚠️ Alteração de `hash_key`/`range_key` força **destroy + create**
- ⚠️ **TODOS os dados serão perdidos**
- ⚠️ Downtime: ~2-5 minutos (tabela indisponível)

### ✅ Aceitável em Hackathon
- ✅ Ambiente efêmero (dados não persistem entre execuções)
- ✅ Sem necessidade de backup (dados de teste)

### 🔧 Código Lambda (se aplicável)
- Se Lambda usa `PK`/`SK` diretamente → **ajuste necessário**
- Se Lambda não existe ou usa variáveis de ambiente → **sem ajuste**

---

## 📦 Entregas

### Código Terraform
- ✅ `terraform/20-data/dynamodb.tf` com `hash_key = "pk"`, `range_key = "sk"`
- ✅ GSI atualizado (nomenclatura conforme decisão)
- ✅ `terraform validate` passando

### Documentação
- ✅ `terraform/20-data/README.md` atualizado com:
  - Modelo de item (JSON example)
  - Padrões de acesso (Query, GetItem, UpdateItem)
  - Vantagens do modelo (idempotência, paralelismo, etc.)
  - Exemplos de operações DynamoDB (JavaScript)

### Validação
- ✅ `terraform plan` mostra recriação de tabela
- ✅ `terraform apply` executado com sucesso
- ✅ `describe-table` confirma schema correto (`pk`/`sk`)
- ✅ Testes funcionais validados (PutItem, GetItem, Query)

---

## 📅 Estimativa

| Subtask | Estimativa | Descrição |
|---------|------------|-----------|
| 01 | 1-2h | Análise de impacto (busca, decisões) |
| 02 | 30min | Ajuste de schema (simples: trocar PK→pk, SK→sk) |
| 03 | 30min | Atualização de GSI (conforme decisão) |
| 04 | 2-3h | Documentação completa (README, exemplos) |
| 05 | 1-2h | Validação e execução (plan, apply, testes) |
| **Total** | **5-8h** | **Estimativa conservadora** |

---

## 🎯 Critérios de Aceite (Resumo)

- [ ] Schema DynamoDB usa `pk`/`sk` (minúsculas)
- [ ] GSI atualizado (nomenclatura consistente)
- [ ] README documenta modelo completo (padrões USER#/VIDEO#)
- [ ] README explica vantagens (idempotência, paralelismo, Query eficiente)
- [ ] README justifica decisões técnicas (billing_mode, PITR, TTL)
- [ ] `terraform validate` passa
- [ ] `terraform plan` mostra recriação de tabela
- [ ] `terraform apply` executado com sucesso
- [ ] `describe-table` confirma schema correto
- [ ] Código Lambda ajustado (se necessário)

---

## 🚀 Comandos Rápidos

### Validação
```bash
cd terraform
terraform validate
terraform plan -var-file=envs/dev.tfvars
```

### Execução
```bash
cd terraform
terraform apply -var-file=envs/dev.tfvars
```

### Validação pós-deploy
```bash
# Descrever tabela
aws dynamodb describe-table \
  --table-name video-processing-engine-dev-videos \
  --region us-east-1

# Teste funcional (PutItem)
aws dynamodb put-item \
  --table-name video-processing-engine-dev-videos \
  --item '{
    "pk": {"S": "USER#test"},
    "sk": {"S": "VIDEO#test"},
    "gsi1pk": {"S": "VIDEO#test"},
    "gsi1sk": {"S": "USER#test"}
  }'

# Teste funcional (GetItem)
aws dynamodb get-item \
  --table-name video-processing-engine-dev-videos \
  --key '{"pk": {"S": "USER#test"}, "sk": {"S": "VIDEO#test"}}'
```

---

## 📝 Referências

- Story completa: `story.md`
- Decisões técnicas: `DECISOES.md`
- Subtasks: `subtask/Subtask-01-*.md` até `Subtask-05-*.md`
- Documentação DynamoDB (AWS): https://docs.aws.amazon.com/dynamodb/
