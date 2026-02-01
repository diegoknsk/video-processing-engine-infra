# Subtask 05: Documentar decisão HTTP API vs REST e validação

## Descrição
Documentar explicitamente no README do módulo `terraform/60-api` a **decisão HTTP API vs REST API** e o porquê (custo, JWT nativo, simplicidade para MVP bootstrap e evolução). Garantir que terraform init, terraform validate e terraform plan executem sem referências quebradas.

## Passos de implementação
1. Criar ou atualizar `terraform/60-api/README.md` com seção "Decisão: HTTP API vs REST API": resumir que foi escolhida **HTTP API** para este projeto; motivos: (a) custo menor (cobrança por request, sem custo por estágio), (b) suporte nativo a JWT authorizer (Cognito/OIDC), (c) configuração mais simples (rotas, integrações, stage em poucos recursos), (d) adequado para bootstrap e evolução incremental do Processador Video MVP. REST API pode ser considerada em story futura se houver requisito de usage plans, API keys ou transformações complexas. Incluir tabela resumo (HTTP API vs REST) conforme story principal.
2. Incluir no README descrição das rotas placeholder (/auth/* → LambdaAuth, /videos/* → LambdaVideoManagement) e do authorizer opcional (enable_authorizer, issuer/audience do Cognito); referência ao contexto arquitetural (autenticação via API Gateway + Lambda Auth + Cognito).
3. Executar `terraform init` e `terraform validate` no módulo `terraform/60-api`; corrigir até "Success! The configuration is valid."
4. Executar `terraform plan` passando lambda_auth_arn e lambda_video_management_arn (e opcionalmente enable_authorizer, cognito_issuer_url, cognito_audience) e verificar que não há erro de referência quebrada.
5. Documentar como o caller deve passar os ARNs das Lambdas (outputs do 50-lambdas-shell) e, quando authorizer habilitado, issuer/audience (outputs do 40-auth).

## Formas de teste
1. Ler o README e confirmar que a decisão HTTP API vs REST está documentada com os motivos (custo, JWT nativo, simplicidade).
2. Rodar `terraform validate` em terraform/60-api/ e confirmar "Success! The configuration is valid."
3. Rodar `terraform plan` com variáveis obrigatórias preenchidas (lambda_auth_arn, lambda_video_management_arn); nenhum erro de referência quebrada.

## Critérios de aceite da subtask
- [ ] README documenta a decisão HTTP API vs REST e o porquê (custo, JWT nativo, simplicidade para MVP bootstrap e evolução).
- [ ] terraform init, terraform validate e terraform plan no módulo 60-api executam sem referências quebradas.
- [ ] Rotas e authorizer opcional descritos no README; referência ao desenho (autenticação e entrada no sistema).
