# Módulo 70-orchestration (Step Functions)

Provisiona a State Machine Step Functions para orquestração do processamento de vídeo: **ProcessVideo** (Lambda Processor) → **Finalização** (SQS ou Lambda) → **Success**. Storie-09.

## Uso pelo root

O root em `terraform/` invoca o módulo passando `prefix`, `common_tags` e os outputs dos módulos **50-lambdas-shell** (Processor e Finalizer ARNs) e **30-messaging** (q-video-zip-finalize URL/ARN quando `finalization_mode = "sqs"`).

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

  q_video_zip_finalize_arn = module.messaging.q_video_zip_finalize_arn
  q_video_zip_finalize_url = module.messaging.q_video_zip_finalize_url
}
```

## Payload padrão (entrada/saída)

### Entrada (StartExecution — Orchestrator envia)

Contrato mínimo que a Lambda Video Orchestrator deve enviar ao chamar `StartExecution`:

| Campo      | Tipo   | Obrigatório | Descrição |
|-----------|--------|-------------|-----------|
| videoId   | string | sim         | Identificador do vídeo (DynamoDB, correlação). |
| userId    | string | sim         | Dono do vídeo (DynamoDB, segurança/partição). |
| s3Bucket  | string | sim         | Bucket onde o vídeo foi enviado. |
| s3VideoKey| string | sim         | Chave S3 do objeto vídeo. |
| requestId | string | não         | Rastreabilidade / idempotência. |

A State Machine repassa esse payload à Lambda Video Processor. A aplicação pode estender o contrato sem remover esses campos.

### Saída (sucesso)

Ao concluir com sucesso (após Processor e, se aplicável, Finalizer):

| Campo        | Tipo   | Descrição |
|-------------|--------|-----------|
| videoId     | string | Eco do input. |
| userId      | string | Eco do input. |
| status      | string | "completed" \| "failed" (ou valor da aplicação). |
| imagesPrefix| string | (opcional) Prefixo das imagens no S3 images. |
| zipS3Key    | string | (opcional) Chave do zip no S3 zip (quando Finalizer já rodou). |

Em **finalization_mode = "sqs"**, a SFN termina após enviar a mensagem para q-video-zip-finalize; a saída da execução pode não incluir `zipS3Key` (a Finalizer preenche ao consumir a fila). Em **finalization_mode = "lambda"**, a SFN invoca a Finalizer e a saída pode incluir `zipS3Key` se a Lambda retornar.

## Decisão de finalização (finalization_mode)

| Valor    | Comportamento | IAM da SFN |
|----------|----------------|------------|
| **sqs**  | State Machine envia mensagem para **q-video-zip-finalize**; a Lambda Video Finalizer é acionada pelo event source mapping (SQS). | lambda:InvokeFunction (Processor); sqs:SendMessage (fila). |
| **lambda** | State Machine **invoca diretamente** a Lambda Video Finalizer após o Processor. | lambda:InvokeFunction (Processor e Finalizer). |

Recomendado: **sqs** para alinhar ao desenho (SQS de finalização → Finalizer).

## Evolução para Map State (fan-out)

A definição atual é sequencial: **ProcessVideo** → **Finalize** → **Success**. A estrutura (estados nomeados, pass-through de payload) está preparada para evolução: em story futura, o estado **ProcessVideo** pode ser substituído por um **Map State** que itera sobre uma lista de itens e invoca o Processor para cada um, sem quebrar o contrato de entrada/saída documentado acima.

## Outputs

- **state_machine_arn** — ARN da State Machine (para Lambda Orchestrator e pipelines).
- **state_machine_name** — Nome da State Machine.
- **log_group_name** — Nome do log group CloudWatch da SFN (retenção configurável por `log_retention_days`).

Quando `enable_stepfunctions = false`, os outputs retornam string vazia (ou o módulo não cria recursos).
