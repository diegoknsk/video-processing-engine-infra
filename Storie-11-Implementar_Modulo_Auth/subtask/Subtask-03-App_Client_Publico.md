# Subtask 03: App Client público (sem secret)

## Descrição
Criar o recurso aws_cognito_user_pool_client no módulo `terraform/40-auth` como **public client** (generate_secret = false), vinculado ao User Pool criado na Subtask 02. Configurar explicit_auth_flows adequados (ex.: ALLOW_USER_SRP_AUTH, ALLOW_REFRESH_TOKEN_AUTH; opcionalmente ALLOW_USER_PASSWORD_AUTH para testes). Token validity (access, refresh, id) parametrizável quando fizer sentido.

## Passos de implementação
1. Criar arquivo `terraform/40-auth/app_client.tf` (ou adicionar ao user_pool.tf) com recurso aws_cognito_user_pool_client: name = "${var.prefix}-app-client" (ou equivalente), user_pool_id = aws_cognito_user_pool.main.id, **generate_secret = false** (public client).
2. Configurar explicit_auth_flows = ["ALLOW_USER_SRP_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"] (recomendado para frontend seguro); opcionalmente "ALLOW_USER_PASSWORD_AUTH" para testes (documentar se incluir). Não incluir ALLOW_ADMIN_USER_PASSWORD_AUTH a menos que seja requisito.
3. Configurar token_validity_units e refresh_token_validity, access_token_validity, id_token_validity quando suportado pelo resource (bloco token_validity_units com access_token = "hours", refresh_token = "days"; token_validity com valores em unidades). Usar variáveis quando declaradas na Subtask 01.
4. Garantir que generate_secret seja explicitamente false; documentar que o client é público (SPA/mobile) e que client_id será usado como audience no API Gateway JWT authorizer.
5. Não criar secret; outputs não devem expor secret (não existe neste client).

## Formas de teste
1. Executar `terraform plan` e verificar que o plano inclui aws_cognito_user_pool_client com generate_secret = false e explicit_auth_flows corretos.
2. Buscar no recurso por generate_secret e confirmar que é false; não há client_secret no output.
3. Confirmar que user_pool_id referencia o User Pool do módulo; terraform validate e plan passam.

## Critérios de aceite da subtask
- [ ] Existe aws_cognito_user_pool_client vinculado ao User Pool com generate_secret = false (public client).
- [ ] explicit_auth_flows inclui ALLOW_USER_SRP_AUTH e ALLOW_REFRESH_TOKEN_AUTH (e opcionalmente ALLOW_USER_PASSWORD_AUTH para testes); token validity parametrizável quando suportado.
- [ ] Nenhum secret criado; client_id disponível para uso como audience no authorizer; terraform validate e plan passam.
