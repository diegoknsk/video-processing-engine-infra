# Módulo 10-storage (Buckets S3)

Provisiona três buckets S3 para o Video Processing Engine MVP: **videos** (upload), **images** (frames extraídos) e **zip** (resultado final). Consome prefix e tags do módulo 00-foundation; não cria recursos IAM.

## Variáveis

| Variável | Tipo | Obrigatório | Default | Descrição |
|----------|------|-------------|---------|-----------|
| `prefix` | string | sim | - | Prefixo de naming do foundation (ex.: `video-processing-engine-dev`). |
| `common_tags` | map(string) | sim | - | Tags padrão do foundation (Project, Environment, ManagedBy, Owner). |
| `region` | string | não | `us-east-1` | Região AWS dos buckets. |
| `enable_versioning` | bool | não | `false` | Habilita versionamento nos buckets. |
| `retention_days` | number | não | `null` | Dias para expirar objetos via lifecycle; 0 ou null desabilita. |
| `enable_lifecycle_expiration` | bool | não | `true` | Habilita regra de expiração quando `retention_days` > 0. |
| `environment` | string | não | `null` | Ambiente (opcional, para consistência com foundation). |

A notificação de upload concluído (S3 → SQS q-video-process) é configurada no **root** (Storie-18); este módulo apenas expõe os outputs do bucket (ex.: `videos_bucket_name`, `videos_bucket_arn`) para o root.

## Outputs

| Output | Descrição |
|--------|-----------|
| `videos_bucket_name` | Nome do bucket de vídeos. |
| `videos_bucket_arn` | ARN do bucket de vídeos. |
| `images_bucket_name` | Nome do bucket de imagens. |
| `images_bucket_arn` | ARN do bucket de imagens. |
| `zip_bucket_name` | Nome do bucket de zip. |
| `zip_bucket_arn` | ARN do bucket de zip. |

## Decisões técnicas

- **Block Public Access:** todos os buckets com as quatro opções habilitadas (block_public_acls, block_public_policy, ignore_public_acls, restrict_public_buckets), conforme recomendação AWS.
- **Encryption:** SSE-S3 (AES256); sem KMS nesta story para simplicidade.
- **Naming:** `{prefix}-videos`, `{prefix}-images`, `{prefix}-zip` para unicidade e rastreabilidade.
- **Versioning:** opcional, controlado por `enable_versioning` (Enabled ou Suspended).
- **Lifecycle:** expiração configurável via `retention_days` e `enable_lifecycle_expiration`; quando `retention_days` é 0 ou null, nenhuma regra de expiração é aplicada.
- **IAM:** não criado neste módulo; políticas de acesso aos buckets ficam na story de Lambdas/IAM.

## Uso (exemplo)

O caller (root ou pipeline) deve passar `prefix` e `common_tags` a partir dos outputs do 00-foundation:

```hcl
module "storage" {
  source = "./10-storage"

  prefix      = module.foundation.prefix
  common_tags = module.foundation.common_tags

  enable_versioning          = false
  retention_days             = 30
  enable_lifecycle_expiration = true
}
```

Execução standalone (exemplo com tfvars):

```bash
terraform init
terraform plan -var="prefix=video-processing-engine-dev" -var='common_tags={"Project"="video-processing-engine","Environment"="dev","ManagedBy"="Terraform","Owner"="infra"}'
```
