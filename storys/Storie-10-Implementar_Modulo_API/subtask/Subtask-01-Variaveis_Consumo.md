# Subtask 01: Variáveis do módulo e consumo de ARNs (Lambdas, Cognito)

## Descrição
Criar o arquivo `terraform/60-api/variables.tf` com as variáveis necessárias para o módulo: prefix, common_tags, lambda_auth_arn, lambda_video_management_arn, enable_authorizer, cognito_issuer_url, cognito_audience e stage_name (default "dev"), para consumo dos módulos 50-lambdas-shell e 40-auth (Cognito). Garantir que o módulo receba os ARNs e parâmetros por variáveis de entrada (caller/root passa os valores).

## Passos de implementação
1. Criar `terraform/60-api/variables.tf` com variáveis obrigatórias ou com default: prefix, common_tags (do foundation).
2. Declarar variáveis de integração: lambda_auth_arn (string, ARN da Lambda Auth), lambda_video_management_arn (string, ARN da Lambda VideoManagement); incluir description indicando origem (output do módulo 50-lambdas-shell).
3. Declarar variáveis de authorizer: enable_authorizer (bool, default = false), cognito_issuer_url (string, default = null ou ""), cognito_audience (string ou list, default = null ou ""); incluir description indicando que vêm dos outputs do Cognito (módulo 40-auth).
4. Declarar stage_name (string, default = "dev") para o nome do stage da API.
5. Garantir que nenhuma variável dependa de path absoluto ou módulo interno; consumo apenas via variáveis de entrada do caller. Documentar que quando 40-auth não existir, enable_authorizer = false ou issuer/audience placeholder.

## Formas de teste
1. Executar `terraform validate` em `terraform/60-api/` após criar variables.tf; validar que não há erro de variável não declarada em outros arquivos que referenciem var.lambda_auth_arn, etc.
2. Verificar que enable_authorizer é bool e que stage_name tem default "dev".
3. Listar variáveis documentadas na story (lambda_auth_arn, lambda_video_management_arn, enable_authorizer, cognito_issuer_url, cognito_audience, stage_name) e confirmar que estão declaradas em variables.tf.

## Critérios de aceite da subtask
- [ ] O arquivo `terraform/60-api/variables.tf` existe e declara prefix, common_tags, lambda_auth_arn, lambda_video_management_arn, enable_authorizer, cognito_issuer_url, cognito_audience, stage_name.
- [ ] stage_name tem default "dev"; enable_authorizer tem default false; nenhuma referência quebrada ao caller; terraform validate passa.
