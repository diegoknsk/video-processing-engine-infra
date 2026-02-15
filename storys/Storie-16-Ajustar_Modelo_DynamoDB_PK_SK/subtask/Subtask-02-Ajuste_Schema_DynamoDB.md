# Subtask 02: Ajuste de schema DynamoDB (pk/sk, attributes, naming)

## Descrição
Ajustar o recurso `aws_dynamodb_table` em `terraform/20-data/dynamodb.tf` para usar nomenclatura de chaves em minúsculas (`pk`/`sk`) ao invés de maiúsculas (`PK`/`SK`). Atualizar declaração de attributes e referências de `hash_key`/`range_key`. Manter billing_mode, TTL, tags e outras configurações existentes. Esta mudança força recriação da tabela (Terraform destroy + create).

## Contexto
A tabela atual usa:
```hcl
hash_key  = "PK"
range_key = "SK"
attribute { name = "PK", type = "S" }
attribute { name = "SK", type = "S" }
```

Deve ser ajustado para:
```hcl
hash_key  = "pk"
range_key = "sk"
attribute { name = "pk", type = "S" }
attribute { name = "sk", type = "S" }
```

Nomenclatura de GSI será definida na Subtask 01 (decisão Opção A ou B).

## Passos de implementação
1. **Abrir `terraform/20-data/dynamodb.tf`**

2. **Ajustar hash_key e range_key:**
   ```hcl
   hash_key  = "pk"   # era "PK"
   range_key = "sk"   # era "SK"
   ```

3. **Ajustar attributes da tabela principal:**
   ```hcl
   attribute {
     name = "pk"   # era "PK"
     type = "S"
   }

   attribute {
     name = "sk"   # era "SK"
     type = "S"
   }
   ```

4. **Manter configurações existentes:**
   - `name = "${var.prefix}-videos"` (sem alteração)
   - `billing_mode = var.billing_mode` (sem alteração)
   - `ttl { enabled = var.enable_ttl, attribute_name = var.ttl_attribute_name }` (sem alteração)
   - `tags = merge(var.common_tags, { Name = "${var.prefix}-videos" })` (sem alteração)

5. **Atualizar comentários no topo do arquivo:**
   - Ajustar comentário de documentação para referenciar `pk`/`sk` ao invés de `PK`/`SK`
   - Exemplo antes:
     ```
     # Tabela principal: PK = UserId, SK = VideoId → Query(PK=UserId) lista vídeos; GetItem(PK, SK) obtém um vídeo.
     ```
   - Exemplo depois:
     ```
     # Tabela principal: pk = USER#{userId}, sk = VIDEO#{videoId} → Query(pk=USER#{userId}) lista vídeos; GetItem(pk, sk) obtém um vídeo.
     ```

6. **Executar `terraform fmt`:**
   ```bash
   cd terraform/20-data
   terraform fmt
   ```

## Formas de teste
1. **Validação de sintaxe:**
   ```bash
   cd terraform  # root do Terraform
   terraform init  # se necessário
   terraform validate
   ```
   - Deve retornar: "Success! The configuration is valid."

2. **Visualizar plano de mudança:**
   ```bash
   cd terraform
   terraform plan -var-file=envs/dev.tfvars -out=planfile
   ```
   - **Esperado:** plano mostra `-/+ aws_dynamodb_table.videos` (destroy + create)
   - **Motivo:** alteração de `hash_key`/`range_key` força substituição (ForceNew = true)
   - **Verificar:**
     - `-hash_key = "PK"` → `+hash_key = "pk"`
     - `-range_key = "SK"` → `+range_key = "sk"`
     - `-attribute.0.name = "PK"` → `+attribute.0.name = "pk"`
     - `-attribute.1.name = "SK"` → `+attribute.1.name = "sk"`

3. **NÃO executar `terraform apply` nesta subtask:**
   - Apply será feito na Subtask 05 (após validação completa de GSI e documentação)
   - Salvar planfile para revisão: `terraform show planfile > plan-output.txt`

## Critérios de aceite da subtask
- [ ] `terraform/20-data/dynamodb.tf` atualizado com `hash_key = "pk"` e `range_key = "sk"` (minúsculas)
- [ ] Attributes `pk` e `sk` declarados corretamente (tipo "S")
- [ ] Comentários no arquivo atualizados para referenciar `pk`/`sk` e padrão `USER#{userId}`/`VIDEO#{videoId}`
- [ ] `terraform fmt` executado sem alterações adicionais (código já formatado)
- [ ] `terraform validate` no root passa sem erros
- [ ] `terraform plan` no root mostra recriação da tabela (destroy + create) com hash_key/range_key corretos
- [ ] Billing_mode, TTL, tags e outros recursos mantidos sem alteração (apenas schema de chaves mudou)

## Exemplo de diff esperado (para referência)
```diff
--- a/terraform/20-data/dynamodb.tf
+++ b/terraform/20-data/dynamodb.tf
@@ -1,5 +1,5 @@
-# Tabela DynamoDB para metadados e status dos vídeos (Video Processing MVP).
-# Tabela principal: PK = UserId, SK = VideoId → Query(PK=UserId) lista vídeos; GetItem(PK, SK) obtém um vídeo.
+# Tabela DynamoDB para metadados e status dos vídeos (Video Processing MVP).
+# Tabela principal: pk = USER#{userId}, sk = VIDEO#{videoId} → Query(pk=USER#{userId}) lista vídeos; GetItem(pk, sk) obtém um vídeo.
 
 resource "aws_dynamodb_table" "videos" {
   name         = "${var.prefix}-videos"
   billing_mode = var.billing_mode
 
-  hash_key  = "PK"
-  range_key = "SK"
+  hash_key  = "pk"
+  range_key = "sk"
 
   attribute {
-    name = "PK"
+    name = "pk"
     type = "S"
   }
 
   attribute {
-    name = "SK"
+    name = "sk"
     type = "S"
   }
```

## Notas importantes
- **Recriação de tabela:** esta mudança é **destrutiva** (todos os dados na tabela serão perdidos)
- **Ambiente hackathon:** aceitável; dados são efêmeros
- **Downtime:** a tabela ficará indisponível por ~2-5 minutos durante destroy + create
- **Rollback:** se necessário, reverter commit e executar `terraform apply` novamente (recria tabela com schema antigo)
- **Lambdas:** garantir que código Lambda foi ajustado (Subtask 01) antes de apply (Subtask 05)
