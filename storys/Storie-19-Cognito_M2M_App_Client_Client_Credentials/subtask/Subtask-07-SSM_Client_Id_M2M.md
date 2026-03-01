# Subtask-07: Expor client_id do App Client M2M em SSM Parameter Store

## Descrição
Criar um parâmetro no **AWS Systems Manager Parameter Store** com o **client_id** do App Client M2M, para que Lambdas e scripts do projeto (ex.: faculdade) possam obter o valor em runtime via `ssm:GetParameter`, sem depender de output do Terraform ou variável de ambiente manual.

> **Contexto:** Uso em ambiente acadêmico/projetinho. Em produção, avaliar se o client_id em SSM é necessário (ele não é tão sensível quanto o secret, mas ainda assim é dado de configuração).

---

## Passos de Implementação

1. **Variável de controle (opcional):** Usar a mesma flag da Subtask-08 (`m2m_expose_credentials_in_ssm`) para criar os parâmetros SSM de client_id e client_secret apenas quando desejado (default `true` para facilitar o uso no projetinho).

2. **Criar recurso `aws_ssm_parameter` para o client_id:**
   - Nome sugerido: `/${var.prefix}/cognito-m2m-client-id` (ex.: `/video-processing-engine-dev/cognito-m2m-client-id`).
   - Tipo: `String`.
   - Valor: `aws_cognito_user_pool_client.m2m[0].id`.
   - Condicionado a `var.enable_m2m_client && var.m2m_expose_credentials_in_ssm` (count ou condicional).

3. **Output (opcional):** Expor o nome do parâmetro SSM do client_id para as Lambdas saberem qual path ler (ex.: output `cognito_m2m_client_id_ssm_parameter_name`).

4. **Documentar no README:** Path do parâmetro e que em prod pode-se desativar com `m2m_expose_credentials_in_ssm = false`.

---

## Formas de Teste

1. Com `enable_m2m_client = true` e `m2m_expose_credentials_in_ssm = true`, `terraform apply` deve criar o parâmetro SSM.
2. Após apply, verificar no console SSM Parameter Store (ou via AWS CLI `aws ssm get-parameter --name "/video-processing-engine-dev/cognito-m2m-client-id"`) que o valor corresponde ao client_id do App Client M2M.
3. Com `m2m_expose_credentials_in_ssm = false`, o parâmetro não deve ser criado.

---

## Critérios de Aceite

- [ ] Parâmetro SSM criado com o client_id do App Client M2M quando feature flag habilitada.
- [ ] Path documentado (ex.: `/${prefix}/cognito-m2m-client-id`) para as Lambdas consumirem.
- [ ] `terraform validate` e `terraform plan` passam; nenhum recurso existente quebrado.
