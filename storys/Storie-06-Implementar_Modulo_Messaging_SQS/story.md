# Storie-06: Implementar Módulo Terraform 30-Messaging (Parte SQS)

## Status
- **Estado:** ✅ Concluída
- **Data de Conclusão:** 05/02/2025

## Rastreamento (dev tracking)
- **Início:** dia 05/02/2025, às 14:30
- **Fim:** dia 05/02/2025, às 15:05
- **Tempo total de desenvolvimento:** 35 min

## Descrição
Como desenvolvedor de infraestrutura, quero que o módulo `terraform/30-messaging` provisione as filas SQS e DLQs necessárias ao fluxo do Processador Video MVP (q-video-process, q-video-status-update, q-video-zip-finalize e suas DLQs), com redrive policy em todas e parâmetros essenciais via variável, para garantir resiliência e uma "caixa de falhas" (DLQ) sem criar Lambdas nem event mappings nesta story.

## Objetivo
Criar a **parte SQS** do módulo `terraform/30-messaging`: três pares de fila + DLQ — **q-video-process** + **dlq-video-process**, **q-video-status-update** + **dlq-video-status-update**, **q-video-zip-finalize** + **dlq-video-zip-finalize** — com redrive policy em todas as filas principais; parâmetros essenciais via variável (visibility timeout, retention, maxReceiveCount); outputs com queue URLs e ARNs. Não criar Lambdas nem event mappings (ex.: subscription SNS→SQS fica em story de integração ou já existente). A story deve encaixar com o desenho (SNS video-submitted → q-video-process; status update → q-video-status-update; finalize zip → q-video-zip-finalize) e reforçar resiliência e DLQ como "caixa de falhas".

## Escopo Técnico
- Tecnologias: Terraform >= 1.0, AWS Provider (~> 5.0)
- Arquivos afetados:
  - `terraform/30-messaging/variables.tf` (adicionar variáveis SQS: visibility_timeout, message_retention_seconds, max_receive_count)
  - `terraform/30-messaging/sqs.tf` ou `main.tf` (aws_sqs_queue, redrive_policy)
  - `terraform/30-messaging/outputs.tf` (adicionar URLs e ARNs das filas e DLQs)
  - `terraform/30-messaging/README.md` (encaixe no desenho, resiliência e DLQ)
- Componentes/Recursos: 6x aws_sqs_queue (3 filas principais + 3 DLQs); redrive_policy em cada fila principal apontando para a DLQ correspondente; nenhum aws_lambda_*, nenhum event_source_mapping nem aws_sns_topic_subscription SNS→SQS nesta story (integração em outra story se necessário).
- Pacotes/Dependências: Nenhum; consumo de prefix/common_tags do foundation via variáveis; módulo 30-messaging pode já conter SNS (Storie-05).

## Dependências e Riscos (para estimativa)
- Dependências: Storie-02 (00-foundation) concluída; Storie-05 (30-messaging SNS) desejável para encaixe (topic-video-submitted → q-video-process), mas não obrigatória para criar as filas.
- Riscos/Pré-condições: Subscription SNS topic-video-submitted → q-video-process será criada em story de integração ou separada; esta story cria apenas as filas e DLQs. Políticas IAM para Lambdas consumirem as filas ficam em story de Lambdas/IAM.

## Modelo de execução (root único)
O diretório `terraform/30-messaging/` é um **módulo** consumido pelo **root** em `terraform/` (Storie-02-Parte2). O root passa prefix e common_tags do module.foundation. Init/plan/apply são executados uma vez em `terraform/`; validar com `terraform plan` no root.

---

## Encaixe no Desenho (fluxo de mensagens)

| Fila principal | Origem (quem publica) | Consumidor (quem processa) | DLQ |
|----------------|----------------------|-----------------------------|-----|
| **q-video-process** | SNS topic-video-submitted (após upload S3) | Lambda Video Orchestrator (inicia Step Functions) | dlq-video-process |
| **q-video-status-update** | Lambda Processor / Step Functions (atualização de status) | Lambda ou worker que atualiza DynamoDB/status | dlq-video-status-update |
| **q-video-zip-finalize** | Step Functions ou Lambda Processor (sinal de conclusão) | Lambda Video Finalizer (gera zip, publica SNS completed) | dlq-video-zip-finalize |

- **SNS video-submitted → SQS q-video-process:** o tópico SNS (Storie-05) encaminha mensagens para esta fila; a subscription SNS→SQS é configurada em outra story ou no mesmo módulo em etapa de integração. Esta story apenas cria a fila e a DLQ.
- **Status update → q-video-status-update:** usado para atualizar status do processamento (ex.: "processing", "extracting frames") sem bloquear o fluxo principal.
- **Finalize zip → q-video-zip-finalize:** dispara a Lambda Video Finalizer para consolidar imagens, gerar zip e publicar em topic-video-completed.

---

## Resiliência e DLQ como "Caixa de Falhas"

- **Redrive policy:** Todas as filas principais possuem `redrive_policy` apontando para a DLQ correspondente com `maxReceiveCount` configurável. Após N falhas de processamento (mensagem devolvida ou não deletada), a mensagem vai para a DLQ.
- **DLQ = caixa de falhas:** As Dead Letter Queues armazenam mensagens que não puderam ser processadas com sucesso, evitando perda de dados e permitindo inspeção, retry manual ou reprocessamento. Nenhuma mensagem é descartada sem passar pela DLQ quando redrive está configurado.
- **Parâmetros essenciais:** `visibility_timeout` (tempo para processar sem ficar visível para outros consumidores), `message_retention_seconds` (retenção na fila principal), `max_receive_count` (tentativas antes de enviar à DLQ) — todos parametrizados por variável para ajuste por ambiente.
- **Sem Lambdas/event mappings nesta story:** Apenas filas e DLQs; quem consome (Lambdas) e quem conecta (SNS→SQS, Step Functions→SQS) é tratado em outras stories.

---

## Variáveis do Módulo (SQS)
- **prefix** (string, obrigatório): prefixo do foundation (já existente se Storie-05 foi aplicada no mesmo módulo).
- **common_tags** (map, obrigatório): tags do foundation.
- **visibility_timeout_seconds** (number, opcional, default ex.: 300): tempo de visibilidade da mensagem após recebimento (segundos).
- **message_retention_seconds** (number, opcional, default ex.: 345600 = 4 dias): retenção de mensagens na fila principal.
- **max_receive_count** (number, opcional, default ex.: 3): número de tentativas antes de enviar mensagem à DLQ (usado na redrive_policy).
- **dlq_message_retention_seconds** (number, opcional): retenção na DLQ (ex.: 1209600 = 14 dias) para inspeção de falhas.

## Decisões Técnicas
- **Somente SQS (filas + DLQs) nesta story:** nenhuma Lambda, nenhum event_source_mapping, nenhuma subscription SNS→SQS criada nesta story (pode ser feita em story de integração).
- **Naming:** nomes ex.: `{prefix}-q-video-process`, `{prefix}-dlq-video-process` (e equivalentes para status-update e zip-finalize).
- **Redrive policy:** cada fila principal tem redrive_policy com queue_arn da DLQ e max_receive_count = var.max_receive_count; DLQs não têm redrive (são destino final).
- **Resiliência:** documentar na story e no README que DLQ é a "caixa de falhas" e que redrive policy evita perda de mensagens.

## Subtasks
- [x] [Subtask 01: Variáveis SQS (visibility, retention, maxReceiveCount) e consumo do foundation](./subtask/Subtask-01-Variaveis_SQS_Foundation.md)
- [x] [Subtask 02: Filas principais e DLQs (q-video-process, q-video-status-update, q-video-zip-finalize)](./subtask/Subtask-02-Filas_DLQs.md)
- [x] [Subtask 03: Redrive policy em todas as filas principais](./subtask/Subtask-03-Redrive_Policy.md)
- [x] [Subtask 04: Outputs (queue URLs e ARNs) e documentação do encaixe no desenho](./subtask/Subtask-04-Outputs_Encaixe.md)
- [x] [Subtask 05: Documentar resiliência e DLQ como caixa de falhas; validação](./subtask/Subtask-05-Resiliencia_Validacao.md)

## Critérios de Aceite da História
- [x] O módulo `terraform/30-messaging` cria três pares de fila + DLQ: q-video-process + dlq-video-process, q-video-status-update + dlq-video-status-update, q-video-zip-finalize + dlq-video-zip-finalize, com nomes derivados do prefix
- [x] Redrive policy está configurada em todas as filas principais, apontando para a DLQ correspondente com maxReceiveCount via variável
- [x] Parâmetros essenciais são configuráveis por variável: visibility_timeout (visibility_timeout_seconds), retention (message_retention_seconds), maxReceiveCount (max_receive_count); DLQ retention opcional (dlq_message_retention_seconds)
- [x] Outputs expõem queue URLs e ARNs das seis filas (três principais + três DLQs)
- [x] Nenhuma Lambda nem event mapping (event_source_mapping, subscription SNS→SQS) criada nesta story
- [x] A story documenta o encaixe no desenho: SNS video-submitted → q-video-process; status update → q-video-status-update; finalize zip → q-video-zip-finalize
- [x] A story reforça resiliência e DLQ como "caixa de falhas" (evitar perda de mensagens, inspeção e retry)
- [x] Consumo de prefix e common_tags do foundation; terraform plan sem referências quebradas

## Checklist de Conclusão
- [x] Arquivos .tf do 30-messaging (parte SQS) criados/atualizados; nenhum aws_lambda_* nem event mapping no escopo desta story
- [x] terraform init e terraform validate em terraform/30-messaging com sucesso
- [x] terraform plan com variáveis fornecidas, sem erros de referência
- [x] README ou story documenta encaixe no desenho e resiliência/DLQ como caixa de falhas
