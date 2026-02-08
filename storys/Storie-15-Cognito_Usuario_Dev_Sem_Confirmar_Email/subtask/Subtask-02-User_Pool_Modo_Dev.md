# Subtask 02: Ajustar User Pool para modo dev (auto_verified e password policy)

## Descrição
Alterar `terraform/40-auth/user_pool.tf` para usar **auto_verified_attributes** parametrizável (lista vazia em dev = sem confirmar email) e política de senha que aceite valores relaxados quando em modo dev (comprimento mínimo menor, símbolos/uppercase opcionais), sem quebrar o comportamento atual quando dev_mode = false.

## Passos de implementação
1. No recurso aws_cognito_user_pool.main, trocar `auto_verified_attributes = ["email"]` por `auto_verified_attributes = var.auto_verified_attributes` (ou por um local que seja [] quando dev_mode = true e ["email"] quando false). Garantir que em dev o valor seja [] para não exigir confirmação de email.
2. Manter password_policy usando as variáveis existentes (password_min_length, password_require_*). Opção A: adicionar variáveis alternativas para dev (ex.: password_min_length_dev) e usar coalesce ou condicional; Opção B: o caller passa em tfvars para dev valores relaxados (password_min_length = 6, password_require_symbols = false, etc.). Preferir Opção B para não duplicar variáveis — documentar na story que em dev o caller deve passar policy relaxada.
3. Garantir que com auto_verified_attributes = [] o login por email funcione sem verificação; account_recovery_setting pode permanecer com verified_email (recuperação ainda por email, sem envio de verificação obrigatória no sign-up).
4. Executar terraform plan com dev_mode/auto_verified_attributes e password policy de dev nos tfvars; verificar que o plano altera apenas o esperado.
5. Comentar no user_pool.tf: "Em dev, use auto_verified_attributes = [] e policy relaxada para usuário sem confirmar email."

## Formas de teste
1. terraform plan com auto_verified_attributes = [] e password_min_length = 6 (e demais require_* = false) em tfvars: plano deve mostrar user pool com esses valores.
2. terraform plan com auto_verified_attributes = ["email"] e policy padrão: comportamento igual ao atual (Storie-11).
3. terraform validate passa.

## Critérios de aceite da subtask
- [ ] User Pool usa auto_verified_attributes parametrizável (lista); com lista vazia não exige confirmação de email.
- [ ] Política de senha continua parametrizada pelas variáveis existentes; em dev o caller pode passar valores relaxados (ex.: min 6, require_symbols = false).
- [ ] terraform validate e plan passam; comentário no código sobre uso em dev.
