# Storie-26: Permissão SNS na IAM Role de Execução da Step Function

## Status
- **Estado:** ⏸️ Pausada
- **Data de Conclusão:** [DD/MM/AAAA]

## Descrição
Como engenheiro de infraestrutura, quero que a IAM Role de execução da Step Function possua permissão para publicar no tópico SNS de erros, para que o fluxo de tratamento de erro da state machine consiga notificar via SNS sem erro de autorização (AuthorizationError 403).

## Objetivo
Adicionar, na IAM Role `${prefix}-sfn-exec-role` gerenciada pelo módulo `70-orchestration`, um statement de política com permissão mínima `sns:Publish` direcionada ao ARN do tópico SNS `topic-video-processing-error`, eliminando o erro 403 que ocorre no bloco `Catch` da State Machine ao tentar publicar a notificação de erro.

## Contexto Técnico
- A Step Function (`video-processing.asl.json`) já possui referência ao `topic_video_processing_error_arn` via `templatefile` em `stepfunctions.tf`.
- A variável `topic_video_processing_error_arn` **não existe** em `terraform/70-orchestration/variables.tf` — precisa ser declarada.
- A IAM policy em `terraform/70-orchestration/iam.tf` **não possui** statement para `sns:Publish` — precisa ser adicionado.
- O módulo `30-messaging` já exporta o output `topic_video_processing_error_arn`.
- O `terraform/main.tf` (root) precisa passar o ARN do SNS ao módulo `orchestration`.
- Princípio de menor privilégio: apenas `sns:Publish`; sem wildcard `*` no Resource.
- Permissões existentes (`lambda:InvokeFunction`, `sqs:SendMessage`, `logs:*`) **não devem ser alteradas**.

## Escopo Técnico
- **Tecnologias:** Terraform >= 1.0, AWS provider ~> 5.0, IAM, SNS, Step Functions
- **Arquivos afetados:**
  - `terraform/70-orchestration/variables.tf` — nova variável `topic_video_processing_error_arn`
  - `terraform/70-orchestration/iam.tf` — novo statement `SNSPublishError` na policy `sfn_exec`
  - `terraform/main.tf` — passar `topic_video_processing_error_arn = module.messaging.topic_video_processing_error_arn` ao módulo `orchestration`
- **Componentes/Recursos:**
  - `aws_iam_role_policy.sfn_exec` (resource existente — adicionar statement)
  - `aws_sfn_state_machine.video_processing` (sem alteração — já usa a variável)
- **Pacotes/Dependências:** Nenhum pacote externo novo; apenas configuração Terraform.

## Dependências e Riscos (para estimativa)
- **Dependências:**
  - Módulo `30-messaging` deve estar aplicado (tópico SNS criado e ARN disponível no output).
  - Módulo `70-orchestration` deve estar habilitado (`enable_stepfunctions = true`).
- **Riscos:**
  - Risco baixo: mudança cirúrgica apenas no statement da policy inline existente.

## Subtasks
- [Subtask 01: Declarar variável topic_video_processing_error_arn no módulo 70-orchestration](./subtask/Subtask-01-Declarar_Variavel_SNS_ARN_Orchestration.md)
- [Subtask 02: Adicionar statement SNSPublishError na policy IAM da Step Function](./subtask/Subtask-02-Adicionar_Statement_SNS_IAM_Policy.md)
- [Subtask 03: Passar ARN do SNS do root main.tf ao módulo orchestration](./subtask/Subtask-03-Passar_ARN_SNS_Root_MainTF.md)
- [Subtask 04: Validar terraform fmt, validate e plano de execução](./subtask/Subtask-04-Validacao_Terraform_Plan.md)

## Critérios de Aceite da História
- [ ] Variável `topic_video_processing_error_arn` declarada em `terraform/70-orchestration/variables.tf` com description e sem default (obrigatória).
- [ ] Statement `SNSPublishError` adicionado à policy `sfn_exec` com `Effect: Allow`, `Action: ["sns:Publish"]` e `Resource: [var.topic_video_processing_error_arn]` — sem wildcard `*`.
- [ ] Permissões existentes (`LambdaInvoke`, `SQSSend`, `CloudWatchLogs`) mantidas sem alteração.
- [ ] Root `main.tf` passa `topic_video_processing_error_arn = module.messaging.topic_video_processing_error_arn` ao módulo `orchestration`.
- [ ] `terraform fmt -recursive` executado sem diff residual.
- [ ] `terraform validate` retorna "The configuration is valid." sem erros.
- [ ] `terraform plan` mostra apenas a atualização da policy `sfn_exec` (nenhum recurso destruído ou recriado desnecessariamente).
- [ ] Após `terraform apply`, execução real da State Machine que cai no `Catch` de erro consegue publicar no SNS sem erro 403.
- [ ] Nenhum ARN hardcoded nos arquivos `.tf`; sempre via variável.

## Rastreamento (dev tracking)
- **Início:** —
- **Fim:** —
- **Tempo total de desenvolvimento:** —
