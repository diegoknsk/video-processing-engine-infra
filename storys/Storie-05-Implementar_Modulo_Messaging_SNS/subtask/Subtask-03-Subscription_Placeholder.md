# Subtask 03: Subscription placeholder configurável (email e Lambda)

## Descrição
Adicionar subscriptions ao topic-video-completed configuráveis por variável: (1) **email** — para notificação, ativo agora: quando enable_email_subscription_completed = true e email_endpoint preenchido, criar aws_sns_topic_subscription com protocol = "email", endpoint = var.email_endpoint; (2) **Lambda** — preparado para depois: quando enable_lambda_subscription_completed = true e lambda_subscription_arn preenchido, criar subscription com protocol = "lambda", endpoint = var.lambda_subscription_arn. Usar count ou dynamic para não criar subscription quando variável desabilitada ou endpoint vazio. Não criar subscription para topic-video-submitted (SQS será em outra story).

## Passos de implementação
1. No arquivo sns.tf (ou main.tf), adicionar recurso aws_sns_topic_subscription para **email** no topic-video-completed: topic_arn = aws_sns_topic.topic_video_completed.arn, protocol = "email", endpoint = var.email_endpoint; condicionar com count = var.enable_email_subscription_completed && var.email_endpoint != "" ? 1 : 0 (ou equivalente) para criar apenas quando habilitado e endpoint informado.
2. Adicionar recurso aws_sns_topic_subscription para **Lambda** no topic-video-completed: protocol = "lambda", endpoint = var.lambda_subscription_arn; condicionar com count = var.enable_lambda_subscription_completed && var.lambda_subscription_arn != "" ? 1 : 0 (ou equivalente), para placeholder "preparado para depois".
3. Garantir que não haja subscription para topic-video-submitted nesta story (subscription SQS será criada na story de SQS).
4. Documentar em comentário no código: email = ativo agora; lambda = preparado para depois; SQS para topic-video-submitted = outra story.

## Formas de teste
1. Executar `terraform plan` com enable_email_subscription_completed = true e email_endpoint = "test@example.com"; verificar que uma subscription email é criada no topic-video-completed; com enable_email_subscription_completed = false, nenhuma subscription email.
2. Executar `terraform plan` com enable_lambda_subscription_completed = true e lambda_subscription_arn = "arn:aws:lambda:..." (placeholder); verificar que subscription Lambda aparece no plano; com false ou ARN vazio, nenhuma subscription Lambda.
3. Confirmar que não existe aws_sns_topic_subscription para topic-video-submitted (nenhuma fila SQS criada nesta story).

## Critérios de aceite da subtask
- [ ] Subscription email no topic-video-completed é configurável por variável (enable_email_subscription_completed, email_endpoint); criada apenas quando habilitada e endpoint preenchido.
- [ ] Subscription Lambda no topic-video-completed é configurável por variável (enable_lambda_subscription_completed, lambda_subscription_arn) como placeholder para futuro; criada apenas quando habilitada e ARN preenchido.
- [ ] Nenhuma subscription para topic-video-submitted nesta story; nenhum recurso SQS no módulo.
