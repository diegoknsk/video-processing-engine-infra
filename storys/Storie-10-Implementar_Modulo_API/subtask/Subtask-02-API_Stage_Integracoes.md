# Subtask 02: HTTP API, stage dev e integrações Lambda (Auth, VideoManagement)

## Descrição
Criar o recurso aws_apigatewayv2_api (HTTP API) no módulo `terraform/60-api`, o stage (dev) e as integrações Lambda para LambdaAuth e LambdaVideoManagement. Cada integração deve apontar para a Lambda casca correspondente (ARN via variável). Garantir permissão para a API invocar as Lambdas (aws_lambda_permission). Sem regras complexas; apenas o mínimo para bootstrap.

## Passos de implementação
1. Criar arquivo `terraform/60-api/api.tf` (ou main.tf) com recurso aws_apigatewayv2_api: name = "${var.prefix}-api" (ou equivalente), protocol_type = "HTTP", description opcional. Tags = var.common_tags.
2. Criar aws_apigatewayv2_stage: api_id = aws_apigatewayv2_api.main.id, name = var.stage_name (dev), auto_deploy = true (ou conforme decisão). Garantir que o stage exista para gerar a invoke URL.
3. Criar duas integrações Lambda: (a) aws_apigatewayv2_integration para Lambda Auth: integration_type = "AWS_PROXY", integration_uri = var.lambda_auth_arn (formato invoke ARN: arn:aws:apigateway:region:lambda:path/2015-03-31/functions/{lambda_arn}/invocations); (b) aws_apigatewayv2_integration para Lambda VideoManagement: integration_type = "AWS_PROXY", integration_uri = var.lambda_video_management_arn (invoke ARN). Payload format version = "2.0" para HTTP API.
4. Criar aws_lambda_permission para cada Lambda permitindo que o API Gateway (apigateway.amazonaws.com) invoque a função: source_arn = "${aws_apigatewayv2_api.main.execution_arn}/*/*" ou equivalente para HTTP API (principal = apigateway.amazonaws.com, statement_id para API Gateway invoke).
5. Documentar em comentário: "Integrações apontam para Lambdas casca (50-lambdas-shell); mínimo para bootstrap."

## Formas de teste
1. Executar `terraform plan` com lambda_auth_arn e lambda_video_management_arn preenchidos; verificar que o plano inclui aws_apigatewayv2_api, aws_apigatewayv2_stage e duas aws_apigatewayv2_integration (Auth e VideoManagement).
2. Verificar que cada integração usa integration_uri com o ARN da Lambda correspondente (var.lambda_auth_arn e var.lambda_video_management_arn).
3. Confirmar que aws_lambda_permission existe para cada Lambda (API Gateway pode invocar); terraform validate e plan passam.

## Critérios de aceite da subtask
- [ ] Existe aws_apigatewayv2_api (HTTP API) com protocol_type = "HTTP" e aws_apigatewayv2_stage com name = var.stage_name (dev).
- [ ] Existem duas integrações Lambda (AWS_PROXY): uma para LambdaAuth e uma para LambdaVideoManagement; integration_uri aponta para as Lambdas casca (ARNs via variável).
- [ ] Existem aws_lambda_permission para API Gateway invocar cada Lambda; nenhuma regra complexa; terraform validate e plan passam.
