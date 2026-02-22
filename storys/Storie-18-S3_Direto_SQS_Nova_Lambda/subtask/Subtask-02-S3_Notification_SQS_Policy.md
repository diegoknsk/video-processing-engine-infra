# Subtask-02: Criar SQS Queue Policy e S3 Bucket Notification (S3 → SQS Direto)

## Descrição
Configurar no `terraform/upload_integration.tf` (root) dois novos recursos que substituem o fluxo S3 → SNS: (1) `aws_sqs_queue_policy` na fila `q-video-process`, permitindo que o bucket S3 `videos` publique mensagens com `Condition aws:SourceArn`; (2) `aws_s3_bucket_notification` apontando diretamente para a fila SQS, com filtros de prefixo e sufixo restritos ao path de vídeos originais.

> **Pré-requisito:** Subtask-01 concluída (recursos SNS removidos).

---

## Passos de Implementação

1. **Criar `aws_sqs_queue_policy` para `q-video-process` em `upload_integration.tf`**

   A policy deve permitir apenas que o S3 (via `SourceArn` do bucket `videos`) publique na fila. Modelo da policy:

   ```hcl
   resource "aws_sqs_queue_policy" "q_video_process_allow_s3" {
     queue_url = module.messaging.q_video_process_url

     policy = jsonencode({
       Version = "2012-10-17"
       Statement = [
         {
           Sid    = "AllowS3Publish"
           Effect = "Allow"
           Principal = {
             Service = "s3.amazonaws.com"
           }
           Action   = "sqs:SendMessage"
           Resource = module.messaging.q_video_process_arn
           Condition = {
             ArnLike = {
               "aws:SourceArn" = module.storage.videos_bucket_arn
             }
           }
         }
       ]
     })
   }
   ```

   - Usar `module.messaging.q_video_process_url` e `module.messaging.q_video_process_arn` (já existem como outputs do módulo `30-messaging`).
   - Usar `module.storage.videos_bucket_arn` (já existe como output do módulo `10-storage`).
   - A `Condition` com `aws:SourceArn` garante que apenas eventos deste bucket específico são aceitos.

2. **Criar `aws_s3_bucket_notification` S3 → SQS em `upload_integration.tf`**

   ```hcl
   resource "aws_s3_bucket_notification" "videos_to_sqs" {
     depends_on = [aws_sqs_queue_policy.q_video_process_allow_s3]

     bucket = module.storage.videos_bucket_name

     queue {
       queue_arn     = module.messaging.q_video_process_arn
       events        = ["s3:ObjectCreated:Put", "s3:ObjectCreated:CompleteMultipartUpload"]
       filter_prefix = "videos/"
       filter_suffix = "original"
     }
   }
   ```

   - `depends_on`: a notificação deve ser criada **após** a queue policy estar em vigor; sem isso o apply pode falhar com erro de permissão (S3 não consegue enviar para a fila).
   - `events`: `s3:ObjectCreated:Put` (upload simples) e `s3:ObjectCreated:CompleteMultipartUpload` (upload multipart — necessário para arquivos grandes via SDK/presigned URL).
   - `filter_prefix = "videos/"`: garante que apenas objetos no diretório `videos/` disparam a notificação (ignora frames, zips, etc.).
   - `filter_suffix = "original"`: garante que apenas o arquivo original do vídeo dispara (ignora thumbnails, metadados, etc.).

3. **Verificar dependência circular potencial no root**

   O root usa `module.storage.videos_bucket_name` (output de `10-storage`) e `module.messaging.q_video_process_arn` (output de `30-messaging`) — ambos independentes entre si. Não há dependência circular.

4. **Garantir que `q_video_process_url` está exposto em `30-messaging/outputs.tf`**

   Verificar que o output `q_video_process_url` existe (usado no `aws_sqs_queue_policy.queue_url`). Já deve existir de Storie-06; confirmar antes de usar.

---

## Formas de Teste

1. **`terraform plan`:** Deve mostrar `aws_sqs_queue_policy.q_video_process_allow_s3` e `aws_s3_bucket_notification.videos_to_sqs` como `+ will be created`. Confirmar que nenhum recurso existente é destruído inesperadamente.
2. **`terraform apply` + upload de teste:**
   - Fazer upload de um arquivo em `s3://bucket/videos/USER#test/VIDEO#test/original` via AWS CLI:
     ```
     aws s3 cp video.mp4 s3://<prefix>-videos/videos/USER#test/VIDEO#test/original
     ```
   - Acessar no console AWS → SQS → `<prefix>-q-video-process` → Poll for messages.
   - A mensagem deve aparecer com evento `ObjectCreated:Put` ou `ObjectCreated:CompleteMultipartUpload`.
3. **Teste de filtro negativo:** Fazer upload em path diferente (ex.: `teste/arquivo.mp4`) — **não** deve gerar mensagem na fila.
4. **Verificar queue policy no console:** AWS Console → SQS → `<prefix>-q-video-process` → Access policy — confirmar que a policy `AllowS3Publish` está presente com a condition `aws:SourceArn`.

---

## Critérios de Aceite

- [ ] `aws_sqs_queue_policy.q_video_process_allow_s3` criada com `Condition: aws:SourceArn = videos_bucket_arn` (sem abrir para qualquer origem)
- [ ] `aws_s3_bucket_notification.videos_to_sqs` criada com `filter_prefix = "videos/"`, `filter_suffix = "original"`, eventos `ObjectCreated:Put` e `ObjectCreated:CompleteMultipartUpload`
- [ ] `depends_on` na notificação aponta para a queue policy (evitando falha de permissão no apply)
- [ ] Upload de teste em `videos/<userId>/<videoId>/original` gera mensagem em `q-video-process`
- [ ] Upload fora do filtro NÃO gera mensagem em `q-video-process`
- [ ] `terraform plan` mostra apenas os novos recursos como criados, sem destruições inesperadas
