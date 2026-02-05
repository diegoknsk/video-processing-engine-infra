# App Client público (sem secret) para SPA/mobile.
# client_id é usado como audience no API Gateway JWT authorizer (módulo 60-api).

resource "aws_cognito_user_pool_client" "main" {
  name         = "${var.prefix}-app-client"
  user_pool_id = aws_cognito_user_pool.main.id

  generate_secret = false

  # Fluxos recomendados: USER_SRP_AUTH (frontend seguro) e REFRESH_TOKEN; USER_PASSWORD para testes opcional
  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_PASSWORD_AUTH"
  ]

  token_validity_units {
    access_token  = "hours"
    id_token      = "hours"
    refresh_token = "days"
  }

  access_token_validity  = var.access_token_validity
  id_token_validity      = var.id_token_validity
  refresh_token_validity = var.refresh_token_validity

  prevent_user_existence_errors = "ENABLED"
}
