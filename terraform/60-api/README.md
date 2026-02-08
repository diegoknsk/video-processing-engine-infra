# Módulo 60-api — API Gateway HTTP API

Provisiona uma **API Gateway HTTP API** com stage (ex.: dev), rotas placeholder para autenticação e gerenciamento de vídeos, e suporte opcional a JWT authorizer (Cognito). Alinhado ao desenho do Processador Video MVP (entrada no sistema via API + Lambda Auth + Lambda Video Management).

---

## Decisão: HTTP API vs REST API

| Critério | HTTP API | REST API |
|----------|----------|----------|
| **Custo** | Mais barato (cobrança por request/mês; sem custo por estágio) | Mais caro (estágios cobrados) |
| **JWT / Cognito** | Suporte nativo a JWT authorizer (Cognito, OIDC) | Requer Lambda authorizer ou Cognito User Pool Authorizer (mais configuração) |
| **Simplicidade** | Mais simples: rotas, integrações, authorizer em poucos recursos | Mais recursos (deployment, stage, method, integration, etc.) |
| **Recursos avançados** | Throttling, CORS, logs; suficiente para MVP | Request/response transformação, API keys, usage plans, mais granularidade |
| **Evolução** | Adequado para bootstrap e evolução incremental (adicionar rotas, authorizer) | Útil quando se precisa de contratos REST complexos, API keys, usage plans |

**Decisão para este projeto:** **HTTP API** — preferência para bootstrap e evolução do Processador Video MVP: custo menor, JWT/Cognito nativo, configuração mínima (rotas placeholder, stage dev, authorizer opcional). REST API pode ser considerada em story futura se houver requisito de usage plans, API keys ou transformações complexas.

---

## Rotas placeholder e integrações

| Rota | Integração | Lambda | Observação |
|------|------------|--------|------------|
| **ANY /auth**, **ANY /auth/{proxy+}** | Lambda proxy | LambdaAuth | Login, token; pública (sem authorizer) para permitir login. |
| **ANY /videos**, **ANY /videos/{proxy+}** | Lambda proxy | LambdaVideoManagement | CRUD vídeos, presigned URL; protegida por JWT quando `enable_authorizer = true`. |

- **Placeholder:** Rotas configuradas com integração Lambda proxy; a aplicação (Lambdas) implementa os verbos e paths concretos (ex.: POST /auth/login, GET /videos, POST /videos).
- **Integrações:** Apontam para as Lambdas casca (ARNs do módulo **50-lambdas-shell**).

---

## JWT Authorizer (Cognito)

- **enable_authorizer** (bool, default = false): quando `true`, configura JWT authorizer usando issuer e audience do Cognito; quando `false`, nenhum authorizer (todas as rotas acessíveis sem token para bootstrap).
- **cognito_issuer_url**: URL do issuer do Cognito User Pool (ex.: `https://cognito-idp.{region}.amazonaws.com/{userPoolId}`); vem do output do módulo **40-auth**.
- **cognito_audience**: audience do JWT (ex.: client ID do App Client Cognito); vem do output do módulo **40-auth**.

Quando `enable_authorizer = true` e issuer/audience fornecidos, o authorizer é criado e associado às rotas **/videos***. Rotas **/auth*** permanecem sem authorizer para login. Quando o módulo 40-auth não existir, usar `enable_authorizer = false` ou variáveis placeholder.

---

## Uso pelo caller (root)

O root deve passar:

- **prefix**, **common_tags**: do módulo `foundation`.
- **lambda_auth_arn**, **lambda_video_management_arn**: outputs do módulo **50-lambdas-shell** (`module.lambdas.lambda_auth_arn`, `module.lambdas.lambda_video_management_arn`).
- **enable_authorizer** (opcional, default = false), **cognito_issuer_url**, **cognito_audience** (opcional): quando authorizer habilitado, usar outputs do módulo **40-auth** (Cognito) quando existir.

Exemplo no root:

```hcl
module "api" {
  source = "./60-api"

  prefix      = module.foundation.prefix
  common_tags = module.foundation.common_tags

  lambda_auth_arn             = module.lambdas.lambda_auth_arn
  lambda_video_management_arn  = module.lambdas.lambda_video_management_arn

  enable_authorizer   = var.enable_api_authorizer
  cognito_issuer_url  = var.cognito_issuer_url
  cognito_audience    = var.cognito_audience
  stage_name         = "dev"
}
```

---

## Outputs

- **api_id**: ID da API Gateway HTTP API.
- **api_invoke_url**: URL de invocação do stage (ex.: `https://{api_id}.execute-api.{region}.amazonaws.com/dev`).
- **api_execution_arn**: ARN de execução da API.

---

## Validação

```bash
cd terraform/60-api
terraform init -backend=false
terraform validate
terraform plan -var="prefix=..." -var="lambda_auth_arn=..." -var="lambda_video_management_arn=..." ...
```

No root, após incluir o módulo: `terraform init`, `terraform validate`, `terraform plan` (com tfvars ou variáveis obrigatórias).
