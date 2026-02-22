# Módulo 30-messaging (SNS + SQS)

Módulo Terraform que provisiona **SNS** (tópicos e subscriptions) e **SQS** (filas + DLQs) do Processador Video MVP. Consome `prefix` e `common_tags` do módulo foundation (caller passa via variáveis). Alinhado ao [contexto arquitetural](../../docs/contexto-arquitetural.md).

---

## Caminho de eventos (SNS)

### topic-video-submitted

| Papel        | Componente                                                                 |
|-------------|-----------------------------------------------------------------------------|
| **Publica** | S3 event (após upload) ou Lambda que confirma upload (Video Management).   |
| **Consome** | SQS de processamento (criada neste módulo); subscription SNS→SQS em outra story. A **Lambda Video Orchestrator** consome a fila e inicia Step Functions. |

#### Modo api_publish (upload concluído)

Quando o upload é confirmado pela API/Lambda (modo api_publish), a **Lambda Video Management** publica no SNS topic-video-submitted; o ARN do tópico (output **topic_video_submitted_arn**) é injetado na Lambda. Desde a Storie-18, o fluxo principal de upload concluído é **S3 → SQS q-video-process** (direto), configurado no root; o tópico SNS continua disponível para publicações da aplicação.

### topic-video-completed

| Papel        | Componente                                                                 |
|-------------|-----------------------------------------------------------------------------|
| **Publica** | **Lambda Video Finalizer** ao concluir o processamento (zip gerado, armazenado no S3). |
| **Consome** | E-mail (ativo agora, configurável por variável) e/ou Lambda (preparado para depois, placeholder). |

Fluxo ponta a ponta: upload → S3 → SNS video-submitted → SQS process → orquestração → processamento → finalização → SNS completed → e-mail/Lambda.

---

## Ativo agora vs Preparado para depois (SNS)

| Item                          | Ativo agora                                                                 | Preparado para depois                                      |
|-------------------------------|-----------------------------------------------------------------------------|------------------------------------------------------------|
| Tópicos SNS                   | topic-video-submitted, topic-video-completed                                | —                                                          |
| Outputs                       | ARNs dos dois tópicos                                                       | —                                                          |
| Subscription email (completed)| Configurável por variável (endpoint email)                                  | —                                                          |
| Subscription Lambda (completed)| —                                                                          | Placeholder configurável por variável (lambda_arn opcional) |
| Subscription SQS (submitted)   | —                                                                          | Outra story (integração SNS→SQS)                           |

---

## Encaixe no desenho (SQS)

| Fila principal        | Origem (quem publica)                    | Consumidor (quem processa)              | DLQ                    |
|------------------------|------------------------------------------|-----------------------------------------|------------------------|
| **q-video-process**    | S3 (notificação direta; prefix `videos/`, suffix `original`) | Lambda Video Dispatcher (Storie-18)    | dlq-video-process       |
| **q-video-status-update** | Lambda Processor / Step Functions       | Lambda/worker que atualiza DynamoDB      | dlq-video-status-update |
| **q-video-zip-finalize** | Step Functions ou Lambda Processor      | Lambda Video Finalizer (zip, publica SNS)| dlq-video-zip-finalize  |

- **S3 → SQS q-video-process (Storie-18):** o bucket videos notifica diretamente esta fila (queue policy e bucket notification no root). Este módulo apenas cria a fila e a DLQ.
- **q-video-status-update:** atualização de status do processamento (ex.: "processing", "extracting frames").
- **q-video-zip-finalize:** dispara a Lambda Video Finalizer para consolidar imagens, gerar zip e publicar em topic-video-completed.

---

## Resiliência e DLQ (caixa de falhas)

Todas as filas principais possuem **redrive_policy** apontando para a DLQ correspondente com `max_receive_count` configurável. Após N falhas de processamento (mensagem devolvida ou não deletada), a mensagem vai para a DLQ.

- **DLQ = caixa de falhas:** as Dead Letter Queues armazenam mensagens que não puderam ser processadas com sucesso, evitando perda de dados e permitindo inspeção, retry manual ou reprocessamento. Nenhuma mensagem é descartada sem passar pela DLQ quando redrive está configurado.
- **Parâmetros configuráveis:** `visibility_timeout_seconds`, `message_retention_seconds`, `max_receive_count`, `dlq_message_retention_seconds` — todos parametrizados por variável para ajuste por ambiente.

*A DLQ é a caixa de falhas do fluxo: garante que nenhuma mensagem seja descartada sem passar por ela, permitindo diagnóstico e retry.*

---

## Integração upload concluído (Storie-18: S3 → SQS)

Desde a Storie-18, o fluxo de upload concluído é **S3 bucket videos → SQS q-video-process** (direto), configurado no **root** (`upload_integration.tf`): queue policy na fila (permite S3 publicar com `aws:SourceArn`) e bucket notification com filtro `prefix = "videos/"`, `suffix = "original"`. Os módulos 10-storage e 30-messaging não recebem mais variáveis de integração (`trigger_mode`, `videos_bucket_arn`, `topic_video_submitted_arn`) para esse fluxo; o root usa os outputs `videos_bucket_name`, `videos_bucket_arn`, `q_video_process_arn` e `q_video_process_url` para configurar os recursos.

---

## Uso pelo caller (root)

O root deve passar `prefix` e `common_tags` (ex.: do output do módulo `00-foundation`) e, opcionalmente, variáveis de subscription SNS e parâmetros SQS:

```hcl
module "messaging" {
  source = "./30-messaging"

  prefix      = module.foundation.prefix
  common_tags = module.foundation.common_tags

  # SNS (opcional)
  enable_email_subscription_completed  = false
  email_endpoint                      = null
  enable_lambda_subscription_completed = false
  lambda_subscription_arn              = null

  # SQS (opcional, defaults no módulo)
  visibility_timeout_seconds    = 300
  message_retention_seconds    = 345600
  max_receive_count            = 3
  dlq_message_retention_seconds = 1209600
}
```

Init/plan/apply são executados no **root** (`terraform/`); validar com `terraform plan` no root.
