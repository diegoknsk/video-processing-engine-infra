# Subtask-02: Adicionar force_destroy nos buckets S3

## Descrição
Adicionar o argumento `force_destroy = true` nos três recursos `aws_s3_bucket` definidos em `terraform/10-storage/buckets.tf` (buckets `videos`, `images` e `zip`), eliminando o erro `BucketNotEmpty` que ocorre durante `terraform destroy` quando os buckets possuem objetos ou versões de objetos.

## Contexto do Problema
O `terraform destroy` falha com:
```
Error: deleting S3 Bucket (video-processing-engine-dev-videos): api error BucketNotEmpty:
The bucket you tried to delete is not empty. You must delete all versions in the bucket.
```
O bucket tem versionamento habilitado (`enable_versioning = true`), logo existem versões de objetos que impedem a exclusão padrão via API S3. O Terraform só consegue esvaziar e excluir um bucket automaticamente quando `force_destroy = true` está definido.

Os três buckets afetados:
- `aws_s3_bucket.videos` — `${var.prefix}-videos`
- `aws_s3_bucket.images` — `${var.prefix}-images`
- `aws_s3_bucket.zip` — `${var.prefix}-zip`

## Passos de Implementação

1. **Abrir `terraform/10-storage/buckets.tf`**
   - Localizar cada um dos três blocos `resource "aws_s3_bucket"`

2. **Adicionar `force_destroy = true` em cada bucket**
   - Adicionar o argumento logo após o argumento `bucket`, antes das `tags`, em cada um dos três recursos:
     ```hcl
     resource "aws_s3_bucket" "videos" {
       bucket        = "${var.prefix}-videos"
       force_destroy = true
       ...
     }
     ```
   - Repetir para `aws_s3_bucket.images` e `aws_s3_bucket.zip`

3. **Verificar impacto no `terraform plan`**
   - `force_destroy` é um meta-argumento local do Terraform e **não** gera replace nem mudança de infraestrutura
   - O plan deve mostrar apenas `~ update in-place` (mudança de state local) ou `No changes` — confirmar que não há replace

## Atenção / Risco
> `force_destroy = true` permite que o Terraform apague o bucket **mesmo com dados dentro**. Em ambientes de produção com dados reais, avaliar se esse comportamento é aceitável ou se deve ser `false` (e o esvaziamento feito manualmente antes do destroy). Para ambientes de lab/dev, `true` é o padrão recomendado pelas regras do repositório.

## Formas de Teste

1. Rodar `terraform plan` no módulo `10-storage` e confirmar que não há replace e que os warnings não aumentaram
2. Rodar `terraform destroy` em ambiente de lab com bucket contendo objetos e verificar que o destroy completa sem erro `BucketNotEmpty`
3. Rodar `terraform validate` no módulo `10-storage` para confirmar que o HCL está válido

## Critérios de Aceite

- [ ] Os três recursos `aws_s3_bucket` (videos, images, zip) possuem `force_destroy = true`
- [ ] `terraform destroy` não retorna `BucketNotEmpty` para nenhum dos três buckets
- [ ] `terraform plan` confirma que a mudança não é um replace (sem recriação do bucket)
- [ ] `terraform validate` retorna sucesso no módulo `10-storage`
