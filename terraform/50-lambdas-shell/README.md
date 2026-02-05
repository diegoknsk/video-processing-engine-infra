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
| **q-video-process** | Lambda Video Orchestrator | Desenho: mensagem de vídeo enviado → orquestrador inicia Step Functions. |
| **q-video-zip-finalize** | Lambda Video Finalizer | Desenho: sinal de conclusão → finalizador gera zip e publica SNS completed. |
| **q-video-status-update** | Lambda Video Management | Quando `enable_status_update_consumer = true`; mesma Lambda que atualiza DynamoDB. |

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
