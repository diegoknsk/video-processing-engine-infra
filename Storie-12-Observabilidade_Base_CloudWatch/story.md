# Storie-12: Observabilidade Base (CloudWatch Logs)

## Status
- **Estado:** 🔄 Em desenvolvimento
- **Data de Conclusão:** [DD/MM/AAAA]

## Descrição
Como desenvolvedor de infraestrutura, quero adicionar observabilidade base usando apenas CloudWatch Logs: Log Groups para as 5 Lambdas e para Step Functions com retenção configurável, padrão de naming (prefix + environment), e garantia de IAM para escrita em logs onde aplicável, para que após o apply seja possível validar que os logs aparecem ao invocar as funções e a state machine.

## Objetivo
Implementar observabilidade base **somente com CloudWatch** (sem ferramentas pagas): **Log Groups para as 5 Lambdas** (Auth, VideoManagement, VideoOrchestrator, VideoProcessor, VideoFinalizer) e **Log Group para Step Functions**, com **retenção configurável** por variável global (ex.: log_retention_days); **padrão de naming** usando prefix + environment (prefix já contém environment, ex.: video-processing-engine-dev); **garantir IAM** para escrita em logs (Lambda roles e SFN role com permissão para CreateLogStream e PutLogEvents nos respectivos log groups). A story inclui **checklist do que validar após apply** (logs aparecendo ao invocar cada Lambda e ao executar a Step Function).

## Escopo Técnico
- Tecnologias: Terraform >= 1.0, AWS Provider (~> 5.0)
- Arquivos afetados:
  - **Opção A — Módulo dedicado:** `terraform/75-observability/variables.tf`, `terraform/75-observability/log_groups.tf`, `terraform/75-observability/outputs.tf`, `terraform/75-observability/README.md`
  - **Opção B — Estender módulos existentes:** adicionar log groups em `terraform/50-lambdas-shell/` (5 log groups) e garantir retenção em `terraform/70-orchestration/` (log group SFN já existe); variável global log_retention_days no foundation ou passada aos módulos
- Componentes/Recursos: 5x aws_cloudwatch_log_group para Lambdas (nomes /aws/lambda/{prefix}-auth, /aws/lambda/{prefix}-video-management, etc., alinhados aos nomes das funções no 50-lambdas-shell); 1x aws_cloudwatch_log_group para Step Functions (nome alinhado ao 70-orchestration, ex.: /aws/stepfunctions/{prefix}-video-processing) ou uso do já existente no 70-orchestration com retenção parametrizável; nenhuma ferramenta paga (apenas CloudWatch).
- Pacotes/Dependências: Nenhum; consumo de prefix/common_tags e de log_retention_days (variável global); dependência dos nomes das Lambdas e da SFN (50-lambdas-shell, 70-orchestration).

## Dependências e Riscos (para estimativa)
- Dependências: Storie-02 (foundation), Storie-08 (50-lambdas-shell — nomes das Lambdas para alinhar log groups), Storie-09 (70-orchestration — log group SFN já existe; garantir retenção via variável global).
- Riscos/Pré-condições: Log groups para Lambda devem ter nome exatamente /aws/lambda/{function_name} para que a Lambda use o grupo ao ser invocada; criar os log groups antes ou na mesma ordem que as Lambdas para evitar criação automática sem retenção pela AWS.

## Modelo de execução (root único)
O diretório `terraform/75-observability/` (ou extensão em 50-lambdas-shell/70-orchestration) é consumido pelo **root** em `terraform/` (Storie-02-Parte2). Init/plan/apply são executados uma vez em `terraform/`; validar com `terraform plan` no root.

---

## Padrão de Naming (prefix + environment)

- **Prefix** já inclui environment no desenho (ex.: video-processing-engine-dev). Logo, naming = prefix + sufixo do recurso.
- **Log Groups Lambdas:** `/aws/lambda/{prefix}-auth`, `/aws/lambda/{prefix}-video-management`, `/aws/lambda/{prefix}-video-orchestrator`, `/aws/lambda/{prefix}-video-processor`, `/aws/lambda/{prefix}-video-finalizer` — devem coincidir com os nomes das funções no 50-lambdas-shell.
- **Log Group Step Functions:** `/aws/stepfunctions/{prefix}-video-processing` (ou o nome já definido no 70-orchestration) — retenção configurável pela mesma variável global (log_retention_days).

---

## Variável Global e Retenção

- **log_retention_days** (number): retenção em dias para todos os log groups (variável global); default ex.: 14 ou 30; reter por X dias conforme requisito.
- Pode ser definida no foundation (00-foundation) e passada aos módulos, ou em cada módulo com o mesmo default; documentar uso consistente.

---

## IAM para Escrita em Logs

- **Lambdas (50-lambdas-shell):** As roles já possuem política para CloudWatch Logs (logs:CreateLogStream, logs:PutLogEvents). Garantir que o recurso da policy permita escrita nos log groups criados: resource "arn:aws:logs:${region}:${account}:log-group:/aws/lambda/${prefix}-*" ou equivalente. Se hoje for "*", está coberto; para least privilege, restringir ao ARN dos 5 log groups quando os nomes forem conhecidos (opcional nesta story).
- **Step Functions (70-orchestration):** A role da SFN já possui permissão de logs no log group da SFN. Garantir que o log group usado pela SFN (logging_configuration) tenha retenção configurável e que a role tenha permissão nesse grupo.
- **Onde aplicável:** Documentar que Lambda e SFN precisam de permissão de escrita nos respectivos log groups; validar que as políticas existentes cobrem os nomes/ARNs dos log groups criados.

---

## Checklist Pós-Apply (validar logs ao invocar)

Após `terraform apply`, validar que os logs aparecem no CloudWatch:

1. **Lambda Auth:** Invocar a Lambda Auth (ex.: via API Gateway GET /auth/health ou teste direto no console); em CloudWatch Logs, abrir o log group `/aws/lambda/{prefix}-auth` e verificar que há log stream com eventos recentes.
2. **Lambda VideoManagement:** Invocar (ex.: GET /videos ou teste direto); verificar log group `/aws/lambda/{prefix}-video-management`.
3. **Lambda VideoOrchestrator:** Enviar mensagem para q-video-process (ou invocar diretamente); verificar log group `/aws/lambda/{prefix}-video-orchestrator`.
4. **Lambda VideoProcessor:** Disparar execução da Step Function (ou invocar diretamente); verificar log group `/aws/lambda/{prefix}-video-processor`.
5. **Lambda VideoFinalizer:** Enviar mensagem para q-video-zip-finalize (ou invocar diretamente); verificar log group `/aws/lambda/{prefix}-video-finalizer`.
6. **Step Functions:** Iniciar uma execução da state machine (ex.: via Orchestrator ou console); em CloudWatch Logs, abrir o log group `/aws/stepfunctions/{prefix}-video-processing` (ou nome configurado no 70-orchestration) e verificar que há log stream da execução.

- **Critério de sucesso:** Em cada recurso invocado, o log group correspondente deve ter pelo menos um log stream com eventos gerados após a invocação. Retenção deve estar aplicada (verificar configuração do log group: retention_in_days = X).

---

## Variáveis do Módulo (75-observability, se opção A)
- **prefix** (string): do foundation (contém environment).
- **common_tags** (map): do foundation.
- **log_retention_days** (number, default ex.: 14): variável global; retenção em dias para todos os log groups.
- **lambda_function_names** (list/object, opcional): nomes das 5 Lambdas para derivar log group names; ou derivar de prefix (prefix-auth, prefix-video-management, etc.) conforme convenção do 50-lambdas-shell.

## Decisões Técnicas
- **Sem ferramentas pagas:** Apenas CloudWatch Logs; sem X-Ray, third-party APM ou ferramentas pagas nesta story.
- **Implementação:** Preferir módulo dedicado **75-observability** que cria os 5 log groups para Lambdas (e opcionalmente centraliza documentação do log group da SFN, que continua criado no 70-orchestration com retenção via variável). Ou estender 50-lambdas-shell com 5 log groups e 70-orchestration com variável log_retention_days alinhada ao foundation.
- **Ordem de criação:** Se módulo 75-observability, aplicá-lo antes ou junto de 50-lambdas-shell para que os log groups existam antes das Lambdas (evitar criação automática sem retenção).
- **Naming:** Sempre prefix + sufixo; prefix já inclui environment.

## Subtasks
- [Subtask 01: Variáveis (log_retention_days global, prefix, naming)](./subtask/Subtask-01-Variaveis_Naming.md)
- [Subtask 02: Log Groups para as 5 Lambdas com retenção](./subtask/Subtask-02-Log_Groups_Lambdas.md)
- [Subtask 03: Log Group Step Functions e alinhamento com 70-orchestration](./subtask/Subtask-03-Log_Group_SFN.md)
- [Subtask 04: Garantir IAM para escrita em logs (onde aplicável)](./subtask/Subtask-04-IAM_Logs.md)
- [Subtask 05: Checklist pós-apply e documentação](./subtask/Subtask-05-Checklist_Documentacao.md)

## Critérios de Aceite da História
- [ ] Existem Log Groups para as 5 Lambdas com retenção configurável (log_retention_days); nomes alinhados ao padrão prefix + environment (/aws/lambda/{prefix}-auth, etc.)
- [ ] Log Group para Step Functions existe com retenção configurável (no 70-orchestration ou no módulo de observabilidade); padrão de naming respeitado
- [ ] Variável global log_retention_days (ou equivalente) aplicada a todos os log groups; reter por X dias conforme variável
- [ ] IAM para escrita em logs garantida onde aplicável (Lambda roles e SFN role com permissão nos respectivos log groups); documentado ou verificado
- [ ] Sem ferramentas pagas; apenas CloudWatch
- [ ] A story inclui checklist do que validar após apply (invocar cada Lambda e a Step Function e verificar que logs aparecem nos log groups corretos)
- [ ] Consumo de prefix/common_tags; terraform plan sem referências quebradas

## Checklist de Conclusão
- [ ] 5 log groups para Lambdas + log group SFN (ou retenção alinhada no 70-orchestration) criados com retention_in_days
- [ ] README ou story contém checklist pós-apply (invocar e validar logs)
- [ ] terraform init, validate e plan passam
