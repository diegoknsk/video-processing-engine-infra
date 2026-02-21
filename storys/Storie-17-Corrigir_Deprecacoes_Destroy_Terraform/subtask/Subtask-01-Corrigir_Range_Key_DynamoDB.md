# Subtask-01: Corrigir range_key deprecated no DynamoDB

## Status para provider ~> 6.0: N/A (não aplicável)

No **AWS provider 6.x** (usado neste projeto — ver `terraform/providers.tf`), o recurso `aws_dynamodb_table` **não** suporta blocos `key_schema`. A configuração válida continua sendo `hash_key` e `range_key` (tabela e GSI). Tentativa de usar `key_schema` resulta em erro: `Blocks of type "key_schema" are not expected here`. Portanto esta subtask fica **encerrada sem alteração** no DynamoDB: manter `hash_key`/`range_key`.

## Descrição (contexto original, provider 5.x)
Migrar o recurso `aws_dynamodb_table` em `terraform/20-data/dynamodb.tf` para substituir os atributos top-level `hash_key` e `range_key` (deprecated no provider AWS 5.x) por blocos `key_schema`, e substituir o atributo `range_key` dentro de `global_secondary_index` pelo mesmo padrão. **Com provider 6.x essa migração não se aplica.**

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

- [x] **Provider 6.x:** Recurso mantido com `hash_key`/`range_key`; `terraform validate` retorna sucesso (key_schema não usado).
- [ ] Nenhum warning `range_key is deprecated` ou `hash_key is deprecated` no output do `terraform plan` (se aparecer em versões futuras do provider, reavaliar).
- [ ] A tabela DynamoDB mantém exatamente as mesmas chaves: PK `pk` (HASH), SK `sk` (RANGE), GSI1 hash `gsi1pk` e range `gsi1sk`
