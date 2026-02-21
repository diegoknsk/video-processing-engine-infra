# Storie-17: Corrigir Deprecações e Erro de Destroy no Terraform

## Status
- **Estado:** ⏸️ Aguardando desenvolvimento
- **Data de Conclusão:** [DD/MM/AAAA]

## Descrição
Como engenheiro de infraestrutura, quero corrigir os warnings de deprecação do provider AWS e o erro de `BucketNotEmpty` durante o `terraform destroy`, para que o ciclo completo de apply/destroy funcione sem erros ou avisos e o código esteja alinhado com o provider AWS ~5.x. É necessário criar e destruir recursos com liberdade, fazendo `destroy` ao terminar o uso (lab/dev).

## Objetivo
Eliminar três categorias de problemas encontrados durante `terraform destroy`: (1) atributos `range_key`/`hash_key` deprecated no recurso `aws_dynamodb_table` — migrar para `key_schema`; (2) buckets S3 sem `force_destroy`, causando falha ao destruir buckets com objetos versionados; (3) atributo `.name` deprecated no data source `aws_region` — substituir pelo atributo correto segundo o provider 5.x.

## Escopo Técnico
- **Tecnologias:** Terraform ≥ 1.0, provider AWS ~> 5.0
- **Arquivos afetados:**
  - `terraform/20-data/dynamodb.tf` — substituir `hash_key`/`range_key` top-level e `range_key` do GSI por blocos `key_schema`
  - `terraform/10-storage/buckets.tf` — adicionar `force_destroy = true` nos três recursos `aws_s3_bucket` (videos, images, zip)
  - `terraform/40-auth/datasource.tf` — substituir `data.aws_region.current.name` pelo atributo não-deprecated
  - `terraform/50-lambdas-shell/datasource.tf` — idem ao anterior
- **Componentes afetados:**
  - Tabela DynamoDB `videos` (módulo `20-data`)
  - Buckets S3 `videos`, `images`, `zip` (módulo `10-storage`)
  - Locals de região nos módulos `40-auth` e `50-lambdas-shell`
- **Pacotes/Dependências:** nenhum pacote externo novo; apenas ajustes de HCL para compatibilidade com o provider AWS vigente

## Dependências e Riscos (para estimativa)
- **Dependências:** nenhuma outra story bloqueante; pré-condição é ter credenciais AWS válidas para validar `terraform plan`
- **Riscos:**
  - A migração de `range_key`/`hash_key` para `key_schema` pode gerar um **replace** (destroy + recreate) da tabela DynamoDB se o provider interpretar como mudança estrutural — verificar com `terraform plan` antes de aplicar em produção
  - Adicionar `force_destroy = true` permite que o Terraform apague buckets com objetos; cuidado ao aplicar em ambientes com dados reais
  - O atributo correto para substituir `.name` no `aws_region` data source deve ser confirmado na documentação do provider 5.x antes de codificar

## Subtasks
- [Subtask 01: Corrigir range_key deprecated no DynamoDB](./subtask/Subtask-01-Corrigir_Range_Key_DynamoDB.md)
- [Subtask 02: Adicionar force_destroy nos buckets S3](./subtask/Subtask-02-Force_Destroy_Buckets_S3.md)
- [Subtask 03: Corrigir aws_region.current.name deprecated](./subtask/Subtask-03-Corrigir_Aws_Region_Name.md)
- [Subtask 04: Validação terraform fmt, validate e plan](./subtask/Subtask-04-Validacao_Fmt_Validate_Plan.md)

## Critérios de Aceite da História
- [ ] `terraform destroy` executa sem erros (sem `BucketNotEmpty`) nos três buckets S3
- [ ] `terraform plan` não exibe nenhum warning de `range_key is deprecated` ou `hash_key is deprecated`
- [ ] `terraform plan` não exibe warning de `The attribute "name" is deprecated` nos módulos `40-auth` e `50-lambdas-shell`
- [ ] A tabela DynamoDB mantém as mesmas chaves (PK `pk`, SK `sk`) e o GSI `GSI1` (hash `gsi1pk`, range `gsi1sk`) após a migração para `key_schema`
- [ ] `terraform fmt -recursive` executado sem diferenças de formatação
- [ ] `terraform validate` retorna "Success! The configuration is valid." em todos os módulos alterados
- [ ] Nenhuma credencial ou ARN hardcoded introduzido nos arquivos alterados
- [ ] `terraform plan` revisado para confirmar que a mudança no DynamoDB não causa replace inesperado (ou o impacto documentado e aceito)

## Implementação (registro)
- **Subtask 01 (DynamoDB key_schema):** `terraform/20-data/dynamodb.tf` — `hash_key`/`range_key` substituídos por blocos `key_schema` na tabela e no GSI1.
- **Subtask 02 (force_destroy S3):** `terraform/10-storage/buckets.tf` — `force_destroy = true` nos três buckets (videos, images, zip) para permitir destroy sem erro BucketNotEmpty.
- **Subtask 03 (aws_region):** `terraform/40-auth/datasource.tf` e `terraform/50-lambdas-shell/datasource.tf` — `data.aws_region.current.name` substituído por `data.aws_region.current.id`.
- **Subtask 04:** Pendente — executar `terraform fmt -recursive`, `terraform validate` e `terraform plan` para validação final.

## Rastreamento (dev tracking)
- **Início:** —
- **Fim:** —
- **Tempo total de desenvolvimento:** —
