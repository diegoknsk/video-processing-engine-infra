# Subtask 07: Ajustar variáveis, outputs e root module (main.tf)

## Descrição
Consolidar as remoções de variáveis obsoletas e adicionar os novos outputs da `LambdaUpdateStatusVideo`. Após as subtasks anteriores (remoção do dispatcher, do SNS topic e do mapeamento antigo), este passo garante que `variables.tf` e `main.tf` não contenham referências pendentes, e que `outputs.tf` exponha a nova Lambda.

## Arquivos e ações

| Arquivo | Ação |
|---------|------|
| `terraform/50-lambdas-shell/variables.tf` | Remover `variable "enable_status_update_consumer"` |
| `terraform/variables.tf` (root) | Remover `variable "enable_status_update_consumer"` |
| `terraform/main.tf` | Remover `enable_status_update_consumer = var.enable_status_update_consumer` do bloco `module "lambdas"` |
| `terraform/50-lambdas-shell/outputs.tf` | Adicionar `lambda_update_status_video_name` e `lambda_update_status_video_arn` |

> **Nota:** A remoção de `topic_video_submitted_arn` das variáveis e do `main.tf` já foi coberta na Subtask 03. Este passo trata apenas do que ficou faltando: `enable_status_update_consumer` e os novos outputs.

## Passos de implementação

1. **`terraform/50-lambdas-shell/variables.tf`** — remover o bloco:
   ```hcl
   variable "enable_status_update_consumer" {
     description = "Se true, mapeia LambdaVideoManagement à fila q-video-status-update; se false, consumo futuro."
     type        = bool
     default     = true
   }
   ```

2. **`terraform/variables.tf` (root)** — remover o bloco:
   ```hcl
   variable "enable_status_update_consumer" {
     description = "Mapeia Lambda Video Management à fila q-video-status-update quando true."
     type        = bool
     default     = true
   }
   ```

3. **`terraform/main.tf`** — no bloco `module "lambdas"`, remover:
   ```hcl
   enable_status_update_consumer = var.enable_status_update_consumer
   ```

4. **`terraform/50-lambdas-shell/outputs.tf`** — adicionar ao final:
   ```hcl
   output "lambda_update_status_video_name" {
     description = "Nome da Lambda LambdaUpdateStatusVideo (responsável exclusiva por atualizar status)."
     value       = aws_lambda_function.update_status_video.function_name
   }

   output "lambda_update_status_video_arn" {
     description = "ARN da Lambda LambdaUpdateStatusVideo."
     value       = aws_lambda_function.update_status_video.arn
   }
   ```

5. Executar `terraform fmt -recursive` no diretório `terraform/`.

## Formas de teste

1. `terraform validate` no root — confirmar "Success! The configuration is valid." sem referências pendentes ao `enable_status_update_consumer`.
2. `terraform plan` — confirmar ausência de erros de "undeclared variable" ou "unknown output".
3. Verificar que `lambda_update_status_video_name` e `lambda_update_status_video_arn` aparecem nos outputs do plan.

## Critérios de aceite

- [ ] `variable "enable_status_update_consumer"` removida de `50-lambdas-shell/variables.tf`
- [ ] `variable "enable_status_update_consumer"` removida de `terraform/variables.tf`
- [ ] Linha `enable_status_update_consumer = var.enable_status_update_consumer` removida de `main.tf`
- [ ] Outputs `lambda_update_status_video_name` e `lambda_update_status_video_arn` adicionados em `50-lambdas-shell/outputs.tf`
- [ ] `terraform validate` no root passa sem erros — sem nenhuma referência pendente das variáveis removidas
