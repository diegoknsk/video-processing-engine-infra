# Subtask 03: SNS topic policy (messaging) quando trigger_mode = s3_event

## Descrição
No módulo **terraform/30-messaging**, implementar a política SNS no tópico topic-video-submitted que permite que o bucket S3 videos publique no tópico, somente quando trigger_mode = "s3_event" e videos_bucket_arn estiver definido. Usar aws_sns_topic_policy; não criar Lambdas; responsabilidade do módulo messaging = configurar quem pode publicar no tópico.

## Passos de implementação
1. Criar arquivo `terraform/30-messaging/sns_topic_policy.tf` (ou adicionar ao existente) com recurso **aws_sns_topic_policy** associado ao tópico topic-video-submitted (arn = aws_sns_topic.topic_video_submitted.arn).
2. Na policy, incluir Statement que permita o serviço S3 (Principal Service = s3.amazonaws.com) do bucket videos (Condition: SourceArn = var.videos_bucket_arn) a publicar (Action SNS:Publish) no tópico. Configurar de forma condicional: count ou dynamic para criar a policy apenas quando var.trigger_mode == "s3_event" e var.videos_bucket_arn != "" (e não null).
3. Garantir que não haja recurso aws_lambda_* nem serviço fora da lista (apenas SNS topic policy para S3).
4. Documentar em comentário: "Integração upload concluído (s3_event): permite que o bucket videos publique no tópico; bucket_arn vem do módulo storage (output)."

## Formas de teste
1. Executar `terraform plan` no módulo 30-messaging com trigger_mode = "s3_event" e videos_bucket_arn = "arn:aws:s3:::bucket-name" e verificar que o plano inclui aws_sns_topic_policy no tópico topic-video-submitted; com trigger_mode = "api_publish" ou bucket_arn vazio, não deve criar policy.
2. Verificar que a policy referencia apenas o tópico topic-video-submitted e var.videos_bucket_arn; nenhuma Lambda.
3. Confirmar que a responsabilidade permanece no messaging (configuração do tópico e quem publica); storage não é alterado nesta subtask.

## Critérios de aceite da subtask
- [ ] O módulo 30-messaging cria aws_sns_topic_policy no tópico topic-video-submitted permitindo que o bucket S3 (videos_bucket_arn) publique no SNS, apenas quando trigger_mode = "s3_event" e videos_bucket_arn está definido.
- [ ] Nenhuma Lambda criada; nenhum serviço fora da lista (SNS topic policy para S3).
- [ ] Responsabilidade do módulo messaging preservada (tópico e política de publicação); terraform validate e plan (com variáveis adequadas) passam.
