# Subtask 03: Atualização de GSI (decisão maiúsculas/minúsculas, attributes)

## Descrição
Atualizar o Global Secondary Index (GSI1) da tabela DynamoDB para seguir nomenclatura consistente com a decisão tomada na Subtask 01. Se decisão foi manter consistência total (Opção A), migrar GSI para minúsculas (`gsi1pk`, `gsi1sk`); se decisão foi minimizar impacto (Opção B), manter GSI em maiúsculas (`GSI1PK`, `GSI1SK`). Ajustar attributes, hash_key/range_key do GSI e comentários de documentação.

## Contexto
A tabela atual possui:
```hcl
attribute { name = "GSI1PK", type = "S" }
attribute { name = "GSI1SK", type = "S" }

global_secondary_index {
  name            = "GSI1"
  hash_key        = "GSI1PK"
  range_key       = "GSI1SK"
  projection_type = "ALL"
}
```

## Decisão (baseada na Subtask 01)

### Opção A: Consistência total (minúsculas)
Migrar GSI para minúsculas para manter nomenclatura consistente com `pk`/`sk`:
```hcl
attribute { name = "gsi1pk", type = "S" }
attribute { name = "gsi1sk", type = "S" }

global_secondary_index {
  name            = "GSI1"  # nome do índice pode manter maiúsculas ou migrar para "gsi1"
  hash_key        = "gsi1pk"
  range_key       = "gsi1sk"
  projection_type = "ALL"
}
```

**Padrão de item:**
```json
{
  "pk": "USER#user123",
  "sk": "VIDEO#video456",
  "gsi1pk": "VIDEO#video456",  // permite Query por videoId
  "gsi1sk": "USER#user123"     // ou timestamp para ordenação
}
```

**Vantagens:**
- Nomenclatura 100% consistente (tudo em minúsculas)
- Padrão mais moderno (single-table design conventions)

**Desvantagens:**
- Requer ajuste em código Lambda que já usa `GSI1PK`/`GSI1SK`

---

### Opção B: Mudança mínima (manter maiúsculas)
Manter GSI em maiúsculas; ajustar apenas tabela principal:
```hcl
attribute { name = "GSI1PK", type = "S" }
attribute { name = "GSI1SK", type = "S" }

global_secondary_index {
  name            = "GSI1"
  hash_key        = "GSI1PK"
  range_key       = "GSI1SK"
  projection_type = "ALL"
}
```

**Padrão de item:**
```json
{
  "pk": "USER#user123",        // minúsculas (tabela principal)
  "sk": "VIDEO#video456",      // minúsculas (tabela principal)
  "GSI1PK": "VIDEO#video456",  // maiúsculas (GSI)
  "GSI1SK": "USER#user123"     // maiúsculas (GSI)
}
```

**Vantagens:**
- Menor impacto no código Lambda (apenas `pk`/`sk` mudam)
- Diferenciação visual entre chaves da tabela principal e GSI

**Desvantagens:**
- Inconsistência de nomenclatura (pk/sk minúsculas, GSI maiúsculas)

---

## Passos de implementação

### Se decisão foi Opção A (minúsculas)
1. **Ajustar attributes do GSI em `terraform/20-data/dynamodb.tf`:**
   ```hcl
   attribute {
     name = "gsi1pk"  # era "GSI1PK"
     type = "S"
   }

   attribute {
     name = "gsi1sk"  # era "GSI1SK"
     type = "S"
   }
   ```

2. **Ajustar global_secondary_index:**
   ```hcl
   global_secondary_index {
     name            = "GSI1"  # ou "gsi1" (decisão de team)
     hash_key        = "gsi1pk"  # era "GSI1PK"
     range_key       = "gsi1sk"  # era "GSI1SK"
     projection_type = "ALL"
   }
   ```

3. **Atualizar comentários no arquivo:**
   ```
   # GSI1: gsi1pk = VIDEO#{videoId}, gsi1sk = USER#{userId} → Query(gsi1pk=VIDEO#{videoId}) busca por VideoId (atualização de status/ZipS3Key/ErrorMessage).
   ```

4. **Documentar ajuste necessário em código Lambda:**
   - Se Lambda usa `GSI1PK`/`GSI1SK`, adicionar nota no README: "⚠️ Código Lambda deve usar `gsi1pk`/`gsi1sk` ao invés de `GSI1PK`/`GSI1SK` após apply desta mudança."

### Se decisão foi Opção B (manter maiúsculas)
1. **Manter attributes do GSI inalterados:**
   ```hcl
   attribute {
     name = "GSI1PK"
     type = "S"
   }

   attribute {
     name = "GSI1SK"
     type = "S"
   }

   global_secondary_index {
     name            = "GSI1"
     hash_key        = "GSI1PK"
     range_key       = "GSI1SK"
     projection_type = "ALL"
   }
   ```

2. **Atualizar apenas comentários (para referenciar tabela principal com pk/sk):**
   ```
   # Tabela principal: pk = USER#{userId}, sk = VIDEO#{videoId}
   # GSI1: GSI1PK = VIDEO#{videoId}, GSI1SK = USER#{userId} → Query(GSI1PK=VIDEO#{videoId}) busca por VideoId.
   ```

3. **Documentar inconsistência no README:**
   - Adicionar nota: "ℹ️ Tabela principal usa minúsculas (`pk`/`sk`); GSI usa maiúsculas (`GSI1PK`/`GSI1SK`) para minimizar impacto no código Lambda existente."

---

## Formas de teste
1. **Validação de sintaxe:**
   ```bash
   cd terraform
   terraform validate
   ```
   - Deve retornar: "Success! The configuration is valid."

2. **Visualizar plano de mudança:**
   ```bash
   terraform plan -var-file=envs/dev.tfvars
   ```
   - **Se Opção A (minúsculas):**
     - Plano mostra recriação de GSI (destroy + create) — attributes do GSI mudaram
     - Verificar: `-attribute.2.name = "GSI1PK"` → `+attribute.2.name = "gsi1pk"`
   - **Se Opção B (manter maiúsculas):**
     - Plano NÃO mostra mudança em GSI (apenas tabela principal recriada)
     - GSI será recriado junto com a tabela (pois tabela está sendo recriada), mas schema do GSI permanece igual

3. **Verificar outputs:**
   - Output `gsi_names` deve continuar retornando `["GSI1"]` ou `["gsi1"]` (conforme nome escolhido)
   - Verificar em `terraform/20-data/outputs.tf` que output está correto:
     ```hcl
     output "gsi_names" {
       value = [for gsi in aws_dynamodb_table.videos.global_secondary_index : gsi.name]
     }
     ```

## Critérios de aceite da subtask
- [ ] Decisão sobre nomenclatura de GSI (Opção A ou B) documentada no arquivo da subtask ou no story.md
- [ ] Attributes do GSI ajustados conforme decisão (minúsculas ou maiúsculas mantidas)
- [ ] `global_secondary_index` bloco atualizado com `hash_key`/`range_key` corretos
- [ ] Comentários no `dynamodb.tf` atualizados para referenciar nomenclatura correta (pk/sk na tabela principal; gsi1pk/gsi1sk ou GSI1PK/GSI1SK no GSI)
- [ ] Se Opção A escolhida: nota adicionada no README sobre ajuste necessário em código Lambda
- [ ] Se Opção B escolhida: nota adicionada no README explicando inconsistência de nomenclatura (justificativa: minimizar impacto)
- [ ] `terraform validate` no root passa sem erros
- [ ] `terraform plan` no root mostra mudanças corretas (recriação de GSI se Opção A; sem mudança de GSI se Opção B)

## Notas importantes
- **Projection_type = "ALL":** mantido; projeta todos os atributos do item no GSI (permite acesso completo via GSI sem consulta adicional à tabela principal)
- **Nome do índice:** `GSI1` pode manter-se em maiúsculas mesmo que attributes sejam minúsculas (nome do índice é diferente de attribute name); decisão de team
- **Recriação de tabela:** GSI será recriado junto com a tabela (pois tabela está sendo recriada na Subtask 02); sem custo adicional de operação
- **Performance:** GSI1 usa billing_mode da tabela (PAY_PER_REQUEST); sem configuração de RCU/WCU adicional necessária

## Recomendação (a ser validada pelo team)
- **Se código Lambda ainda não está implementado:** escolher Opção A (consistência total, minúsculas)
- **Se código Lambda já está em produção/staging:** escolher Opção B (manter maiúsculas, menor impacto)
- **Contexto hackathon:** provável que código Lambda ainda não esteja maduro; priorizar consistência (Opção A)
