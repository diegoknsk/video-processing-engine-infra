# Subtask 03: API Gateway invocando Lambda Auth por qualified ARN

## Descrição
Se a API Gateway (módulo 40-api ou equivalente) estiver configurada para invocar a Lambda Auth por nome ou ARN não qualificado, ajustar para usar o **qualified ARN** (versão publicada) da Lambda Auth, para que as requisições à API também se beneficiem do SnapStart.

- Verificar onde a integração Lambda da API referencia a Lambda Auth (variável, output do módulo lambdas).
- Garantir que o módulo 50-lambdas-shell exporte o qualified ARN da Lambda Auth (ex.: output `lambda_auth_qualified_arn`) e que o root/API use esse valor na integração.

## Critério de conclusão
- [x] A integração da API com a Lambda Auth usa qualified ARN (versão publicada); ou documentado que não se aplica se a API já usar outro mecanismo.
