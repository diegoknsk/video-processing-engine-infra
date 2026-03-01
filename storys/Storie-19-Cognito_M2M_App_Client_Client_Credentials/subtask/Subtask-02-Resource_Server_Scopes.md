# Subtask-02: Resource Server e scopes no Cognito User Pool

## Descrição
Criar o recurso `aws_cognito_user_pool_resource_server` no User Pool existente do módulo 40-auth, definindo um identifier (ex.: `video-processing-engine`) e os scopes mínimos `analyze:run` e `videos:update_status`, condicionado à variável `enable_m2m_client`. O Resource Server é necessário para que o App Client M2M (Subtask-04) possa solicitar tokens com escopos.

> **Escopo:** Apenas Resource Server; App Client M2M e domain serão criados nas próximas subtasks.

---

## Passos de Implementação

1. **Criar arquivo `terraform/40-auth/resource_server.tf`:**
   - Recurso `resource "aws_cognito_user_pool_resource_server" "m2m"` com `count = var.enable_m2m_client ? 1 : 0`.
   - `user_pool_id = aws_cognito_user_pool.main.id`.
   - `identifier` = var.m2m_resource_server_identifier (ex.: "video-processing-engine").
   - `name` = identificador legível (ex.: "${var.prefix}-resource-server" ou "VideoProcessingEngine").
   - Bloco `scope` para cada item em var.m2m_scopes: `scope_name`, `scope_description`. Ex.: scope_name = "analyze:run", scope_description = "Run analyze job"; scope_name = "videos:update_status", scope_description = "Update video status".

2. **Garantir que `var.m2m_scopes` está no formato esperado:** lista de objetos com name e description (definida na Subtask-01). No resource server, usar `dynamic "scope"` iterando sobre var.m2m_scopes.

3. **Não alterar** `user_pool.tf` nem `app_client.tf` (App Client público). Apenas novo arquivo e referência ao user_pool existente.

4. **Executar `terraform plan`:** deve mostrar 1 resource to add (aws_cognito_user_pool_resource_server); nenhum to destroy.

---

## Formas de Teste

1. **`terraform plan`** no root: exibe criação de `aws_cognito_user_pool_resource_server` quando `enable_m2m_client = true`.
2. **`terraform apply`** (apenas esta subtask): aplicar e verificar no console AWS Cognito → User Pool → App integration → Resource servers que o Resource Server aparece com os dois scopes.
3. Com `enable_m2m_client = false`, `terraform plan` não deve mostrar criação do resource server.

---

## Critérios de Aceite

- [ ] Arquivo `resource_server.tf` existe no 40-auth com `aws_cognito_user_pool_resource_server` condicionado a `enable_m2m_client`
- [ ] Identifier e scopes (`analyze:run`, `videos:update_status`) estão configurados; scopes parametrizados via var.m2m_scopes
- [ ] `terraform validate` e `terraform plan` passam; apply cria apenas o Resource Server
- [ ] User Pool e App Client público existentes permanecem inalterados
