# Subtask 02: Log group dedicado para SFN com retenção configurável

## Descrição
Criar um log group CloudWatch dedicado para a State Machine Step Functions no módulo `terraform/70-orchestration`, com nome derivado do prefix (ex.: `/aws/stepfunctions/{prefix}-video-processing`) e retenção configurável por variável (log_retention_days). O recurso deve ser criado apenas quando enable_stepfunctions = true. A State Machine usará esse log group para logging de execuções.

## Passos de implementação
1. Criar arquivo `terraform/70-orchestration/logs.tf` (ou adicionar ao main.tf) com recurso aws_cloudwatch_log_group para a SFN: name = "/aws/stepfunctions/${var.prefix}-video-processing" (ou equivalente), retention_in_days = var.log_retention_days, tags = var.common_tags.
2. Condicionar a criação do log group a var.enable_stepfunctions: usar count = var.enable_stepfunctions ? 1 : 0 (ou equivalente) para que o recurso exista apenas quando enable_stepfunctions = true.
3. Garantir que a State Machine (criada na Subtask 04) referencie este log group na configuração de logging (logging_configuration do aws_sfn_state_machine).
4. Documentar em comentário: "Log group dedicado para Step Functions; retenção configurável para controle de custo e compliance."

## Formas de teste
1. Executar `terraform plan` com enable_stepfunctions = true e log_retention_days = 14; verificar que o plano inclui aws_cloudwatch_log_group com retention_in_days = 14.
2. Executar `terraform plan` com enable_stepfunctions = false; verificar que o log group não é criado (count = 0).
3. Confirmar que o nome do log group usa var.prefix e que retention_in_days = var.log_retention_days.

## Critérios de aceite da subtask
- [ ] Existe recurso aws_cloudwatch_log_group dedicado à SFN com nome derivado do prefix e retention_in_days = var.log_retention_days.
- [ ] O log group é criado apenas quando enable_stepfunctions = true (count ou conditional).
- [ ] A State Machine (quando criada) pode referenciar este log group em logging_configuration; terraform validate e plan passam.
