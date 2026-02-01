# Subtask 02: Log Groups para as 5 Lambdas com retenção

## Descrição
Criar os 5 recursos aws_cloudwatch_log_group para as Lambdas: Auth, VideoManagement, VideoOrchestrator, VideoProcessor, VideoFinalizer. Nomes: /aws/lambda/{prefix}-auth, /aws/lambda/{prefix}-video-management, /aws/lambda/{prefix}-video-orchestrator, /aws/lambda/{prefix}-video-processor, /aws/lambda/{prefix}-video-finalizer (alinhados aos nomes das funções no 50-lambdas-shell). Retenção configurável: retention_in_days = var.log_retention_days. Tags = var.common_tags. Sem ferramentas pagas; apenas CloudWatch.

## Passos de implementação
1. Criar arquivo `terraform/75-observability/log_groups.tf` (ou adicionar ao 50-lambdas-shell se opção B) com 5 recursos aws_cloudwatch_log_group: name = "/aws/lambda/${var.prefix}-auth", retention_in_days = var.log_retention_days, tags = var.common_tags; idem para video-management, video-orchestrator, video-processor, video-finalizer.
2. Garantir que os nomes coincidam exatamente com os nomes das funções Lambda no módulo 50-lambdas-shell (formato {prefix}-auth, etc.), para que ao invocar a Lambda a AWS use esse log group (e não crie um novo sem retenção).
3. Se o módulo 75-observability for aplicado antes do 50-lambdas-shell, os log groups existirão quando as Lambdas forem criadas e as Lambdas usarão esses grupos automaticamente.
4. Documentar em comentário: "Log groups para observabilidade base; retenção configurável; sem ferramentas pagas."
5. Não criar recursos além de CloudWatch Logs; nenhuma ferramenta paga.

## Formas de teste
1. Executar `terraform plan` com prefix e log_retention_days preenchidos; verificar que o plano inclui 5 aws_cloudwatch_log_group com retention_in_days = var.log_retention_days.
2. Comparar os nomes dos log groups com os nomes das funções no 50-lambdas-shell (variables ou resources) e confirmar que são idênticos ao padrão /aws/lambda/{function_name}.
3. Verificar que não há recurso de ferramenta paga (X-Ray, etc.); apenas aws_cloudwatch_log_group; terraform validate e plan passam.

## Critérios de aceite da subtask
- [ ] Existem 5 aws_cloudwatch_log_group para as 5 Lambdas com nomes /aws/lambda/{prefix}-auth, /aws/lambda/{prefix}-video-management, /aws/lambda/{prefix}-video-orchestrator, /aws/lambda/{prefix}-video-processor, /aws/lambda/{prefix}-video-finalizer.
- [ ] retention_in_days = var.log_retention_days em todos; tags = var.common_tags; sem ferramentas pagas; terraform validate e plan passam.
