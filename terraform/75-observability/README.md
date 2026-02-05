# Módulo 75-observability — CloudWatch Logs (observabilidade base)

Provisiona **log groups do CloudWatch** para as 5 Lambdas do projeto (Auth, Video Management, Video Orchestrator, Video Processor, Video Finalizer) com **retenção configurável**. Apenas CloudWatch; sem ferramentas pagas (sem X-Ray, APM de terceiros nesta story).

O **log group da Step Functions** permanece no módulo **70-orchestration** com retenção configurável (`log_retention_days`). Use a mesma variável global de retenção (ex.: `orchestration_log_retention_days` no root) para este módulo e para o 70-orchestration, para consistência.

---

## Padrão de naming

- **Prefix** já inclui environment (ex.: `video-processing-engine-dev`). Naming = prefix + sufixo.
- **Log groups Lambdas:** `/aws/lambda/{prefix}-auth`, `/aws/lambda/{prefix}-video-management`, `/aws/lambda/{prefix}-video-orchestrator`, `/aws/lambda/{prefix}-video-processor`, `/aws/lambda/{prefix}-video-finalizer` — coincidem com os nomes das funções no **50-lambdas-shell**.
- **Log group Step Functions:** `/aws/stepfunctions/{prefix}-video-processing` — criado no **70-orchestration** (não neste módulo).

---

## Variável global de retenção

- **log_retention_days** (number, default 14): retenção em dias para os 5 log groups das Lambdas. No root, repasse o mesmo valor usado no 70-orchestration (ex.: `orchestration_log_retention_days`) para consistência.

---

## IAM para escrita em logs

- **Lambdas (50-lambdas-shell):** Em AWS Academy as Lambdas usam **lab_role_arn**. A Lab Role deve ter permissão de escrita nos log groups: `logs:CreateLogStream`, `logs:PutLogEvents` em `arn:aws:logs:{region}:{account}:log-group:/aws/lambda/{prefix}-*:*`. Se a policy já usar `log-group:/aws/lambda/*`, está coberto.
- **Step Functions (70-orchestration):** A SFN usa **lab_role_arn**. A Lab Role deve ter permissão de escrita no log group `/aws/stepfunctions/{prefix}-video-processing`.

---

## Checklist pós-apply (validar logs ao invocar)

Após `terraform apply`, validar que os logs aparecem no CloudWatch:

1. **Lambda Auth:** Invocar via API Gateway (ex.: GET /auth/health) ou teste direto no console. Em CloudWatch Logs, abrir `/aws/lambda/{prefix}-auth` e verificar log stream com eventos recentes.
2. **Lambda Video Management:** Invocar (ex.: GET /videos ou teste direto). Verificar `/aws/lambda/{prefix}-video-management`.
3. **Lambda Video Orchestrator:** Enviar mensagem para q-video-process ou invocar direto. Verificar `/aws/lambda/{prefix}-video-orchestrator`.
4. **Lambda Video Processor:** Disparar execução da Step Function ou invocar direto. Verificar `/aws/lambda/{prefix}-video-processor`.
5. **Lambda Video Finalizer:** Enviar mensagem para q-video-zip-finalize ou invocar direto. Verificar `/aws/lambda/{prefix}-video-finalizer`.
6. **Step Functions:** Iniciar uma execução da state machine (via Orchestrator ou console). Em CloudWatch Logs, abrir `/aws/stepfunctions/{prefix}-video-processing` e verificar log stream da execução.

**Critério de sucesso:** Para cada recurso invocado, o log group correspondente deve ter pelo menos um log stream com eventos gerados após a invocação. Verificar que `retention_in_days` está aplicado na configuração do log group.

---

## Uso pelo caller (root)

Invocar o módulo **antes** do 50-lambdas-shell (ou na mesma execução) para que os log groups existam quando as Lambdas forem criadas:

```hcl
module "observability" {
  source = "./75-observability"

  prefix             = module.foundation.prefix
  common_tags        = module.foundation.common_tags
  log_retention_days  = var.orchestration_log_retention_days  # mesma variável global
}
```
