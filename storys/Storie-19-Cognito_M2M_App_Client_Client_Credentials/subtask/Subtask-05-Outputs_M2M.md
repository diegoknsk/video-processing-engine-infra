# Subtask-05: Outputs M2M (client_id, client_secret, scopes, token_endpoint)

## Descrição
Adicionar aos outputs do módulo 40-auth os valores necessários para consumo pelos repositórios de aplicação e pipelines: client_id do App Client M2M, client_secret (marcado como sensitive), resource_server_identifier, lista de scopes e URL do token_endpoint. Garantir que os outputs estejam condicionados a `enable_m2m_client` (usar count nos recursos, então referenciar com [0] ou one(); quando count = 0, o output pode retornar null ou string vazia conforme boa prática).

> **Escopo:** Apenas outputs; documentação de uso na Subtask-06.

---

## Passos de Implementação

1. **Em `terraform/40-auth/outputs.tf`:**
   - **cognito_m2m_client_id** (ou nome alinhado ao padrão do repo): value = aws_cognito_user_pool_client.m2m[0].id; description = "App Client M2M client_id para OAuth2 client_credentials". Usar one() ou [0] com condição: quando enable_m2m_client = false, o recurso não existe — usar try() ou condicional para não quebrar (ex.: try(aws_cognito_user_pool_client.m2m[0].id, null)).
   - **cognito_m2m_client_secret:** value = aws_cognito_user_pool_client.m2m[0].client_secret; **sensitive = true**; description = "Client secret do App Client M2M; armazenar em SSM/Secrets Manager; não commitar."
   - **cognito_m2m_resource_server_identifier:** value = var.m2m_resource_server_identifier (ou aws_cognito_user_pool_resource_server.m2m[0].identifier); description = "Identifier do Resource Server para uso no scope (identifier/scope_name)."
   - **cognito_m2m_scopes:** value = lista de scopes no formato "identifier/scope_name" (ex.: [for s in var.m2m_scopes : "${var.m2m_resource_server_identifier}/${s.name}"]) ou equivalente; description = "Lista de scopes para o parâmetro scope no token request."
   - **cognito_m2m_token_endpoint:** value = "https://${aws_cognito_user_pool_domain.auth_domain[0].domain}.auth.${local.region}.amazonaws.com/oauth2/token" (recurso domain criado na Subtask-03); description = "URL do endpoint OAuth2 token para grant_type=client_credentials."

2. **Tratamento quando enable_m2m_client = false:** Os recursos m2m têm count = 0; referências a [0] falham. Usar try(..., null) nos outputs ou output condicional (value = var.enable_m2m_client ? ... : null). Garantir que `terraform plan` com enable_m2m_client = false não quebre.

3. **Root outputs (opcional):** Se o root reexpõe outputs do módulo auth, adicionar em `terraform/outputs.tf` do root os outputs M2M repassando module.auth.cognito_m2m_* para que pipelines e outros módulos consumam sem acessar o módulo diretamente.

4. **Validar:** `terraform plan` e `terraform output` após apply; client_secret não deve aparecer em log (sensitive).

---

## Formas de Teste

1. **`terraform apply`** com enable_m2m_client = true: após apply, executar `terraform output` e verificar que cognito_m2m_client_id, cognito_m2m_token_endpoint e cognito_m2m_scopes aparecem; cognito_m2m_client_secret deve aparecer como (sensitive).
2. **`terraform output -raw cognito_m2m_client_secret`** (no módulo ou root): deve retornar o valor do secret (para teste manual de token na Subtask-06).
3. Com enable_m2m_client = false, `terraform output` não deve gerar erro; outputs M2M podem ser null.

---

## Critérios de Aceite

- [ ] Outputs cognito_m2m_client_id, cognito_m2m_client_secret (sensitive), cognito_m2m_resource_server_identifier, cognito_m2m_scopes e cognito_m2m_token_endpoint existem no 40-auth (ou root)
- [ ] client_secret marcado como sensitive; não aparece em log em texto claro
- [ ] token_endpoint é URL completa até /oauth2/token
- [ ] Quando enable_m2m_client = false, outputs não quebram (null ou ausência tratada)
- [ ] `terraform validate` e `terraform plan` passam; outputs utilizáveis por pipeline/deploy
