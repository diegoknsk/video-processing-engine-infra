# Subtask-04: App Client M2M (client_credentials + client_secret)

## Descrição
Criar o App Client Cognito dedicado à autenticação M2M no mesmo User Pool, com nome `${var.prefix}-internal-m2m-client`, fluxo OAuth2 `client_credentials`, geração de client_secret (confidencial) e associação aos scopes do Resource Server criado na Subtask-02. O recurso deve ser condicionado a `enable_m2m_client`.

> **Escopo:** Apenas `aws_cognito_user_pool_client` M2M; outputs sensíveis na Subtask-05.

---

## Passos de Implementação

1. **Criar arquivo `terraform/40-auth/app_client_m2m.tf`:**
   - Recurso `aws_cognito_user_pool_client` com `count = var.enable_m2m_client ? 1 : 0`.
   - `name` = "${var.prefix}-internal-m2m-client".
   - `user_pool_id` = aws_cognito_user_pool.main.id.
   - `generate_secret = true` (obrigatório para client confidencial).
   - `allowed_oauth_flows` = ["client_credentials"].
   - `allowed_oauth_flows_user_pool_client` = true.
   - `allowed_oauth_scopes` = lista dos scope names completos no formato "identifier/scope_name" (ex.: "video-processing-engine/analyze:run", "video-processing-engine/videos:update_status"). Construir a partir de var.m2m_resource_server_identifier e var.m2m_scopes.
   - Não usar explicit_auth_flows de usuário (USER_SRP_AUTH etc.); apenas OAuth flows.
   - `token_validity_units` e `access_token_validity` podem ser definidos (ex.: 1 hora) para o access token do client_credentials.
   - `prevent_user_existence_errors` = "ENABLED" se desejado (opcional para M2M).

2. **Dependência:** O App Client M2M deve ser criado após o Resource Server (Subtask-02); o Terraform resolve a ordem pela referência ao resource server (allowed_oauth_scopes referenciam o identifier). Garantir que os scopes usados existam no resource server.

3. **Não alterar** o recurso `aws_cognito_user_pool_client.main` (app_client.tf); apenas adicionar novo client.

4. **Executar `terraform plan`:** deve mostrar 1 resource to add (aws_cognito_user_pool_client M2M). O client_secret será conhecido apenas após o primeiro apply (Cognito gera no create).

---

## Formas de Teste

1. **`terraform plan`:** exibe criação do novo user pool client com generate_secret = true e allowed_oauth_flows = ["client_credentials"].
2. **`terraform apply`:** após apply, no console Cognito → User Pool → App clients, deve aparecer o client com nome *-internal-m2m-client; em "Client secret" deve estar "Show" (secret presente).
3. Verificar que o App Client público (main) continua existindo e inalterado.

---

## Critérios de Aceite

- [ ] Arquivo `app_client_m2m.tf` existe com `aws_cognito_user_pool_client` condicionado a `enable_m2m_client`
- [ ] Nome do client segue `${var.prefix}-internal-m2m-client`
- [ ] `generate_secret = true`, `allowed_oauth_flows = ["client_credentials"]`, `allowed_oauth_flows_user_pool_client = true`
- [ ] `allowed_oauth_scopes` contém os scopes do Resource Server no formato "identifier/scope_name"
- [ ] `terraform validate` e `terraform apply` passam; App Client público (main) não é modificado
- [ ] Client secret é gerado pelo Cognito (visível no console após create)
