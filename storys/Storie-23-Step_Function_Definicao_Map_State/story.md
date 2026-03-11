# Storie-23: Step Function — Definição Map State (Fan-out Chunks)

## Status
- **Estado:** 🟡 Em desenvolvimento
- **Data de Conclusão:** [DD/MM/AAAA]

## Descrição
Como engenheiro de infraestrutura, quero substituir o placeholder da State Machine Step Functions pela definição real com Map State, para que o processamento de chunks de vídeo ocorra em paralelo e o status de conclusão seja enviado à fila SQS correta.

## Objetivo
Substituir a definição placeholder da State Machine (Pass state) pela definição completa que executa: **Map** (fan-out paralelo de chunks via Lambda `video-processor`) → **Update Status** (envio de mensagem à fila `q-video-status-update`) → **Success**. O JSON de definição deverá ser gerenciado via Terraform, sem ARNs e URLs hardcoded.

## Escopo Técnico
- **Tecnologias:** Terraform ~> 5.0 (AWS provider), AWS Step Functions, AWS Lambda, AWS SQS
- **Arquivos afetados:**
  - `terraform/70-orchestration/stepfunctions.tf` — substituir `locals.sfn_definition` com a definição Map State
  - `terraform/70-orchestration/variables.tf` — adicionar variável `q_video_status_update_url`
  - `terraform/main.tf` — passar `q_video_status_update_url = module.messaging.q_video_status_update_url` ao módulo `orchestration`
- **Componentes/Recursos:**
  - `aws_sfn_state_machine.video_processing` — resource já existente, apenas a `definition` muda
  - `local.sfn_definition` — local Terraform com o jsonencode da nova definição
- **Pacotes/Dependências:** Nenhum pacote externo novo; usa recursos AWS já criados nos módulos `50-lambdas-shell` e `30-messaging`

## Dependências e Riscos (para estimativa)
- **Dependências:**
  - Módulo `50-lambdas-shell`: output `lambda_video_processor_arn` (já disponível e passado ao módulo)
  - Módulo `30-messaging`: output `q_video_status_update_url` (já existe no módulo, mas ainda não é passado ao módulo `70-orchestration`)
- **Riscos/Pré-condições:**
  - A Lab Role usada pela State Machine (`var.lab_role_arn`) deve ter permissão `sqs:SendMessage` para `q-video-status-update`; verificar se já está coberta pela LabRole da AWS Academy
  - O contrato de entrada da State Machine muda: o payload deve conter `chunks` (array), `contractVersion`, `videoId`, `userId`, `s3BucketVideo`, `s3KeyVideo` e `output` (com `manifestBucket`, `framesBucket`, `framesBasePrefix`)
  - A variável `finalization_mode` deixa de controlar a definição da SFN nesta story; pode ser removida do local ou mantida para uso futuro
  - Sem alterações em outros módulos além dos listados acima

## Subtasks
- [x] [Subtask 01: Adicionar variável q_video_status_update_url e passar no root](./subtask/Subtask-01-Variavel_Status_Update_Root.md)
- [x] [Subtask 02: Substituir sfn_definition pelo Map State completo](./subtask/Subtask-02-Map_State_Definicao_SFN.md)
- [x] [Subtask 03: Validar terraform fmt, validate e plan](./subtask/Subtask-03-Validacao_Fmt_Validate_Plan.md)

## Critérios de Aceite da História
- [ ] `terraform fmt -recursive` executado sem alterações (código já formatado)
- [ ] `terraform validate` retorna "Success! The configuration is valid."
- [ ] `terraform plan` não exibe erros; mostra `~ update in-place` apenas no recurso `aws_sfn_state_machine.video_processing[0]` (mudança de `definition`)
- [ ] A definição da State Machine não contém ARNs ou URLs hardcoded; usa `var.lambda_processor_arn` e `var.q_video_status_update_url`
- [ ] O local `sfn_definition` gera JSON equivalente ao backup fornecido pelo usuário (Map state com ItemSelector, Retry, Update Status e Success)
- [ ] A variável `q_video_status_update_url` está declarada em `variables.tf` do módulo `70-orchestration` e passada corretamente no root `main.tf`
- [ ] O README do módulo `70-orchestration` reflete o novo contrato de entrada (campos `chunks`, `contractVersion`, `output`, etc.)

## Rastreamento (dev tracking)
- **Início:** dia 10/03/2025 (Brasília)
- **Fim:** —
- **Tempo total de desenvolvimento:** —
