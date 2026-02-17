# Subtask 05: Validação e execução (terraform plan, análise de recriação, apply, describe-table)

## Descrição
Validar todas as mudanças realizadas nas subtasks anteriores (schema pk/sk, GSI, documentação) e executar o fluxo completo de Terraform: validação de sintaxe, análise do plano de execução (terraform plan), revisão de impacto (recriação de tabela), execução (terraform apply) e validação pós-deploy com AWS CLI (describe-table). Documentar evidências de conclusão (plan output, apply output, schema validado).

## Contexto
Esta é a última subtask da story. Todas as mudanças de código e documentação foram realizadas nas subtasks anteriores:
- Subtask 01: Análise de impacto e decisão de nomenclatura
- Subtask 02: Ajuste de schema da tabela principal (pk/sk)
- Subtask 03: Ajuste de GSI (nomenclatura conforme decisão)
- Subtask 04: Documentação completa (README)

Agora é o momento de:
1. Validar que Terraform está correto (syntax, plan)
2. Revisar impacto da recriação de tabela (destroy + create)
3. Executar apply (se aprovado)
4. Validar que schema foi aplicado corretamente na AWS

## Passos de implementação

### 1. Validação de sintaxe e formatação
```bash
cd terraform/20-data
terraform fmt -recursive
cd ..
terraform fmt -recursive
```

Resultado esperado: nenhuma mudança (arquivos já formatados) ou apenas ajustes de indentação.

```bash
cd terraform  # root do Terraform
terraform validate
```

Resultado esperado:
```
Success! The configuration is valid.
```

Se houver erro, corrigir antes de prosseguir. Erros comuns:
- Attribute declarado mas não usado em hash_key/range_key
- Typo em nome de attribute (ex.: `gsi1pk` declarado, mas `gsi1PK` usado em hash_key)

---

### 2. Análise do plano de execução (terraform plan)

```bash
cd terraform
terraform plan -var-file=envs/dev.tfvars -out=planfile
```

**Resultado esperado:**

```
Terraform will perform the following actions:

  # module.data.aws_dynamodb_table.videos must be replaced
-/+ resource "aws_dynamodb_table" "videos" {
      ~ arn              = "arn:aws:dynamodb:us-east-1:123456789012:table/video-processing-engine-dev-videos" -> (known after apply)
      ~ hash_key         = "PK" -> "pk" # forces replacement
      ~ range_key        = "SK" -> "sk" # forces replacement
      ~ id               = "video-processing-engine-dev-videos" -> (known after apply)
      ~ stream_arn       = "" -> (known after apply)
      ~ stream_label     = "" -> (known after apply)
        name             = "video-processing-engine-dev-videos"
        billing_mode     = "PAY_PER_REQUEST"
        # ... outros atributos sem alteração

      ~ attribute {
          ~ name = "PK" -> "pk"
            type = "S"
        }

      ~ attribute {
          ~ name = "SK" -> "sk"
            type = "S"
        }

      # (Se Opção A escolhida na Subtask 03)
      ~ attribute {
          ~ name = "GSI1PK" -> "gsi1pk"
            type = "S"
        }

      ~ attribute {
          ~ name = "GSI1SK" -> "gsi1sk"
            type = "S"
        }

      ~ global_secondary_index {
          ~ hash_key  = "GSI1PK" -> "gsi1pk"
          ~ range_key = "GSI1SK" -> "gsi1sk"
            name      = "GSI1"
            # ... outros atributos sem alteração
        }

        # tags, ttl, etc. sem alteração
    }

Plan: 1 to add, 0 to change, 1 to destroy.
```

**Pontos críticos para revisar:**
- `must be replaced` → confirma que tabela será recriada (esperado)
- `hash_key` e `range_key` mudando de maiúsculas para minúsculas → correto
- `attribute` mudando conforme esperado → correto
- `Plan: 1 to add, 0 to change, 1 to destroy` → confirma destroy + create

**Salvar plan output para evidência:**
```bash
terraform show planfile > plan-output.txt
```

---

### 3. Revisão de impacto (checklist pré-apply)

Antes de executar `terraform apply`, verificar:

- [ ] **Código Lambda ajustado (se necessário):**
  - Se Subtask 01 identificou código Lambda que usa `PK`/`SK` diretamente, garantir que código foi atualizado para `pk`/`sk`
  - Se Lambda ainda não foi ajustado: **NÃO executar apply** (ou aceitar que Lambda quebrará temporariamente até ajuste)

- [ ] **Ambiente é hackathon/efêmero:**
  - Confirmar que ambiente é dev/staging/hackathon (não produção)
  - Confirmar que perda de dados na tabela é aceitável (tabela será destruída)

- [ ] **Backup (se necessário):**
  - Se tabela contém dados importantes: criar snapshot antes de apply
  - Comando: `aws dynamodb create-backup --table-name <nome-tabela> --backup-name pre-migration-backup`
  - Em hackathon: backup não é necessário (dados efêmeros)

- [ ] **Downtime aceitável:**
  - Tabela ficará indisponível por ~2-5 minutos (destroy + create)
  - Aplicação deve tolerar erro temporário (ex.: Lambda com retry, API retorna 503)

- [ ] **Aprovação do time/aluno:**
  - Se necessário, obter aprovação explícita para recriação de tabela
  - Mostrar plan output para stakeholders

---

### 4. Execução do terraform apply

Se todos os checkpoints acima foram validados:

```bash
cd terraform
terraform apply planfile
```

OU (se planfile não foi salvo):

```bash
terraform apply -var-file=envs/dev.tfvars
```

Terraform solicitará confirmação:
```
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: 
```

**Digitar `yes` e aguardar.**

**Resultado esperado:**
```
module.data.aws_dynamodb_table.videos: Destroying... [id=video-processing-engine-dev-videos]
module.data.aws_dynamodb_table.videos: Destruction complete after 1m30s
module.data.aws_dynamodb_table.videos: Creating...
module.data.aws_dynamodb_table.videos: Creation complete after 2m15s [id=video-processing-engine-dev-videos]

Apply complete! Resources: 1 added, 0 changed, 1 destroyed.

Outputs:

dynamodb_table_name = "video-processing-engine-dev-videos"
dynamodb_table_arn  = "arn:aws:dynamodb:us-east-1:123456789012:table/video-processing-engine-dev-videos"
dynamodb_gsi1_name  = ["GSI1"]
```

**Tempo esperado:** ~3-5 minutos (destroy ~1-2 min, create ~2-3 min)

**Salvar apply output:**
```bash
# (copiar output do terminal ou redirecionar)
terraform apply -var-file=envs/dev.tfvars | tee apply-output.txt
```

---

### 5. Validação pós-deploy (AWS CLI)

Validar que schema foi aplicado corretamente:

```bash
aws dynamodb describe-table --table-name <nome-tabela> --region <região>
```

Substituir `<nome-tabela>` pelo output `dynamodb_table_name` (ex.: `video-processing-engine-dev-videos`).

**Resultado esperado (trecho relevante):**
```json
{
  "Table": {
    "TableName": "video-processing-engine-dev-videos",
    "KeySchema": [
      {
        "AttributeName": "pk",
        "KeyType": "HASH"
      },
      {
        "AttributeName": "sk",
        "KeyType": "RANGE"
      }
    ],
    "AttributeDefinitions": [
      {
        "AttributeName": "pk",
        "AttributeType": "S"
      },
      {
        "AttributeName": "sk",
        "AttributeType": "S"
      },
      {
        "AttributeName": "gsi1pk",  // ou "GSI1PK" se Opção B
        "AttributeType": "S"
      },
      {
        "AttributeName": "gsi1sk",  // ou "GSI1SK" se Opção B
        "AttributeType": "S"
      }
    ],
    "GlobalSecondaryIndexes": [
      {
        "IndexName": "GSI1",
        "KeySchema": [
          {
            "AttributeName": "gsi1pk",  // ou "GSI1PK"
            "KeyType": "HASH"
          },
          {
            "AttributeName": "gsi1sk",  // ou "GSI1SK"
            "KeyType": "RANGE"
          }
        ],
        "Projection": {
          "ProjectionType": "ALL"
        },
        "IndexStatus": "ACTIVE"
      }
    ],
    "BillingModeSummary": {
      "BillingMode": "PAY_PER_REQUEST"
    },
    "TableStatus": "ACTIVE"
  }
}
```

**Pontos críticos para validar:**
- `KeySchema`: `pk` (HASH) e `sk` (RANGE) → correto (minúsculas)
- `AttributeDefinitions`: `pk`, `sk`, `gsi1pk` (ou `GSI1PK`), `gsi1sk` (ou `GSI1SK`) → correto
- `GlobalSecondaryIndexes`: `IndexName: "GSI1"`, `KeySchema` com `gsi1pk` (HASH) e `gsi1sk` (RANGE) → correto
- `TableStatus: "ACTIVE"` → tabela está pronta para uso
- `IndexStatus: "ACTIVE"` (no GSI) → GSI está pronto para uso

**Salvar describe-table output:**
```bash
aws dynamodb describe-table --table-name <nome-tabela> --region <região> > describe-table-output.json
```

---

### 6. Teste funcional (opcional, mas recomendado)

Validar operações básicas na tabela:

**PutItem (criar item de teste):**
```bash
aws dynamodb put-item \
  --table-name <nome-tabela> \
  --item '{
    "pk": {"S": "USER#test-user-123"},
    "sk": {"S": "VIDEO#test-video-456"},
    "videoId": {"S": "test-video-456"},
    "userId": {"S": "test-user-123"},
    "status": {"S": "PENDING"},
    "createdAt": {"S": "2026-02-14T10:00:00Z"},
    "updatedAt": {"S": "2026-02-14T10:00:00Z"},
    "gsi1pk": {"S": "VIDEO#test-video-456"},
    "gsi1sk": {"S": "USER#test-user-123"}
  }' \
  --region <região>
```

**GetItem (validar que item foi criado):**
```bash
aws dynamodb get-item \
  --table-name <nome-tabela> \
  --key '{
    "pk": {"S": "USER#test-user-123"},
    "sk": {"S": "VIDEO#test-video-456"}
  }' \
  --region <região>
```

Resultado esperado: item retornado com todos os atributos.

**Query por usuário (tabela principal):**
```bash
aws dynamodb query \
  --table-name <nome-tabela> \
  --key-condition-expression "pk = :pk" \
  --expression-attribute-values '{":pk":{"S":"USER#test-user-123"}}' \
  --region <região>
```

Resultado esperado: lista com 1 item (o item de teste).

**Query por videoId (GSI):**
```bash
aws dynamodb query \
  --table-name <nome-tabela> \
  --index-name GSI1 \
  --key-condition-expression "gsi1pk = :gsi1pk" \
  --expression-attribute-values '{":gsi1pk":{"S":"VIDEO#test-video-456"}}' \
  --region <região>
```

Resultado esperado: lista com 1 item (o item de teste).

**DeleteItem (limpar item de teste):**
```bash
aws dynamodb delete-item \
  --table-name <nome-tabela> \
  --key '{
    "pk": {"S": "USER#test-user-123"},
    "sk": {"S": "VIDEO#test-video-456"}
  }' \
  --region <região>
```

---

### 7. Evidências de conclusão

Coletar e salvar as seguintes evidências:

1. **terraform validate output:**
   ```
   Success! The configuration is valid.
   ```

2. **terraform plan output:**
   - Arquivo: `plan-output.txt`
   - Confirma: `Plan: 1 to add, 0 to change, 1 to destroy`

3. **terraform apply output:**
   - Arquivo: `apply-output.txt`
   - Confirma: `Apply complete! Resources: 1 added, 0 changed, 1 destroyed`
   - Outputs: `dynamodb_table_name`, `dynamodb_table_arn`, `dynamodb_gsi1_name`

4. **aws dynamodb describe-table output:**
   - Arquivo: `describe-table-output.json`
   - Confirma: `KeySchema` com `pk`/`sk`, `GlobalSecondaryIndexes` com `gsi1pk`/`gsi1sk` (ou maiúsculas)

5. **Testes funcionais (se executados):**
   - Output de PutItem, GetItem, Query (tabela principal), Query (GSI)

Anexar evidências à story (ou documentar em arquivo `EVIDENCIAS.md`).

---

## Formas de teste
1. **terraform validate:** deve passar sem erros
2. **terraform plan:** deve mostrar recriação de tabela (destroy + create) com schema correto
3. **terraform apply:** deve completar em ~3-5 minutos sem erros
4. **describe-table:** deve confirmar schema pk/sk (minúsculas) e GSI correto
5. **Testes funcionais:** operações básicas (PutItem, GetItem, Query) devem funcionar conforme esperado

## Critérios de aceite da subtask
- [ ] `terraform fmt` executado sem alterações (código já formatado)
- [ ] `terraform validate` no root passa sem erros
- [ ] `terraform plan` no root salvo (`plan-output.txt`) e revisado
- [ ] Plan mostra recriação de tabela (destroy + create) com hash_key/range_key mudando de `PK`/`SK` para `pk`/`sk`
- [ ] Checklist pré-apply validado (código Lambda ajustado, ambiente é hackathon, downtime aceitável, aprovação obtida)
- [ ] `terraform apply` executado com sucesso (recursos: 1 added, 0 changed, 1 destroyed)
- [ ] `aws dynamodb describe-table` confirma schema correto:
  - `KeySchema`: `pk` (HASH), `sk` (RANGE)
  - `AttributeDefinitions`: `pk`, `sk`, `gsi1pk` (ou `GSI1PK`), `gsi1sk` (ou `GSI1SK`)
  - `GlobalSecondaryIndexes`: `GSI1` com `gsi1pk`/`gsi1sk` (ou maiúsculas)
  - `TableStatus`: `ACTIVE`, `IndexStatus`: `ACTIVE`
- [ ] Testes funcionais (PutItem, GetItem, Query) executados e validados (opcional)
- [ ] Evidências coletadas e documentadas (`plan-output.txt`, `apply-output.txt`, `describe-table-output.json`)

## Critérios de rollback (se apply falhar ou comportamento inesperado)
1. **Reverter commit Terraform:**
   ```bash
   git revert HEAD  # ou git reset --hard <commit-anterior>
   ```

2. **Executar terraform apply novamente:**
   ```bash
   cd terraform
   terraform apply -var-file=envs/dev.tfvars
   ```
   - Tabela será recriada com schema antigo (`PK`/`SK`)

3. **Validar rollback:**
   ```bash
   aws dynamodb describe-table --table-name <nome-tabela>
   ```
   - Confirmar que schema voltou para `PK`/`SK` (maiúsculas)

4. **Investigar erro:**
   - Revisar logs de `terraform apply`
   - Verificar se erro foi de sintaxe (corrigir e tentar novamente) ou de infraestrutura AWS (verificar permissões, quotas, etc.)

---

## Notas importantes
- **Não executar apply em produção sem teste em dev/staging primeiro**
- **Backup:** se tabela contém dados críticos, criar snapshot antes de apply (comando: `aws dynamodb create-backup`)
- **Monitoramento:** após apply, monitorar logs de Lambdas para identificar erros relacionados ao schema (ex.: Lambda tentando usar `PK`/`SK` ao invés de `pk`/`sk`)
- **Downtime:** aplicação pode retornar erros (ex.: `ResourceNotFoundException`) durante destroy + create; garantir que aplicação tem retry logic
- **Performance:** tabela recriada herda billing_mode (PAY_PER_REQUEST); sem impacto de performance vs. tabela anterior (mesmo throughput on-demand)
