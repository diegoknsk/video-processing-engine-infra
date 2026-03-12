# Subtask 03: Variáveis, Outputs e Integração com o Root

## Descrição
Adicionar as novas variáveis necessárias em `terraform/20-data/variables.tf`, os outputs da nova tabela em `terraform/20-data/outputs.tf` e, se necessário, expor esses outputs no root `terraform/main.tf`. Todas as adições usam prefixo `chunks_` para isolamento semântico das variáveis/outputs da tabela principal.

## Passos de Implementação

1. **Adicionar variáveis em `terraform/20-data/variables.tf`** (apenas append — sem modificar variáveis existentes):

   ```hcl
   variable "chunks_billing_mode" {
     description = "Billing mode da tabela de chunks (PAY_PER_REQUEST ou PROVISIONED)."
     type        = string
     default     = "PAY_PER_REQUEST"
   }

   variable "enable_chunks_ttl" {
     description = "Habilita TTL na tabela de chunks."
     type        = bool
     default     = false
   }

   variable "chunks_ttl_attribute_name" {
     description = "Nome do atributo TTL na tabela de chunks (número epoch seconds)."
     type        = string
     default     = "TTL"
   }
   ```

2. **Adicionar outputs em `terraform/20-data/outputs.tf`** (apenas append — sem modificar outputs existentes):

   ```hcl
   output "chunks_table_name" {
     description = "Nome da tabela DynamoDB de status de chunks."
     value       = aws_dynamodb_table.video_chunks.name
   }

   output "chunks_table_arn" {
     description = "ARN da tabela DynamoDB de status de chunks."
     value       = aws_dynamodb_table.video_chunks.arn
   }
   ```

3. **Verificar o root `terraform/main.tf`:**
   - As novas variáveis possuem `default` definido, portanto **não é obrigatório** passá-las explicitamente no bloco `module "data"` do root; o root continua funcionando sem alteração.
   - Se o projeto necessitar expor os outputs do módulo no nível root (ex.: para pipeline ou outros módulos), adicionar no `outputs.tf` do root:

   ```hcl
   output "chunks_table_name" {
     value = module.data.chunks_table_name
   }

   output "chunks_table_arn" {
     value = module.data.chunks_table_arn
   }
   ```

   > Verificar se outros módulos (ex.: `50-lambdas-shell`) já consomem outputs do `data`; se sim, adicionar os novos outputs ao root para manter consistência.

## Formas de Teste

1. `terraform validate` no root confirma que as novas variáveis e outputs estão sintaticamente corretos
2. `terraform plan` no root não exige alterações no arquivo `envs/dev.tfvars` (variáveis possuem defaults); confirmar que o plan não falha por variável obrigatória sem valor
3. Verificação manual: outputs `chunks_table_name` e `chunks_table_arn` aparecem no plano de recursos do módulo `data`

## Critérios de Aceite da Subtask
- [ ] Três variáveis adicionadas ao `variables.tf` com prefixo `chunks_`: `chunks_billing_mode` (default `PAY_PER_REQUEST`), `enable_chunks_ttl` (default `false`), `chunks_ttl_attribute_name` (default `"TTL"`)
- [ ] Dois outputs adicionados ao `outputs.tf` do módulo: `chunks_table_name` e `chunks_table_arn`
- [ ] Variáveis existentes do módulo (`prefix`, `common_tags`, `enable_ttl`, `billing_mode`, etc.) não modificadas
- [ ] Outputs existentes do módulo (`table_name`, `table_arn`, `gsi_names`) não modificados
- [ ] `terraform plan` no root não exige novos valores em `envs/dev.tfvars` para a nova tabela (todos os parâmetros têm default)
