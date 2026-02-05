# Módulo 20-data (DynamoDB Vídeos)

Provisiona uma tabela DynamoDB para rastrear vídeos e estado do processamento (status, datas, ZipS3Key, ErrorMessage, UserId, VideoId). Consome prefix e tags do módulo 00-foundation; não cria recursos IAM.

## Modelo de dados e acessos

### Tabela principal (acesso por usuário)

- **PK (Partition Key):** UserId (ex.: `USER#<userId>`).
- **SK (Sort Key):** VideoId (ex.: `VIDEO#<videoId>`).

| Acesso | Onde | Chave |
|--------|------|--------|
| Listar vídeos de um usuário | Tabela principal | Query PK = UserId |
| Obter um vídeo (UserId + VideoId) | Tabela principal | GetItem PK = UserId, SK = VideoId |
| Buscar por VideoId (atualizar status, ZipS3Key, etc.) | GSI1 | Query GSI1PK = VideoId |

### GSI1 (acesso por VideoId)

- **GSI1PK:** VideoId (ex.: `VIDEO#<videoId>`).
- **GSI1SK:** UserId (ex.: `USER#<userId>`).

A aplicação (Lambdas) deve persistir UserId e VideoId nos atributos e usar PK=UserId, SK=VideoId na tabela principal; e GSI1PK=VideoId, GSI1SK=UserId no GSI.

Atributos não-chave (Status, CreatedAt, UpdatedAt, ZipS3Key, ErrorMessage, UserId, VideoId) são definidos pela aplicação ao escrever itens.

## Variáveis

| Variável | Tipo | Obrigatório | Default | Descrição |
|----------|------|-------------|---------|-----------|
| `prefix` | string | sim | - | Prefixo de naming do foundation (ex.: `video-processing-engine-dev`). |
| `common_tags` | map(string) | sim | - | Tags padrão do foundation. |
| `enable_ttl` | bool | não | `false` | Habilita TTL na tabela. |
| `ttl_attribute_name` | string | não | `TTL` | Nome do atributo TTL (epoch em segundos). |
| `billing_mode` | string | não | `PAY_PER_REQUEST` | PAY_PER_REQUEST ou PROVISIONED. |
| `environment` | string | não | `null` | Ambiente (opcional). |

## Outputs

| Output | Descrição |
|--------|-----------|
| `table_name` | Nome da tabela DynamoDB. |
| `table_arn` | ARN da tabela. |
| `gsi1_name` | Nome do GSI1 (ByVideoId). |
| `gsi_names` | Lista dos nomes dos GSIs. |

## Decisões técnicas

- **Somente DynamoDB:** nenhum recurso IAM neste módulo; políticas de acesso à tabela na story de Lambdas/IAM.
- **Naming:** nome da tabela `{prefix}-videos`.
- **GSI:** um GSI (GSI1) com projection ALL; GSI1PK/GSI1SK documentados para consumo pelas Lambdas.
- **TTL:** opcional; quando `enable_ttl = true`, atributo configurável (ex.: TTL).

## Uso (exemplo)

O caller (root) deve passar `prefix` e `common_tags` a partir dos outputs do 00-foundation:

```hcl
module "data" {
  source = "./20-data"

  prefix      = module.foundation.prefix
  common_tags = module.foundation.common_tags

  enable_ttl         = false
  ttl_attribute_name = "TTL"
  billing_mode       = "PAY_PER_REQUEST"
}
```
