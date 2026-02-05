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

---

## Uso pelo caller (root)

O root deve passar:

- **prefix**, **common_tags**: do módulo `foundation`.
- Opcionalmente: variáveis de política de senha e token validity; **region** (se null, usa a região do provider).

Exemplo de invocação no root:

```hcl
module "auth" {
  source = "./40-auth"

  prefix      = module.foundation.prefix
  common_tags = module.foundation.common_tags
}

# No module "api":
#   enable_authorizer  = true
#   cognito_issuer_url = module.auth.issuer
#   cognito_audience   = [module.auth.client_id]
```
