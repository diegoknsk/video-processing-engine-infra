# Subtask 01: Variáveis modo dev e usuário inicial

## Descrição
Adicionar ao módulo `terraform/40-auth` variáveis para **modo dev** (desabilitar verificação de email e relaxar política de senha) e para **criação de usuário inicial** (email, senha, nome). Todas com defaults seguros; senha marcada como sensível.

## Passos de implementação
1. Em `terraform/40-auth/variables.tf`, adicionar variável **dev_mode** (bool, default = false): quando true, o User Pool usará auto_verified_attributes vazio e política de senha relaxada (valores definidos por variáveis com defaults fracos quando dev_mode = true, ou variáveis dedicadas como password_min_length_dev).
2. Adicionar variável **auto_verified_attributes** (list(string), default = ["email"]): quando dev_mode = true o caller pode passar [] ou o módulo pode usar dynamic/condicional; preferir variável explícita para o User Pool (ex.: default ["email"], e em tfvars de dev passar []).
3. Adicionar variáveis do usuário inicial: **create_initial_user** (bool, default = false), **initial_user_email** (string, default = null), **initial_user_password** (string, default = null, **sensitive = true**), **initial_user_name** (string, default = "Dev User"). Incluir description indicando uso apenas em dev/lab.
4. Garantir que initial_user_password tenha `sensitive = true` no bloco variable; não usar default com valor real (deixar null e exigir via tfvars ou env).
5. Documentar em comment que dev_mode e create_initial_user não devem ser usados em produção.

## Formas de teste
1. Executar `terraform validate` no módulo 40-auth; verificar que novas variáveis não quebram referências existentes.
2. Verificar que initial_user_password está com sensitive = true (não aparece em plan/apply output).
3. Testar com create_initial_user = false e dev_mode = false: plan deve ser idêntico ao comportamento atual.

## Critérios de aceite da subtask
- [ ] Variáveis dev_mode, auto_verified_attributes (ou equivalente), create_initial_user, initial_user_email, initial_user_password (sensitive), initial_user_name existem em variables.tf com descriptions.
- [ ] initial_user_password declarada com sensitive = true; sem default com valor literal de senha.
- [ ] terraform validate passa; documentação/comentário sobre uso apenas em dev.
