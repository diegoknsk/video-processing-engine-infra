# Módulo 70-orchestration (Step Functions)

Provisiona a State Machine Step Functions para orquestração do processamento de vídeo com **Map State** (fan-out de chunks): **Map** (Lambda Video Processor por chunk) → **PrepareUpdateMessage** → **Update Status** (SQS q-video-status-update) → **Success**. Storie-09, Storie-23.

## Fluxo da State Machine

1. **Map** — Itera sobre `$.chunks` (modo INLINE); para cada item invoca a Lambda Video Processor com o payload do ItemSelector; resultado em `$.chunkResults`.
2. **PrepareUpdateMessage** — Monta o corpo da mensagem de status (videoId, userId, status=2, progressPercent=100, s3BucketFrames, framesPrefix).
3. **Update Status** — Envia mensagem para a fila SQS **q-video-status-update** (conclusão do processamento).
4. **Success** — Fim da execução.

## Uso pelo root

O root em `terraform/` invoca o módulo passando `prefix`, `common_tags`, outputs dos módulos **50-lambdas-shell** (Processor e Finalizer ARNs) e **30-messaging** (q-video-zip-finalize e **q-video-status-update** URLs/ARNs).

```hcl
module "orchestration" {
  source = "./70-orchestration"

  prefix       = module.foundation.prefix
  common_tags  = module.foundation.common_tags

  enable_stepfunctions = true
  log_retention_days   = 14
  finalization_mode    = "sqs"  # ou "lambda"

  lambda_processor_arn = module.lambdas.lambda_video_processor_arn
  lambda_finalizer_arn = module.lambdas.lambda_video_finalizer_arn

  q_video_zip_finalize_arn  = module.messaging.q_video_zip_finalize_arn
  q_video_zip_finalize_url  = module.messaging.q_video_zip_finalize_url
  q_video_status_update_url = module.messaging.q_video_status_update_url

  lab_role_arn = var.lab_role_arn
}
```

## Contrato de entrada (StartExecution)

A Lambda Video Orchestrator (ou outro iniciador) deve enviar ao `StartExecution` um payload com os campos abaixo. A State Machine usa `chunks` para o Map e repassa ao Processor, via ItemSelector, os campos necessários por iteração.

| Campo           | Tipo   | Obrigatório | Descrição |
|-----------------|--------|-------------|-----------|
| contractVersion | string | sim         | Versão do contrato (compatibilidade). |
| videoId         | string | sim         | Identificador do vídeo (DynamoDB, correlação). |
| userId          | string | sim         | Dono do vídeo (DynamoDB, segurança/partição). |
| s3BucketVideo   | string | sim         | Bucket onde o vídeo foi enviado. |
| s3KeyVideo      | string | sim         | Chave S3 do objeto vídeo. |
| output          | object | sim         | Destinos de saída: `manifestBucket`, `framesBucket`, `framesBasePrefix`. |
| chunks          | array  | sim         | Lista de chunks a processar em paralelo (cada item é repassado ao Processor como `chunk`). |
| requestId       | string | não         | Rastreabilidade / idempotência. |

O **ItemSelector** do Map passa a cada iteração: `contractVersion`, `videoId`, `userId`, `s3BucketVideo`, `s3KeyVideo`, `output` e o item atual em `chunk`.

## Decisão de finalização (finalization_mode)

| Valor    | Comportamento | IAM da SFN |
|----------|----------------|------------|
| **sqs**  | State Machine envia mensagem para **q-video-zip-finalize**; a Lambda Video Finalizer é acionada pelo event source mapping (SQS). A fila **q-video-status-update** recebe a mensagem de conclusão (status=2, progressPercent=100) ao fim do Map. | lambda:InvokeFunction (Processor); sqs:SendMessage (q-video-zip-finalize e q-video-status-update). |
| **lambda** | State Machine **invoca diretamente** a Lambda Video Finalizer após o Processor. | lambda:InvokeFunction (Processor e Finalizer). |

Recomendado: **sqs** para alinhar ao desenho (SQS de finalização → Finalizer). A Lab Role deve ter permissão `sqs:SendMessage` para **q-video-status-update**.

## Outputs

- **state_machine_arn** — ARN da State Machine (para Lambda Orchestrator e pipelines).
- **state_machine_name** — Nome da State Machine.
- **log_group_name** — Nome do log group CloudWatch da SFN (retenção configurável por `log_retention_days`).

Quando `enable_stepfunctions = false`, os outputs retornam string vazia (ou o módulo não cria recursos).
