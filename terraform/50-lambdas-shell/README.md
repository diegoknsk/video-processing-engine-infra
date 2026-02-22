# Módulo 50-lambdas-shell (Storie-08)

Provisiona as cinco Lambdas **em casca** do Processador Video MVP: **Auth**, **Video Management**, **Video Orchestrator**, **Video Processor**, **Video Finalizer**. Runtime e handler parametrizáveis; artefato `artifacts/empty.zip`; IAM least privilege por função; variáveis de ambiente por Lambda; event source mappings SQS → Lambda conforme o desenho.

---

## Permissões por Lambda (Least Privilege)

| Lambda | CloudWatch Logs | S3 | DynamoDB | SQS | SNS | Step Functions | Justificativa |
|--------|-----------------|-----|----------|-----|-----|----------------|---------------|
| **Auth** | ✅ CreateLogStream, PutLogEvents | — | — | — | — | — | Apenas logs; autenticação via Cognito/API Gateway. |
| **Video Management** | ✅ | ✅ videos: PutObject, GetObject | ✅ PutItem, GetItem, UpdateItem | ✅ q-video-status-update: ReceiveMessage, DeleteMessage, GetQueueAttributes | ✅ topic-video-submitted: Publish | — | API: cria registro, presigned URL; consumer da fila status-update; publica no SNS (api_publish). |
| **Video Orchestrator** | ✅ | — | — | ✅ q-video-process: ReceiveMessage, DeleteMessage, GetQueueAttributes | — | ✅ StartExecution | Consome q-video-process e inicia Step Functions. |
| **Video Processor** | ✅ | ✅ videos: GetObject; images: PutObject | ✅ UpdateItem | ✅ status-update e zip-finalize: SendMessage | — | — | Invocada pela Step Function: lê vídeo, grava frames, atualiza status, envia para filas. |
| **Video Finalizer** | ✅ | ✅ images: GetObject; zip: PutObject | ✅ UpdateItem | ✅ q-video-zip-finalize: ReceiveMessage, DeleteMessage, GetQueueAttributes | ✅ topic-video-completed: Publish | — | Consome q-video-zip-finalize: gera zip, atualiza DynamoDB, publica SNS completed. |

Nenhuma política ampla (`s3:*`, `dynamodb:*`); cada função recebe apenas os recursos e ações necessários.

---

## Event Source Mappings

| Fila SQS | Lambda | Observação |
|----------|--------|------------|
| **q-video-process** | Lambda Video Dispatcher | Desenho (Storie-18): S3 notifica SQS direto; dispatcher recebe evento e despacha o pipeline. |
| **q-video-zip-finalize** | Lambda Video Finalizer | Desenho: sinal de conclusão → finalizador gera zip e publica SNS completed. |
| **q-video-status-update** | Lambda Video Management | Quando `enable_status_update_consumer = true`; mesma Lambda que atualiza DynamoDB. |

---

## Contrato de entrada — LambdaVideoDispatcher

**Origem:** SQS `q-video-process`, populada por notificação de evento S3 (upload no bucket videos com prefix `videos/` e suffix `original`).

**Estrutura do Body (mensagem SQS):** O `Body` é um JSON com o envelope de evento S3 padrão:

```json
{
  "Records": [
    {
      "eventVersion": "2.1",
      "eventSource": "aws:s3",
      "awsRegion": "us-east-1",
      "eventName": "ObjectCreated:Put",
      "s3": {
        "bucket": { "name": "<bucket-name>", "arn": "arn:aws:s3:::..." },
        "object": {
          "key": "videos/USER%23abc123/VIDEO%23xyz456/original",
          "size": 104857600
        }
      }
    }
  ]
}
```

**Campos obrigatórios para o consumer:**

| Campo | Caminho no JSON | Observação |
|-------|-----------------|------------|
| **bucket** | `Records[0].s3.bucket.name` | Nome do bucket (sem prefixo ARN). |
| **key (raw)** | `Records[0].s3.object.key` | **URL-encoded**: `#` → `%23`; o consumer **deve** aplicar URL-decode antes de usar. |
| **key (decodificado)** | `urldecode(Records[0].s3.object.key)` | Ex.: `videos/USER#abc123/VIDEO#xyz456/original`. |

**Edge cases:**

| Situação | Comportamento esperado |
|----------|------------------------|
| `Records` vazio ou nulo | Rejeitar mensagem (log de erro; não deletar da fila para DLQ). |
| `Records` com mais de 1 item | Processar cada record individualmente. |
| `key` com caracteres especiais | Aplicar URL-decode completo (RFC 3986) antes de usar. |
| `eventName` diferente de `ObjectCreated:*` | Ignorar; logar como warning. |
| `s3.object.size` igual a 0 | Logar warning. |

---

## Variáveis (caller/root)

O root passa `prefix`, `common_tags`, `artifact_path` (ex.: `"${path.root}/artifacts/empty.zip"`) e os outputs dos módulos **storage**, **data**, **messaging** e, quando existir, **orchestration** (`step_function_arn`). Exemplo:

```hcl
module "lambdas" {
  source = "./50-lambdas-shell"

  prefix      = module.foundation.prefix
  common_tags = module.foundation.common_tags

  runtime     = "python3.12"
  handler     = "index.handler"
  artifact_path = "${path.root}/artifacts/empty.zip"

  table_name  = module.data.table_name
  table_arn   = module.data.table_arn

  videos_bucket_name = module.storage.videos_bucket_name
  videos_bucket_arn  = module.storage.videos_bucket_arn
  images_bucket_name = module.storage.images_bucket_name
  images_bucket_arn  = module.storage.images_bucket_arn
  zip_bucket_name   = module.storage.zip_bucket_name
  zip_bucket_arn    = module.storage.zip_bucket_arn

  q_video_process_url       = module.messaging.q_video_process_url
  q_video_process_arn       = module.messaging.q_video_process_arn
  q_video_status_update_url = module.messaging.q_video_status_update_url
  q_video_status_update_arn = module.messaging.q_video_status_update_arn
  q_video_zip_finalize_url  = module.messaging.q_video_zip_finalize_url
  q_video_zip_finalize_arn  = module.messaging.q_video_zip_finalize_arn

  topic_video_submitted_arn = module.messaging.topic_video_submitted_arn
  topic_video_completed_arn = module.messaging.topic_video_completed_arn

  step_function_arn         = ""  # ou module.orchestration.state_machine_arn quando Storie-09
  enable_status_update_consumer = true
}
```

Init/plan/apply no **root** (`terraform/`).
