# Subtask 03: Remover SNS topic-video-submitted e todas as suas referências

## Descrição
Eliminar completamente o tópico SNS `topic-video-submitted` do projeto, removendo o recurso `aws_sns_topic.topic_video_submitted` de `30-messaging/sns.tf`, o output `topic_video_submitted_arn` de `30-messaging/outputs.tf`, a variável `topic_video_submitted_arn` de `50-lambdas-shell/variables.tf`, a passagem dessa variável em `terraform/main.tf` e a variável de ambiente `TOPIC_VIDEO_SUBMITTED_ARN` do `LambdaVideoManagement` em `lambdas.tf`.

## Contexto — recursos e referências a remover

| Arquivo | O que remover |
|---------|--------------|
| `terraform/30-messaging/sns.tf` | Bloco `resource "aws_sns_topic" "topic_video_submitted"` |
| `terraform/30-messaging/outputs.tf` | Bloco `output "topic_video_submitted_arn"` |
| `terraform/50-lambdas-shell/variables.tf` | Bloco `variable "topic_video_submitted_arn"` |
| `terraform/main.tf` | Linha `topic_video_submitted_arn = module.messaging.topic_video_submitted_arn` no bloco `module "lambdas"` |
| `terraform/50-lambdas-shell/lambdas.tf` | Env var `TOPIC_VIDEO_SUBMITTED_ARN = var.topic_video_submitted_arn` dentro de `aws_lambda_function.video_management` |

> **Nota:** O tópico `topic-video-completed` e suas subscriptions **não devem ser alterados** — eles continuam existindo e em uso.

## Passos de implementação

1. Em `terraform/30-messaging/sns.tf`: remover o bloco completo `resource "aws_sns_topic" "topic_video_submitted"` (4 linhas). O arquivo deve manter apenas `topic_video_completed` e as subscriptions.

2. Em `terraform/30-messaging/outputs.tf`: remover o bloco `output "topic_video_submitted_arn"` (4 linhas).

3. Em `terraform/50-lambdas-shell/variables.tf`: remover o bloco `variable "topic_video_submitted_arn"`.

4. Em `terraform/main.tf`: no bloco `module "lambdas"`, remover a linha:
   ```hcl
   topic_video_submitted_arn = module.messaging.topic_video_submitted_arn
   ```

5. Em `terraform/50-lambdas-shell/lambdas.tf`: dentro do recurso `aws_lambda_function.video_management`, no bloco `environment.variables`, remover a linha:
   ```hcl
   TOPIC_VIDEO_SUBMITTED_ARN = var.topic_video_submitted_arn
   ```

6. Executar `terraform fmt -recursive` nos diretórios `terraform/30-messaging/`, `terraform/50-lambdas-shell/` e `terraform/`.

## Formas de teste

1. `terraform validate` no root (`terraform/`) — confirmar "Success! The configuration is valid." (sem referências pendentes ao `topic_video_submitted`).
2. `terraform plan` — confirmar que o plan mostra `-` destroy para `aws_sns_topic.topic_video_submitted`.
3. Buscar (grep) por `topic_video_submitted` em todos os arquivos `.tf` para confirmar ausência total de referências.

## Critérios de aceite

- [ ] `aws_sns_topic.topic_video_submitted` removido de `30-messaging/sns.tf`
- [ ] `output "topic_video_submitted_arn"` removido de `30-messaging/outputs.tf`
- [ ] `variable "topic_video_submitted_arn"` removida de `50-lambdas-shell/variables.tf`
- [ ] Linha `topic_video_submitted_arn = module.messaging.topic_video_submitted_arn` removida de `main.tf`
- [ ] Env var `TOPIC_VIDEO_SUBMITTED_ARN` removida de `aws_lambda_function.video_management` em `lambdas.tf`
- [ ] `terraform validate` no root passa sem erros — sem referências não resolvidas
- [ ] `terraform plan` mostra destruição de `aws_sns_topic.topic_video_submitted` (ou confirma que não existia no state)
- [ ] `topic-video-completed` e suas subscriptions **não foram alterados**
