# Subtask 04: JWT authorizer (Cognito) opcional e outputs

## Descrição
Configurar o JWT authorizer do Cognito de forma opcional: quando enable_authorizer = true e cognito_issuer_url e cognito_audience fornecidos, criar aws_apigatewayv2_authorizer (JWT) e associar às rotas que devem ser protegidas (ex.: /videos/*); /auth/* pode permanecer sem authorizer para login. Criar outputs com a invoke URL da API (ex.: https://{api_id}.execute-api.{region}.amazonaws.com/{stage_name}).

## Passos de implementação
1. Criar arquivo `terraform/60-api/authorizer.tf` com recurso aws_apigatewayv2_authorizer condicionado a var.enable_authorizer e var.cognito_issuer_url != "" (e cognito_audience quando necessário): api_id = aws_apigatewayv2_api.main.id, authorizer_type = "JWT", identity_sources = ["$request.header.Authorization"], jwt_configuration { audience = [var.cognito_audience], issuer = var.cognito_issuer_url }. Usar count = var.enable_authorizer && var.cognito_issuer_url != "" ? 1 : 0 (ou equivalente).
2. Associar o authorizer às rotas que devem ser protegidas: em aws_apigatewayv2_route das rotas /videos/*, adicionar authorization_type = "JWT" e authorizer_id = aws_apigatewayv2_authorizer.jwt[0].id quando enable_authorizer = true. Rotas /auth/* podem não ter authorizer (públicas para login). Usar dynamic block ou condicional para não quebrar quando authorizer não existir.
3. Criar `terraform/60-api/outputs.tf` com output api_invoke_url (value = "${aws_apigatewayv2_stage.dev.invoke_url}" ou equivalente — formato para HTTP API é invoke_url do stage). Garantir que o output referencie o stage criado na Subtask 02.
4. Opcionalmente output api_id (value = aws_apigatewayv2_api.main.id) para uso pelo caller; documentar que cognito_issuer_url e cognito_audience vêm dos outputs do módulo 40-auth (Cognito).

## Formas de teste
1. Executar `terraform plan` com enable_authorizer = true, cognito_issuer_url e cognito_audience preenchidos; verificar que o plano inclui aws_apigatewayv2_authorizer e que as rotas /videos/* têm authorizer_id; rotas /auth/* sem authorizer.
2. Executar `terraform plan` com enable_authorizer = false; verificar que nenhum authorizer é criado e que as rotas não quebram.
3. Verificar que o output api_invoke_url existe e que o valor é a URL de invocação do stage (ex.: https://xxx.execute-api.region.amazonaws.com/dev); terraform plan lista o output sem erro.

## Critérios de aceite da subtask
- [ ] JWT authorizer (Cognito) é criado apenas quando enable_authorizer = true e cognito_issuer_url (e audience) fornecidos; issuer e audience vêm de variáveis (outputs do Cognito / 40-auth).
- [ ] Rotas /videos/* podem ser associadas ao authorizer quando habilitado; /auth/* permanece acessível sem authorizer para login.
- [ ] Output api_invoke_url expõe a invoke URL da API (stage invoke_url); terraform plan passa; documentação indica que issuer/audience vêm do 40-auth.
