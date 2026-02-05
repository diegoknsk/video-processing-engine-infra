# API Gateway HTTP API, stage dev e integrações Lambda (Auth, VideoManagement).
# Integrações apontam para Lambdas casca (50-lambdas-shell); mínimo para bootstrap.

# --- HTTP API ---
resource "aws_apigatewayv2_api" "main" {
  name          = "${var.prefix}-api"
  protocol_type = "HTTP"
  description   = "API Gateway HTTP API para Processador Video MVP (auth e vídeos)."
  tags          = var.common_tags
}

# --- Stage (dev) ---
resource "aws_apigatewayv2_stage" "dev" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = var.stage_name
  auto_deploy = true
  tags        = var.common_tags
}

# --- Integração Lambda Auth ---
resource "aws_apigatewayv2_integration" "lambda_auth" {
  api_id                 = aws_apigatewayv2_api.main.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.lambda_auth_arn
  payload_format_version = "2.0"
}

# --- Integração Lambda Video Management ---
resource "aws_apigatewayv2_integration" "lambda_video_management" {
  api_id                 = aws_apigatewayv2_api.main.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.lambda_video_management_arn
  payload_format_version = "2.0"
}

# --- Permissão: API Gateway pode invocar Lambda Auth ---
resource "aws_lambda_permission" "api_invoke_auth" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_auth_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}

# --- Permissão: API Gateway pode invocar Lambda Video Management ---
resource "aws_lambda_permission" "api_invoke_video_management" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_video_management_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}

# --- Rotas placeholder: /auth/* → LambdaAuth, /videos/* → LambdaVideoManagement ---
# A aplicação (Lambdas) implementa os verbos e paths concretos (ex.: POST /auth/login, GET /videos).

resource "aws_apigatewayv2_route" "auth_proxy" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "ANY /auth/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_auth.id}"
}

resource "aws_apigatewayv2_route" "auth" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "ANY /auth"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_auth.id}"
}

resource "aws_apigatewayv2_route" "videos_proxy" {
  api_id             = aws_apigatewayv2_api.main.id
  route_key          = "ANY /videos/{proxy+}"
  target             = "integrations/${aws_apigatewayv2_integration.lambda_video_management.id}"
  authorization_type = length(aws_apigatewayv2_authorizer.jwt) > 0 ? "JWT" : "NONE"
  authorizer_id      = length(aws_apigatewayv2_authorizer.jwt) > 0 ? aws_apigatewayv2_authorizer.jwt[0].id : null
}

resource "aws_apigatewayv2_route" "videos" {
  api_id             = aws_apigatewayv2_api.main.id
  route_key          = "ANY /videos"
  target             = "integrations/${aws_apigatewayv2_integration.lambda_video_management.id}"
  authorization_type = length(aws_apigatewayv2_authorizer.jwt) > 0 ? "JWT" : "NONE"
  authorizer_id      = length(aws_apigatewayv2_authorizer.jwt) > 0 ? aws_apigatewayv2_authorizer.jwt[0].id : null
}
