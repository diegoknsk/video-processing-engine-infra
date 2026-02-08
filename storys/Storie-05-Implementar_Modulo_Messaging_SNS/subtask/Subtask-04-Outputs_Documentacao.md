# Subtask 04: Outputs (topic ARNs) e documentação do caminho de eventos

## Descrição
Criar `terraform/30-messaging/outputs.tf` expondo os ARNs dos dois tópicos SNS (topic_video_submitted_arn, topic_video_completed_arn). Documentar no README do módulo o caminho de evento: quem publica em topic-video-submitted (ex.: S3 event / Lambda Video Management) e quem consome depois (SQS); quem publica em topic-video-completed (Lambda Video Finalizer) e quem consome (email/Lambda).

## Passos de implementação
1. Criar `terraform/30-messaging/outputs.tf` com outputs: `topic_video_submitted_arn` (value = aws_sns_topic.topic_video_submitted.arn), `topic_video_completed_arn` (value = aws_sns_topic.topic_video_completed.arn). Garantir que os outputs referenciem apenas recursos existentes no módulo.
2. Criar ou atualizar `terraform/30-messaging/README.md` com seção "Caminho de eventos": (a) topic-video-submitted: publicador = S3 event (após upload) ou Lambda que confirma upload; consumidor = SQS de processamento (criada em outra story), depois Lambda Video Orchestrator. (b) topic-video-completed: publicador = Lambda Video Finalizer; consumidor = email (ativo agora) ou Lambda (preparado para depois).
3. Incluir referência ao documento [docs/contexto-arquitetural.md](../../docs/contexto-arquitetural.md) para o fluxo ponta a ponta (upload → SNS → SQS → orquestração → processamento → finalização → SNS completed).
4. Verificar que nenhum output referencia módulo foundation nem recursos inexistentes; apenas os dois aws_sns_topic.

## Formas de teste
1. Executar `terraform plan` em 30-messaging e verificar que os outputs topic_video_submitted_arn e topic_video_completed_arn aparecem no plano sem erro.
2. Ler o README e confirmar que o caminho de evento (quem publica / quem consome) está documentado para ambos os tópicos.
3. Confirmar que não há referência a SQS como recurso criado nesta story (apenas documentação de que SQS consome topic-video-submitted em outra story).

## Critérios de aceite da subtask
- [ ] outputs.tf expõe topic_video_submitted_arn e topic_video_completed_arn; terraform plan lista os outputs sem referências quebradas.
- [ ] README documenta o caminho de evento: quem publica e quem consome cada tópico (topic-video-submitted → SQS em outra story; topic-video-completed → email/Lambda).
- [ ] Referência ao contexto arquitetural para alinhamento com o desenho do Processador Video MVP.
