# Subtask 01: Variáveis do módulo (password policy, token validity, etc.)

## Descrição
Criar o arquivo `terraform/40-auth/variables.tf` com as variáveis necessárias para o módulo: prefix, common_tags, política de senha parametrizável (password_min_length, password_require_uppercase/lowercase/numbers/symbols), token validity (access_token_validity, refresh_token_validity, id_token_validity) e region (ou uso de data para construir issuer/jwks_url). Garantir que tudo que fizer sentido seja parametrizável, com defaults seguros e sem exagero.

## Passos de implementação
1. Criar `terraform/40-auth/variables.tf` com variáveis obrigatórias ou com default: prefix, common_tags (do foundation).
2. Declarar variáveis de política de senha: password_min_length (number, default = 8), password_require_uppercase (bool, default = true), password_require_lowercase (bool, default = true), password_require_numbers (bool, default = true), password_require_symbols (bool, default = true); incluir description.
3. Declarar variáveis de token: access_token_validity (number, default ex.: 1 em horas), refresh_token_validity (number, default ex.: 30 em dias), id_token_validity (number, default ex.: 1 em horas); token_validity_units no Cognito é "hours" ou "days" — usar variáveis em unidades compatíveis. Incluir description.
4. Declarar region (string, opcional) ou documentar que region será obtida via data.aws_region ou provider para construir issuer e jwks_url.
5. Garantir que nenhuma variável dependa de path absoluto ou módulo interno; defaults seguros (senha não trivial).

## Formas de teste
1. Executar `terraform validate` em `terraform/40-auth/` após criar variables.tf; validar que não há erro de variável não declarada em outros arquivos que referenciem var.password_min_length, etc.
2. Verificar que os defaults da política de senha são seguros (mínimo 8, requisitos true) e que token validity tem valores razoáveis.
3. Listar variáveis documentadas na story (password_*, token_*, region) e confirmar que estão declaradas em variables.tf.

## Critérios de aceite da subtask
- [ ] O arquivo `terraform/40-auth/variables.tf` existe e declara prefix, common_tags, variáveis de password policy e token validity (e region se necessário).
- [ ] Configurações parametrizáveis quando fizer sentido; defaults seguros; nenhuma referência quebrada; terraform validate passa.
