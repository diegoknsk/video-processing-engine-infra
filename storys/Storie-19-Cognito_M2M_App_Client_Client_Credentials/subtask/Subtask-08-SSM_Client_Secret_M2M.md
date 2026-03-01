# Subtask-08: Expor client_secret do App Client M2M em SSM Parameter Store (SecureString)

## Descrição
Criar um parâmetro no **AWS Systems Manager Parameter Store** do tipo **SecureString** com o **client_secret** do App Client M2M, para que as Lambdas do projeto (ex.: faculdade) possam obter o secret em runtime via `ssm:GetParameter` e usar no fluxo OAuth2 client_credentials.

> **Atenção (segurança):** Gravar o secret no SSM via Terraform faz com que o valor conste no **state** do Terraform. Para **ambiente acadêmico/projetinho** isso é aceitável para simplificar; em **produção** o ideal é não criar este recurso pelo Terraform (manter `m2m_expose_credentials_in_ssm = false`) e gravar o secret no SSM fora do Terraform (ex.: pipeline ou script único após o primeiro apply). Esta subtask deixa explícito o trade-off.

---

## Passos de Implementação

1. **Variável de controle:** `m2m_expose_credentials_in_ssm` (bool, default = true para uso acadêmico). Quando true, Terraform cria os parâmetros SSM de client_id (Subtask-07) e client_secret (esta subtask).

2. **Criar recurso `aws_ssm_parameter` para o client_secret:**
   - Nome: `/${var.prefix}/cognito-m2m-client-secret` (ex.: `/video-processing-engine-dev/cognito-m2m-client-secret`).
   - Tipo: `SecureString` (criptografia KMS).
   - Valor: `aws_cognito_user_pool_client.m2m[0].client_secret`.
   - Condicionado a `var.enable_m2m_client && var.m2m_expose_credentials_in_ssm`.

3. **Output (opcional):** Nome do parâmetro SSM do secret para as Lambdas (ex.: output `cognito_m2m_client_secret_ssm_parameter_name`), alinhado ao placeholder `m2m_secret_ssm_parameter_name` já documentado.

4. **README:** Deixar claro que em prod recomenda-se `m2m_expose_credentials_in_ssm = false` e gravar o secret no SSM manualmente/pipeline.

---

## Formas de Teste

1. Com `enable_m2m_client = true` e `m2m_expose_credentials_in_ssm = true`, `terraform apply` cria o parâmetro SSM SecureString.
2. Lambda (ou script) com permissão `ssm:GetParameter` consegue ler o valor e obter o token via POST no token endpoint.
3. Com `m2m_expose_credentials_in_ssm = false`, o parâmetro do secret não é criado.

---

## Critérios de Aceite

- [ ] Parâmetro SSM SecureString criado com o client_secret quando feature flag habilitada.
- [ ] Path documentado para as Lambdas (ex.: `/${prefix}/cognito-m2m-client-secret`); variável `m2m_secret_ssm_parameter_name` ou output referenciável.
- [ ] Documentação deixa explícito o uso para ambiente acadêmico e a recomendação para produção.
- [ ] `terraform validate` e `terraform plan` passam.
