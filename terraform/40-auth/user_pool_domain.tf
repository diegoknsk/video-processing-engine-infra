# User Pool Domain para expor o endpoint OAuth2 /oauth2/token (client_credentials — Storie-19).
# URL base: https://<domain>.auth.<region>.amazonaws.com

resource "aws_cognito_user_pool_domain" "auth_domain" {
  count = var.enable_m2m_client ? 1 : 0

  user_pool_id = aws_cognito_user_pool.main.id
  domain       = "${var.prefix}-auth"
}
