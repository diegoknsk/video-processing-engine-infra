# Subtask 02: Criar Recurso aws_dynamodb_table video-chunks

## Descrição
Criar o arquivo `terraform/20-data/dynamodb-chunks.tf` contendo o recurso `aws_dynamodb_table.video_chunks` com chave composta `pk`/`sk`, TTL opcional e tags do foundation. Nenhum arquivo existente do módulo será modificado nesta subtask.

## Passos de Implementação

1. **Criar o arquivo `terraform/20-data/dynamodb-chunks.tf`** com o seguinte conteúdo:

   ```hcl
   resource "aws_dynamodb_table" "video_chunks" {
     name         = "${var.prefix}-video-chunks"
     billing_mode = var.chunks_billing_mode
     hash_key     = "pk"
     range_key    = "sk"

     attribute {
       name = "pk"
       type = "S"
     }

     attribute {
       name = "sk"
       type = "S"
     }

     dynamic "ttl" {
       for_each = var.enable_chunks_ttl ? [1] : []
       content {
         attribute_name = var.chunks_ttl_attribute_name
         enabled        = true
       }
     }

     tags = merge(var.common_tags, {
       Name = "${var.prefix}-video-chunks"
     })
   }
   ```

2. **Verificar o isolamento:** confirmar que o arquivo não referencia nem modifica o recurso `aws_dynamodb_table.videos` existente em nenhuma linha.

3. **Verificar nomenclatura:** confirmar que o nome do recurso Terraform (`video_chunks`) e o nome da tabela AWS (`{prefix}-video-chunks`) são únicos no módulo e não colidem com recursos existentes.

## Formas de Teste

1. `terraform validate` no root (`terraform/`) deve retornar "The configuration is valid." após a criação do arquivo
2. `terraform plan` no root deve mostrar apenas `+ aws_dynamodb_table.video_chunks` como novo recurso; nenhum `destroy` ou `update` na tabela `aws_dynamodb_table.videos`
3. Revisão manual do arquivo gerado: confirmar ausência de referências ao recurso `aws_dynamodb_table.videos` ou a atributos de GSI (que pertencem apenas à tabela principal)

## Critérios de Aceite da Subtask
- [ ] Arquivo `terraform/20-data/dynamodb-chunks.tf` criado com o recurso `aws_dynamodb_table.video_chunks`
- [ ] Chaves definidas: `hash_key = "pk"` e `range_key = "sk"`, ambas do tipo `"S"`
- [ ] Bloco `ttl` dinâmico controlado por `var.enable_chunks_ttl`; nome do atributo via `var.chunks_ttl_attribute_name`
- [ ] Tags aplicadas com `merge(var.common_tags, { Name = ... })`, reutilizando variáveis já passadas pelo root
- [ ] `terraform validate` no root sem erros após criação do arquivo
- [ ] `terraform plan` mostra `+ create` exclusivamente para `aws_dynamodb_table.video_chunks`; sem alterações na tabela principal
