# Subtask 01: Variável trigger_mode e variáveis de integração (topic_arn / bucket_arn)

## Descrição
Introduzir a variável **trigger_mode** ("s3_event" | "api_publish") e as variáveis de integração **topic_video_submitted_arn** (no módulo storage) e **videos_bucket_arn** (no módulo messaging) nos módulos 10-storage e 30-messaging, para que a escolha do fluxo "upload concluído" seja parametrizável e o caller possa passar o ARN do tópico ao storage e o ARN do bucket ao messaging quando trigger_mode = "s3_event".

## Passos de implementação
1. No módulo **terraform/10-storage/variables.tf**, adicionar variável `trigger_mode` (string, default = "api_publish", description: "s3_event = S3 notifica SNS ao criar objeto; api_publish = Lambda publica no SNS após confirmação") e variável `topic_video_submitted_arn` (string, default = null ou "", optional, description: "ARN do SNS topic-video-submitted; obrigatório quando trigger_mode = s3_event").
2. No módulo **terraform/30-messaging/variables.tf**, adicionar variável `trigger_mode` (string, default = "api_publish") e variável `videos_bucket_arn` (string, default = null ou "", optional, description: "ARN do bucket S3 videos; obrigatório quando trigger_mode = s3_event para policy SNS").
3. Garantir que os defaults permitam execução sem erro quando trigger_mode = "api_publish" (topic_arn e bucket_arn vazios não devem quebrar validate/plan).
4. Documentar em comment ou README que o root/caller deve passar topic_video_submitted_arn (output de messaging) ao storage e videos_bucket_arn (output de storage) ao messaging quando trigger_mode = "s3_event".

## Formas de teste
1. Executar `terraform validate` em 10-storage e 30-messaging com trigger_mode = "api_publish" e variáveis opcionais vazias; deve passar.
2. Verificar que trigger_mode existe em ambos os módulos com os mesmos valores aceitos (s3_event | api_publish).
3. Listar variáveis documentadas na story (trigger_mode, topic_video_submitted_arn, videos_bucket_arn) e confirmar que estão declaradas nos módulos corretos.

## Critérios de aceite da subtask
- [ ] O módulo 10-storage declara trigger_mode e topic_video_submitted_arn (opcional); o módulo 30-messaging declara trigger_mode e videos_bucket_arn (opcional).
- [ ] Valores de trigger_mode documentados: "s3_event" | "api_publish"; default "api_publish" para não quebrar quem já usa os módulos.
- [ ] terraform validate em ambos os módulos passa com trigger_mode = "api_publish" e variáveis opcionais vazias; nenhuma referência quebrada.
