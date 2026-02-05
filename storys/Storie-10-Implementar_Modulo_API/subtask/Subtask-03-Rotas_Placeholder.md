# Subtask 03: Rotas placeholder /auth/* e /videos/*

## Descrição
Criar as rotas placeholder na HTTP API: /auth/* (qualquer path sob /auth) → integração LambdaAuth, e /videos/* (qualquer path sob /videos) → integração LambdaVideoManagement. Usar aws_apigatewayv2_route com route_key no formato adequado (ex.: ANY /auth/{proxy+}, ANY /videos/{proxy+} ou equivalente conforme provider Terraform para HTTP API). As rotas devem usar as integrações criadas na Subtask 02.

## Passos de implementação
1. No arquivo api.tf (ou routes.tf), criar aws_apigatewayv2_route para /auth: api_id = aws_apigatewayv2_api.main.id, route_key = "ANY /auth/{proxy+}" (ou "GET /auth/{proxy+}", "POST /auth/{proxy+}" etc. conforme necessidade; para placeholder, ANY ou GET/POST cobrindo o necessário), target = "integrations/{integration_id}" da integração Lambda Auth. Incluir rota para path exato /auth se necessário (ex.: route_key = "ANY /auth").
2. Criar aws_apigatewayv2_route para /videos: route_key = "ANY /videos/{proxy+}" (e opcionalmente "ANY /videos"), target = integração Lambda VideoManagement.
3. Garantir que route_key e target estejam corretos para HTTP API (formato pode ser "ANY /auth/{proxy+}" ou equivalente no provider AWS); documentação Terraform aws_apigatewayv2_route para HTTP API.
4. Documentar em comentário: "Rotas placeholder; a aplicação (Lambdas) implementa os verbos e paths concretos (ex.: POST /auth/login, GET /videos)."
5. Não criar rotas adicionais complexas; apenas /auth/* e /videos/*.

## Formas de teste
1. Executar `terraform plan` e verificar que o plano inclui aws_apigatewayv2_route para /auth e /videos com target apontando para as integrações corretas.
2. Verificar na documentação AWS/ Terraform o formato de route_key para HTTP API (ex.: "ANY /auth/{proxy+}") e confirmar que as rotas cobrem /auth/* e /videos/*.
3. Confirmar que nenhuma rota aponta para integração errada (/auth → LambdaAuth, /videos → LambdaVideoManagement); terraform validate e plan passam.

## Critérios de aceite da subtask
- [ ] Existem rotas placeholder: /auth/* (ou equivalente) → integração LambdaAuth, /videos/* → integração LambdaVideoManagement.
- [ ] route_key e target corretos para HTTP API; integrações são as criadas na Subtask 02.
- [ ] Apenas o mínimo de rotas (auth e videos); terraform validate e plan passam.
