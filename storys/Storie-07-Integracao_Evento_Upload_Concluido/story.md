# Storie-07: Integração do Evento "Upload Concluído" com o Desenho

## Status
- **Estado:** ✅ Concluída
- **Data de Conclusão:** 05/02/2026

## Rastreamento (dev tracking)
- **Início:** dia 05/02/2026, às 14:00 (Brasília)
- **Fim:** dia 05/02/2026, às 15:45 (Brasília)
- **Tempo total de desenvolvimento:** 1h 45min

## Descrição
Como desenvolvedor de infraestrutura, quero que o fluxo "upload concluído" esteja integrado ao desenho do Processador Video MVP de forma parametrizável: ou (1) S3 bucket videos notifica o SNS topic-video-submitted quando um objeto for criado, ou (2) a Lambda Video Management publica no SNS após confirmação via API — com a escolha configurável por variável (trigger_mode = "s3_event" | "api_publish"), sem quebrar responsabilidades entre módulos storage e messaging.

## Objetivo
Implementar a integração do evento "upload concluído" com o desenho: quando **trigger_mode = "s3_event"**, configurar notificação do bucket S3 videos para publicar no SNS topic-video-submitted ao criar objeto (S3 event → SNS), implementando somente o necessário nos módulos storage e messaging (S3 bucket notification + SNS topic policy), sem criar Lambdas. Quando **trigger_mode = "api_publish"**, documentar e preparar outputs/variáveis para que a Lambda Video Management publique no SNS (sem código de Lambda nesta story). A escolha deve ser parametrizável por variável; não criar serviços fora da lista; preservar responsabilidades entre módulos (storage = bucket e eventos do bucket; messaging = tópico e política de publicação).

## Escopo Técnico
- Tecnologias: Terraform >= 1.0, AWS Provider (~> 5.0)
- Arquivos afetados:
  - **10-storage:** `terraform/10-storage/variables.tf` (trigger_mode, topic_video_submitted_arn opcional), `terraform/10-storage/s3_notification.tf` ou equivalente (aws_sns_topic + aws_s3_bucket_notification quando s3_event)
  - **30-messaging:** `terraform/30-messaging/variables.tf` (trigger_mode, videos_bucket_arn opcional), `terraform/30-messaging/sns_topic_policy.tf` ou equivalente (aws_sns_topic_policy quando s3_event)
  - Documentação em README dos módulos e/ou docs do repo
- Componentes/Recursos: **s3_event:** aws_s3_bucket_notification (bucket videos → SNS topic-video-submitted, evento s3:ObjectCreated:*), aws_sns_topic_policy (permitir que o bucket S3 publique no tópico); **api_publish:** nenhum recurso novo, apenas documentação e outputs/variáveis. Nenhuma Lambda criada nesta story.
- Pacotes/Dependências: Nenhum; módulos 10-storage e 30-messaging já existem (Storie-03, Storie-05).

## Dependências e Riscos (para estimativa)
- Dependências: Storie-03 (10-storage) e Storie-05 (30-messaging SNS) concluídas; bucket videos e tópico topic-video-submitted existentes.
- Riscos/Pré-condições: Quando trigger_mode = "s3_event", o caller/root deve passar topic_video_submitted_arn ao módulo storage e videos_bucket_arn ao módulo messaging (saídas de um alimentam o outro); não há dependência circular se o root orquestrar. Quando api_publish, nenhum recurso novo; apenas documentação e garantia de que topic_video_submitted_arn está em outputs para a Lambda usar.

## Modelo de execução (root único)
A integração é feita nos módulos 10-storage e 30-messaging, ambos consumidos pelo **root** em `terraform/` (Storie-02-Parte2). O root orquestra e repassa topic_video_submitted_arn e videos_bucket_arn entre módulos. Init/plan/apply são executados uma vez em `terraform/`.

---

## Escolha do Modo (trigger_mode)

| trigger_mode | Comportamento | Onde implementar | Lambdas |
|--------------|---------------|-------------------|---------|
| **s3_event** | S3 emite evento ao criar objeto no bucket videos → publica no SNS topic-video-submitted | Storage: S3 bucket notification. Messaging: SNS topic policy (permitir S3 publicar). | Nenhuma nesta story |
| **api_publish** | Lambda Video Management (via API) publica no SNS após confirmação de upload | Apenas documentar e preparar outputs (topic_video_submitted_arn); código da Lambda em outro repo | Nenhum código Lambda nesta story |

- **s3_event:** Alinhado ao contexto arquitetural ("Após o upload, o S3 emite um evento" → "publica uma mensagem em um SNS de vídeo enviado"). Implementação: notificação no bucket (módulo storage) + política no tópico (módulo messaging).
- **api_publish:** Alternativa quando se prefere que a API/Lambda confirme o upload e publique no SNS (ex.: validação antes de disparar o fluxo). Apenas documentação e outputs/variáveis; a Lambda Video Management será implementada em story/repo de aplicação.

---

## Responsabilidades entre Módulos (não quebrar)

- **10-storage:** Dono do bucket videos. Quando trigger_mode = "s3_event", adiciona **aws_s3_bucket_notification** no bucket videos (evento s3:ObjectCreated:*, destino = SNS topic_video_submitted_arn). Recebe topic_video_submitted_arn como variável (output do módulo messaging). Não cria SNS nem políticas de SNS.
- **30-messaging:** Dono do tópico topic-video-submitted. Quando trigger_mode = "s3_event", adiciona **aws_sns_topic_policy** no tópico permitindo que o bucket videos (videos_bucket_arn) publique no SNS. Recebe videos_bucket_arn como variável (output do módulo storage). Não cria bucket nem notificação de bucket.
- **Caller/Root:** Passa topic_video_submitted_arn (output de messaging) para storage e videos_bucket_arn (output de storage) para messaging quando trigger_mode = "s3_event", garantindo que a integração funcione em um único apply.

Nenhum módulo "invade" o outro: storage só configura o bucket; messaging só configura o tópico.

---

## Variáveis e Outputs

### 10-storage (adicionar/ajustar)
- **trigger_mode** (string, opcional, default = "api_publish"): "s3_event" | "api_publish".
- **topic_video_submitted_arn** (string, opcional): ARN do tópico SNS topic-video-submitted; obrigatório quando trigger_mode = "s3_event".
- Output **videos_bucket_arn** (e/ou id) já deve existir (Storie-03); garantir que o caller possa passar ao messaging.

### 30-messaging (adicionar/ajustar)
- **trigger_mode** (string, opcional, default = "api_publish"): "s3_event" | "api_publish".
- **videos_bucket_arn** (string, opcional): ARN do bucket S3 videos; obrigatório quando trigger_mode = "s3_event" para criar a topic policy.
- Output **topic_video_submitted_arn** já deve existir (Storie-05); garantir que o caller possa passar ao storage e que esteja documentado para uso pela Lambda quando api_publish.

---

## Decisões Técnicas
- **Sem novos serviços:** Apenas S3 (bucket notification) e SNS (topic policy); nenhum EventBridge, Lambda ou serviço fora da lista.
- **s3_event:** Evento utilizado = s3:ObjectCreated:* (qualquer criação de objeto no bucket videos). Filtro opcional por prefix/suffix pode ser variável futura.
- **api_publish:** Nenhum recurso Terraform novo; README e story documentam que a Lambda Video Management deve publicar em topic_video_submitted_arn após confirmação de upload; outputs do módulo messaging já expõem o ARN.

## Subtasks
- [x] [Subtask 01: Variável trigger_mode e variáveis de integração (topic_arn / bucket_arn)](./subtask/Subtask-01-Variavel_Trigger_Integracao.md)
- [x] [Subtask 02: S3 bucket notification (storage) quando trigger_mode = s3_event](./subtask/Subtask-02-S3_Notification_Storage.md)
- [x] [Subtask 03: SNS topic policy (messaging) quando trigger_mode = s3_event](./subtask/Subtask-03-SNS_Topic_Policy_Messaging.md)
- [x] [Subtask 04: Documentar api_publish e garantir outputs/variáveis para Lambda](./subtask/Subtask-04-Documentar_Api_Publish_Outputs.md)
- [x] [Subtask 05: Documentar responsabilidades e validação (terraform plan)](./subtask/Subtask-05-Responsabilidades_Validacao.md)

## Critérios de Aceite da História
- [ ] A escolha entre S3 event e API publish é parametrizável por variável (trigger_mode = "s3_event" | "api_publish") em storage e messaging (ou em um único lugar documentado para o root).
- [ ] Quando trigger_mode = "s3_event": notificação do bucket S3 videos para o SNS topic-video-submitted (objeto criado) está implementada no módulo storage; política SNS permitindo o bucket publicar no tópico está implementada no módulo messaging; nenhuma Lambda criada.
- [ ] Quando trigger_mode = "api_publish": apenas documentação e preparação de outputs/variáveis (topic_video_submitted_arn disponível para Lambda Video Management); nenhum código de Lambda nesta story.
- [ ] Nenhum serviço novo fora da lista (S3, SNS); responsabilidades preservadas (storage = bucket + notificação; messaging = tópico + policy).
- [ ] A story deixa o fluxo alinhado ao desenho (upload concluído → SNS topic-video-submitted → SQS q-video-process) e não quebra responsabilidades entre módulos.
- [ ] Caller/root documentado para passar topic_arn ao storage e bucket_arn ao messaging quando s3_event; terraform plan sem referências quebradas.

## Checklist de Conclusão
- [ ] trigger_mode e variáveis de integração (topic_video_submitted_arn, videos_bucket_arn) existem nos módulos afetados
- [ ] S3 bucket notification (s3_event) criada apenas quando trigger_mode = "s3_event" e topic_arn fornecido
- [ ] SNS topic policy (s3_event) criada apenas quando trigger_mode = "s3_event" e bucket_arn fornecido
- [ ] api_publish documentado; topic_video_submitted_arn em outputs para uso pela Lambda
- [ ] README ou docs descrevem responsabilidades (storage vs messaging) e como o root conecta os módulos
