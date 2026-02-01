# Subtask 04: Outputs (queue URLs e ARNs) e documentação do encaixe no desenho

## Descrição
Criar ou atualizar `terraform/30-messaging/outputs.tf` expondo as URLs e ARNs das seis filas (três principais + três DLQs): q-video-process, dlq-video-process, q-video-status-update, dlq-video-status-update, q-video-zip-finalize, dlq-video-zip-finalize. Documentar no README do módulo o encaixe no desenho: SNS video-submitted → q-video-process; status update → q-video-status-update; finalize zip → q-video-zip-finalize.

## Passos de implementação
1. Em `terraform/30-messaging/outputs.tf`, adicionar outputs para cada fila: url e arn. Ex.: `q_video_process_url`, `q_video_process_arn`, `dlq_video_process_url`, `dlq_video_process_arn`; idem para status-update e zip-finalize. Usar value = aws_sqs_queue.xxx.url e value = aws_sqs_queue.xxx.arn. Garantir que os outputs referenciem apenas recursos existentes no módulo.
2. Criar ou atualizar `terraform/30-messaging/README.md` com seção "Encaixe no desenho (SQS)": (a) q-video-process: origem = SNS topic-video-submitted (subscription em outra story), consumidor = Lambda Video Orchestrator; (b) q-video-status-update: origem = Lambda Processor / Step Functions (atualização de status), consumidor = worker/Lambda que atualiza status; (c) q-video-zip-finalize: origem = Step Functions ou Lambda Processor (sinal de conclusão), consumidor = Lambda Video Finalizer. Incluir tabela resumo se necessário.
3. Referenciar o documento [docs/contexto-arquitetural.md](../../docs/contexto-arquitetural.md) para o fluxo ponta a ponta (upload → SNS → SQS process → orquestração → processamento → status update / zip finalize).
4. Verificar que nenhum output referencia recursos inexistentes; apenas os seis aws_sqs_queue.

## Formas de teste
1. Executar `terraform plan` em 30-messaging e verificar que os outputs (URLs e ARNs das 6 filas) aparecem no plano sem erro.
2. Ler o README e confirmar que o encaixe no desenho (SNS→q-video-process; status update→q-video-status-update; finalize zip→q-video-zip-finalize) está documentado.
3. Confirmar que outputs cobrem as seis filas (3 principais + 3 DLQs) com url e arn.

## Critérios de aceite da subtask
- [ ] outputs.tf expõe queue URLs e ARNs das seis filas (q-video-process, dlq-video-process, q-video-status-update, dlq-video-status-update, q-video-zip-finalize, dlq-video-zip-finalize); terraform plan lista os outputs sem referências quebradas.
- [ ] README documenta o encaixe no desenho: SNS video-submitted → q-video-process; status update → q-video-status-update; finalize zip → q-video-zip-finalize.
- [ ] Referência ao contexto arquitetural para alinhamento com o Processador Video MVP.
