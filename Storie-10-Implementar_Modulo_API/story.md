# Storie-10: Implementar Módulo Terraform 60-API (API Gateway HTTP API)

## Status
- **Estado:** 🔄 Em desenvolvimento
- **Data de Conclusão:** [DD/MM/AAAA]

## Descrição
Como desenvolvedor de infraestrutura, quero que o módulo `terraform/60-api` provisione uma API Gateway HTTP API com stage dev e rotas placeholder (/auth/* → LambdaAuth, /videos/* → LambdaVideoManagement), com suporte preparado para JWT authorizer do Cognito (enable_authorizer, issuer/audience via outputs do módulo 40-auth), para que o fluxo de entrada no sistema (autenticação e gerenciamento de vídeos) esteja alinhado ao desenho do Processador Video MVP com o mínimo necessário para bootstrap e evolução.

## Objetivo
Criar o módulo `terraform/60-api` com **API Gateway HTTP API** (preferência sobre REST API): **stage dev**; **rotas placeholder** — /auth/* → LambdaAuth, /videos/* → LambdaVideoManagement; integrações apontando para as Lambdas casca (módulo 50-lambdas-shell). **Preparar suporte para JWT authorizer do Cognito:** enable_authorizer por variável; issuer e audience via outputs do Cognito (módulo 40-auth). **Outputs:** invoke URL da API. Regras: sem regras complexas; só o mínimo para bootstrap e evolução. A story **documenta a decisão HTTP API vs REST** e o porquê.

## Escopo Técnico
- Tecnologias: Terraform >= 1.0, AWS Provider (~> 5.0)
- Arquivos afetados:
  - `terraform/60-api/variables.tf` (prefix, common_tags, lambda_auth_arn, lambda_video_management_arn, enable_authorizer, cognito_issuer_url, cognito_audience)
  - `terraform/60-api/api.tf` ou `main.tf` (aws_apigatewayv2_api, aws_apigatewayv2_stage, aws_apigatewayv2_integration, aws_apigatewayv2_route)
  - `terraform/60-api/authorizer.tf` (aws_apigatewayv2_authorizer JWT quando enable_authorizer = true)
  - `terraform/60-api/outputs.tf`
  - `terraform/60-api/README.md` (decisão HTTP API vs REST, rotas, authorizer)
- Componentes/Recursos: aws_apigatewayv2_api (HTTP API), aws_apigatewayv2_stage (dev), aws_apigatewayv2_integration (Lambda Auth e Lambda VideoManagement), aws_apigatewayv2_route (/auth/*, /videos/*); aws_apigatewayv2_authorizer (JWT Cognito) e associação às rotas quando enable_authorizer = true; permissão da API invocar as Lambdas (aws_lambda_permission). Nenhuma regra complexa (throttling, WAF etc.) nesta story.
- Pacotes/Dependências: Nenhum; consumo de prefix/common_tags e de outputs dos módulos 50-lambdas-shell (Lambda ARNs) e 40-auth (Cognito issuer/audience quando existir).

## Dependências e Riscos (para estimativa)
- Dependências: Storie-02 (foundation), Storie-08 (50-lambdas-shell — LambdaAuth e LambdaVideoManagement ARNs). Módulo 40-auth (Cognito) desejável para JWT authorizer (issuer/audience); quando 40-auth não existir, enable_authorizer = false ou variáveis placeholder.
- Riscos/Pré-condições: JWT authorizer exige que o Cognito User Pool esteja configurado (issuer URL e audience); sem Cognito, authorizer fica desabilitado.

---

## Decisão: HTTP API vs REST API

| Critério | HTTP API | REST API |
|----------|----------|----------|
| **Custo** | Mais barato (cobrança por request/mês; sem custo por estágio) | Mais caro (estágios cobrados) |
| **JWT / Cognito** | Suporte nativo a JWT authorizer (Cognito, OIDC) | Requer Lambda authorizer ou Cognito User Pool Authorizer (mais configuração) |
| **Simplicidade** | Mais simples: rotas, integrações, authorizer em poucos recursos | Mais recursos (deployment, stage, method, integration, etc.) |
| **Recursos avançados** | Throttling, CORS, logs; suficiente para MVP | Request/response transformação, API keys, usage plans, mais granularidade |
| **Evolução** | Adequado para bootstrap e evolução incremental (adicionar rotas, authorizer) | Útil quando se precisa de contratos REST complexos, API keys, usage plans |

**Decisão para este projeto:** **HTTP API** — preferência para bootstrap e evolução do Processador Video MVP: custo menor, JWT/Cognito nativo, configuração mínima (rotas placeholder, stage dev, authorizer opcional). REST API pode ser considerada em story futura se houver requisito de usage plans, API keys ou transformações complexas. A story documenta essa escolha no README do módulo.

---

## Rotas Placeholder e Integrações

| Rota | Integração | Lambda | Observação |
|------|------------|--------|------------|
| **/auth/** (qualquer método sob /auth) | Lambda proxy | LambdaAuth | Login, token; pode ficar pública ou com authorizer conforme decisão (geralmente /auth/login pública). |
| **/videos/** (qualquer método sob /videos) | Lambda proxy | LambdaVideoManagement | CRUD vídeos, presigned URL; protegida por JWT quando enable_authorizer = true. |

- **Placeholder:** Rotas configuradas com integração Lambda proxy; a aplicação (Lambdas) implementa os verbos e paths concretos (ex.: POST /auth/login, GET /videos, POST /videos).
- **Integrações:** Apontam para as Lambdas casca (ARNs do módulo 50-lambdas-shell); sem código de Lambda nesta story.

---

## JWT Authorizer (Cognito)

- **enable_authorizer** (bool, default = false): quando true, configura JWT authorizer usando issuer e audience do Cognito; quando false, nenhum authorizer (todas as rotas acessíveis sem token para bootstrap).
- **cognito_issuer_url** (string, opcional): URL do issuer do Cognito User Pool (ex.: https://cognito-idp.{region}.amazonaws.com/{userPoolId}); vem do output do módulo 40-auth.
- **cognito_audience** (string ou list, opcional): audience do JWT (ex.: client ID do App Client Cognito); vem do output do módulo 40-auth.
- Quando enable_authorizer = true e issuer/audience fornecidos, criar aws_apigatewayv2_authorizer (JWT) e associar às rotas que devem ser protegidas (ex.: /videos/*); /auth/* pode permanecer sem authorizer para login.
- Quando 40-auth não existir, usar enable_authorizer = false ou variáveis placeholder; documentar no README.

---

## Variáveis do Módulo
- **prefix**, **common_tags**: do foundation.
- **lambda_auth_arn** (string): ARN da Lambda Auth (módulo 50-lambdas-shell).
- **lambda_video_management_arn** (string): ARN da Lambda VideoManagement (módulo 50-lambdas-shell).
- **enable_authorizer** (bool, default = false): habilita JWT authorizer Cognito.
- **cognito_issuer_url** (string, opcional): issuer URL do Cognito (output do 40-auth).
- **cognito_audience** (string ou list, opcional): audience do JWT (output do 40-auth).
- **stage_name** (string, default = "dev"): nome do stage (ex.: dev).

## Decisões Técnicas
- **HTTP API:** aws_apigatewayv2_api com protocol_type = "HTTP"; sem API key nem usage plan nesta story.
- **Stage:** aws_apigatewayv2_stage com name = var.stage_name (dev); auto_deploy opcional (true para simplicidade).
- **Rotas:** aws_apigatewayv2_route para /auth/$proxy+ e /videos/$proxy+ (ou equivalente) com integração Lambda proxy; cada rota aponta para a integração da Lambda correspondente.
- **Integrações:** aws_apigatewayv2_integration com integration_type = "AWS_PROXY", integration_uri = Lambda invoke ARN; aws_lambda_permission para api gateway invocar cada Lambda.
- **Authorizer:** aws_apigatewayv2_authorizer com identity_sources = ["$request.header.Authorization"], issuer_url e audience quando enable_authorizer = true; default_authorizer ou authorizer por rota (ex.: apenas /videos/* protegido).
- **Mínimo para bootstrap:** Sem throttling, WAF ou regras complexas; apenas API, stage, rotas, integrações e authorizer opcional.

## Subtasks
- [Subtask 01: Variáveis do módulo e consumo de ARNs (Lambdas, Cognito)](./subtask/Subtask-01-Variaveis_Consumo.md)
- [Subtask 02: HTTP API, stage dev e integrações Lambda (Auth, VideoManagement)](./subtask/Subtask-02-API_Stage_Integracoes.md)
- [Subtask 03: Rotas placeholder /auth/* e /videos/*](./subtask/Subtask-03-Rotas_Placeholder.md)
- [Subtask 04: JWT authorizer (Cognito) opcional e outputs](./subtask/Subtask-04-Authorizer_Outputs.md)
- [Subtask 05: Documentar decisão HTTP API vs REST e validação](./subtask/Subtask-05-Documentacao_Validacao.md)

## Critérios de Aceite da História
- [ ] O módulo `terraform/60-api` cria uma API Gateway HTTP API com stage dev quando variáveis de Lambdas são fornecidas
- [ ] Rotas placeholder configuradas: /auth/* → LambdaAuth, /videos/* → LambdaVideoManagement; integrações apontam para as Lambdas casca (ARNs do módulo 50-lambdas-shell)
- [ ] Suporte a JWT authorizer do Cognito preparado: enable_authorizer por variável; issuer e audience via variáveis (outputs do Cognito / 40-auth quando existir); quando enable_authorizer = true e issuer/audience fornecidos, authorizer configurado (rotas /videos/* protegidas ou conforme decisão)
- [ ] Outputs expõem a invoke URL da API (ex.: https://{api_id}.execute-api.{region}.amazonaws.com/dev)
- [ ] Sem regras complexas (apenas API, stage, rotas, integrações, authorizer opcional); mínimo para bootstrap e evolução
- [ ] A story documenta a decisão HTTP API vs REST e o porquê (custo, JWT nativo, simplicidade para MVP)
- [ ] Consumo de prefix/common_tags e dos outputs dos módulos lambdas (e 40-auth quando authorizer habilitado); terraform plan sem referências quebradas

## Checklist de Conclusão
- [ ] HTTP API e stage dev criados; rotas /auth/* e /videos/* com integrações Lambda
- [ ] JWT authorizer opcional (enable_authorizer, issuer/audience); outputs com invoke URL
- [ ] README com decisão HTTP API vs REST e descrição das rotas
- [ ] terraform init, validate e plan com variáveis fornecidas passam
