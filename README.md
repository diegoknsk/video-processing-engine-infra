# Video Processing Engine — Infraestrutura

Repositório de **Infraestrutura como Código (IaC)** do projeto **Video Processing Engine**, parte do Hackathon FIAP Pós Tech em Arquitetura de Software. Provisiona a infraestrutura AWS via Terraform (API Gateway, Cognito, DynamoDB, S3, SNS, SQS, Step Functions, Lambdas em casca, CloudWatch).

Este repositório **cria recursos de infraestrutura** e não realiza deploy do código das aplicações (cada Lambda possui seu próprio repositório).

---

## Visão geral da estrutura

```
video-processing-engine-infra/
├── docs/                    # Documentação (contexto arquitetural)
├── terraform/
│   ├── 00-foundation/       # Providers, tags, variáveis globais, convenções
│   ├── 10-storage/          # Buckets S3 (vídeos, imagens, zip)
│   ├── 20-data/             # DynamoDB (metadados e status dos vídeos)
│   ├── 30-messaging/        # SNS (tópicos) e SQS (filas + DLQs)
│   ├── 40-auth/             # Cognito (User Pool, App Client)
│   ├── 50-lambdas-shell/    # Lambdas em casca (Auth, Video Management, Orchestrator, Processor, Finalizer)
│   ├── 60-api/              # API Gateway HTTP API
│   ├── 70-orchestration/    # Step Functions (State Machine)
│   └── envs/                # Variáveis por ambiente (ex.: dev.tfvars)
├── .github/workflows/       # GitHub Actions (validate, plan, apply)
├── artifacts/               # Artefatos de build/deploy (ex.: empty.zip)
└── Storie-01-Bootstrap_Repositorio_Infra/   # Stories e subtasks
```

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

## Pré-requisitos e uso

- **Terraform** >= 1.0
- **Credenciais AWS** via variáveis de ambiente ou perfil (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN` quando aplicável, `AWS_REGION`)
- Nenhuma credencial deve ser commitada; usar GitHub Secrets em CI/CD

Exemplo de uso local (após Storie-02):

```bash
cd terraform/00-foundation
terraform init
terraform plan -var-file=../envs/dev.tfvars
```

---

## Referências

- [Contexto arquitetural](docs/contexto-arquitetural.md) — visão geral, fluxos e organização dos repositórios.
- Regras de infraestrutura em `.cursor/rules/infrarules.mdc`.
