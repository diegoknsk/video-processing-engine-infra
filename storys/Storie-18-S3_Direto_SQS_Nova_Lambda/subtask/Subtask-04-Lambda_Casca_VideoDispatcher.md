# Subtask-04: Criar Lambda Casca LambdaVideoDispatcher no Módulo 50-lambdas-shell

## Descrição
Adicionar o recurso `aws_lambda_function.video_dispatcher` no arquivo `terraform/50-lambdas-shell/lambdas.tf`, seguindo o padrão das cinco Lambdas casca existentes (runtime parametrizável, handler placeholder, `artifacts/empty.zip`, `lab_role_arn`). Adicionar variáveis de entrada necessárias em `variables.tf` e output em `outputs.tf`. O log group CloudWatch para esta Lambda deve ser criado pelo módulo `75-observability` (ou adicionado a ele).

---

## Passos de Implementação

1. **Adicionar `aws_lambda_function.video_dispatcher` em `terraform/50-lambdas-shell/lambdas.tf`**

   Seguir o padrão das Lambdas existentes:

   ```hcl
   resource "aws_lambda_function" "video_dispatcher" {
     function_name = "${var.prefix}-video-dispatcher"
     role          = var.lab_role_arn
     runtime       = var.runtime
     handler       = var.handler
     filename      = var.artifact_path
     timeout       = 900

     environment {
       variables = {
         TABLE_NAME              = var.table_name
         VIDEOS_BUCKET           = var.videos_bucket_name
         QUEUE_VIDEO_PROCESS_URL = var.q_video_process_url
       }
     }

     tags = var.common_tags
   }
   ```

   - `function_name`: `${var.prefix}-video-dispatcher` — segue o padrão de nomenclatura `prefix-<papel>`.
   - `role`: `var.lab_role_arn` — AWS Academy; sem criação de IAM Role.
   - `runtime`, `handler`, `filename`: mesmas variáveis compartilhadas pelas demais Lambdas casca.
   - `timeout`: 900 segundos — consistente com as demais Lambdas.
   - **Variáveis de ambiente:** mínimas para o contexto de dispatcher (tabela para registro, bucket para referência, URL da fila para auto-documentação). O código real definirá quais variáveis precisa; aqui é o mínimo necessário.

2. **Adicionar output em `terraform/50-lambdas-shell/outputs.tf`**

   ```hcl
   output "lambda_video_dispatcher_name" {
     description = "Nome da Lambda LambdaVideoDispatcher."
     value       = aws_lambda_function.video_dispatcher.function_name
   }

   output "lambda_video_dispatcher_arn" {
     description = "ARN da Lambda LambdaVideoDispatcher."
     value       = aws_lambda_function.video_dispatcher.arn
   }
   ```

3. **Verificar/adicionar log group CloudWatch para a nova Lambda**

   O módulo `75-observability` (`terraform/75-observability/log_groups.tf`) cria log groups para as Lambdas. Ler o arquivo e adicionar o log group para `video-dispatcher`:

   ```hcl
   resource "aws_cloudwatch_log_group" "lambda_video_dispatcher" {
     name              = "/aws/lambda/${var.prefix}-video-dispatcher"
     retention_in_days = var.log_retention_days
     tags              = var.common_tags
   }
   ```

   Isso garante que o log group exista antes da Lambda ser invocada e que a retenção seja configurada.

4. **Revisar variáveis em `terraform/50-lambdas-shell/variables.tf`**

   As variáveis `table_name`, `videos_bucket_name`, `q_video_process_url` já devem existir (usadas pelas demais Lambdas). Confirmar que estão presentes. Se alguma não existir, adicioná-la com descrição e tipo adequados.

5. **Não criar nem alterar políticas IAM**

   Em AWS Academy, todas as Lambdas usam `lab_role_arn`. Nenhuma policy IAM adicional deve ser criada nesta subtask para a nova Lambda (a permissão de consumo SQS está implícita na Lab Role).

---

## Formas de Teste

1. **`terraform plan`:** Deve mostrar `aws_lambda_function.video_dispatcher` como `+ will be created` com as variáveis de ambiente corretas.
2. **`terraform apply` + verificação no console:** AWS Console → Lambda → procurar por `<prefix>-video-dispatcher` — confirmar criação, runtime, handler placeholder, timeout 900s.
3. **`terraform validate`:** Sem erros de variáveis indefinidas; confirmar que todas as variáveis usadas no bloco estão declaradas em `variables.tf`.
4. **Log group:** AWS Console → CloudWatch → Log groups → `/aws/lambda/<prefix>-video-dispatcher` deve existir após apply.

---

## Critérios de Aceite

- [ ] `aws_lambda_function.video_dispatcher` adicionado em `lambdas.tf` com `function_name = "${var.prefix}-video-dispatcher"`, `lab_role_arn`, runtime/handler/filename parametrizáveis e timeout 900s
- [ ] Variáveis de ambiente mínimas configuradas: `TABLE_NAME`, `VIDEOS_BUCKET`, `QUEUE_VIDEO_PROCESS_URL`
- [ ] Outputs `lambda_video_dispatcher_name` e `lambda_video_dispatcher_arn` adicionados em `outputs.tf`
- [ ] Log group `/aws/lambda/${prefix}-video-dispatcher` criado no módulo `75-observability`
- [ ] `terraform validate` passa sem erros no módulo `50-lambdas-shell`
- [ ] Nenhuma IAM Role ou policy nova criada pelo Terraform (usar `lab_role_arn`)
