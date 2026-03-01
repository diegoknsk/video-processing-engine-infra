# Módulo 40-auth — Cognito User Pool e App Client

Provisiona um **Cognito User Pool** e um **App Client** (public client, sem secret) para autenticação do Processador Video MVP. Configurações mínimas seguras (política de senha parametrizável, atributos name/email). Deixa o Cognito pronto para o **JWT authorizer** do API Gateway (módulo 60-api).

---

## Uso pelo API Gateway (Authorizer)

O módulo **60-api** consome os outputs do 40-auth para configurar o JWT authorizer:

| Output 40-auth | Uso no 60-api |
|----------------|----------------|
| **user_pool_id** | Identificação do User Pool; usado para construir issuer e jwks_url |
| **client_id** | **Audience** do JWT authorizer (`cognito_audience`) |
| **issuer** | **Issuer URL** do JWT authorizer (`cognito_issuer_url`) |
| **jwks_url** | Referência ou uso custom; o HTTP API JWT authorizer usa o issuer para obter as chaves |

Ao configurar o root com o módulo `auth` e `enable_authorizer = true`, passar:

- **cognito_issuer_url** = `module.auth.issuer`
- **cognito_audience** = `[module.auth.client_id]` (lista; o 60-api espera `list(string)`)

---

## Pronto para o API Gateway Authorizer

- Os outputs **user_pool_id**, **client_id**, **issuer** e **jwks_url** são expostos pelo módulo.
- O módulo **60-api** (Storie-10) usa **issuer** como `cognito_issuer_url` e **client_id** como `cognito_audience` no JWT authorizer.
- Para aplicar 40-auth e 60-api com authorizer: no root, invocar `module "auth"` e repassar ao `module "api"`: `enable_authorizer = true`, `cognito_issuer_url = module.auth.issuer`, `cognito_audience = [module.auth.client_id]`.

---

## Configurações mínimas seguras

- **Política de senha:** comprimento mínimo e requisitos (maiúscula, minúscula, número, símbolo) parametrizáveis; defaults seguros (mín. 8, todos true).
- **Atributos:** name e email obrigatórios; login por email (`username_attributes = ["email"]`); auto_verified_attributes = email.
- **App Client:** public client (`generate_secret = false`), adequado para SPA/mobile; fluxos USER_SRP_AUTH, REFRESH_TOKEN_AUTH e USER_PASSWORD_AUTH (testes).
- Sem MFA obrigatório nem Lambda de customização nesta story (mínimo para bootstrap).

---

## Modo dev — sem confirmação de email (Storie-15)

**Uso apenas em dev/lab. Não usar em produção.**

- **Sem confirmação de email (default):** o User Pool usa `auto_verified_attributes = []` por padrão. Não exige verificação de email; usuários podem fazer login logo após serem criados (via console, CLI ou aplicação).
- **Política de senha relaxada:** em dev, passe nos tfvars valores como `auth_password_min_length = 6`, `auth_password_require_symbols = false` (via variáveis do root).
- **Usuários:** criar manualmente no console Cognito, via AWS CLI ou pelo fluxo de sign-up da aplicação. Não há criação automática de usuário pelo Terraform.

---

## Variáveis parametrizáveis

| Variável | Descrição | Default |
|----------|-----------|---------|
| prefix, common_tags | Do foundation | — |
| password_min_length | Comprimento mínimo da senha | 8 |
| password_require_uppercase / lowercase / numbers / symbols | Requisitos da senha | true |
| access_token_validity | Validade do access token (horas) | 1 |
| id_token_validity | Validade do ID token (horas) | 1 |
| refresh_token_validity | Validade do refresh token (dias) | 30 |
| region | Região para issuer/jwks_url (null = região do provider) | null |
| auto_verified_attributes | Atributos verificados (ex.: email). Default [] = sem confirmação de email | [] |
| enable_m2m_client | Habilita App Client M2M e Resource Server (OAuth2 client_credentials) | true |
| m2m_resource_server_identifier | Identifier do Resource Server (ex.: video-processing-engine) | video-processing-engine |
| m2m_scopes | Lista de scopes (name, description); default: analyze:run, videos:update_status | ver variables.tf |
| m2m_secret_ssm_parameter_name | Path SSM onde o pipeline gravará o client_secret (placeholder para Lambdas) | null |

---

## Uso pelo caller (root)

O root deve passar:

- **prefix**, **common_tags**: do módulo `foundation`.
- Opcionalmente: variáveis de política de senha e token validity; **region** (se null, usa a região do provider).

Exemplo de invocação no root (modo dev: sem confirmação de email):

```hcl
module "auth" {
  source = "./40-auth"

  prefix      = module.foundation.prefix
  common_tags = module.foundation.common_tags
  region      = module.foundation.region

  auto_verified_attributes = var.auth_auto_verified_attributes  # [] = sem confirmação de email (default)
  password_min_length       = coalesce(var.auth_password_min_length, 6)
  password_require_symbols  = coalesce(var.auth_password_require_symbols, false)
}

# No module "api":
#   enable_authorizer  = true
#   cognito_issuer_url = module.auth.issuer
#   cognito_audience   = [module.auth.client_id]
```

Exemplo de tfvars para dev: `auth_auto_verified_attributes = []`, `auth_password_min_length = 6`, `auth_password_require_symbols = false`.

---

## App Client M2M (client_credentials — Storie-19)

App Client **confidencial** no mesmo User Pool para autenticação **Machine-to-Machine (M2M)**. Usado por Lambdas (Orchestrator, Analyze) e serviços internos para chamar APIs no API Gateway com token de escopo restrito, **sem login de usuário**. Nome do client: `${prefix}-internal-m2m-client`. O **Resource Server** expõe os scopes `analyze:run` e `videos:update_status`.

### Como obter o token

1. **Credenciais:** obter `client_id` (output `cognito_m2m_client_id`) e `client_secret` do **SSM Parameter Store** (path configurado em `m2m_secret_ssm_parameter_name`; ver seção abaixo).
2. **Requisição:**
   - **URL:** output `cognito_m2m_token_endpoint` (ex.: `https://<domain>.auth.<region>.amazonaws.com/oauth2/token`).
   - **Método:** POST.
   - **Content-Type:** `application/x-www-form-urlencoded`.
   - **Body:** `grant_type=client_credentials&client_id=<client_id>&client_secret=<client_secret>&scope=<scope1>+<scope2>`  
     Exemplo de scope: `video-processing-engine/analyze:run+video-processing-engine/videos:update_status` (formato `identifier/scope_name`, separados por `+`). Use a lista do output `cognito_m2m_scopes` unida por `+`.
3. **Resposta:** JSON com `access_token`, `expires_in`, `token_type`. Usar no header: `Authorization: Bearer <access_token>` nas chamadas ao API Gateway.
4. **Cache:** recomenda-se cachear o token até perto de `expires_in` para evitar chamadas desnecessárias ao Cognito.

Exemplo **curl** (substituir placeholders; não commitar credenciais):

```bash
curl -X POST "$TOKEN_ENDPOINT" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=client_credentials&client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET&scope=video-processing-engine/analyze:run+video-processing-engine/videos:update_status"
```

Para verificar os scopes no token: decodificar o JWT (payload em base64) e conferir a claim `scope` (se presente).

### Onde armazenar o client_secret

**Recomendação: AWS Systems Manager Parameter Store (SSM)** com parâmetro tipo **SecureString**.

- **Por quê:** (1) Custo zero para parâmetros standard; (2) integração nativa com IAM e Lambda (policy `ssm:GetParameter`); (3) criptografia KMS; (4) adequado para MVP/hackathon sem rotação automática de secret.  
- **Secrets Manager** é preferível quando há rotação automática ou múltiplos consumidores com auditoria avançada; para M2M interno, SSM é suficiente.

O **Terraform não grava o secret no SSM** (evita gravar secret no state). Após o primeiro `terraform apply`, o pipeline ou operador deve:

1. Ler o secret: `terraform output -raw cognito_m2m_client_secret` (no root ou no diretório do módulo).
2. Gravar no SSM, por exemplo: `/video-processing-engine/dev/cognito-m2m-client-secret` (path sugerido; pode ser parametrizado).

Nas Lambdas, usar a variável de ambiente ou placeholder **`m2m_secret_ssm_parameter_name`** com o path do parâmetro SSM para ler o `client_secret` em runtime.

### Outputs M2M

| Output | Descrição |
|--------|------------|
| cognito_m2m_client_id | client_id do App Client M2M |
| cognito_m2m_client_secret | client_secret (sensitive; armazenar em SSM) |
| cognito_m2m_resource_server_identifier | Identifier do Resource Server (ex.: video-processing-engine) |
| cognito_m2m_scopes | Lista de scopes no formato identifier/scope_name |
| cognito_m2m_token_endpoint | URL completa do endpoint /oauth2/token |

Quando `enable_m2m_client = false`, esses outputs retornam `null`. Nenhum recurso M2M (Resource Server, App Client M2M, User Pool Domain) é criado.
