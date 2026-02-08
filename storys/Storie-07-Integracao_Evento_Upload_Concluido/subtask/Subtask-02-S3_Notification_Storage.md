# Subtask 02: S3 bucket notification (storage) quando trigger_mode = s3_event

## Descrição
No módulo **terraform/10-storage**, implementar a notificação do bucket S3 videos para o SNS topic-video-submitted quando um objeto for criado (evento s3:ObjectCreated:*), somente quando trigger_mode = "s3_event" e topic_video_submitted_arn estiver definido. Usar aws_s3_bucket_notification (ou equivalente) no bucket videos; não criar Lambdas; responsabilidade do módulo storage = configurar eventos do bucket.

## Passos de implementação
1. Criar arquivo `terraform/10-storage/s3_notification.tf` (ou adicionar ao arquivo existente de buckets) com recurso **aws_s3_bucket_notification** associado ao bucket videos (bucket = aws_sqs_queue ou id do bucket videos conforme nome do recurso no módulo).
2. Configurar a notificação de forma condicional: usar count ou dynamic de modo que o recurso (ou o bloco topic) exista apenas quando var.trigger_mode == "s3_event" e var.topic_video_submitted_arn != "" (e não null). Evento = s3:ObjectCreated:*; topic_arn = var.topic_video_submitted_arn.
3. Garantir que não haja recurso aws_lambda_* nem serviço fora da lista (apenas S3 e SNS como destino da notificação).
4. Documentar em comentário: "Integração upload concluído (s3_event): S3 notifica SNS topic-video-submitted ao criar objeto; topic_arn vem do módulo messaging (output)."

## Formas de teste
1. Executar `terraform plan` no módulo 10-storage com trigger_mode = "s3_event" e topic_video_submitted_arn = "arn:aws:sns:..." e verificar que o plano inclui aws_s3_bucket_notification (ou topic dentro de bucket_notification) para o bucket videos; com trigger_mode = "api_publish" ou topic_arn vazio, não deve criar notificação.
2. Verificar que o recurso referencia apenas o bucket videos e var.topic_video_submitted_arn; nenhuma Lambda.
3. Confirmar que a responsabilidade permanece no storage (configuração do bucket); messaging não é alterado nesta subtask.

## Critérios de aceite da subtask
- [ ] O módulo 10-storage cria aws_s3_bucket_notification no bucket videos (evento s3:ObjectCreated:*, destino SNS topic_video_submitted_arn) apenas quando trigger_mode = "s3_event" e topic_video_submitted_arn está definido.
- [ ] Nenhuma Lambda criada; nenhum serviço fora da lista (S3, SNS como destino).
- [ ] Responsabilidade do módulo storage preservada (bucket e eventos do bucket); terraform validate e plan (com variáveis adequadas) passam.
