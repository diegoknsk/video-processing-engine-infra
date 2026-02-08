# JWT Authorizer (Cognito) opcional. Quando enable_authorizer = true e issuer/audience fornecidos,
# protege rotas /videos/*. Rotas /auth/* permanecem sem authorizer para login.
# cognito_issuer_url e cognito_audience vêm dos outputs do módulo 40-auth (Cognito).

locals {
  create_authorizer = var.enable_authorizer && try(var.cognito_issuer_url, "") != "" && try(length(var.cognito_audience), 0) > 0
}

resource "aws_apigatewayv2_authorizer" "jwt" {
  count = local.create_authorizer ? 1 : 0

  api_id           = aws_apigatewayv2_api.main.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "${var.prefix}-api-jwt-authorizer"

  jwt_configuration {
    audience = var.cognito_audience
    issuer   = var.cognito_issuer_url
  }
}
