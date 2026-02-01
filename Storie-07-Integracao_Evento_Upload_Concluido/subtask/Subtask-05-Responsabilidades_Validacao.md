# Subtask 05: Documentar responsabilidades e validação (terraform plan)

## Descrição
Documentar explicitamente no README ou em docs a divisão de responsabilidades entre os módulos storage e messaging na integração "upload concluído" (storage = bucket + notificação do bucket; messaging = tópico + política de quem publica) e como o root/caller deve conectar os módulos (passar topic_arn ao storage e bucket_arn ao messaging quando s3_event). Garantir que terraform init, terraform validate e terraform plan executem sem referências quebradas em ambos os módulos.

## Passos de implementação
1. Adicionar ao README do repositório (ou à documentação em docs/) uma seção "Integração upload concluído – responsabilidades": **Storage (10-storage):** dono do bucket videos; quando trigger_mode = "s3_event", configura a notificação do bucket para o SNS (recebe topic_video_submitted_arn). **Messaging (30-messaging):** dono do tópico topic-video-submitted; quando trigger_mode = "s3_event", configura a policy do tópico permitindo o bucket publicar (recebe videos_bucket_arn). **Root/Caller:** deve passar topic_video_submitted_arn (output de messaging) para o módulo storage e videos_bucket_arn (output de storage) para o módulo messaging quando trigger_mode = "s3_event", em um único apply.
2. Incluir na story ou README a confirmação de que o fluxo permanece alinhado ao desenho (upload concluído → SNS topic-video-submitted → SQS q-video-process) e que as responsabilidades não foram quebradas (storage não cria SNS; messaging não cria bucket).
3. Executar `terraform init` e `terraform validate` nos módulos 10-storage e 30-messaging; corrigir até "Success! The configuration is valid." em ambos.
4. Executar `terraform plan` no módulo 10-storage com trigger_mode = "api_publish" (e sem topic_arn) e no módulo 30-messaging com trigger_mode = "api_publish" (e sem bucket_arn); ambos devem passar sem erro. Opcionalmente executar plan com trigger_mode = "s3_event" e variáveis de integração preenchidas (ex.: valores placeholder) para validar que os recursos de notificação e policy aparecem no plano.
5. Documentar que não há dependência circular: o root aplica os dois módulos passando os outputs entre eles no mesmo apply (Terraform resolve a ordem).

## Formas de teste
1. Ler a documentação e confirmar que as responsabilidades (storage = bucket + notificação; messaging = tópico + policy) e o papel do root (passar topic_arn e bucket_arn) estão descritos.
2. Rodar `terraform validate` em 10-storage e 30-messaging e confirmar "Success! The configuration is valid." em ambos.
3. Rodar `terraform plan` em 10-storage e 30-messaging com trigger_mode = "api_publish" e variáveis opcionais vazias; nenhum erro de referência quebrada.

## Critérios de aceite da subtask
- [ ] README ou docs documentam a divisão de responsabilidades (storage vs messaging) e como o root conecta os módulos (topic_arn → storage, bucket_arn → messaging quando s3_event).
- [ ] terraform init e terraform validate em 10-storage e 30-messaging executam sem referências quebradas.
- [ ] A story/fluxo permanece alinhado ao desenho e não quebra responsabilidades entre módulos; terraform plan passa com trigger_mode = "api_publish" e com "s3_event" (quando variáveis de integração fornecidas).
