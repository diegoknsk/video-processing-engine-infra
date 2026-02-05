# Subtask 01: Variáveis do módulo e consumo de prefix/tags do foundation

## Descrição
Criar o arquivo `terraform/30-messaging/variables.tf` com as variáveis necessárias para a parte SNS do módulo messaging: prefix e common_tags (consumo do foundation), enable_email_subscription_completed, email_endpoint, enable_lambda_subscription_completed e lambda_subscription_arn (placeholder). Garantir que o módulo receba prefix e common_tags por variáveis de entrada, sem referências quebradas ao foundation.

## Passos de implementação
1. Criar `terraform/30-messaging/variables.tf` com variável obrigatória `prefix` (string) e `common_tags` (map/object) para consumo do foundation.
2. Declarar variáveis de subscription: `enable_email_subscription_completed` (bool, default = false), `email_endpoint` (string, default = null ou ""), `enable_lambda_subscription_completed` (bool, default = false), `lambda_subscription_arn` (string, default = null ou ""); incluir description indicando "ativo agora" (email) e "preparado para depois" (Lambda).
3. Garantir que o módulo não dependa de path absoluto ou module "foundation" sem que o caller forneça as variáveis; consumo apenas via variáveis de entrada.
4. Documentar em comment ou description que SQS não é criada nesta story (outra story).

## Formas de teste
1. Executar `terraform validate` em `terraform/30-messaging/` após criar variables.tf (e providers se necessário); validar que não há erro de variável não declarada.
2. Verificar que não existe referência a module.foundation ou remote_state sem caller configurado.
3. Listar variáveis documentadas na story (prefix, common_tags, enable_email_subscription_completed, email_endpoint, enable_lambda_subscription_completed, lambda_subscription_arn) e confirmar que estão declaradas em variables.tf.

## Critérios de aceite da subtask
- [ ] O arquivo `terraform/30-messaging/variables.tf` existe e declara prefix e common_tags (obrigatórios ou com default compatível).
- [ ] Variáveis de subscription (email e Lambda placeholder) estão declaradas com default; nenhuma referência quebrada ao foundation; terraform validate passa.
