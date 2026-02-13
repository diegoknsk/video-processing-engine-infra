# JWT Authorizer (Cognito) opcional. Quando enable_authorizer = true e issuer/audience fornecidos,
# protege rotas /videos/*. Rotas /auth/* permanecem sem authorizer para login.
# cognito_issuer_url e cognito_audience vêm dos outputs do módulo 40-auth (Cognito).

# count deve depender apenas de valor conhecido no plan (var.enable_authorizer).
# cognito_issuer_url e cognito_audience vêm de outputs do 40-auth (computados); não usar no count.
resource "aws_apigatewayv2_authorizer" "jwt" {
  count = var.enable_authorizer ? 1 : 0

  api_id           = aws_apigatewayv2_api.main.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "${var.prefix}-api-jwt-authorizer"

  jwt_configuration {
    audience = var.cognito_audience
    issuer   = var.cognito_issuer_url
  }
}
