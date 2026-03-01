# App Client confidencial M2M para OAuth2 client_credentials (Storie-19).
# Lambdas e serviços internos usam client_id + client_secret para obter access_token com scopes.

resource "aws_cognito_user_pool_client" "m2m" {
  count = var.enable_m2m_client ? 1 : 0

  name         = "${var.prefix}-internal-m2m-client"
  user_pool_id = aws_cognito_user_pool.main.id

  generate_secret = true

  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes = [
    for s in var.m2m_scopes : "${var.m2m_resource_server_identifier}/${s.name}"
  ]

  token_validity_units {
    access_token = "hours"
  }
  access_token_validity = coalesce(var.access_token_validity, 1)

  prevent_user_existence_errors = "ENABLED"

  depends_on = [aws_cognito_resource_server.m2m]
}
