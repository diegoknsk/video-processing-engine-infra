# Storie-25: Ajustar SNS — Remover Tópico Completed e Criar Tópico de Erro

## Status
- **Estado:** 🟡 Em desenvolvimento
- **Data de Conclusão:** —

## Descrição
Como engenheiro de infraestrutura, quero remover o tópico SNS `topic-video-completed` (não mais utilizado) e criar um novo tópico SNS exclusivo para notificação de erros de processamento de vídeo, para manter a infraestrutura de mensageria alinhada ao fluxo real da aplicação.

## Objetivo
Remover o tópico SNS `topic-video-completed` do módulo `30-messaging` (recurso, subscriptions, variáveis e output associados), criar o novo tópico SNS `topic-video-processing-error` com suas variáveis e output, e atualizar o wiring no `main.tf` raiz. As Lambdas e a Step Function **não são alteradas nesta story**.

## Proposta de Mudança

| Ação | Recurso Terraform | Nome AWS |
|---|---|---|
| **Remover** | `aws_sns_topic.topic_video_completed` | `{prefix}-topic-video-completed` |
| **Remover** | `aws_sns_topic_subscription.completed_email` | subscription email do tópico acima |
| **Remover** | `aws_sns_topic_subscription.completed_lambda` | subscription lambda do tópico acima |
| **Criar** | `aws_sns_topic.topic_video_processing_error` | `{prefix}-topic-video-processing-error` |
| **Criar** | `aws_sns_topic_subscription.error_email` (feature flag) | subscription email no novo tópico |

**Nome sugerido do novo tópico:**
```
${var.prefix}-topic-video-processing-error
```

Resource Terraform: `aws_sns_topic.topic_video_processing_error`

## Escopo Técnico
- **Tecnologias:** Terraform >= 1.0, AWS Provider ~> 5.0, AWS SNS
- **Arquivos modificados:**
  - `terraform/30-messaging/sns.tf` — remoção do tópico/subscriptions antigos; criação do novo tópico e subscription de erro
  - `terraform/30-messaging/variables.tf` — remoção das variáveis do tópico completed; adição de variáveis do tópico de erro
  - `terraform/30-messaging/outputs.tf` — remoção do output `topic_video_completed_arn`; adição do output `topic_video_processing_error_arn`
  - `terraform/main.tf` — remoção do input `topic_video_completed_arn` para o módulo `lambdas`; adição do novo output de erro onde necessário
- **Componentes/Recursos:** `aws_sns_topic`, `aws_sns_topic_subscription`
- **Pacotes/Dependências:** nenhum pacote externo; apenas provider AWS já configurado

## Dependências e Riscos (para estimativa)

### Dependências
- O módulo `50-lambdas-shell` referencia `topic_video_completed_arn` em `variables.tf`, `iam.tf` e `lambdas.tf`. A limpeza dessas referências **está fora do escopo desta story** e deve ser tratada em story subsequente de ajuste do módulo de Lambdas.
- Após esta story, o `terraform validate` no root **pode falhar** enquanto `50-lambdas-shell` ainda referenciar `topic_video_completed_arn` via input de `main.tf`. O `main.tf` deve ser atualizado nesta story para remover o input; a variável órfã no módulo `50-lambdas-shell` é deuda técnica tolerável até a story de lambdas.

### Riscos
- **Risk: destruição do tópico em produção.** O `terraform apply` irá fazer `destroy` do recurso `aws_sns_topic.topic_video_completed`; confirmar que não há consumidores ativos antes de aplicar.
- **Risk: subscriptions ativas.** Se `enable_email_subscription_completed = true` estiver ativo, a subscription será destruída junto com o tópico. Verificar valor da variável antes do apply.
- **Risk: output removido.** O root `main.tf` passa `topic_video_completed_arn` para o módulo `lambdas`; se não for removido do main.tf nesta story, o `terraform validate` falhará.
- **Pré-condição:** credenciais AWS (Access Key, Secret Key, Session Token) válidas e `var.lab_role` configurada antes de `terraform plan/apply`.

## Subtasks
- [x] [Subtask 01: Remover tópico topic_video_completed do 30-messaging](./subtask/Subtask-01-Remover_Topico_SNS_VideoCompleted.md)
- [x] [Subtask 02: Criar tópico topic-video-processing-error no 30-messaging](./subtask/Subtask-02-Criar_Topico_SNS_VideoProcessingError.md)
- [x] [Subtask 03: Atualizar variáveis e outputs do módulo 30-messaging](./subtask/Subtask-03-Variaveis_Outputs_Messaging.md)
- [x] [Subtask 04: Atualizar wiring no main.tf raiz](./subtask/Subtask-04-Atualizar_WireUp_MainTF.md)

## Critérios de Aceite da História
- [x] O recurso `aws_sns_topic.topic_video_completed` foi removido de `terraform/30-messaging/sns.tf`
- [x] As subscriptions `completed_email` e `completed_lambda` foram removidas de `terraform/30-messaging/sns.tf`
- [x] O output `topic_video_completed_arn` foi removido de `terraform/30-messaging/outputs.tf`
- [x] As variáveis `enable_email_subscription_completed`, `email_endpoint`, `enable_lambda_subscription_completed` e `lambda_subscription_arn` foram removidas de `terraform/30-messaging/variables.tf`
- [x] O recurso `aws_sns_topic.topic_video_processing_error` foi criado em `terraform/30-messaging/sns.tf` com nome `${var.prefix}-topic-video-processing-error` e tags padrão
- [x] A subscription de e-mail para o tópico de erro foi criada com feature flag (`enable_email_subscription_error`) e variável `email_endpoint_error` em `terraform/30-messaging/variables.tf`
- [x] O output `topic_video_processing_error_arn` foi adicionado em `terraform/30-messaging/outputs.tf`
- [x] O `terraform/main.tf` foi atualizado: input `topic_video_completed_arn` removido do módulo `lambdas`
- [x] `terraform fmt -recursive` executado sem erros de formatação
- [x] `terraform validate` executado com resultado "The configuration is valid." no módulo `30-messaging` de forma isolada (ou no root após ajuste do main.tf)
- [x] Nenhum ARN hardcoded nos arquivos `.tf`; nenhuma credencial commitada

## Rastreamento (dev tracking)
- **Início:** dia 12/03/2025 (Brasília)
- **Fim:** —
- **Tempo total de desenvolvimento:** —
