# Subtask-03: User Pool Domain (token endpoint)

## Descrição
Criar o recurso `aws_cognito_user_pool_domain` no módulo 40-auth para o User Pool existente, de forma que o endpoint OAuth2 `/oauth2/token` fique disponível. O domain é necessário para o fluxo client_credentials. Se o repositório já possuir um User Pool Domain (ex.: para Hosted UI), esta subtask deve apenas referenciar o domain existente e expor o token_endpoint nos outputs (Subtask-05); caso contrário, criar o domain com nome único (ex.: `${var.prefix}-auth` ou similar).

> **Escopo:** Garantir que existe um domain no User Pool; criar somente se ainda não existir.

---

## Passos de Implementação

1. **Verificar se já existe `aws_cognito_user_pool_domain`** em algum arquivo do 40-auth (ex.: `user_pool_domain.tf`, `user_pool.tf`). Se existir, pular a criação e apenas documentar o uso para token_endpoint; garantir que o domain name esteja disponível em local ou output para construir a URL do token.

2. **Se não existir domain, criar arquivo `terraform/40-auth/user_pool_domain.tf`:**
   - Recurso `resource "aws_cognito_user_pool_domain" "auth_domain"` com `count = var.enable_m2m_client ? 1 : 0` (ou count = 1 se o domain for compartilhado com futuro Hosted UI).
   - `user_pool_id = aws_cognito_user_pool.main.id`.
   - `domain` = nome único. Cognito exige domínio prefix (ex.: "video-processing-engine-dev-auth"); usar `var.prefix` com sufixo fixo (ex.: "${var.prefix}-auth") para evitar conflito. O domain completo será `<domain>.auth.<region>.amazonaws.com`.

3. **Garantir unicidade:** O domain name no Cognito é global por conta/região; o prefix já inclui environment, reduzindo risco de conflito.

4. **Output (preparar para Subtask-05):** O token endpoint será `https://<domain>.auth.<region>.amazonaws.com/oauth2/token`. Usar `aws_cognito_user_pool_domain.auth_domain[0].domain` e `local.region` (ou data.aws_region) para construir a URL em outputs.

---

## Formas de Teste

1. **`terraform plan`:** deve mostrar 1 resource to add (user_pool_domain) se criado; ou 0 se já existir.
2. **`terraform apply`:** após apply, no console Cognito → User Pool → App integration → Domain name, o domain deve aparecer.
3. Teste manual (após Subtask-04 e 05): a URL base do domain deve responder (ex.: GET para verificar que o domain existe); o POST em `/oauth2/token` será validado na Subtask de critérios de aceite.

---

## Critérios de Aceite

- [ ] Existe um `aws_cognito_user_pool_domain` no 40-auth (criado nesta subtask ou já existente); nome do domain segue padrão do repo (ex.: prefix + sufixo)
- [ ] O domain está associado ao mesmo User Pool do módulo (aws_cognito_user_pool.main.id)
- [ ] Token endpoint pode ser construído como `https://<domain>.auth.<region>.amazonaws.com/oauth2/token` (implementação do output na Subtask-05)
- [ ] `terraform validate` e `terraform plan` passam; nenhum recurso existente alterado ou destruído
