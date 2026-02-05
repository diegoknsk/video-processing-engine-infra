# Storie-02-Parte2: Root Terraform Único Orquestrando Todos os Módulos

## Status
- **Estado:** ✅ Concluído
- **Data de Conclusão:** 05/02/2025

## Descrição
Como desenvolvedor de infraestrutura, quero um **único root Terraform** que orquestre todos os módulos (00-foundation, 10-storage, 20-data, 30-messaging, 40-auth, 50-lambdas-shell, 60-api, 70-orchestration e observabilidade), para que init, plan e apply sejam executados **uma única vez** a partir de um único diretório (terraform/), com um único state e encadeamento correto de variáveis e outputs entre módulos.

## Objetivo
Criar a configuração **root** em `terraform/` (main.tf ou arquivos modulares, variables.tf, outputs.tf, providers.tf, backend.tf) que invoca todos os módulos como `module "foundation"`, `module "storage"`, etc., passando outputs do foundation para os demais (prefix, common_tags), e reexportando outputs necessários para CI/CD e outros repositórios. Garantir que **todas as stories existentes (01 a 13)** sejam revisadas para deixar explícito que cada pasta (00-foundation, 10-storage, …) é um **módulo consumido pelo root** e que a execução padrão é **init/plan/apply a partir de terraform/**.

## Escopo Técnico
- Tecnologias: Terraform >= 1.0, AWS Provider (~> 5.0)
- Arquivos afetados:
  - `terraform/main.tf` (ou `terraform/root.tf` / `terraform/modules.tf`) — chamadas aos módulos
  - `terraform/variables.tf` — variáveis do root (project_name, environment, region, owner, etc.)
  - `terraform/outputs.tf` — agregação/reexporte dos outputs dos módulos
  - `terraform/providers.tf` — required_version, required_providers, provider aws
  - `terraform/backend.tf` — backend S3 (e lock DynamoDB) único para o state do root
  - `terraform/envs/dev.tfvars` (ou equivalente) — uso pelo root
  - Revisão de **todas** as stories 01 a 13 (story.md e, se necessário, subtasks) para referência ao root e ao modelo “módulo consumido pelo root”
- Componentes/Recursos: Nenhum recurso AWS novo criado nesta story; apenas configuração Terraform do root que invoca módulos existentes ou placeholders.
- Pacotes/Dependências: Nenhum; apenas Terraform e provider AWS já utilizados nos módulos.

## Dependências e Riscos (para estimativa)
- Dependências: Storie-01 (Bootstrap) concluída; Storie-02 (00-foundation) e Storie-03 (10-storage) implementadas; demais módulos (04 a 12) podem estar em placeholder — o root deve invocar os que existirem e permitir inclusão progressiva dos demais.
- Riscos/Pré-condições: Backend S3 do root exige bucket e tabela DynamoDB para lock (podem ser criados fora do Terraform ou em story dedicada); revisão das 13 stories deve ser consistente (mesma terminologia: “módulo”, “root”, “execução a partir de terraform/”).

## Decisões Técnicas
- **Root único:** O diretório de trabalho para `terraform init`, `terraform plan` e `terraform apply` é **terraform/** (raiz dos módulos). Não há “um Terraform por pasta” para execução padrão; cada pasta (00-foundation, 10-storage, …) é um **módulo** referenciado pelo root com `source = "./00-foundation"`, `source = "./10-storage"`, etc.
- **State único:** Um único backend (ex.: S3 + DynamoDB lock) para o root; os módulos não possuem state próprio quando invocados pelo root.
- **Variáveis e outputs:** O root declara variáveis globais (project_name, environment, region, owner, flags, **lab_role_arn** para AWS Academy) e repassa aos módulos; recebe outputs (ex.: prefix, common_tags do foundation) e repassa a storage, data, messaging, etc.; reexporta outputs para pipelines e documentação. Em **AWS Academy**, lab_role_arn é obrigatória e repassada a 50-lambdas-shell e 70-orchestration (evita iam:CreateRole).
- **Ordem de aplicação:** Terraform resolve dependências entre módulos automaticamente (ex.: storage depende de foundation por causa de prefix/common_tags).

## Subtasks
- [Subtask 01: Estrutura do root (providers, backend, variables, main)](./subtask/Subtask-01-Estrutura_Root_Providers_Backend_Variables.md)
- [Subtask 02: Invocação dos módulos (foundation, storage e demais)](./subtask/Subtask-02-Invocacao_Modulos_Foundation_Storage.md)
- [Subtask 03: Outputs do root e integração com tfvars](./subtask/Subtask-03-Outputs_Root_Tfvars.md)
- [Subtask 04: Validação (init, fmt, validate, plan) e documentação do comando](./subtask/Subtask-04-Validacao_Documentacao_Comando.md)
- [Subtask 05: Revisão de todas as stories 01 a 13 (root e módulos)](./subtask/Subtask-05-Revisao_Stories_01_a_13.md)

## Critérios de Aceite da História
- [x] Existe configuração root em `terraform/` (main.tf ou equivalente, variables.tf, outputs.tf, providers.tf, backend.tf) que invoca módulos 00-foundation e 10-storage (e demais quando implementados)
- [x] O root passa variáveis ao module "foundation" e recebe prefix e common_tags; repassa esses outputs aos módulos que os consomem (ex.: storage, data, messaging)
- [x] Um único `terraform init` e um único `terraform plan` (com -var-file ou -var) executados em `terraform/` geram plano coerente sem referências quebradas
- [x] Backend do root configurado (S3 e opcionalmente DynamoDB para lock); documentado como configurar ou usar -backend=false localmente
- [x] README ou documentação na story explicita: “Execução: cd terraform && terraform init && terraform plan -var-file=envs/dev.tfvars”
- [x] Todas as stories 01, 02, 03, 04, 05, 06, 07, 08, 09, 10, 11, 12 e 13 revisadas para indicar que os diretórios são módulos consumidos pelo root e que init/plan/apply são executados a partir de terraform/

## Checklist de Conclusão
- [x] Arquivos .tf do root criados em terraform/
- [x] terraform init (com backend ou -backend=false) e terraform validate executados com sucesso em terraform/
- [x] terraform plan em terraform/ com variáveis do foundation e storage não apresenta erros de referência
- [x] Stories 01 a 13 atualizadas com menção ao root e ao modelo de execução única
