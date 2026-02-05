# Subtask 03: Log Group Step Functions e alinhamento com 70-orchestration

## Descrição
Garantir que o Log Group para Step Functions exista com **retenção configurável** e siga o padrão de naming (prefix + environment). O log group da SFN já existe no módulo 70-orchestration (Storie-09); esta subtask garante que (1) a retenção seja controlada por variável global (log_retention_days) ou variável do módulo 70-orchestration alinhada à observabilidade, e (2) o nome siga o padrão /aws/stepfunctions/{prefix}-video-processing (ou equivalente). Se o módulo 75-observability for usado, documentar que o log group da SFN permanece no 70-orchestration com retenção via variável; ou criar o log group da SFN no 75-observability e referenciar no 70-orchestration (mais invasivo). Preferir: manter log group SFN no 70-orchestration e documentar alinhamento da variável log_retention_days.

## Passos de implementação
1. Verificar no módulo **70-orchestration** que o log group da SFN (aws_cloudwatch_log_group) existe com retention_in_days = var.log_retention_days (ou variável equivalente). Se não existir variável de retenção, adicionar log_retention_days ao 70-orchestration e usar no recurso do log group; documentar que a mesma variável global (log_retention_days) deve ser passada ao 70-orchestration para alinhamento com observabilidade.
2. Confirmar que o nome do log group da SFN segue o padrão: /aws/stepfunctions/{prefix}-video-processing (ou o já definido na Storie-09); prefix já inclui environment.
3. Se for criado módulo 75-observability e optar por centralizar o log group da SFN nele: criar aws_cloudwatch_log_group para SFN em 75-observability com name = "/aws/stepfunctions/${var.prefix}-video-processing", retention_in_days = var.log_retention_days; o 70-orchestration precisaria referenciar esse log group (data source ou variável) em logging_configuration — mais invasivo. Preferir manter no 70-orchestration e apenas alinhar variável.
4. Documentar no README da observabilidade: "Log group da Step Functions está no módulo 70-orchestration com retenção configurável; usar a mesma variável log_retention_days para consistência."
5. Garantir que não haja duplicação de log group (apenas um recurso por nome).

## Formas de teste
1. Executar `terraform plan` no 70-orchestration com log_retention_days (ou variável de retenção) preenchida; verificar que o log group da SFN tem retention_in_days configurado.
2. Verificar que o nome do log group da SFN segue o padrão prefix + sufixo (stepfunctions/video-processing).
3. Confirmar que não há dois recursos criando o mesmo log group; terraform validate e plan passam.

## Critérios de aceite da subtask
- [ ] Log group para Step Functions existe com retenção configurável (no 70-orchestration com var.log_retention_days ou equivalente); nome alinhado ao padrão (prefix + sufixo).
- [ ] Documentação de alinhamento entre observabilidade e 70-orchestration (mesma variável de retenção); sem duplicação de recurso; terraform validate e plan passam.
