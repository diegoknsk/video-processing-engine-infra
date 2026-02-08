# Subtask 03: Criar usuário inicial via admin (null_resource + AWS CLI)

## Descrição
Criar em `terraform/40-auth/initial_user.tf` um recurso que provisiona um usuário no User Pool quando create_initial_user = true, usando AWS CLI (admin-create-user com message-action SUPPRESS e email_verified=true; em seguida admin-set-user-password com --permanent), para que o usuário fique CONFIRMED e com senha permanente, sem precisar confirmar email.

## Passos de implementação
1. Criar arquivo `terraform/40-auth/initial_user.tf`. Usar **null_resource** com provisioner local-exec (ou múltiplos local-exec em ordem).
2. Condição: criar o recurso apenas quando create_initial_user = true e initial_user_email e initial_user_password não são null (count ou conditional resource).
3. Primeiro comando: `aws cognito-idp admin-create-user` com --user-pool-id = aws_cognito_user_pool.main.id, --username = var.initial_user_email, --user-attributes Name=email_verified,Value=true Name=name,Value=var.initial_user_name, --message-action SUPPRESS, --temporary-password = var.initial_user_password (evita envio de email). Região: usar var.region ou data.aws_region.
4. Segundo comando: `aws cognito-idp admin-set-user-password` com --user-pool-id, --username, --password = var.initial_user_password, --permanent. Assim o usuário não fica em FORCE_CHANGE_PASSWORD.
5. Triggers do null_resource: incluir user_pool_id e, se possível, um hash do email (não da senha) para recriar apenas quando pool ou usuário mudar; evitar trigger na senha em texto para não expor. Quando o usuário já existir, admin-create-user falha — usar || true ou verificar existência antes (opcional: idempotência com aws cognito-idp admin-get-user; se existir, só admin-set-user-password se necessário).
6. Garantir que variáveis sensíveis (initial_user_password) não sejam impressas no log: Terraform já trata sensitive; no comando não usar echo da senha.

## Formas de teste
1. Após apply com create_initial_user = true e tfvars com email/senha válidos, listar usuários: `aws cognito-idp list-users --user-pool-id <id>` — deve listar o usuário com status CONFIRMED.
2. Testar login (InitiateAuth ou AdminInitiateAuth com USER_PASSWORD) com client_id do App Client e email/senha do usuário inicial — deve retornar tokens.
3. Apply com create_initial_user = false: null_resource não deve ser criado; plan sem initial_user.tf resources.

## Critérios de aceite da subtask
- [ ] Existe initial_user.tf com null_resource (ou equivalente) que executa admin-create-user (SUPPRESS, email_verified=true) e admin-set-user-password (permanent).
- [ ] Recurso só é criado quando create_initial_user = true e email/senha fornecidos; usuário fica CONFIRMED e com senha permanente.
- [ ] Login com o usuário criado retorna JWT; senha não aparece em outputs nem em log; terraform validate passa.
