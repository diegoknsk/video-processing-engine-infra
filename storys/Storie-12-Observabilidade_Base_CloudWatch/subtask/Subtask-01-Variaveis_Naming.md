# Subtask 01: Variáveis (log_retention_days global, prefix, naming)

## Descrição
Criar ou alinhar as variáveis necessárias para observabilidade base: **log_retention_days** (variável global, retenção em dias para todos os log groups), **prefix** (contém environment, ex.: video-processing-engine-dev) e **common_tags**. Definir o padrão de naming dos log groups: /aws/lambda/{prefix}-auth, /aws/lambda/{prefix}-video-management, /aws/lambda/{prefix}-video-orchestrator, /aws/lambda/{prefix}-video-processor, /aws/lambda/{prefix}-video-finalizer e /aws/stepfunctions/{prefix}-video-processing. Garantir que prefix + environment esteja documentado (prefix já inclui environment no desenho).

## Passos de implementação
1. Se for criado módulo **75-observability**, criar `terraform/75-observability/variables.tf` com variáveis: prefix (string), common_tags (map), log_retention_days (number, default ex.: 14 ou 30). Incluir description: "Variável global de retenção em dias para todos os log groups; reter por X dias."
2. Se for estender **50-lambdas-shell** e **70-orchestration**, adicionar variável log_retention_days ao 50-lambdas-shell (e garantir que 70-orchestration já use log_retention_days ou variável equivalente). Documentar no foundation ou nos módulos que log_retention_days é a variável global para observabilidade.
3. Documentar o padrão de naming: log group Lambda = /aws/lambda/{prefix}-{suffix} onde suffix é auth, video-management, video-orchestrator, video-processor, video-finalizer; log group SFN = /aws/stepfunctions/{prefix}-video-processing (ou nome já usado no 70-orchestration). Prefix já inclui environment (ex.: video-processing-engine-dev).
4. Garantir que nenhuma variável dependa de path absoluto; consumo de prefix/common_tags do foundation quando aplicável.

## Formas de teste
1. Executar `terraform validate` no(s) módulo(s) afetado(s) após criar/atualizar variables.tf; validar que não há erro de variável não declarada.
2. Verificar que log_retention_days tem default seguro (ex.: 14 ou 30) e que prefix está disponível para construção dos nomes dos log groups.
3. Listar os 6 nomes de log groups esperados (5 Lambda + 1 SFN) e confirmar que seguem o padrão prefix + sufixo documentado.

## Critérios de aceite da subtask
- [ ] Variável global log_retention_days existe (no módulo 75-observability ou nos módulos 50-lambdas-shell/70-orchestration) com default seguro; prefix e common_tags disponíveis.
- [ ] Padrão de naming (prefix + environment já em prefix; sufixos para auth, video-management, video-orchestrator, video-processor, video-finalizer, e stepfunctions/video-processing) está documentado; terraform validate passa.
