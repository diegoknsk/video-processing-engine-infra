# Storie-13: Finalizar CI/CD e Documentação do Repositório de Infraestrutura

## Status
- **Estado:** 🔄 Em desenvolvimento
- **Data de Conclusão:** [DD/MM/AAAA]

## Rastreamento (dev tracking)
- **Início:** dia 05/02/2026, início da sessão (horário Brasília a confirmar pelo usuário)
- **Fim:** —
- **Tempo total de desenvolvimento:** —

## Descrição
Como desenvolvedor de infraestrutura, quero que o repositório `video-processing-engine-infra` tenha CI/CD finalizado (workflows terraform-apply e terraform-destroy) e README completo com visão geral da arquitetura alinhada ao desenho "Processador Video MVP + Fan-out", lista de recursos por módulo, como rodar apply/destroy, ordem recomendada de execução, variáveis importantes e outputs/contratos consumidos pelos outros repositórios (Lambdas, API URL, Cognito, DynamoDB, buckets, queues, topics, SFN), para que o repo esteja pronto para uso em equipe e integração com os repositórios de aplicação.

## Objetivo
Finalizar **CI/CD** e **documentação** do repo infra: **(1) Workflows obrigatórios:** terraform-apply.yml (trigger workflow_dispatch e opcional push main; steps: fmt, validate, plan, apply; secrets AWS Academy: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN, AWS_REGION) e terraform-destroy.yml (trigger workflow_dispatch; steps: destroy). **(2) README obrigatório:** visão geral da arquitetura alinhada ao desenho Processador Video MVP + Fan-out; lista de recursos criados por módulo; como rodar apply/destroy; ordem recomendada (1 provisionar infra, 2 deploy dos repos de Lambdas fora deste repo, 3 smoke tests); documentar variáveis importantes (enable_stepfunctions, enable_authorizer, retention_days); listar outputs/contratos consumidos pelos outros repos (Lambdas, API URL, Cognito, DynamoDB, buckets, queues, topics, SFN). A story inclui **DoD** e **checklist final**.

## Escopo Técnico
- Tecnologias: GitHub Actions (YAML), Terraform (comandos no workflow), Markdown
- Arquivos afetados:
  - `.github/workflows/terraform-apply.yml`
  - `.github/workflows/terraform-destroy.yml`
  - `README.md` (raiz do repositório)
  - Opcional: `docs/` (ordem de execução, variáveis, outputs para outros repos)
- Componentes/Recursos: Dois workflows GitHub Actions; README com seções obrigatórias; nenhum recurso AWS novo (apenas automação e documentação).
- Pacotes/Dependências: Nenhum; workflows usam actions oficiais (hashicorp/setup-terraform, checkout, etc.) e secrets do repositório.

## Dependências e Riscos (para estimativa)
- Dependências: Stories de módulos Terraform (02 a 12) concluídas ou em estado que permitam apply/destroy; credenciais AWS (Academy ou IAM) configuradas como GitHub Secrets.
- Riscos/Pré-condições: Secrets AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN (quando temporárias), AWS_REGION devem estar configurados no repositório; nunca commitar credenciais.

## Modelo de execução (root único)
O repositório adota **um único root Terraform** em `terraform/` que orquestra todos os módulos (Storie-02-Parte2). Os workflows **terraform-apply** e **terraform-destroy** devem usar **working-directory: terraform/** (ou equivalente) para init, plan e apply; não é necessário rodar Terraform em cada subpasta (00-foundation, 10-storage, etc.).

---

## Workflows Obrigatórios

### terraform-apply.yml
- **Trigger:** workflow_dispatch (obrigatório); opcional push main (conforme decisão).
- **Steps:** checkout → setup Terraform → terraform fmt -recursive → terraform validate (por módulo ou root) → terraform plan → terraform apply (com -auto-approve ou aprovação manual conforme política).
- **Secrets AWS Academy (e uso com credenciais temporárias):** AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN, AWS_REGION; injetar como variáveis de ambiente no job para que Terraform e AWS provider usem as credenciais.
- **Regra:** Nunca commitar credenciais; usar apenas GitHub Secrets.

### terraform-destroy.yml
- **Trigger:** workflow_dispatch (apenas manual).
- **Steps:** checkout → setup Terraform → terraform destroy (com -auto-approve ou confirmação manual).
- **Secrets:** Mesmos (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN, AWS_REGION) para autenticação na AWS.
- **Regra:** Destroy apenas sob demanda (workflow_dispatch); não disparar em push.

---

## README Obrigatório (conteúdo)

1. **Visão geral da arquitetura** alinhada ao desenho "Processador Video MVP + Fan-out": entrada via API Gateway + Cognito; upload S3 → SNS → SQS → Orchestrator → Step Functions → Processor → Finalizer → SNS completed; DynamoDB para estado; S3 videos/images/zip; referência a [docs/contexto-arquitetural.md](docs/contexto-arquitetural.md).
2. **Lista de recursos criados por módulo:** 00-foundation (providers, locals, variables, outputs, backend opcional); 10-storage (3 buckets S3); 20-data (tabela DynamoDB); 30-messaging (SNS topics, SQS + DLQs); 40-auth (User Pool, App Client); 50-lambdas-shell (5 Lambdas + IAM + event mappings); 60-api (HTTP API, stage, rotas, authorizer opcional); 70-orchestration (Step Functions, log group); 75-observability (log groups Lambdas/SFN). Resumo por módulo.
3. **Como rodar apply/destroy:** localmente (terraform init, plan, apply com -var-file ou tfvars; credenciais via env); via GitHub Actions (terraform-apply.yml, terraform-destroy.yml; configurar secrets). Comandos mínimos e pré-requisitos.
4. **Ordem recomendada:** (1) Provisionar infra (apply deste repo); (2) Deploy dos repositórios de Lambdas (fora deste repo); (3) Smoke tests. Documentar que este repo não faz deploy de código das Lambdas.
5. **Variáveis importantes:** enable_stepfunctions, enable_authorizer, log_retention_days (ou retention_days), trigger_mode (s3_event | api_publish), finalization_mode (sqs | lambda), **lab_role_arn** (obrigatório em AWS Academy para Lambdas e Step Functions), etc.; onde são usadas e impacto.
6. **Outputs/contratos consumidos pelos outros repos:** tabela ou lista com: Lambdas (ARNs, nomes, role ARNs); API URL (invoke URL da HTTP API); Cognito (user_pool_id, client_id, issuer, jwks_url); DynamoDB (table_name, table_arn); S3 (bucket names/ARNs para videos, images, zip); SQS (queue URLs/ARNs); SNS (topic ARNs); Step Functions (state_machine_arn). Para cada um: qual módulo expõe e qual repo de aplicação consome.

---

## Definition of Done (DoD)

- [ ] Workflow terraform-apply.yml existe com trigger workflow_dispatch (e opcional push main), steps fmt, validate, plan, apply, e uso de secrets AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN, AWS_REGION.
- [ ] Workflow terraform-destroy.yml existe com trigger workflow_dispatch e steps destroy; usa os mesmos secrets para autenticação.
- [ ] README na raiz contém: visão geral da arquitetura (Processador Video MVP + Fan-out), lista de recursos por módulo, como rodar apply/destroy, ordem recomendada (1 infra, 2 deploy Lambdas, 3 smoke tests), variáveis importantes (enable_stepfunctions, enable_authorizer, retention_days, **lab_role_arn** para AWS Academy), lista de outputs/contratos consumidos pelos outros repos (Lambdas, API URL, Cognito, DynamoDB, buckets, queues, topics, SFN).
- [ ] Nenhuma credencial commitada; apenas referência a GitHub Secrets.
- [ ] Story inclui checklist final (abaixo) e DoD explícito.

---

## Checklist Final

- [ ] `.github/workflows/terraform-apply.yml` e `terraform-destroy.yml` existem e estão configurados conforme especificação (triggers, steps, secrets).
- [ ] README.md contém todas as seções obrigatórias (arquitetura, recursos por módulo, como rodar apply/destroy, ordem recomendada, variáveis importantes, outputs/contratos).
- [ ] Secrets do repositório documentados (quais configurar: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN, AWS_REGION) sem expor valores.
- [ ] Ordem recomendada (1 provisionar infra, 2 deploy Lambdas, 3 smoke tests) está clara; referência a que deploy de Lambdas é fora deste repo.
- [ ] Lista de outputs/contratos permite que os repos de aplicação (Lambdas, frontend, etc.) saibam o que consumir (API URL, Cognito, DynamoDB, buckets, queues, topics, SFN ARN).
- [ ] DoD e checklist final revisados; story pronta para conclusão.

---

## Variáveis Importantes (documentar no README)

| Variável | Onde | Impacto |
|----------|------|---------|
| **enable_stepfunctions** | 70-orchestration | Habilita/desabilita criação da State Machine e log group SFN. |
| **enable_authorizer** | 60-api | Habilita JWT authorizer Cognito nas rotas protegidas (ex.: /videos/*). |
| **log_retention_days** / **retention_days** | Foundation, 75-observability, 70-orchestration | Retenção em dias dos log groups e políticas de retenção. |
| **trigger_mode** | 10-storage, 30-messaging | s3_event = S3 notifica SNS ao upload; api_publish = Lambda publica no SNS. |
| **finalization_mode** | 70-orchestration | sqs = SFN envia para q-video-zip-finalize; lambda = SFN invoca Finalizer. |
| **lab_role_arn** | Root (repassado a 50-lambdas-shell e 70-orchestration) | Obrigatório em AWS Academy (sem iam:CreateRole). ARN da Lab Role usada por todas as Lambdas e pela State Machine. Ex.: arn:aws:iam::ACCOUNT_ID:role/LabRole. |

---

## Outputs/Contratos para Outros Repos (listar no README)

| Consumidor | Output/Contrato | Módulo origem |
|------------|-----------------|---------------|
| **Repos Lambdas** | Lambda ARNs, role ARNs, nomes | 50-lambdas-shell |
| **Frontend / API client** | API invoke URL | 60-api |
| **Auth / Login** | user_pool_id, client_id, issuer, jwks_url | 40-auth |
| **Lambdas (DynamoDB)** | table_name, table_arn | 20-data |
| **Lambdas (S3)** | bucket names/ARNs (videos, images, zip) | 10-storage |
| **Lambdas (SQS)** | queue URLs/ARNs (q-video-process, q-video-status-update, q-video-zip-finalize) | 30-messaging |
| **Lambdas (SNS)** | topic ARNs (topic-video-submitted, topic-video-completed) | 30-messaging |
| **Orchestrator Lambda** | state_machine_arn | 70-orchestration |

---

## Subtasks
- [Subtask 01: Workflow terraform-apply.yml (triggers, steps, secrets)](./subtask/Subtask-01-Workflow_Apply.md)
- [Subtask 02: Workflow terraform-destroy.yml (trigger, destroy, secrets)](./subtask/Subtask-02-Workflow_Destroy.md)
- [Subtask 03: README – visão geral, recursos por módulo, como rodar apply/destroy](./subtask/Subtask-03-README_Arquitetura_Apply.md)
- [Subtask 04: README – ordem recomendada, variáveis importantes, outputs/contratos](./subtask/Subtask-04-README_Ordem_Variaveis_Outputs.md)
- [Subtask 05: DoD e checklist final; validação](./subtask/Subtask-05-DoD_Checklist_Final.md)

## Critérios de Aceite da História
- [ ] Workflow terraform-apply.yml existe com trigger workflow_dispatch (e opcional push main), steps fmt, validate, plan, apply, e secrets AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN, AWS_REGION
- [ ] Workflow terraform-destroy.yml existe com trigger workflow_dispatch e steps destroy; usa secrets para autenticação AWS
- [ ] README contém visão geral da arquitetura alinhada ao desenho Processador Video MVP + Fan-out e lista de recursos criados por módulo
- [ ] README contém como rodar apply/destroy (local e GitHub Actions) e ordem recomendada (1 provisionar infra, 2 deploy Lambdas, 3 smoke tests)
- [ ] README documenta variáveis importantes (enable_stepfunctions, enable_authorizer, retention_days) e lista outputs/contratos consumidos pelos outros repos (Lambdas, API URL, Cognito, DynamoDB, buckets, queues, topics, SFN)
- [ ] Story inclui DoD e checklist final; nenhuma credencial commitada

## Checklist de Conclusão
- [ ] Dois workflows criados e testados (ou documentados para teste após configurar secrets)
- [ ] README completo com todas as seções obrigatórias
- [ ] DoD e checklist final presentes na story e revisados
