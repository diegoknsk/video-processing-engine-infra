# Subtask-01: Corrigir range_key deprecated no DynamoDB

## Descrição
Migrar o recurso `aws_dynamodb_table` em `terraform/20-data/dynamodb.tf` para substituir os atributos top-level `hash_key` e `range_key` (deprecated no provider AWS 5.x) por blocos `key_schema`, e substituir o atributo `range_key` dentro de `global_secondary_index` pelo mesmo padrão.

## Contexto do Problema
O `terraform destroy` (e qualquer `plan`/`apply`) emite dois warnings:
```
range_key is deprecated. Use key_schema instead.
```
- Linha 11: `range_key = "sk"` (top-level da tabela)
- Linha 36: `range_key = "gsi1sk"` (dentro do bloco `global_secondary_index`)

O `hash_key = "pk"` na linha 10 também pode ser sinalizado dependendo da versão do provider.

## Passos de Implementação

1. **Confirmar sintaxe do `key_schema` no provider vigente**
   - Consultar a documentação do resource `aws_dynamodb_table` no provider AWS 5.x
   - O bloco `key_schema` aceita `attribute_name` e `key_type` (`HASH` ou `RANGE`)
   - Verificar se o `global_secondary_index` também usa `key_schema` interno ou atributos diretos

2. **Atualizar o recurso `aws_dynamodb_table "videos"`**
   - Remover `hash_key = "pk"` e `range_key = "sk"` do nível top do recurso
   - Adicionar dois blocos `key_schema`:
     ```hcl
     key_schema {
       attribute_name = "pk"
       key_type       = "HASH"
     }
     key_schema {
       attribute_name = "sk"
       key_type       = "RANGE"
     }
     ```

3. **Atualizar o bloco `global_secondary_index "GSI1"`**
   - Remover `hash_key = "gsi1pk"` e `range_key = "gsi1sk"` do bloco GSI
   - Adicionar blocos `key_schema` dentro do `global_secondary_index`:
     ```hcl
     global_secondary_index {
       name = "GSI1"
       key_schema {
         attribute_name = "gsi1pk"
         key_type       = "HASH"
       }
       key_schema {
         attribute_name = "gsi1sk"
         key_type       = "RANGE"
       }
       projection_type = "ALL"
     }
     ```

4. **Executar `terraform plan` e verificar impacto**
   - Verificar se o plan indica `No changes` ou algum `replace`
   - Se houver `replace` na tabela, documentar e avaliar impacto antes de aplicar (tabela existente contém dados?)
   - Garantir que os warnings desaparecem do output do plan

## Formas de Teste

1. Rodar `terraform plan` no módulo `20-data` e verificar ausência dos warnings `range_key is deprecated` e `hash_key is deprecated`
2. Rodar `terraform validate` no módulo `20-data` e confirmar retorno "Success! The configuration is valid."
3. Inspecionar o plan para garantir que PK (`pk`), SK (`sk`), GSI1 (hash `gsi1pk`, range `gsi1sk`) permanecem inalterados em estrutura

## Critérios de Aceite

- [ ] Nenhum warning `range_key is deprecated` ou `hash_key is deprecated` no output do `terraform plan`
- [ ] `terraform validate` retorna sucesso no módulo `20-data`
- [ ] A tabela DynamoDB mantém exatamente as mesmas chaves: PK `pk` (HASH), SK `sk` (RANGE), GSI1 hash `gsi1pk` e range `gsi1sk`
- [ ] O impacto no plan (no-change vs replace) está documentado e compreendido antes de prosseguir para apply
