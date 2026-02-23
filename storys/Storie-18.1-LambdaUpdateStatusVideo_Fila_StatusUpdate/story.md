# Storie-18.1: Revisão de Fluxo — LambdaUpdateStatusVideo, Orquestrador via SQS e Remoção do SNS topic-video-submitted

## Status
- **Estado:** 🔄 Em desenvolvimento
- **Data de Conclusão:** [DD/MM/AAAA]

## Rastreamento (dev tracking)
- **Início:** dia 22/02/2026, às 18:21 (Brasília)
- **Fim:** —
- **Tempo total de desenvolvimento:** —

## Descrição
Como engenheiro de infraestrutura, quero corrigir e consolidar o fluxo de processamento de vídeos: eliminando a `LambdaVideoDispatcher` (criada indevidamente na Story 18), conectando a fila `q-video-process` diretamente ao `LambdaVideoOrchestrator`, removendo o SNS `topic-video-submitted` que não é mais necessário, e criando a `LambdaUpdateStatusVideo` como consumidora exclusiva da fila `q-video-status-update`, para que cada componente tenha responsabilidade única e o fluxo seja simples e rastreável.

## Objetivo
Consolidar o pipeline de vídeo no seguinte fluxo final:

```
[Upload S3] → q-video-process → LambdaVideoOrchestrator
                                        ↓
                          (Step Functions / processamento)
                                        ↓
                         q-video-status-update → LambdaUpdateStatusVideo
```

Para isso: (1) remover `LambdaVideoDispatcher` e seu event source mapping de `q-video-process`; (2) criar event source mapping `q-video-process → LambdaVideoOrchestrator`; (3) eliminar o tópico SNS `topic-video-submitted` e todas as suas referências em variáveis, outputs e variáveis de ambiente das Lambdas; (4) criar a Lambda casca `LambdaUpdateStatusVideo` com responsabilidade exclusiva de atualizar status; (5) criar event source mapping `q-video-status-update → LambdaUpdateStatusVideo`; (6) remover o mapeamento `q-video-status-update → LambdaVideoManagement` e a variável de controle `enable_status_update_consumer`.

---

## Contexto: Fluxo Atual vs Fluxo Novo

### Fluxo atual (resultado da Story 18 — a ser corrigido)
```
Upload S3 (bucket videos, prefix "videos/", suffix "original")
  → aws_s3_bucket_notification → SQS q-video-process (direto)     ← correto, manter
  → LambdaVideoDispatcher (event source mapping)                   ← incorreto, remover

q-video-status-update
  → LambdaVideoManagement (condicional via enable_status_update_consumer)  ← remover
```

SNS `topic-video-submitted` ainda existe no módulo 30-messaging (criado na Story 05).
`LambdaVideoManagement` ainda usa `TOPIC_VIDEO_SUBMITTED_ARN` como variável de ambiente.

### Fluxo novo (a implementar nesta story)
```
Upload S3 (bucket videos)
  → aws_s3_bucket_notification → SQS q-video-process (direto)   ← mantém da Story 18
  → LambdaVideoOrchestrator (event source mapping novo)          ← CORRETO

q-video-status-update
  → LambdaUpdateStatusVideo (exclusivo, só atualiza status)      ← NOVO

SNS topic-video-submitted                                         ← REMOVIDO
```

---

## Relação com Story 18

| Story | Escopo |
|-------|--------|
| **Story 18** | S3 → `q-video-process` direto (sem SNS); `LambdaVideoDispatcher` foi criado mas **não deve permanecer** |
| **Story 18.1** | Corrige o que foi feito na Story 18: remove `LambdaVideoDispatcher`, conecta `q-video-process` ao orquestrador, elimina SNS `topic-video-submitted`, cria `LambdaUpdateStatusVideo` para `q-video-status-update` |

> **Nota:** O trecho S3 → `q-video-process` (notificação direta com filtros) criado na Story 18 em `upload_integration.tf` está **correto e não deve ser alterado**.

---

## Escopo Técnico
- **Tecnologias:** Terraform >= 1.0, AWS Provider (~> 6.0)
- **Arquivos afetados:**

| Arquivo | Ação |
|---------|------|
| `terraform/50-lambdas-shell/lambdas.tf` | Remover `aws_lambda_function.video_dispatcher`; adicionar `aws_lambda_function.update_status_video`; remover env var `TOPIC_VIDEO_SUBMITTED_ARN` do `video_management` |
| `terraform/50-lambdas-shell/event_source_mapping.tf` | Remover `sqs_invoke_video_dispatcher` e `video_dispatcher_q_video_process`; adicionar `sqs_invoke_orchestrator` e `orchestrator_q_video_process`; remover blocos condicionais de `video_management_q_video_status_update`; adicionar `sqs_invoke_update_status_video` e `update_status_video_q_video_status_update` |
| `terraform/50-lambdas-shell/variables.tf` | Remover `enable_status_update_consumer`; remover `topic_video_submitted_arn` |
| `terraform/50-lambdas-shell/outputs.tf` | Remover outputs de `video_dispatcher`; adicionar outputs de `update_status_video` |
| `terraform/30-messaging/sns.tf` | Remover `aws_sns_topic.topic_video_submitted` |
| `terraform/30-messaging/outputs.tf` | Remover `output "topic_video_submitted_arn"` |
| `terraform/variables.tf` | Remover `enable_status_update_consumer` |
| `terraform/main.tf` | Remover `enable_status_update_consumer` e `topic_video_submitted_arn` do bloco `module "lambdas"` |

- **Componentes/Recursos criados:**
  - `aws_lambda_function.update_status_video` (novo — casca `empty.zip`, apenas atualiza status)
  - `aws_lambda_permission.sqs_invoke_update_status_video` (novo)
  - `aws_lambda_event_source_mapping.update_status_video_q_video_status_update` (novo)
  - `aws_lambda_permission.sqs_invoke_orchestrator` (novo)
  - `aws_lambda_event_source_mapping.orchestrator_q_video_process` (novo)

- **Componentes/Recursos removidos:**
  - `aws_lambda_function.video_dispatcher` (remover)
  - `aws_lambda_permission.sqs_invoke_video_dispatcher` (remover)
  - `aws_lambda_event_source_mapping.video_dispatcher_q_video_process` (remover)
  - `aws_lambda_permission.sqs_invoke_video_management` (remover — bloco condicional)
  - `aws_lambda_event_source_mapping.video_management_q_video_status_update` (remover — bloco condicional)
  - `aws_sns_topic.topic_video_submitted` (remover do módulo 30-messaging)
  - `output "topic_video_submitted_arn"` (remover do módulo 30-messaging)
  - `variable "enable_status_update_consumer"` (remover do módulo e do root)
  - `variable "topic_video_submitted_arn"` (remover do módulo 50-lambdas-shell)
  - Env var `TOPIC_VIDEO_SUBMITTED_ARN` de `LambdaVideoManagement` (remover)

- **Pacotes/Dependências:** Nenhum pacote externo; apenas recursos HCL e AWS Provider existente.

---

## Dependências e Riscos (para estimativa)

- **Dependências:**
  - Story 18 (concluída ou em paralelo): o trecho S3 → `q-video-process` de `upload_integration.tf` deve estar deployado.
  - Storie-05 (30-messaging SNS): `topic-video-submitted` será destruído — confirmar que nenhum outro recurso referencia esse tópico.
  - Storie-06 (30-messaging SQS): filas `q-video-process` e `q-video-status-update` existentes.
  - Storie-08 (50-lambdas-shell): `LambdaVideoOrchestrator` existente; `event_source_mapping.tf` existente.

- **Riscos/Pré-condições:**
  - **Risco (destrutivo — SNS):** `aws_sns_topic.topic_video_submitted` será destruído. Confirmar antes que nenhuma subscription ou outro recurso depende desse tópico.
  - **Risco (destrutivo — LambdaVideoDispatcher):** `aws_lambda_function.video_dispatcher` e seus event source mappings serão destruídos.
  - **Risco (janela sem consumer):** Entre remoção do `video_dispatcher` e criação do mapeamento para `video_orchestrator`, a fila `q-video-process` ficará sem consumer. Executar ambos no mesmo `terraform apply`.
  - **Risco (referência pendente):** `topic_video_submitted_arn` é passado pelo root `main.tf` ao módulo `lambdas`. Remover a variável e a passagem no mesmo apply para evitar erro de "undeclared variable".
  - **AWS Academy:** Usar `lab_role_arn` para a nova Lambda; nenhuma criação de IAM Role pelo Terraform.

---

## Subtasks

- [ ] [Subtask 01: Remover LambdaVideoDispatcher e seus event source mappings](./subtask/Subtask-01-Remover_LambdaVideoDispatcher.md)
- [ ] [Subtask 02: Criar event source mapping q-video-process para LambdaVideoOrchestrator](./subtask/Subtask-02-Mapping_QVideoProcess_Orquestrador.md)
- [ ] [Subtask 03: Remover SNS topic-video-submitted e todas as suas referências](./subtask/Subtask-03-Remover_SNS_TopicVideoSubmitted.md)
- [ ] [Subtask 04: Criar Lambda casca LambdaUpdateStatusVideo](./subtask/Subtask-04-Lambda_Casca_UpdateStatusVideo.md)
- [ ] [Subtask 05: Adicionar event source mapping q-video-status-update para LambdaUpdateStatusVideo](./subtask/Subtask-05-Mapping_QVideoStatusUpdate_UpdateStatus.md)
- [ ] [Subtask 06: Remover event source mapping q-video-status-update do LambdaVideoManagement](./subtask/Subtask-06-Remover_Mapeamento_VideoManagement.md)
- [ ] [Subtask 07: Ajustar variáveis, outputs e root module (main.tf)](./subtask/Subtask-07-Variaveis_Outputs_Root.md)
- [ ] [Subtask 08: Validação Terraform (fmt, validate, plan)](./subtask/Subtask-08-Validacao_Terraform.md)

---

## Critérios de Aceite da História

- [ ] `LambdaVideoDispatcher` **não existe** após apply: `aws_lambda_function.video_dispatcher`, `aws_lambda_permission.sqs_invoke_video_dispatcher` e `aws_lambda_event_source_mapping.video_dispatcher_q_video_process` removidos; `terraform plan` confirma a destruição
- [ ] O event source mapping `q-video-process → LambdaVideoOrchestrator` está ativo com `batch_size = 1`; a Lambda `video-orchestrator` é invocada ao consumir a fila
- [ ] O SNS `topic-video-submitted` **não existe** após apply: `aws_sns_topic.topic_video_submitted` removido de `30-messaging/sns.tf`; `terraform plan` confirma a destruição
- [ ] O output `topic_video_submitted_arn` removido de `30-messaging/outputs.tf`; a variável `topic_video_submitted_arn` removida de `50-lambdas-shell/variables.tf` e a passagem em `main.tf`; env var `TOPIC_VIDEO_SUBMITTED_ARN` removida de `LambdaVideoManagement`
- [ ] A Lambda `LambdaUpdateStatusVideo` existe com function name `${prefix}-update-status-video`, role `lab_role_arn`, artefato `empty.zip`, responsabilidade exclusiva de atualização de status
- [ ] O event source mapping `q-video-status-update → LambdaUpdateStatusVideo` está ativo com `batch_size = 1`
- [ ] A `aws_lambda_permission.sqs_invoke_update_status_video` está configurada com `principal = "sqs.amazonaws.com"` e `source_arn = q_video_status_update_arn`
- [ ] `aws_lambda_event_source_mapping.video_management_q_video_status_update` e `aws_lambda_permission.sqs_invoke_video_management` removidos; `terraform plan` confirma a destruição
- [ ] A variável `enable_status_update_consumer` removida de `50-lambdas-shell/variables.tf`, `terraform/variables.tf` e `terraform/main.tf`
- [ ] `terraform fmt -recursive`, `terraform validate` e `terraform plan` executam sem erros nos módulos alterados (`30-messaging`, `50-lambdas-shell`, root)
- [ ] Nenhuma credencial, ARN de Lab Role ou valor sensível hardcoded nos arquivos `.tf` alterados
