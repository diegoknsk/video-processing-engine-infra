# Subtask 02: Validação e documentação

## Descrição
Validar que o root continua executando plan/apply sem erro após a inclusão dos outputs do Cognito e documentar brevemente o propósito desses outputs (consumo por CI/CD, API, pipelines no GitHub). Opcional: atualizar README ou documentação da ordem de módulos se houver menção aos outputs do root.

## Passos de implementação
1. No diretório `terraform/`, executar `terraform init` (se necessário), `terraform validate` e `terraform plan -var-file=envs/dev.tfvars`.
2. Confirmar que não há erros de referência (ex.: "unknown module auth") e que os novos outputs aparecem no plano.
3. No arquivo `terraform/outputs.tf`, garantir que o comentário no topo do arquivo ou na seção Auth mencione que os outputs do Cognito são reexportados para CI/CD, pipelines e configuração da API (ex.: GitHub Actions, variáveis de ambiente da aplicação).
4. Se existir documentação que lista os outputs do root (ex.: README em terraform/ ou docs/), incluir os quatro outputs do Cognito na lista.

## Formas de teste
1. `terraform plan -var-file=envs/dev.tfvars` no root deve concluir com sucesso e exibir os outputs cognito_*.
2. `terraform output` no root (com state já aplicado) deve listar cognito_user_pool_id, cognito_client_id, cognito_issuer, cognito_jwks_url.
3. Revisar comentários no outputs.tf para clareza para quem for usar no GitHub ou na API.

## Critérios de aceite da subtask
- [x] terraform validate e terraform plan no root passam sem erro.
- [x] Comentário ou descrição no outputs.tf deixa claro que os outputs do Cognito são para consumo por CI/CD, API e pipelines.
- [x] Story pronta para conclusão: todos os critérios de aceite da Storie-14 atendidos.
