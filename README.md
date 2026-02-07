# Video Processing Engine — Infraestrutura

Repositório de **Infraestrutura como Código (IaC)** do projeto **Video Processing Engine**, parte do Hackathon FIAP Pós Tech em Arquitetura de Software. Provisiona a infraestrutura AWS via Terraform (API Gateway, Cognito, DynamoDB, S3, SNS, SQS, Step Functions, Lambdas em casca, CloudWatch).

Este repositório **cria recursos de infraestrutura** e não realiza deploy do código das aplicações (cada Lambda possui seu próprio repositório).

---

## Visão geral da arquitetura (Processador Video MVP + Fan-out)

A arquitetura segue o desenho **Processador Video MVP + Fan-out**:

- **Entrada:** usuário autentica via **Cognito** e acessa a **API Gateway (HTTP API)**; upload de vídeo é feito via **Lambda Video Management** (URL pré-assinada S3).
- **Upload:** vídeo vai para o **bucket S3 (vídeos)**; ao concluir, o evento é publicado no **SNS (topic-video-submitted)** e consumido pela fila **SQS (q-video-process)**.
- **Orquestração:** a **Lambda Orchestrator** consome a fila, inicia a **Step Functions** (State Machine), que invoca a **Lambda Processor** (extração de frames → bucket S3 imagens) e em seguida a **Lambda Finalizer** (zip → bucket S3 zip).
- **Finalização:** ao concluir, o fluxo publica no **SNS (topic-video-completed)**; **DynamoDB** armazena metadados e status dos vídeos durante todo o processo.

Resumo do fluxo: **API Gateway + Cognito** → upload **S3** → **SNS** → **SQS** → **Orchestrator** → **Step Functions** → **Processor** → **Finalizer** → **SNS completed**; estado em **DynamoDB**; artefatos em **S3** (vídeos, imagens, zip).

Para detalhes, fluxos e organização dos repositórios, veja [docs/contexto-arquitetural.md](docs/contexto-arquitetural.md).

---

## Visão geral da estrutura

```
video-processing-engine-infra/
├── docs/                    # Documentação (contexto arquitetural)
├── terraform/               # Root Terraform (init/plan/apply a partir daqui)
│   ├── *.tf                 # providers, backend, variables, main, outputs
│   ├── 00-foundation/       # Módulo: convenções, tags, prefix
│   ├── 10-storage/          # Módulo: buckets S3 (vídeos, imagens, zip)
│   ├── 20-data/             # Módulo: DynamoDB (metadados e status dos vídeos)
│   ├── 30-messaging/        # Módulo: SNS (tópicos) e SQS (filas + DLQs)
│   ├── 40-auth/             # Módulo: Cognito (User Pool, App Client)
│   ├── 50-lambdas-shell/    # Módulo: Lambdas em casca
│   ├── 60-api/              # Módulo: API Gateway HTTP API
│   ├── 70-orchestration/    # Módulo: Step Functions (State Machine)
│   └── envs/                # Variáveis por ambiente (ex.: dev.tfvars)
├── .github/workflows/       # GitHub Actions (validate, plan, apply)
├── artifacts/               # Artefatos de build/deploy (ex.: empty.zip)
└── storys/                  # Stories e subtasks (Storie-01, Storie-02, …)
    ├── Storie-01-Bootstrap_Repositorio_Infra/
    ├── Storie-02-Implementar_Modulo_Foundation/
    ├── Storie-02-Parte2-Root_Terraform_Orquestrador/
    └── … (Storie-03 a Storie-13)
```

---

## Recursos criados por módulo

| Módulo | Recursos / responsabilidade |
|--------|-----------------------------|
| **00-foundation** | Providers, backend (opcional), locals, variables, outputs base; convenções de naming e tags. |
| **10-storage** | 3 buckets S3: vídeos (upload), imagens (frames), zip (resultado final). |
| **20-data** | Tabela DynamoDB para metadados e status dos vídeos; GSI para consulta por VideoId. |
| **30-messaging** | SNS: topic-video-submitted, topic-video-completed; SQS: q-video-process, q-video-status-update, q-video-zip-finalize + DLQs. |
| **40-auth** | Cognito User Pool e App Client (autenticação JWT para a API). |
| **50-lambdas-shell** | 5 Lambdas em casca (Auth, Video Management, Orchestrator, Processor, Finalizer), IAM (Lab Role), event source mappings. |
| **60-api** | API Gateway HTTP API, stage, rotas (/auth/*, /videos/*), authorizer Cognito (opcional). |
| **70-orchestration** | Step Functions (State Machine do processamento), log group CloudWatch. |
| **75-observability** | Log groups CloudWatch para as Lambdas e suporte a retenção. |

---

## Plano de evolução — Stories e ordem de execução

A ordem recomendada de execução dos módulos, alinhada ao desenho **Processador Video MVP + Fan-out**, é:

| Ordem | Módulo           | Story                          | Descrição breve |
|------:|------------------|--------------------------------|------------------|
| 1     | (Bootstrap)      | Storie-01 Bootstrap            | Estrutura do repo, convenções, workflows placeholder |
| 2     | 00-foundation    | Storie-02 Foundation           | Providers, backend, locals, variáveis, outputs |
| 3     | 10-storage       | Storie-03 Storage              | Buckets S3 (vídeos, imagens, zip) |
| 4     | 20-data          | Storie-04 Data                 | Tabela DynamoDB e GSI |
| 5     | 30-messaging     | Storie-05 SNS, Storie-06 SQS   | Tópicos SNS e filas SQS + DLQs |
| 6     | 40-auth          | Storie-11 Auth                 | Cognito User Pool e App Client |
| 7     | 50-lambdas-shell | Storie-08 Lambdas Shell        | Lambdas em casca e IAM |
| 8     | 60-api           | Storie-10 API                  | API Gateway HTTP API e rotas |
| 9     | 70-orchestration | Storie-09 Orchestration        | Step Functions State Machine |
| —     | Integração       | Storie-07 Upload concluído     | S3 → SNS/SQS (evento de upload) |
| —     | Observabilidade  | Storie-12 CloudWatch            | Log groups, métricas |
| —     | CI/CD            | Storie-13 Finalizar CI/CD      | Workflows apply/destroy, documentação |

**Ordem de aplicação dos módulos Terraform:**  
`00-foundation` → `10-storage` → `20-data` → `30-messaging` → `40-auth` → `50-lambdas-shell` → `60-api` → `70-orchestration`

---

## Conexão dos módulos com o Processador Video MVP + Fan-out

Cada módulo se conecta ao fluxo descrito no [contexto arquitetural](docs/contexto-arquitetural.md) da seguinte forma:

| Módulo           | Papel no fluxo |
|------------------|----------------|
| **00-foundation** | Base: tags, naming, variáveis e outputs consumidos por todos os módulos. |
| **10-storage**   | S3: bucket de **vídeos** (upload), bucket de **imagens** (frames), bucket de **zip** (resultado final). |
| **20-data**      | DynamoDB: metadados do vídeo, status do processamento, consulta por usuário e por vídeo. |
| **30-messaging** | SNS (tópicos video-submitted, video-completed) e SQS (filas de processamento, status, finalização + DLQs). |
| **40-auth**      | Cognito: autenticação e autorização (JWT) para API Gateway. |
| **50-lambdas-shell** | Cascas das Lambdas: Auth, Video Management, Orchestrator, Processor, Finalizer (código em repositórios próprios). |
| **60-api**       | API Gateway HTTP API: rotas /auth/* e /videos/*, integração com Lambdas, authorizer Cognito. |
| **70-orchestration** | Step Functions: orquestração do processamento (Processor → Finalizer), preparado para Map State (fan-out). |

**Fluxo ponta a ponta (ASCII):**

```
Upload → S3 (vídeos) → [evento] → SNS (video-submitted) → SQS (processar)
  → Lambda Orchestrator → Step Functions → Lambda Processor → S3 (imagens)
  → SQS (finalizar) → Lambda Finalizer → S3 (zip) → SNS (video-completed) → notificação
```

Cadastro e autenticação: **API Gateway** + **Lambda Auth** (Cognito) e **Lambda Video Management** (DynamoDB + URL pré-assinada S3).

---

## Como rodar apply/destroy

### Pré-requisitos

- **Terraform** >= 1.0
- **Credenciais AWS** via variáveis de ambiente ou perfil (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN` quando aplicável, `AWS_REGION`)
- **Nunca commitar credenciais**; em CI/CD usar apenas GitHub Secrets.

### Root único (terraform/)

O diretório de trabalho é **terraform/**. Um único Terraform orquestra todos os módulos; não é necessário rodar init/plan/apply em cada subpasta.

### Localmente

**Bash/WSL:**

```bash
cd terraform
terraform init -backend=false
terraform plan -var-file=envs/dev.tfvars
terraform apply -var-file=envs/dev.tfvars
```

**PowerShell (Windows)** — use espaço entre `-var-file` e o caminho:

```powershell
cd terraform
terraform init -backend=false
terraform plan -var-file envs\dev.tfvars
terraform apply -var-file envs\dev.tfvars
```

**Destroy:**

```bash
cd terraform
terraform destroy -var-file=envs/dev.tfvars
```

- **Backend:** sem backend remoto use `terraform init -backend=false`. Com S3 (e opcional DynamoDB lock), use `-backend-config=backend.hcl` no `init`.
- **Variáveis:** use `-var-file envs/dev.tfvars` ou `-var` para obrigatórias (ex.: `owner`, `lab_role_arn`).

### Via GitHub Actions

1. **Configurar secrets** no repositório (Settings → Secrets and variables → Actions): `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`, `AWS_REGION`. Em credenciais temporárias (ex.: AWS Academy), o `AWS_SESSION_TOKEN` é obrigatório.
2. **Apply:** acionar o workflow **Terraform Apply** manualmente (Actions → Terraform Apply → Run workflow) ou, se configurado, ele pode rodar em push na `main` (apenas quando há alterações em `terraform/`).
3. **Destroy:** acionar o workflow **Terraform Destroy** apenas manualmente (workflow_dispatch); não é disparado em push.

Os workflows usam `working-directory: terraform` e, por padrão, `-var-file=envs/dev.tfvars`. Garanta que o arquivo exista no branch ou ajuste o workflow para usar variáveis injetadas por secrets.

---

## Ordem recomendada de execução

1. **Provisionar a infraestrutura:** executar `terraform apply` neste repositório (local ou via workflow **Terraform Apply**) para criar todos os recursos AWS (S3, DynamoDB, SNS, SQS, Cognito, Lambdas em casca, API Gateway, Step Functions, etc.).
2. **Deploy dos repositórios de Lambdas:** cada Lambda tem seu próprio repositório de código; fazer o deploy do código das Lambdas nesses repos **fora deste repo de infra**. Este repositório apenas cria a “casca” (função, IAM, integrações); não faz deploy de código de aplicação.
3. **Smoke tests:** validar que a API responde, que o fluxo de upload e processamento funciona ponta a ponta.

---

## Variáveis importantes

| Variável | Onde | Impacto |
|----------|------|---------|
| **enable_stepfunctions** | 70-orchestration | Habilita ou desabilita a criação da State Machine e do log group da Step Functions. |
| **enable_api_authorizer** | 60-api | Habilita o JWT authorizer Cognito nas rotas protegidas (ex.: /videos/*). |
| **retention_days** / **orchestration_log_retention_days** | Foundation, 75-observability, 70-orchestration | Retenção em dias dos log groups e políticas de retenção. |
| **trigger_mode** | 10-storage, 30-messaging | `s3_event` = S3 notifica SNS ao upload; `api_publish` = Lambda publica no SNS. |
| **finalization_mode** | 70-orchestration | `sqs` = Step Functions envia para q-video-zip-finalize; `lambda` = Step Functions invoca a Lambda Finalizer. |
| **lab_role_arn** | Root (repassado a 50-lambdas-shell e 70-orchestration) | Obrigatório em AWS Academy (sem permissão iam:CreateRole). ARN da Lab Role usada por todas as Lambdas e pela State Machine. Ex.: `arn:aws:iam::ACCOUNT_ID:role/LabRole`. |

---

## Outputs e contratos para outros repositórios

Os outputs do root Terraform (e dos módulos) são consumidos por outros repos (Lambdas, frontend, pipelines). Resumo:

| Consumidor | Output / contrato | Módulo origem |
|------------|-------------------|----------------|
| Repos Lambdas | Lambda ARNs, nomes, role ARNs | 50-lambdas-shell |
| Frontend / API client | API invoke URL (`api_invoke_url`, `api_id`) | 60-api |
| Auth / Login | `user_pool_id`, `client_id`, `issuer`, `jwks_url` | 40-auth |
| Lambdas (DynamoDB) | `dynamodb_table_name`, `dynamodb_table_arn`, `dynamodb_gsi1_name` | 20-data (root outputs) |
| Lambdas (S3) | Bucket names/ARNs: vídeos, imagens, zip | 10-storage (root outputs) |
| Lambdas (SQS) | Queue URLs/ARNs: q-video-process, q-video-status-update, q-video-zip-finalize (+ DLQs) | 30-messaging |
| Lambdas (SNS) | Topic ARNs: topic-video-submitted, topic-video-completed | 30-messaging |
| Lambda Orchestrator | `step_machine_arn` (State Machine) | 70-orchestration (root output `step_machine_arn`) |

Os outputs do root estão em `terraform/outputs.tf`; módulos 40-auth e 30-messaging expõem seus outputs (podem ser reexportados no root conforme necessidade).

---

## Secrets do repositório (GitHub Actions)

Para os workflows **Terraform Apply** e **Terraform Destroy** funcionarem, configure no repositório (Settings → Secrets and variables → Actions) os seguintes secrets — **nunca commitar os valores**:

| Secret | Uso |
|--------|-----|
| `AWS_ACCESS_KEY_ID` | Identificador da credencial AWS. |
| `AWS_SECRET_ACCESS_KEY` | Chave secreta AWS. |
| `AWS_SESSION_TOKEN` | Obrigatório quando as credenciais são temporárias (ex.: AWS Academy, SSO). |
| `AWS_REGION` | Região AWS (ex.: us-east-1). |

Credenciais temporárias (AWS Academy) expiram; é necessário renová-las no portal e atualizar os secrets antes de rodar apply/destroy no CI.

---

## Referências

- [Contexto arquitetural](docs/contexto-arquitetural.md) — visão geral, fluxos e organização dos repositórios.
- Regras de infraestrutura em `.cursor/rules/infrarules.mdc`.
- **Stories e subtasks** — diretório `storys/` (Storie-01 a Storie-13).
