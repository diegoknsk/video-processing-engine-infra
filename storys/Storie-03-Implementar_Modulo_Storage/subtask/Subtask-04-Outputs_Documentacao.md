# Subtask 04: Outputs (nomes e ARNs) e documentação de variáveis/decisões

## Descrição
Criar `terraform/10-storage/outputs.tf` expondo os nomes e ARNs dos três buckets (videos, images, zip). Documentar no README do módulo (ou em docs) as variáveis do módulo e as decisões técnicas (Block Public Access, encryption, naming, IAM fora do escopo), para que a story cumpra o critério de documentar variáveis e decisões.

## Passos de implementação
1. Criar `terraform/10-storage/outputs.tf` com outputs: `videos_bucket_name` (value = aws_s3_bucket.videos.id), `videos_bucket_arn` (value = aws_s3_bucket.videos.arn); `images_bucket_name`, `images_bucket_arn`; `zip_bucket_name`, `zip_bucket_arn`. Opcionalmente um output map ou list para consumo programático.
2. Garantir que os outputs referenciem apenas recursos existentes no módulo (aws_s3_bucket.videos, .images, .zip) para que terraform plan não tenha referências quebradas.
3. Criar ou atualizar `terraform/10-storage/README.md` com seções: Variáveis (prefix, common_tags, enable_versioning, retention_days, enable_lifecycle_expiration), Outputs (nomes e ARNs), Decisões (Block Public Access habilitado, encryption SSE-S3, versioning opcional, lifecycle configurável, IAM não criado neste módulo).
4. Opcional: incluir exemplo de uso do módulo (module "storage" { source = "..."; prefix = ...; common_tags = ... }).

## Formas de teste
1. Executar `terraform plan` em 10-storage e verificar que os outputs aparecem no plano (Outputs: videos_bucket_name, videos_bucket_arn, ...) sem erro.
2. Ler o README e confirmar que variáveis e decisões estão documentadas.
3. Verificar que outputs.tf não referencia módulo foundation nem recursos inexistentes; apenas aws_s3_bucket.*.

## Critérios de aceite da subtask
- [x] outputs.tf expõe nomes e ARNs dos três buckets (videos, images, zip); seis outputs no mínimo (name + arn por bucket).
- [x] README ou documentação equivalente descreve variáveis do módulo e decisões técnicas (Block Public Access, encryption, versioning, lifecycle, IAM fora do escopo).
- [x] terraform plan lista os outputs sem referências quebradas.
