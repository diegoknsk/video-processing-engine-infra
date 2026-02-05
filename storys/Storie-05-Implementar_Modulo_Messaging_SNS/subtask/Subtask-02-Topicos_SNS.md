# Subtask 02: Tópicos SNS topic-video-submitted e topic-video-completed

## Descrição
Criar os dois recursos `aws_sns_topic` no módulo `terraform/30-messaging`: topic-video-submitted e topic-video-completed, com nomes derivados do prefix do foundation e tags. Não criar SQS nem subscriptions nesta subtask (subscriptions na Subtask 03).

## Passos de implementação
1. Criar arquivo `terraform/30-messaging/sns.tf` (ou `main.tf`) com recurso `aws_sns_topic` para topic-video-submitted: name = "${var.prefix}-topic-video-submitted" (ou equivalente), tags = var.common_tags.
2. Criar segundo recurso `aws_sns_topic` para topic-video-completed: name = "${var.prefix}-topic-video-completed", tags = var.common_tags.
3. Garantir que não haja recurso aws_sqs_queue nem aws_sns_topic_subscription ainda (subscriptions na próxima subtask); apenas os dois tópicos.
4. Verificar que providers.tf ou configuração do módulo exista (provider AWS); consumo de prefix e common_tags via variáveis.

## Formas de teste
1. Executar `terraform plan` em `terraform/30-messaging/` passando prefix e common_tags e verificar que o plano lista criação dos 2 tópicos SNS; sem SQS.
2. Buscar em `terraform/30-messaging/*.tf` por "aws_sqs" e confirmar que não há recurso SQS.
3. Confirmar que os nomes dos tópicos usam var.prefix e que tags = var.common_tags.

## Critérios de aceite da subtask
- [ ] Existem dois recursos aws_sns_topic: topic-video-submitted e topic-video-completed, com nomes usando var.prefix e tags = var.common_tags.
- [ ] Nenhum recurso aws_sqs_queue no módulo; nenhuma subscription ainda (será na Subtask 03).
- [ ] terraform validate e plan (com variáveis) passam.
