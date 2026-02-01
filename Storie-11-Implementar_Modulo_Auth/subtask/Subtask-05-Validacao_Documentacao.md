# Subtask 05: Validação e documentação (pronto para API Gateway authorizer)

## Descrição
Garantir que terraform init, terraform validate e terraform plan executem sem referências quebradas no módulo `terraform/40-auth`. Documentar no README que o módulo deixa o Cognito pronto para o JWT authorizer do API Gateway: o caller (root ou pipeline) deve passar os outputs issuer e client_id ao módulo 60-api quando enable_authorizer = true. Incluir resumo das configurações mínimas seguras e do que é parametrizável.

## Passos de implementação
1. Adicionar ao README do módulo `terraform/40-auth` uma seção "Pronto para o API Gateway Authorizer": resumir que user_pool_id, client_id, issuer e jwks_url são expostos; o módulo 60-api (Storie-10) usa issuer como cognito_issuer_url e client_id como cognito_audience no JWT authorizer; ao aplicar 40-auth e 60-api, configurar 60-api com enable_authorizer = true, cognito_issuer_url = module.auth.issuer, cognito_audience = module.auth.client_id (ou equivalentes).
2. Incluir resumo das configurações mínimas seguras (política de senha, atributos, public client) e lista do que é parametrizável (password_*, token_*, etc.); sem exagero.
3. Executar `terraform init` e `terraform validate` no módulo `terraform/40-auth`; corrigir até "Success! The configuration is valid."
4. Executar `terraform plan` passando prefix e common_tags (e opcionalmente variáveis de password e token); verificar que não há erro de referência quebrada e que User Pool e App Client são criados com outputs preenchidos.
5. Garantir que data.aws_region.current (ou var.region) está disponível para construção de issuer e jwks_url; criar data source se necessário em datasource.tf ou no próprio user_pool.tf.

## Formas de teste
1. Ler o README e confirmar que "pronto para API Gateway authorizer" está descrito e que a conexão com o 60-api (issuer, client_id) está clara.
2. Rodar `terraform validate` em terraform/40-auth/ e confirmar "Success! The configuration is valid."
3. Rodar `terraform plan` com variáveis mínimas (prefix, common_tags); User Pool, App Client e quatro outputs devem aparecer no plano sem erro.

## Critérios de aceite da subtask
- [ ] README documenta que o módulo deixa o Cognito pronto para o authorizer do API Gateway (passar issuer e client_id ao 60-api quando enable_authorizer = true).
- [ ] terraform init, terraform validate e terraform plan no módulo 40-auth executam sem referências quebradas.
- [ ] Configurações mínimas seguras e parametrizáveis resumidas no README; story cumpre critério "pronto para o authorizer".
