# Subtask 04: Documentação e segurança (README, sensitive)

## Descrição
Atualizar o README do módulo 40-auth e garantir que nenhuma credencial (senha do usuário inicial) seja exposta em outputs ou documentação versionada. Documentar como usar modo dev e usuário inicial em ambiente de lab/dev.

## Passos de implementação
1. Em `terraform/40-auth/README.md`, adicionar seção **Modo dev e usuário inicial**: quando usar dev_mode e create_initial_user; que auto_verified_attributes = [] dispensa confirmação de email; que a senha do usuário inicial deve ser passada via tfvars (nunca commitada) ou variável de ambiente (TF_VAR_initial_user_password).
2. Documentar exemplo de tfvars para dev (sem valores reais de senha): create_initial_user = true, initial_user_email = "dev@example.com", initial_user_name = "Dev User"; initial_user_password deve ser definido fora do repositório.
3. Garantir que outputs.tf **não** exponha initial_user_email nem initial_user_password; opcionalmente documentar no README que o "usuário de dev" é o valor passado em initial_user_email (sem repetir a senha).
4. Revisar que variável initial_user_password permanece sensitive = true e que em pipelines de CI não se usa create_initial_user com senha em plaintext no código.
5. Mencionar que em produção dev_mode e create_initial_user devem ser false; usuários criados por fluxo normal (sign-up ou IdP).

## Formas de teste
1. Ler README e confirmar que não há senha nem token em exemplos; apenas placeholders ou "definir fora do repo".
2. Executar terraform output no root após apply: nenhum output deve mostrar email ou senha do usuário inicial.
3. Verificar que variables.tf e initial_user.tf não contêm valores literais de senha.

## Critérios de aceite da subtask
- [ ] README do 40-auth descreve modo dev (auto_verified_attributes, policy relaxada) e usuário inicial (create_initial_user, variáveis, onde definir senha).
- [ ] Nenhum output expõe initial_user_password nem initial_user_email (ou apenas email se for requisito explícito, sem senha).
- [ ] Documentação deixa claro que senha e dados sensíveis não devem ser commitados; uso em produção não deve usar create_initial_user/dev_mode.
