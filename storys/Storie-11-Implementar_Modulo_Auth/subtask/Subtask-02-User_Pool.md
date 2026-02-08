# Subtask 02: User Pool com configurações mínimas seguras

## Descrição
Criar o recurso aws_cognito_user_pool no módulo `terraform/40-auth` com nome derivado do prefix, política de senha parametrizável (comprimento mínimo, maiúscula, minúscula, número, símbolo), atributos padrão (name, email) e auto_verified_attributes conforme necessidade do MVP. Configurações mínimas seguras sem exagero (sem MFA obrigatório nesta story; sem Lambda de customização).

## Passos de implementação
1. Criar arquivo `terraform/40-auth/user_pool.tf` com recurso aws_cognito_user_pool: name = "${var.prefix}-user-pool" (ou equivalente), tags = var.common_tags.
2. Configurar bloco password_policy: minimum_length = var.password_min_length, require_lowercase = var.password_require_lowercase, require_uppercase = var.password_require_uppercase, require_numbers = var.password_require_numbers, require_symbols = var.password_require_symbols.
3. Configurar schema: atributos name (required) e email (required ou mutable conforme desenho); ou usar schema padrão do Cognito (name, email, preferred_username). auto_verified_attributes = ["email"] para verificação de e-mail.
4. Não configurar MFA obrigatório nem Lambda triggers nesta story (mínimo para bootstrap); opcionalmente variável enable_mfa para story futura.
5. Documentar em comentário: "Configurações mínimas seguras; política de senha parametrizável."

## Formas de teste
1. Executar `terraform plan` com variáveis preenchidas; verificar que o plano inclui aws_cognito_user_pool com password_policy e schema conforme variáveis.
2. Verificar que password_policy usa var.* e não valores hardcoded; mínimo 8 caracteres e requisitos ativados por default.
3. Confirmar que não há MFA obrigatório nem Lambda; terraform validate e plan passam.

## Critérios de aceite da subtask
- [ ] Existe aws_cognito_user_pool com nome derivado do prefix e tags = var.common_tags.
- [ ] Política de senha está parametrizada (minimum_length, require_uppercase/lowercase/numbers/symbols); configurações mínimas seguras.
- [ ] Schema inclui name e email (ou atributos padrão); auto_verified_attributes configurado; sem exagero (sem MFA obrigatório nesta story); terraform validate e plan passam.
