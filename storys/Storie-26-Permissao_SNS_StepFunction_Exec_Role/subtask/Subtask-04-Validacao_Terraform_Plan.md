# Subtask-04: Validar terraform fmt, validate e plano de execução

## Descrição
Executar a sequência de validação obrigatória (`fmt`, `validate`, `plan`) para garantir que as alterações das subtasks anteriores estão corretas, sem regressões, e prontas para `apply`.

## Passos de implementação

1. Executar `terraform fmt -recursive` na raiz do diretório `terraform/`:
   ```bash
   cd terraform
   terraform fmt -recursive
   ```
   Não deve haver diff residual (todos os arquivos já formatados).

2. Executar `terraform validate`:
   ```bash
   terraform validate
   ```
   Deve retornar: `Success! The configuration is valid.`

3. Executar `terraform plan` com as credenciais AWS configuradas:
   ```bash
   terraform plan
   ```
   Verificar no output:
   - `~ module.orchestration.aws_iam_role_policy.sfn_exec[0]` → `update in-place` (adição do statement SNSPublishError).
   - Nenhum outro recurso com `destroy` ou `replace`.
   - Plan deve finalizar com algo como `1 to change, 0 to destroy`.

4. (Opcional) Executar `terraform apply` e validar execução real da State Machine:
   - Disparar uma execução que force o caminho de erro (ex.: payload inválido).
   - Verificar nos logs do CloudWatch que o estado de Catch conseguiu publicar no SNS sem erro 403.
   - Confirmar que a execução finaliza com `Fail` após publicar no SNS e atualizar o SQS.

## Formas de teste

1. `terraform fmt -recursive` — saída vazia (sem arquivos reformatados).
2. `terraform validate` — retorna "The configuration is valid."
3. `terraform plan` — apenas `aws_iam_role_policy.sfn_exec[0]` com mudança; 0 destruições.
4. Após `apply`: execução da State Machine com erro → SNS publica sem erro 403 → CloudWatch Logs confirma.

## Critérios de aceite

- [ ] `terraform fmt -recursive` não produz diff (nenhum arquivo reformatado).
- [ ] `terraform validate` retorna "The configuration is valid." sem warnings.
- [ ] `terraform plan` mostra exatamente 1 recurso a ser atualizado (`aws_iam_role_policy.sfn_exec[0]`) e 0 destruições.
- [ ] Após `terraform apply`, execução real da State Machine que cai no `Catch` publica no SNS sem erro 403.
- [ ] CloudWatch Logs da Step Function confirma transição bem-sucedida pelo caminho de erro (SNS → SQS → Fail).
- [ ] Nenhum ARN hardcoded nos arquivos `.tf`; sempre via variável.
