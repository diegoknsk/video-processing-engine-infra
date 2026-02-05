# Storie-09: Implementar Módulo Terraform 70-Orchestration (Step Functions)

## Status
- **Estado:** 🔄 Em desenvolvimento
- **Data de Conclusão:** [DD/MM/AAAA]

## Descrição
Como desenvolvedor de infraestrutura, quero que o módulo `terraform/70-orchestration` provisione uma State Machine Step Functions inicial simples (sequencial, 1 processor), com estrutura preparada para evolução para Map State (fan-out), log group dedicado com retenção configurável e IAM com permissões mínimas para invocar LambdaVideoProcessor e encaminhar a finalização (SQS ou Lambda), para que o fluxo Orchestrator → SFN → Processor → finalização esteja alinhado ao desenho do Processador Video MVP.

## Objetivo
Criar o módulo `terraform/70-orchestration` com: State Machine Step Functions **inicial simples** (sequencial, 1 processor — invoca LambdaVideoProcessor); **estrutura preparada para Map State** (fan-out) conforme desenho; **enable_stepfunctions** via variável; **log group dedicado** para SFN com retenção configurável; **IAM role da SFN** com permissões mínimas (invocar LambdaVideoProcessor e encaminhar finalização). Decisão de finalização parametrizável: ao final, **publicar mensagem em q-video-zip-finalize** (Finalizer acionada por SQS) **ou** **chamar LambdaVideoFinalizer** diretamente (parametrizar por variável, ex.: finalization_mode = "sqs" | "lambda"). Outputs: state machine ARN e log group name. A story define o **payload padrão de entrada/saída** da State Machine.

## Escopo Técnico
- Tecnologias: Terraform >= 1.0, AWS Provider (~> 5.0)
- Arquivos afetados:
  - `terraform/70-orchestration/variables.tf` (prefix, common_tags, enable_stepfunctions, log_retention_days, finalization_mode, Lambda ARNs, queue URL/ARN)
  - `terraform/70-orchestration/stepfunctions.tf` ou `main.tf` (aws_sfn_state_machine, definição em JSON/HCL)
  - `terraform/70-orchestration/iam.tf` (role da SFN, políticas: lambda:InvokeFunction para Processor; sqs:SendMessage para q-video-zip-finalize ou lambda:InvokeFunction para Finalizer conforme finalization_mode)
  - `terraform/70-orchestration/logs.tf` (aws_cloudwatch_log_group para SFN, retenção configurável)
  - `terraform/70-orchestration/outputs.tf`
  - `terraform/70-orchestration/README.md` (payload, decisão de finalização, evolução Map State)
- Componentes/Recursos: aws_sfn_state_machine (definição simples: Start → Invoke Processor → Finalização [SQS ou Lambda] → End), aws_iam_role + policy para SFN, aws_cloudwatch_log_group; condicional por enable_stepfunctions.
- Pacotes/Dependências: Nenhum; consumo de prefix/common_tags e de outputs dos módulos lambdas (Processor ARN, Finalizer ARN) e messaging (q-video-zip-finalize URL/ARN).

## Dependências e Riscos (para estimativa)
- Dependências: Storie-02 (foundation), Storie-06 (messaging SQS — q-video-zip-finalize), Storie-08 (lambdas-shell — Processor e Finalizer ARNs).
- Riscos/Pré-condições: Definição da state machine em JSON/HCL deve refletir o payload padrão; evolução para Map State implica alterar definição em story futura sem quebrar contrato de entrada/saída.

## Modelo de execução (root único)
O diretório `terraform/70-orchestration/` é um **módulo** consumido pelo **root** em `terraform/` (Storie-02-Parte2). O root passa prefix, common_tags e outputs dos módulos lambdas e messaging. Init/plan/apply são executados uma vez em `terraform/`; validar com `terraform plan` no root.

---

## Payload Padrão (entrada/saída)

### Entrada (input da execução — Orchestrator envia ao iniciar SFN)
Contrato mínimo que a Lambda Video Orchestrator deve enviar ao chamar `StartExecution`:

```json
{
  "videoId": "<string>",
  "userId": "<string>",
  "s3Bucket": "<string>",
  "s3VideoKey": "<string>",
  "requestId": "<string, opcional>"
}
```

- **videoId:** identificador do vídeo (DynamoDB, correlação).
- **userId:** dono do vídeo (DynamoDB, segurança/partição).
- **s3Bucket:** bucket onde o vídeo foi enviado (ex.: videos).
- **s3VideoKey:** chave S3 do objeto vídeo.
- **requestId:** opcional, para rastreabilidade (ex.: idempotência).

A State Machine repassa esse payload (ou subconjunto) à Lambda Video Processor; a aplicação pode estender o contrato sem quebrar esses campos obrigatórios.

### Saída (output da execução — sucesso)
Contrato mínimo ao concluir com sucesso (após Processor e, se aplicável, Finalizer):

```json
{
  "videoId": "<string>",
  "userId": "<string>",
  "status": "completed",
  "imagesPrefix": "<string, opcional>",
  "zipS3Key": "<string, opcional>"
}
```

- **videoId, userId:** eco do input.
- **status:** "completed" | "failed" (ou valor definido pela aplicação).
- **imagesPrefix:** prefixo das imagens no S3 images (quando aplicável).
- **zipS3Key:** chave do zip no S3 zip (quando finalização já tiver rodado na mesma execução ou quando for retorno da Finalizer).

Em cenário **finalization_mode = "sqs"**, a SFN pode terminar após o Processor e a saída da execução não incluir zipS3Key (a Finalizer preenche depois ao consumir q-video-zip-finalize). Em **finalization_mode = "lambda"**, a SFN invoca a Finalizer e a saída pode incluir zipS3Key se a Lambda retornar isso.

A story documenta esse contrato; a aplicação pode adicionar campos sem remover os obrigatórios.

---

## Decisão de Finalização (parametrizável)

| finalization_mode | Comportamento | IAM da SFN | Alinhamento |
|-------------------|---------------|------------|-------------|
| **sqs** | Ao final do processamento, a State Machine envia uma mensagem para **q-video-zip-finalize**; a Lambda Video Finalizer é acionada pelo event source mapping (SQS). | lambda:InvokeFunction (Processor); sqs:SendMessage (q-video-zip-finalize). | Desenho: "Uma SQS de finalização é acionada" → Finalizer consome a fila. |
| **lambda** | Ao final do processamento, a State Machine **invoca diretamente** a Lambda Video Finalizer. | lambda:InvokeFunction (Processor e Finalizer). | Alternativa mais acoplada; útil se não quiser depender da fila na mesma execução. |

- **Variável:** `finalization_mode` (string): "sqs" | "lambda"; default recomendado "sqs" para alinhar ao desenho (SQS de finalização → Finalizer).
- **Implementação:** Definição da state machine (estado de finalização) e IAM da SFN devem respeitar o valor de finalization_mode (condicional ou definição gerada).

---

## Alinhamento ao Desenho

- **Orchestrator** inicia a execução da SFN (StartExecution) com payload de entrada (videoId, userId, s3Bucket, s3VideoKey).
- **State Machine** (inicial simples): sequência **Start → Invoke LambdaVideoProcessor → Finalização (SQS ou Lambda) → End**.
- **Processor** gera frames no S3 images e pode publicar em q-video-status-update; ao concluir, a SFN encaminha para finalização (SQS ou Lambda).
- **Finalização:** modo **sqs** = SFN envia mensagem para q-video-zip-finalize; **lambda** = SFN invoca LambdaVideoFinalizer. A Finalizer consolida imagens, gera zip, publica SNS topic-video-completed.

Evolução futura: **Map State** para fan-out (múltiplos processamentos em paralelo); a estrutura da definição (estados nomeados, payload pass-through) deve permitir inserir um Map State sem quebrar o contrato de entrada/saída.

---

## Variáveis do Módulo
- **prefix**, **common_tags**: do foundation.
- **enable_stepfunctions** (bool, default = true): habilita criação da state machine, log group e IAM; false para desabilitar o módulo.
- **log_retention_days** (number, default ex.: 14): retenção em dias do log group da SFN.
- **finalization_mode** (string, default = "sqs"): "sqs" | "lambda".
- **lambda_processor_arn**: ARN da Lambda Video Processor (módulo 50-lambdas-shell).
- **lambda_finalizer_arn**: ARN da Lambda Video Finalizer (módulo 50-lambdas-shell).
- **q_video_zip_finalize_arn** (ou URL): fila q-video-zip-finalize (obrigatório quando finalization_mode = "sqs").

## Decisões Técnicas
- **State Machine:** Definição em JSON (inline ou arquivo) ou HCL (aws_sfn_state_machine com definition); fluxo simples: Process → Finalize (SQS ou Lambda) → End; estrutura de estados preparada para inserção de Map State (ex.: estado "Process" que pode ser substituído por Map sobre lista de itens).
- **Log group:** Nome ex.: `/aws/stepfunctions/{prefix}-video-processing` ou equivalente; retenção = var.log_retention_days.
- **IAM:** Role da SFN com policy: logs (CreateLogStream, PutLogEvents no log group da SFN), lambda:InvokeFunction para Processor; conforme finalization_mode: sqs:SendMessage para q-video-zip-finalize ou lambda:InvokeFunction para Finalizer.
- **enable_stepfunctions:** Quando false, não criar state machine nem log group (count = 0 ou conditional); outputs podem retornar string vazia ou placeholder.

## Subtasks
- [Subtask 01: Variáveis do módulo e consumo de ARNs (Processor, Finalizer, queue)](./subtask/Subtask-01-Variaveis_Consumo.md)
- [Subtask 02: Log group dedicado para SFN com retenção configurável](./subtask/Subtask-02-Log_Group_SFN.md)
- [Subtask 03: IAM role da SFN com permissões mínimas (Processor + finalização)](./subtask/Subtask-03-IAM_Role_SFN.md)
- [Subtask 04: State Machine inicial simples e estrutura para Map State](./subtask/Subtask-04-State_Machine_Definicao.md)
- [Subtask 05: Outputs (state machine ARN, log group name) e documentação do payload](./subtask/Subtask-05-Outputs_Payload.md)

## Critérios de Aceite da História
- [ ] O módulo `terraform/70-orchestration` cria uma State Machine Step Functions inicial simples (sequencial, 1 processor — invoca LambdaVideoProcessor) quando enable_stepfunctions = true
- [ ] Estrutura da definição preparada para evolução para Map State (fan-out) conforme desenho (estados e pass-through de payload documentados ou organizados para inserção de Map)
- [ ] enable_stepfunctions é parametrizável por variável; quando false, state machine e recursos opcionais não são criados (ou criados com count = 0)
- [ ] Log group dedicado para SFN existe com retenção configurável (log_retention_days)
- [ ] IAM role da SFN tem permissões mínimas: invocar LambdaVideoProcessor e encaminhar finalização (SQS SendMessage para q-video-zip-finalize ou Lambda Invoke Finalizer conforme finalization_mode)
- [ ] Decisão de finalização parametrizada: finalization_mode = "sqs" | "lambda"; implementação e IAM alinhadas ao modo
- [ ] Outputs expõem state machine ARN e log group name
- [ ] A story define o payload padrão de entrada (videoId, userId, s3Bucket, s3VideoKey, requestId opcional) e saída (videoId, userId, status, imagesPrefix, zipS3Key opcional)
- [ ] Consumo de prefix/common_tags e dos outputs dos módulos lambdas e messaging; terraform plan sem referências quebradas

## Checklist de Conclusão
- [ ] State machine criada com definição simples (Processor → Finalização); enable_stepfunctions respeitado
- [ ] Log group com retenção configurável; IAM com permissões mínimas (Processor + finalização)
- [ ] README ou story documenta payload de entrada/saída e finalization_mode
- [ ] terraform init, validate e plan com variáveis fornecidas passam
