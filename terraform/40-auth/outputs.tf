# Outputs consumidos pelo módulo 60-api (JWT authorizer): issuer e client_id (audience).

output "user_pool_id" {
  description = "ID do Cognito User Pool."
  value       = aws_cognito_user_pool.main.id
}

output "client_id" {
  description = "ID do App Client (public client). Usar como audience no JWT authorizer do API Gateway."
  value       = aws_cognito_user_pool_client.main.id
}

output "issuer" {
  description = "URL do issuer do User Pool para o JWT authorizer. Formato: https://cognito-idp.{region}.amazonaws.com/{user_pool_id}"
  value       = "https://cognito-idp.${local.region}.amazonaws.com/${aws_cognito_user_pool.main.id}"
}

output "jwks_url" {
  description = "URL do JWKS do User Pool (referência ou uso custom). O HTTP API JWT authorizer usa o issuer para descobrir as chaves."
  value       = "https://cognito-idp.${local.region}.amazonaws.com/${aws_cognito_user_pool.main.id}/.well-known/jwks.json"
}

# --- Outputs M2M (Storie-19: client_credentials) ---
output "cognito_m2m_client_id" {
  description = "App Client M2M client_id para OAuth2 client_credentials. null quando enable_m2m_client = false."
  value       = try(aws_cognito_user_pool_client.m2m[0].id, null)
}

output "cognito_m2m_client_secret" {
  description = "Client secret do App Client M2M; armazenar em SSM/Secrets Manager; não commitar."
  value       = try(aws_cognito_user_pool_client.m2m[0].client_secret, null)
  sensitive   = true
}

output "cognito_m2m_resource_server_identifier" {
  description = "Identifier do Resource Server para uso no scope (identifier/scope_name)."
  value       = var.enable_m2m_client ? var.m2m_resource_server_identifier : null
}

output "cognito_m2m_scopes" {
  description = "Lista de scopes para o parâmetro scope no token request (formato identifier/scope_name)."
  value       = var.enable_m2m_client ? [for s in var.m2m_scopes : "${var.m2m_resource_server_identifier}/${s.name}"] : null
}

output "cognito_m2m_token_endpoint" {
  description = "URL do endpoint OAuth2 token para grant_type=client_credentials."
  value       = try("https://${aws_cognito_user_pool_domain.auth_domain[0].domain}.auth.${local.region}.amazonaws.com/oauth2/token", null)
}
