# Storie-19: Cognito App Client M2M (OAuth2 Client Credentials)

## Status
- **Estado:** 🔄 Em desenvolvimento
- **Data de Conclusão:** [DD/MM/AAAA]

## Rastreamento (dev tracking)
- **Início:** —
- **Fim:** —
- **Tempo total de desenvolvimento:** —

## Descrição
Como engenheiro de infraestrutura, quero provisionar via IaC (Terraform) um App Client dedicado no Cognito User Pool para autenticação M2M (Machine-to-Machine), com fluxo OAuth2 client_credentials e scopes específicos, para que Lambdas (Orchestrator/Analyze) e outros serviços internos possam chamar APIs no API Gateway com token de escopo restrito, sem login de usuário humano.

## Objetivo
Criar no módulo `terraform/40-auth` (ou em arquivos incrementais no root que referenciem o User Pool existente) um **Cognito App Client confidencial** para uso interno M2M, habilitando o fluxo **OAuth2 client_credentials**, um **Resource Server** com scopes (`analyze:run`, `videos:update_status`), **client_secret** obrigatório, e **outputs** (client_id, client_secret sensível, resource_server_identifier, scopes, token_endpoint) para consumo por repositórios de aplicação e pipelines. Incluir **User Pool Domain** se ainda não existir, para expor o endpoint `/oauth2/token`. Documentar como as Lambdas obtêm o token e onde armazenar o client_secret (Secrets Manager vs SSM — decisão justificada).

## Escopo Técnico

- **Tecnologias:** Terraform >= 1.0, AWS Provider (~> 5.x / 6.x conforme repo)
- **Arquivos afetados:**
  - `terraform/40-auth/resource_server.tf` (novo) — Resource Server e scopes
  - `terraform/40-auth/app_client_m2m.tf` (novo) — App Client M2M com client_credentials
  - `terraform/40-auth/user_pool_domain.tf` (novo, se inexistente) — domínio para token endpoint
  - `terraform/40-auth/variables.tf` — variáveis para M2M (enable_m2m_client, resource_server_identifier, scopes, etc.)
  - `terraform/40-auth/outputs.tf` — outputs M2M (client_id, client_secret sensitive, resource_server_identifier, scopes, token_endpoint)
  - `terraform/40-auth/README.md` — documentação M2M e obtenção de token
  - `terraform/main.tf` — repasse de variáveis ao module.auth se necessário
  - `terraform/variables.tf` — variável de feature flag (ex.: enable_m2m_client) se no root
- **Componentes/Recursos criados:**
  - `aws_cognito_user_pool_resource_server` — identifier ex.: `video-processing-engine`, scopes `analyze:run`, `videos:update_status`
  - `aws_cognito_user_pool_client` (M2M) — nome `${var.prefix}-internal-m2m-client`, `generate_secret = true`, `allowed_oauth_flows = ["client_credentials"]`, `allowed_oauth_flows_user_pool_client = true`, `allowed_oauth_scopes` com os scopes do Resource Server
  - `aws_cognito_user_pool_domain` (se ainda não existir) — para construir token_endpoint
- **Pacotes/Dependências:** Nenhum; apenas recursos HCL e AWS Provider já utilizado no repo.

## Decisões Técnicas

### Naming (padrão do repositório)
- **App Client:** `${var.prefix}-internal-m2m-client` (ex.: `video-processing-engine-dev-internal-m2m-client`). O prefix já inclui project_name e environment (ex.: `video-processing-engine-dev`).
- **Resource Server identifier:** parametrizável; sugestão `video-processing-engine` ou `${var.prefix}` conforme convenção do módulo.

### OAuth2 e Scopes
- **allowed_oauth_flows:** `["client_credentials"]`
- **allowed_oauth_flows_user_pool_client:** `true`
- **Scopes mínimos:** `analyze:run`, `videos:update_status` (definidos no Resource Server e atribuídos ao App Client via `allowed_oauth_scopes`).

### Client secret
- **generate_secret = true** (App Client confidencial). O valor é gerado pelo Cognito e exposto apenas via output `sensitive = true`. Não commitar em tfvars.

### Onde armazenar client_secret para Lambdas
- **Decisão recomendada:** **AWS Systems Manager Parameter Store (SSM)** com tipo **SecureString**.
  - **Por quê:** (1) Custo zero para parâmetros standard; (2) integração nativa com IAM e Lambda (policy `ssm:GetParameter`); (3) KMS encryption; (4) adequado para hackathon/MVP sem rotação automática de secret. Secrets Manager é preferível quando há rotação automática ou múltiplos consumidores com auditoria avançada; para M2M interno, SSM é suficiente.
  - **Implementação:** Terraform **não** cria o parâmetro SSM com o valor do secret (evita gravar secret em state). O pipeline ou operador, após o primeiro `terraform apply`, deve ler o output sensível (ex.: via `terraform output -raw cognito_m2m_client_secret`) e gravar em SSM (ex.: `/video-processing-engine/dev/cognito-m2m-client-secret`). Documentar o path no README e prever variável/placeholder (ex.: `m2m_secret_ssm_parameter_name`) para as Lambdas consumirem.

### Token endpoint
- URL: `https://<user_pool_domain>/oauth2/token`. O User Pool Domain tem formato `https://<domain>.auth.<region>.amazonaws.com`; o token endpoint é então `https://<domain>.auth.<region>.amazonaws.com/oauth2/token`. Criar `aws_cognito_user_pool_domain` no 40-auth se ainda não existir (um domain por User Pool serve tanto Hosted UI quanto OAuth2 token).

### Ambiente (dev/stg/prd)
- Nomes parametrizados por `var.prefix` (já derivado de `project_name` e `environment` no foundation). Não quebrar recursos existentes; adicionar apenas novos recursos condicionados a variável (ex.: `enable_m2m_client`) se desejado.

## Como as Lambdas obtêm o token (documentar no story e no README)

1. **Obter credenciais:** Ler `client_id` (output ou variável de ambiente) e `client_secret` do **SSM Parameter Store** (path documentado, ex.: `m2m_secret_ssm_parameter_name`).
2. **Chamar o endpoint de token:**
   - **URL:** `https://<user_pool_domain>.auth.<region>.amazonaws.com/oauth2/token`
   - **Método:** POST
   - **Content-Type:** `application/x-www-form-urlencoded`
   - **Corpo:** `grant_type=client_credentials&client_id=<client_id>&client_secret=<client_secret>&scope=<scope1>+<scope2>` (ex.: `scope=video-processing-engine/analyze:run+video-processing-engine/videos:update_status` — formato do scope é `identifier/scope_name`).
3. **Resposta:** JSON com `access_token`, `expires_in`, `token_type`. Usar `access_token` no header `Authorization: Bearer <access_token>` nas chamadas ao API Gateway.
4. **Cache:** Recomendável cachear o token até perto de `expires_in` para evitar chamadas desnecessárias ao Cognito.

## Dependências e Riscos (para estimativa)

- **Dependências:** Storie-11 (módulo 40-auth) concluída — User Pool e App Client público existentes. O M2M client e o Resource Server são **adicionados** ao mesmo User Pool; não alterar o App Client público existente.
- **Riscos/Pré-condições:**
  - **Recursos existentes:** Não remover nem alterar `aws_cognito_user_pool_client.main` (public client). Apenas adicionar novos recursos.
  - **User Pool Domain:** Se o 40-auth ainda não tiver domínio, criar um (nome único por conta/região). Conflito de nome possível se outro pool usar o mesmo domain prefix; usar prefix no nome do domain (ex.: `${var.prefix}-auth`).
  - **AWS Academy/LabRole:** Não criar IAM roles adicionais; apenas Cognito. Evitar permissões além do padrão Cognito (cognito-idp).
  - **client_secret no state:** O Terraform armazena o client_secret no state; garantir backend remoto (S3) e state locking. Nunca commitar state; não expor output em logs de CI.

## Subtasks

- [ ] [Subtask 01: Variáveis e feature flag para M2M (40-auth e root)](./subtask/Subtask-01-Variaveis_Feature_Flag_M2M.md)
- [ ] [Subtask 02: Resource Server e scopes no Cognito User Pool](./subtask/Subtask-02-Resource_Server_Scopes.md)
- [ ] [Subtask 03: User Pool Domain (token endpoint)](./subtask/Subtask-03-User_Pool_Domain.md)
- [ ] [Subtask 04: App Client M2M (client_credentials + client_secret)](./subtask/Subtask-04-App_Client_M2M.md)
- [ ] [Subtask 05: Outputs M2M (client_id, client_secret, scopes, token_endpoint)](./subtask/Subtask-05-Outputs_M2M.md)
- [ ] [Subtask 06: Documentação e critérios de aceite (README, obtenção de token, SSM)](./subtask/Subtask-06-Documentacao_Obtencao_Token_SSM.md)

---

## Critérios de Aceite da História

- [ ] `terraform apply` cria, sem quebrar recursos existentes: (1) Resource Server no User Pool com identifier e scopes `analyze:run` e `videos:update_status`; (2) App Client M2M com nome `${prefix}-internal-m2m-client`, `generate_secret = true`, `allowed_oauth_flows = ["client_credentials"]`, `allowed_oauth_flows_user_pool_client = true`, `allowed_oauth_scopes` contendo os scopes do Resource Server; (3) User Pool Domain criado se ainda não existir
- [ ] É possível obter um `access_token` via fluxo client_credentials: POST em `https://<domain>.auth.<region>.amazonaws.com/oauth2/token` com `grant_type=client_credentials`, `client_id`, `client_secret` e `scope` (validação manual com curl ou script)
- [ ] O token retornado contém os scopes esperados (ex.: claim `scope` ou equivalente no JWT decode)
- [ ] Outputs Terraform disponíveis e documentados: `cognito_m2m_client_id`, `cognito_m2m_client_secret` (sensitive), `cognito_m2m_resource_server_identifier`, `cognito_m2m_scopes` (lista), `cognito_m2m_token_endpoint` (URL completa); utilizáveis por pipeline ou repositórios de aplicação
- [ ] Documentação no README (ou story): como as Lambdas obtêm o token (URL, body, scope), e onde armazenar o client_secret (SSM Parameter Store recomendado, com path/placeholder `m2m_secret_ssm_parameter_name`); decisão SSM vs Secrets Manager justificada
- [ ] `terraform fmt -recursive` e `terraform validate` executam sem erros; `terraform plan` não mostra destruição ou alteração indesejada do App Client público existente
- [ ] Nenhuma credencial ou client_secret hardcoded em arquivos `.tf` ou tfvars versionados; client_secret apenas em output sensível e (após apply) em SSM pelo pipeline/operador
