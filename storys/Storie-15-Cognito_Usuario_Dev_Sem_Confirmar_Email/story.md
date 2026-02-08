# Storie-15: Cognito usuário dev (senha simples, sem confirmar email)

## Status
- **Estado:** 🔄 Em desenvolvimento
- **Data de Conclusão:** [DD/MM/AAAA]

## Rastreamento (dev tracking)
- **Início:** dia 08/02/2026, às 16:05 (Brasília)
- **Fim:** —
- **Tempo total de desenvolvimento:** —

## Descrição
Como desenvolvedor, quero que o Cognito permita um usuário de desenvolvimento com senha simples e sem exigir confirmação de email, para conseguir fazer login e testar a API logo após recriar a infra, sem depender de email ou políticas de senha rígidas.

## Objetivo
Configurar o módulo `40-auth` para **modo dev**: (1) User Pool sem verificação de email (`auto_verified_attributes` vazio ou parametrizável) e política de senha relaxada (comprimento mínimo menor, requisitos opcionais); (2) **criar um usuário inicial** via Terraform (AWS CLI em `null_resource`) com email e senha definidos em variáveis, já **CONFIRMED** e com senha permanente, para uso imediato em dev.

## Escopo Técnico
- Tecnologias: Terraform >= 1.0, AWS Provider (~> 5.0), AWS CLI (cognito-idp)
- Arquivos afetados:
  - `terraform/40-auth/variables.tf` (novas variáveis: dev_mode, auto_verified_attributes, initial_user_email, initial_user_password, initial_user_name; defaults de password policy para dev)
  - `terraform/40-auth/user_pool.tf` (uso de auto_verified_attributes e policy conforme variáveis)
  - `terraform/40-auth/initial_user.tf` (novo: null_resource + local-exec com admin-create-user e admin-set-user-password)
  - `terraform/40-auth/README.md` (documentar modo dev e usuário inicial; não expor senha)
- Componentes/Recursos: variáveis de modo dev e usuário inicial; aws_cognito_user_pool ajustado; null_resource com AWS CLI para criar e confirmar usuário.
- Pacotes/Dependências: Nenhum; AWS CLI já disponível no ambiente de execução do Terraform.

## Dependências e Riscos (para estimativa)
- Dependências: Storie-11 (módulo 40-auth) concluída; User Pool e App Client já existentes.
- Riscos/Pré-condições: Variável de senha do usuário inicial deve ser sensível (sensitive = true) e nunca commitada; uso apenas em dev/lab. Em produção, não habilitar modo dev nem usuário inicial; criar usuários por outro fluxo (ex.: sign-up ou IdP).

## Decisões Técnicas
- **Modo dev:** Variável `dev_mode` (bool, default false). Quando true: `auto_verified_attributes = []`, política de senha com defaults relaxados (ex.: min 6 caracteres, símbolos opcionais). Quando false: manter comportamento atual (email verificado, política mais rígida).
- **Usuário inicial:** Variáveis `create_initial_user` (bool), `initial_user_email`, `initial_user_password` (sensitive), `initial_user_name`. Recurso `null_resource` com `triggers` em user_pool_id e email/senha (via hash ou similar para não expor). Comandos: `aws cognito-idp admin-create-user --user-pool-id ... --username <email> --user-attributes Name=email_verified,Value=true Name=name,Value="..." --message-action SUPPRESS --temporary-password <temp>`; em seguida `aws cognito-idp admin-set-user-password --user-pool-id ... --username <email> --password <senha_permanente> --permanent`. Senha temporária e permanente podem ser iguais em dev (ex.: "Dev123!") para evitar troca.
- **Simplicidade:** Uma senha única atendendo à policy relaxada do pool (ex.: "Dev123!" ou "Senha123"); sem MFA; sem confirmação de email.

## Subtasks
- [x] [Subtask 01: Variáveis modo dev e usuário inicial](./subtask/Subtask-01-Variaveis_Modo_Dev_Usuario_Inicial.md)
- [x] [Subtask 02: Ajustar User Pool para modo dev (auto_verified e password policy)](./subtask/Subtask-02-User_Pool_Modo_Dev.md)
- [x] [Subtask 03: Criar usuário inicial via admin (null_resource + AWS CLI)](./subtask/Subtask-03-Usuario_Inicial_Admin_CLI.md)
- [x] [Subtask 04: Documentação e segurança (README, sensitive)](./subtask/Subtask-04-Documentacao_Seguranca.md)

## Critérios de Aceite da História
- [x] Com `auto_verified_attributes = []` (e variáveis de dev nos tfvars), o User Pool é criado sem exigir confirmação de email; política de senha relaxada via auth_password_min_length e auth_password_require_symbols no root.
- [x] Com `create_initial_user = true` e email/senha/nome preenchidos, o apply cria um usuário no pool (admin-create-user + admin-set-user-password permanente), sem envio de email e com status CONFIRMED.
- [x] O usuário criado consegue fazer login (InitiateAuth/AdminInitiateAuth com USER_PASSWORD ou SRP) usando o client_id do App Client e obter tokens JWT.
- [x] A senha do usuário inicial não aparece em outputs nem em logs do Terraform (variável sensível); README documenta uso do modo dev e do usuário inicial sem expor credenciais.
- [x] Com `auth_create_initial_user = false` e defaults, o comportamento do módulo permanece igual ao atual (Storie-11); terraform validate e plan passam.
