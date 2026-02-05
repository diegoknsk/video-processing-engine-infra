# Storie-11: Implementar Módulo Terraform 40-Auth (Cognito)

## Status
- **Estado:** 🔄 Em desenvolvimento
- **Data de Conclusão:** [DD/MM/AAAA]

## Descrição
Como desenvolvedor de infraestrutura, quero que o módulo `terraform/40-auth` provisione um User Pool e um App Client (public client, sem secret) no Amazon Cognito, com configurações mínimas seguras (política de senha, etc.) e parâmetros parametrizáveis, para que o API Gateway (módulo 60-api) possa usar o JWT authorizer com issuer e audience e o fluxo de autenticação do Processador Video MVP esteja pronto conforme desenho.

## Objetivo
Criar o módulo `terraform/40-auth` com **Cognito User Pool** e **App Client sem secret** (public client). Configurações mínimas seguras: política de senha parametrizável, atributos e fluxos conforme necessidade do MVP; tudo parametrizável quando fizer sentido. **Outputs obrigatórios:** user_pool_id, client_id, issuer, jwks_url (quando aplicável). A story deixa o Cognito pronto para o **authorizer do API Gateway** (módulo 60-api): issuer e client_id (audience) são consumidos pelo JWT authorizer da HTTP API.

## Escopo Técnico
- Tecnologias: Terraform >= 1.0, AWS Provider (~> 5.0)
- Arquivos afetados:
  - `terraform/40-auth/variables.tf` (prefix, common_tags, password_policy, schema attributes, etc.)
  - `terraform/40-auth/user_pool.tf` (aws_cognito_user_pool)
  - `terraform/40-auth/app_client.tf` (aws_cognito_user_pool_client — public, sem secret)
  - `terraform/40-auth/outputs.tf`
  - `terraform/40-auth/README.md` (outputs para authorizer, configurações)
- Componentes/Recursos: aws_cognito_user_pool (política de senha, atributos, MFA opcional parametrizável); aws_cognito_user_pool_client (generate_secret = false, public client; fluxos ALLOW_USER_PASSWORD_AUTH e/ou ALLOW_REFRESH_TOKEN_AUTH conforme necessidade; ALLOW_USER_SRP_AUTH recomendado para frontend). Nenhuma Lambda de customização nesta story (mínimo para bootstrap).
- Pacotes/Dependências: Nenhum; consumo de prefix/common_tags do foundation.

## Dependências e Riscos (para estimativa)
- Dependências: Storie-02 (00-foundation) concluída.
- Riscos/Pré-condições: Issuer URL do Cognito segue o formato https://cognito-idp.{region}.amazonaws.com/{userPoolId}; jwks_uri é https://cognito-idp.{region}.amazonaws.com/{userPoolId}/.well-known/jwks.json. O API Gateway JWT authorizer valida o token usando issuer e audience (client_id); este módulo expõe esses valores via outputs.

## Modelo de execução (root único)
O diretório `terraform/40-auth/` é um **módulo** consumido pelo **root** em `terraform/` (Storie-02-Parte2). O root passa prefix e common_tags do module.foundation. Init/plan/apply são executados uma vez em `terraform/`; validar com `terraform plan` no root.

---

## Uso pelo API Gateway (Authorizer)

O módulo **60-api** (Storie-10) consome os outputs do 40-auth para configurar o JWT authorizer:

| Output 40-auth | Uso no 60-api |
|----------------|----------------|
| **user_pool_id** | Identificação do User Pool; usado para construir issuer e jwks_url |
| **client_id** | **Audience** do JWT authorizer (audience no jwt_configuration do authorizer) |
| **issuer** | **Issuer URL** do JWT authorizer (issuer no jwt_configuration) |
| **jwks_url** | Opcional: API Gateway obtém as chaves via issuer; jwks_url documentado para referência ou uso em Lambda/custom |

- **Issuer:** Formato `https://cognito-idp.{region}.amazonaws.com/{user_pool_id}`.
- **JWKS URL:** Formato `https://cognito-idp.{region}.amazonaws.com/{user_pool_id}/.well-known/jwks.json` (aplicável para validação de assinatura; o HTTP API JWT authorizer da AWS usa o issuer para descobrir o jwks).
- A story deixa o Cognito pronto para o authorizer: caller passa issuer e client_id (audience) ao módulo 60-api quando enable_authorizer = true.

---

## Configurações Mínimas Seguras

- **Política de senha:** Comprimento mínimo parametrizável (ex.: 8); exigir maiúscula, minúscula, número e símbolo parametrizável (ex.: true para produção, relaxado para dev). Bloco password_policy do User Pool.
- **Atributos:** name (obrigatório), email (obrigatório para login ou preferido_username) conforme desenho; atributos padrão ou custom conforme necessidade mínima.
- **App Client:** Sem secret (generate_secret = false) para public client (SPA, mobile); refresh token expiration parametrizável; explicit_auth_flows: ALLOW_USER_SRP_AUTH, ALLOW_REFRESH_TOKEN_AUTH (e opcionalmente ALLOW_USER_PASSWORD_AUTH para testes). Nada de exagero: sem customização de Lambda, sem MFA obrigatório nesta story (MFA opcional por variável se fizer sentido).
- **Tudo parametrizável quando fizer sentido:** password_min_length, password_require_uppercase/lowercase/numbers/symbols, token_validity_units (access/refresh), etc. via variáveis com default seguro.

## Variáveis do Módulo
- **prefix**, **common_tags**: do foundation.
- **password_min_length** (number, default = 8): comprimento mínimo da senha.
- **password_require_uppercase** (bool, default = true), **password_require_lowercase** (bool, default = true), **password_require_numbers** (bool, default = true), **password_require_symbols** (bool, default = true): requisitos da política de senha.
- **schema_attributes** (list/object, opcional): atributos do User Pool além dos padrões (name, email); default pode ser apenas name e email.
- **access_token_validity** (number, default ex.: 1 hora em unidades), **refresh_token_validity** (number, default ex.: 30 dias), **id_token_validity** (number): validade dos tokens em horas/dias conforme token_validity_units.
- **region** (string, opcional): para construir issuer e jwks_url (ou data.aws_region).

## Decisões Técnicas
- **User Pool:** aws_cognito_user_pool com name = "${var.prefix}-user-pool" (ou equivalente); password_policy e schema parametrizáveis; auto_verified_attributes = ["email"] (ou conforme variável); sem MFA obrigatório nesta story.
- **App Client:** aws_cognito_user_pool_client com generate_secret = false (public client); user_pool_id = aws_cognito_user_pool.main.id; explicit_auth_flows = ["ALLOW_USER_SRP_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"] (e opcionalmente ALLOW_USER_PASSWORD_AUTH); token_validity parametrizável.
- **Outputs:** user_pool_id (id do User Pool), client_id (id do App Client), issuer (URL construída com region e user_pool_id), jwks_url (URL construída para .well-known/jwks.json).
- **Mínimo seguro:** Política de senha não trivial; sem expor dados sensíveis nos outputs; sem secret no client (public client é esperado para SPA/mobile).

## Subtasks
- [Subtask 01: Variáveis do módulo (password policy, token validity, etc.)](./subtask/Subtask-01-Variaveis_Parametrizaveis.md)
- [Subtask 02: User Pool com configurações mínimas seguras](./subtask/Subtask-02-User_Pool.md)
- [Subtask 03: App Client público (sem secret)](./subtask/Subtask-03-App_Client_Publico.md)
- [Subtask 04: Outputs (user_pool_id, client_id, issuer, jwks_url) e documentação para authorizer](./subtask/Subtask-04-Outputs_Authorizer.md)
- [Subtask 05: Validação e documentação (pronto para API Gateway authorizer)](./subtask/Subtask-05-Validacao_Documentacao.md)

## Critérios de Aceite da História
- [ ] O módulo `terraform/40-auth` cria um Cognito User Pool com configurações mínimas seguras (política de senha parametrizável; atributos name e email conforme necessidade)
- [ ] App Client sem secret (public client) está criado; generate_secret = false; fluxos adequados (ex.: USER_SRP_AUTH, REFRESH_TOKEN_AUTH)
- [ ] Outputs obrigatórios expostos: user_pool_id, client_id, issuer, jwks_url (quando aplicável — jwks_url é construída a partir do user_pool_id e region)
- [ ] Configurações parametrizáveis quando fizer sentido (password policy, token validity, etc.) sem exagero
- [ ] A story deixa o Cognito pronto para o authorizer do API Gateway: issuer e client_id (audience) documentados para uso no módulo 60-api; README ou story descreve como conectar 40-auth ao 60-api (enable_authorizer = true, cognito_issuer_url = output issuer, cognito_audience = output client_id)
- [ ] Consumo de prefix/common_tags do foundation; terraform plan sem referências quebradas

## Checklist de Conclusão
- [ ] User Pool e App Client criados; outputs user_pool_id, client_id, issuer, jwks_url
- [ ] README descreve uso dos outputs pelo API Gateway (JWT authorizer)
- [ ] terraform init, validate e plan com variáveis fornecidas passam
