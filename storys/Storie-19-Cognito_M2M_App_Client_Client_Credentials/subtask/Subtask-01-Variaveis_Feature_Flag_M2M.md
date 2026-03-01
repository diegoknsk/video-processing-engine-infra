# Subtask-01: Variáveis e feature flag para M2M (40-auth e root)

## Descrição
Introduzir as variáveis necessárias no módulo `40-auth` e, se aplicável, no root para habilitar de forma parametrizada o App Client M2M e o Resource Server. Inclui feature flag (ex.: `enable_m2m_client`) para permitir ativar/desativar os recursos M2M sem remover código, e variáveis para identifier do Resource Server, lista de scopes e nome do parâmetro SSM onde o client_secret será armazenado (placeholder para as Lambdas).

> **Escopo:** Apenas declaração de variáveis e repasse; nenhum recurso Cognito ainda criado.

---

## Passos de Implementação

1. **No módulo `terraform/40-auth/variables.tf`:**
   - Adicionar `variable "enable_m2m_client"` (type = bool, default = true, description: habilita criação do App Client M2M e do Resource Server).
   - Adicionar `variable "m2m_resource_server_identifier"` (type = string, description: identifier do Resource Server, ex.: "video-processing-engine"; default pode ser derivado do prefix ou fixo).
   - Adicionar `variable "m2m_scopes"` (type = list(object({ name = string, description = string })), default com `analyze:run` e `videos:update_status` com descrições curtas).
   - Adicionar `variable "m2m_secret_ssm_parameter_name"` (type = string, default = null, description: path do SSM Parameter Store onde o pipeline/operador gravará o client_secret; placeholder para documentação e uso pelas Lambdas).

2. **No root `terraform/variables.tf` (se o controle for no root):**
   - Adicionar `variable "enable_m2m_client"` (type = bool, default = true) se a decisão for centralizar no root.
   - Ou repassar ao module.auth a variável já existente no 40-auth; garantir que `main.tf` passe `enable_m2m_client` (e demais) para `module "auth"`.

3. **Em `terraform/main.tf`:**
   - Na chamada `module "auth"`, adicionar os parâmetros: `enable_m2m_client = var.enable_m2m_client` (se existir no root), `m2m_resource_server_identifier`, `m2m_scopes`, `m2m_secret_ssm_parameter_name` conforme definido no módulo.

4. **Validar:** Executar `terraform validate` no root; garantir que não há variáveis obrigatórias sem default que quebrem o plan em ambiente existente.

---

## Formas de Teste

1. **`terraform validate`** no diretório root: deve retornar "Success! The configuration is valid."
2. **`terraform plan`** com variáveis padrão: não deve falhar por variável inexistente; os recursos M2M ainda não existem (Subtask-02 a 05).
3. Revisão manual de `variables.tf` (40-auth e root): todas as variáveis M2M documentadas com description e type corretos.

---

## Critérios de Aceite

- [ ] Variáveis `enable_m2m_client`, `m2m_resource_server_identifier`, `m2m_scopes` e `m2m_secret_ssm_parameter_name` existem no módulo 40-auth com tipos e descrições adequados
- [ ] Root repassa ao `module.auth` as variáveis M2M (ou usa defaults no módulo sem repasse)
- [ ] `terraform validate` e `terraform plan` (sem apply) executam sem erro
- [ ] Nenhum recurso existente do 40-auth é alterado ou removido por esta subtask
