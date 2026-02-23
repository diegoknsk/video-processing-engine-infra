# Subtask 01: Remover LambdaVideoDispatcher e seus event source mappings

## Descrição
Remover do módulo `50-lambdas-shell` todos os recursos relacionados à `LambdaVideoDispatcher` criada na Story 18: o recurso `aws_lambda_function.video_dispatcher` em `lambdas.tf`, os recursos `aws_lambda_permission.sqs_invoke_video_dispatcher` e `aws_lambda_event_source_mapping.video_dispatcher_q_video_process` em `event_source_mapping.tf`, e os outputs correspondentes em `outputs.tf`.

## Contexto — recursos a remover

**`lambdas.tf`** — remover o bloco completo:
```hcl
resource "aws_lambda_function" "video_dispatcher" { ... }
```

**`event_source_mapping.tf`** — remover os blocos:
```hcl
resource "aws_lambda_permission" "sqs_invoke_video_dispatcher" { ... }
resource "aws_lambda_event_source_mapping" "video_dispatcher_q_video_process" { ... }
```
Remover também o comentário de seção `# --- q-video-process → LambdaVideoDispatcher (Storie-18) ---`.

**`outputs.tf`** — remover os blocos:
```hcl
output "lambda_video_dispatcher_name" { ... }
output "lambda_video_dispatcher_arn"  { ... }
```

## Passos de implementação

1. Em `terraform/50-lambdas-shell/lambdas.tf`: localizar e remover o bloco `resource "aws_lambda_function" "video_dispatcher"` por completo.

2. Em `terraform/50-lambdas-shell/event_source_mapping.tf`: localizar e remover os blocos `resource "aws_lambda_permission" "sqs_invoke_video_dispatcher"` e `resource "aws_lambda_event_source_mapping" "video_dispatcher_q_video_process"`, incluindo o comentário de seção.

3. Em `terraform/50-lambdas-shell/outputs.tf`: remover os outputs `lambda_video_dispatcher_name` e `lambda_video_dispatcher_arn`.

4. Executar `terraform fmt -recursive` no diretório `terraform/50-lambdas-shell/`.

> **Atenção:** Operação destrutiva. Se o state Terraform tiver esses recursos, o `terraform plan` mostrará `-` (destroy) para cada um deles. Isso é esperado.

## Formas de teste

1. `terraform validate` no módulo `50-lambdas-shell` — confirmar "Success! The configuration is valid." (sem referências ao `video_dispatcher`).
2. `terraform plan` no root — confirmar que o plan mostra `-` destroy para os recursos removidos.
3. Buscar (grep) por `video_dispatcher` nos arquivos do módulo para confirmar que não há referência residual.

## Critérios de aceite

- [ ] `aws_lambda_function.video_dispatcher` ausente de `lambdas.tf`
- [ ] `aws_lambda_permission.sqs_invoke_video_dispatcher` e `aws_lambda_event_source_mapping.video_dispatcher_q_video_process` ausentes de `event_source_mapping.tf`
- [ ] Outputs `lambda_video_dispatcher_name` e `lambda_video_dispatcher_arn` ausentes de `outputs.tf`
- [ ] `terraform validate` no módulo passa sem erros
- [ ] `terraform plan` mostra a destruição dos recursos correspondentes (ou confirma que não existiam no state)
