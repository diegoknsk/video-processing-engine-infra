# Subtask 04: Outputs (user_pool_id, client_id, issuer, jwks_url) e documentação para authorizer

## Descrição
Criar `terraform/40-auth/outputs.tf` com os **outputs obrigatórios:** user_pool_id, client_id, issuer e jwks_url (quando aplicável). O issuer deve ser a URL no formato https://cognito-idp.{region}.amazonaws.com/{user_pool_id}; jwks_url no formato https://cognito-idp.{region}.amazonaws.com/{user_pool_id}/.well-known/jwks.json. Documentar no README que esses outputs são consumidos pelo módulo 60-api (JWT authorizer): cognito_issuer_url = output issuer, cognito_audience = output client_id.

## Passos de implementação
1. Criar `terraform/40-auth/outputs.tf` com output user_pool_id (value = aws_cognito_user_pool.main.id) e output client_id (value = aws_cognito_user_pool_client.main.id).
2. Criar output issuer: value = "https://cognito-idp.${data.aws_region.current.name}.amazonaws.com/${aws_cognito_user_pool.main.id}" (ou usar var.region se disponível). Garantir que data.aws_region.current exista no módulo (data source) ou usar var.region.
3. Criar output jwks_url: value = "https://cognito-idp.${data.aws_region.current.name}.amazonaws.com/${aws_cognito_user_pool.main.id}/.well-known/jwks.json". Documentar que o API Gateway JWT authorizer usa o issuer para validar o token; jwks_url é referência para documentação ou uso custom.
4. Criar ou atualizar README com seção "Uso pelo API Gateway (Authorizer)": explicar que o módulo 60-api consome user_pool_id (implícito no issuer), client_id (audience) e issuer (cognito_issuer_url); ao configurar enable_authorizer = true no 60-api, passar cognito_issuer_url = output issuer e cognito_audience = output client_id.
5. Garantir que nenhum output exponha dados sensíveis; apenas IDs e URLs públicas.

## Formas de teste
1. Executar `terraform plan` e verificar que os outputs user_pool_id, client_id, issuer e jwks_url aparecem no plano sem erro.
2. Verificar que issuer e jwks_url seguem o formato esperado (cognito-idp.{region}.amazonaws.com/{user_pool_id} e .../.well-known/jwks.json).
3. Ler o README e confirmar que o uso pelo API Gateway (authorizer) está documentado (passar issuer e client_id ao 60-api).

## Critérios de aceite da subtask
- [ ] outputs.tf expõe user_pool_id, client_id, issuer e jwks_url; issuer e jwks_url construídos com region e user_pool_id.
- [ ] README (ou story) documenta que os outputs deixam o Cognito pronto para o authorizer do API Gateway (60-api: cognito_issuer_url = issuer, cognito_audience = client_id).
- [ ] Nenhum dado sensível nos outputs; terraform plan passa.
