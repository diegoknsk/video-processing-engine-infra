# Subtask 01: Outputs Cognito no outputs.tf do root

## Descrição
Adicionar ao arquivo `terraform/outputs.tf` uma seção dedicada aos outputs do módulo 40-auth (Cognito), reexportando user_pool_id, client_id, issuer e jwks_url com nomes claros para consumo na raiz (cognito_user_pool_id, cognito_client_id, cognito_issuer, cognito_jwks_url). Manter o mesmo padrão de descrição e comentário usado nas demais seções (Foundation, Storage, Data, API).

## Passos de implementação
1. Abrir `terraform/outputs.tf` e localizar o final do arquivo (após a seção API Gateway — Storie-10).
2. Inserir comentário de seção: `# --- Auth (Cognito — Storie-11) ---`.
3. Adicionar quatro blocos `output`:
   - `cognito_user_pool_id` → `value = module.auth.user_pool_id`; description indicando ID do User Pool.
   - `cognito_client_id` → `value = module.auth.client_id`; description indicando ID do App Client (audience do JWT).
   - `cognito_issuer` → `value = module.auth.issuer`; description indicando URL do issuer para JWT authorizer.
   - `cognito_jwks_url` → `value = module.auth.jwks_url`; description indicando URL do JWKS (referência ou uso custom).
4. Garantir que a indentação e o estilo (description + value) sigam o padrão dos outputs existentes no mesmo arquivo.

## Formas de teste
1. No diretório `terraform/`, executar `terraform validate` e confirmar que a configuração é válida.
2. Executar `terraform plan -var-file=envs/dev.tfvars` e verificar que a seção "Outputs" do plano inclui os quatro novos outputs sem referência a módulo inexistente.
3. Se o state já tiver o módulo auth aplicado, executar `terraform output` e conferir que os valores de cognito_* aparecem.

## Critérios de aceite da subtask
- [x] terraform/outputs.tf contém a seção "Auth (Cognito)" com os quatro outputs (cognito_user_pool_id, cognito_client_id, cognito_issuer, cognito_jwks_url).
- [x] Cada output referencia o módulo auth corretamente (module.auth.user_pool_id, etc.).
- [x] terraform validate no root retorna "Success! The configuration is valid."
- [x] Nenhuma credencial ou dado sensível nos outputs (apenas IDs e URLs públicas do Cognito).
