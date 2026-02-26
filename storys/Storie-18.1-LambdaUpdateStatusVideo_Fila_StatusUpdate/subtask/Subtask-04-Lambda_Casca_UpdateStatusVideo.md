# Subtask 04: Criar Lambda casca LambdaUpdateStatusVideo

## Descrição
Adicionar o recurso `aws_lambda_function.update_status_video` no arquivo `terraform/50-lambdas-shell/lambdas.tf`. Esta Lambda tem responsabilidade única e exclusiva: atualizar o status de vídeos no DynamoDB quando receber uma mensagem da fila `q-video-status-update`. O nome da função no AWS será `${var.prefix}-update-status-video`.

## Passos de implementação

1. Em `terraform/50-lambdas-shell/lambdas.tf`, adicionar o bloco ao final do arquivo (após o `video_finalizer` — o `video_dispatcher` já foi removido na Subtask 01):

```hcl
resource "aws_lambda_function" "update_status_video" {
  function_name = "${var.prefix}-update-status-video"
  role          = var.lab_role_arn
  runtime       = var.runtime
  handler       = var.handler
  filename      = var.artifact_path
  timeout       = 900

  environment {
    variables = {
      TABLE_NAME              = var.table_name
      QUEUE_STATUS_UPDATE_URL = var.q_video_status_update_url
    }
  }

  tags = var.common_tags
}
```

2. Verificar que as variáveis utilizadas (`table_name`, `q_video_status_update_url`, `lab_role_arn`, `runtime`, `handler`, `artifact_path`, `common_tags`) já existem em `variables.tf` — não criar duplicatas.

3. Executar `terraform fmt -recursive` no diretório `terraform/50-lambdas-shell/`.

> **Responsabilidade explícita:** O nome `update-status-video` deixa claro que esta Lambda **apenas atualiza status** — não orquestra, não processa frames, não cria zip.

## Formas de teste

1. `terraform validate` no módulo `50-lambdas-shell` — confirmar "Success! The configuration is valid."
2. `terraform plan` — confirmar que o plan mostra `+ aws_lambda_function.update_status_video` com `function_name = "video-processing-engine-dev-update-status-video"` (ou o prefixo do ambiente).
3. Verificar que as variáveis de ambiente configuradas (`TABLE_NAME`, `QUEUE_STATUS_UPDATE_URL`) são suficientes para o único propósito da função: atualizar status.

## Critérios de aceite

- [ ] `aws_lambda_function.update_status_video` adicionado em `lambdas.tf` com `function_name = "${var.prefix}-update-status-video"`
- [ ] Role é `var.lab_role_arn` (nenhuma IAM Role nova criada)
- [ ] Variáveis de ambiente apenas as necessárias para atualização de status (`TABLE_NAME`, `QUEUE_STATUS_UPDATE_URL`)
- [ ] Nenhuma variável duplicada criada — todas as vars referenciadas já existem em `variables.tf`
- [ ] `terraform validate` passa sem erros
