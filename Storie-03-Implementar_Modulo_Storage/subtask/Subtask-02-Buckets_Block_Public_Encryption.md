# Subtask 02: Recursos S3 (buckets) com Block Public Access e encryption

## Descrição
Criar os recursos Terraform para os três buckets S3: videos (upload), images (frames), zip (resultado final). Cada bucket deve usar o prefix e common_tags do foundation no nome e nas tags; Block Public Access habilitado (quatro opções true) e encryption habilitada (SSE-S3/AES256). Não criar recursos IAM.

## Passos de implementação
1. Criar arquivo `terraform/10-storage/buckets.tf` (ou `main.tf`) com três recursos `aws_s3_bucket`: um para videos (nome ex.: `"${var.prefix}-videos"`), um para images (`"${var.prefix}-images"`), um para zip (`"${var.prefix}-zip"`); tags = var.common_tags (ou merge com tags específicas).
2. Para cada bucket, criar recurso `aws_s3_bucket_public_access_block` com block_public_acls = true, block_public_policy = true, ignore_public_acls = true, restrict_public_buckets = true (vinculado ao bucket via bucket = aws_s3_bucket.xxx.id).
3. Para cada bucket, criar recurso `aws_s3_bucket_server_side_encryption_configuration` com rule { apply_server_side_encryption_by_default { sse_algorithm = "AES256" } } e bucket_id = aws_s3_bucket.xxx.id.
4. Garantir que providers.tf ou configuração do módulo exista (provider AWS herdado ou explícito); não declarar nenhum aws_iam_role, aws_iam_policy ou aws_iam_role_policy_attachment.

## Formas de teste
1. Executar `terraform plan` em `terraform/10-storage/` passando -var="prefix=video-processing-engine-dev" e -var="common_tags={}" (ou tfvars) e verificar que o plano lista criação dos 3 buckets, 3 public_access_block e 3 server_side_encryption_configuration; sem erros de referência.
2. Buscar em `terraform/10-storage/*.tf` por "aws_iam" e confirmar que não há recursos IAM.
3. Verificar nos recursos aws_s3_bucket_public_access_block que as quatro opções estão true.

## Critérios de aceite da subtask
- [ ] Existem três recursos aws_s3_bucket (videos, images, zip) com nomes usando var.prefix e tags usando var.common_tags.
- [ ] Cada bucket possui aws_s3_bucket_public_access_block com block_public_acls, block_public_policy, ignore_public_acls, restrict_public_buckets = true.
- [ ] Cada bucket possui aws_s3_bucket_server_side_encryption_configuration com SSE-S3 (AES256); nenhum recurso IAM no módulo.
