# Subtask-04: Validação terraform plan e comportamento esperado

## Descrição
Validar que após as alterações da Subtask 01, o comportamento do Terraform está correto: (1) primeiro apply continua criando Lambdas com empty.zip; (2) segundo apply (com Lambdas já existentes e, se aplicável, com código real) não propõe alteração no código das funções; (3) alterações em outros atributos (ex.: environment) ainda são aplicadas.

## Passos de Implementação

1. **Executar formatação e validação**
   - `terraform fmt -recursive` no repositório (ou ao menos em `terraform/`).
   - `terraform init` e `terraform validate` no diretório root `terraform/`.

2. **Validar comportamento do plan (quando possível)**
   - Se houver estado remoto com Lambdas já criadas: rodar `terraform plan -var-file=envs/dev.tfvars` e verificar que não há mudanças em `filename` nem `source_code_hash` nos recursos `aws_lambda_function`.
   - Se for ambiente limpo: documentar que o primeiro apply cria as Lambdas com empty.zip e que um segundo apply (após eventual deploy de código por outro meio) não deve mostrar update de código graças ao `ignore_changes`.

3. **Registro**
   - Anotar no story ou nesta subtask o resultado do plan (sem alterações nas Lambdas em cenário de re-apply), ou que a validação foi feita em ambiente sem estado disponível (e o critério fica como verificação em ambiente real).

## Formas de Teste

1. `terraform fmt -recursive` não altera arquivos (ou apenas formatação esperada).
2. `terraform validate` retorna "Success! The configuration is valid."
3. Em ambiente com estado: `terraform plan` não mostra update no pacote das Lambdas; alteração em `environment` em um recurso mostra apenas essa mudança no plan.

## Critérios de Aceite

- [ ] `terraform fmt -recursive` e `terraform validate` executados com sucesso.
- [ ] Quando aplicável (estado com Lambdas existentes): `terraform plan` não indica alteração em `filename` ou `source_code_hash` das Lambdas.
- [ ] Alteração proposital em um atributo não ignorado (ex.: variável de ambiente) aparece no `terraform plan` como mudança esperada.
