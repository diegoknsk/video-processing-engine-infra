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
