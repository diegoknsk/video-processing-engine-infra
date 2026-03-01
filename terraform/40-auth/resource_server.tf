# Resource Server no User Pool para scopes OAuth2 (client_credentials — Storie-19).
# Necessário para o App Client M2M solicitar tokens com escopos (analyze:run, videos:update_status).

resource "aws_cognito_resource_server" "m2m" {
  count = var.enable_m2m_client ? 1 : 0

  user_pool_id = aws_cognito_user_pool.main.id
  identifier   = var.m2m_resource_server_identifier
  name         = "${var.prefix}-resource-server"

  dynamic "scope" {
    for_each = var.m2m_scopes
    content {
      scope_name        = scope.value.name
      scope_description = scope.value.description
    }
  }
}
