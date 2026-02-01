# Storie-05: Implementar Módulo Terraform 30-Messaging (Parte SNS)

## Status
- **Estado:** 🔄 Em desenvolvimento
- **Data de Conclusão:** [DD/MM/AAAA]

## Descrição
Como desenvolvedor de infraestrutura, quero que o módulo `terraform/30-messaging` provisione os tópicos SNS necessários ao fluxo do Processador Video MVP (topic-video-submitted e topic-video-completed), com subscription placeholder configurável por variável (email para notificação ou Lambda para futuro), para suportar o desenho de eventos sem criar SQS nesta story.

## Objetivo
Criar a **parte SNS** do módulo `terraform/30-messaging`: dois tópicos SNS — **topic-video-submitted** e **topic-video-completed** — com outputs dos ARNs; subscription placeholder configurável por variável (email para notificação **ativo agora** ou Lambda **preparado para depois**). Alinhar com o desenho do contexto arquitetural: documentar o caminho de evento (quem publica em cada tópico e quem consome). Não criar SQS nesta story (SQS é outra story). Sem inventar serviços fora da lista (apenas SNS e subscriptions email/Lambda). A story separa claramente "ativo agora" vs "preparado para depois".

## Escopo Técnico
- Tecnologias: Terraform >= 1.0, AWS Provider (~> 5.0)
- Arquivos afetados:
  - `terraform/30-messaging/variables.tf`
  - `terraform/30-messaging/sns.tf` ou `main.tf` (aws_sns_topic, aws_sns_topic_subscription)
  - `terraform/30-messaging/outputs.tf`
  - `terraform/30-messaging/README.md` (caminho de eventos, ativo vs preparado)
- Componentes/Recursos: 2x aws_sns_topic (topic-video-submitted, topic-video-completed); aws_sns_topic_subscription opcionais (email e/ou placeholder Lambda) configuráveis por variável; nenhum aws_sqs_queue.
- Pacotes/Dependências: Nenhum; consumo de prefix/common_tags do foundation via variáveis.

## Dependências e Riscos (para estimativa)
- Dependências: Storie-02 (00-foundation) concluída; Storie-03 (10-storage) e Storie-04 (20-data) não obrigatórias para esta story.
- Riscos/Pré-condições: Subscriptions SQS aos tópicos serão criadas na story de SQS; não criar SQS aqui. Subscriptions Lambda ao topic-video-completed podem ser "preparado para depois" (variável/placeholder).

---

## Caminho de Eventos (desenho)

### topic-video-submitted
- **Quem publica:** Após o upload no S3, o **evento S3** (ou Lambda acionada por S3) publica mensagem neste tópico. No desenho do contexto arquitetural: "O S3 emite um evento" → "publica uma mensagem em um SNS de vídeo enviado". Na prática, pode ser configurado como S3 Event Notification → SNS (ou Lambda Video Management / outra Lambda que confirme upload e publique no SNS).
- **Quem consome (depois):** A **SQS de processamento** (criada em outra story) será inscrita neste tópico; o SNS encaminha a mensagem para a fila; a **Lambda Video Orchestrator** consome a fila e inicia Step Functions.
- **Nesta story:** Apenas o tópico SNS; **sem SQS**. Subscriptions ao tópico (ex.: SQS) ficam para a story de messaging (SQS).

### topic-video-completed
- **Quem publica:** A **Lambda Video Finalizer** publica neste tópico ao concluir o processamento (zip gerado, armazenado no S3).
- **Quem consome:** Notificação por **e-mail** (ativo agora, configurável por variável) e/ou **Lambda** (preparado para depois, placeholder por variável) para notificar usuário, atualizar status no banco ou integrar com outro sistema.

Resumo: **ativo agora** = tópicos SNS + subscription email (opcional, configurável); **preparado para depois** = subscription Lambda (placeholder/variável), subscriptions SQS (outra story).

---

## Ativo agora vs Preparado para depois

| Item | Ativo agora | Preparado para depois |
|------|-------------|------------------------|
| Tópicos SNS | topic-video-submitted, topic-video-completed | — |
| Outputs | ARNs dos dois tópicos | — |
| Subscription email (topic-video-completed) | Configurável por variável (endpoint email) | — |
| Subscription Lambda (topic-video-completed) | — | Placeholder configurável por variável (lambda_arn opcional) |
| Subscription SQS (topic-video-submitted) | — | Outra story (30-messaging SQS) |

---

## Variáveis do Módulo
- **prefix** (string, obrigatório): prefixo do foundation (ex.: video-processing-engine-dev).
- **common_tags** (map, obrigatório): tags do foundation.
- **enable_email_subscription_completed** (bool, opcional, default = false): habilita subscription email no topic-video-completed (ativo agora).
- **email_endpoint** (string, opcional): e-mail para notificação quando enable_email_subscription_completed = true; vazio ou null desabilita.
- **enable_lambda_subscription_completed** (bool, opcional, default = false): placeholder para subscription Lambda no topic-video-completed (preparado para depois).
- **lambda_subscription_arn** (string, opcional): ARN da Lambda para subscription; usado quando enable_lambda_subscription_completed = true (futuro).

## Decisões Técnicas
- **Somente SNS nesta story:** nenhuma fila SQS; subscriptions SQS aos tópicos em story dedicada.
- **Naming:** topic names ex.: `{prefix}-topic-video-submitted`, `{prefix}-topic-video-completed`.
- **Subscriptions:** email e Lambda configuráveis por variável; quando variável desabilitada ou endpoint vazio, não criar subscription (ou criar com endpoint placeholder e confirmar depois manualmente no caso de email).
- **Serviços:** apenas SNS e aws_sns_topic_subscription (protocol email ou lambda); sem inventar outros serviços.

## Subtasks
- [Subtask 01: Variáveis do módulo e consumo de prefix/tags do foundation](./subtask/Subtask-01-Variaveis_Consumo_Foundation.md)
- [Subtask 02: Tópicos SNS topic-video-submitted e topic-video-completed](./subtask/Subtask-02-Topicos_SNS.md)
- [Subtask 03: Subscription placeholder configurável (email e Lambda)](./subtask/Subtask-03-Subscription_Placeholder.md)
- [Subtask 04: Outputs (topic ARNs) e documentação do caminho de eventos](./subtask/Subtask-04-Outputs_Documentacao.md)
- [Subtask 05: Documentar "ativo agora" vs "preparado para depois" e validação](./subtask/Subtask-05-Ativo_Preparado_Validacao.md)

## Critérios de Aceite da História
- [ ] O módulo `terraform/30-messaging` cria dois tópicos SNS: topic-video-submitted e topic-video-completed, com nomes derivados do prefix
- [ ] Outputs expõem os ARNs dos dois tópicos (topic_video_submitted_arn, topic_video_completed_arn)
- [ ] Subscription placeholder é configurável por variável: email (notificação, ativo agora) e/ou Lambda (futuro, preparado para depois) para topic-video-completed
- [ ] Nenhuma fila SQS criada nesta story; nenhum serviço inventado fora da lista (SNS, subscriptions email/Lambda)
- [ ] A story documenta o caminho de evento: quem publica em topic-video-submitted (ex.: S3 event / Lambda Video Management) e quem consome depois (SQS); quem publica em topic-video-completed (Lambda Video Finalizer) e quem consome (email/Lambda)
- [ ] A story separa explicitamente "ativo agora" (tópicos + subscription email opcional) vs "preparado para depois" (subscription Lambda placeholder, SQS em outra story)
- [ ] Consumo de prefix e common_tags do foundation; terraform plan sem referências quebradas

## Checklist de Conclusão
- [ ] Arquivos .tf do 30-messaging (parte SNS) criados; nenhum aws_sqs_queue no módulo
- [ ] terraform init e terraform validate em terraform/30-messaging com sucesso
- [ ] terraform plan com prefix e common_tags fornecidos, sem erros de referência
- [ ] README ou story documenta caminho de eventos e tabela ativo agora vs preparado para depois
