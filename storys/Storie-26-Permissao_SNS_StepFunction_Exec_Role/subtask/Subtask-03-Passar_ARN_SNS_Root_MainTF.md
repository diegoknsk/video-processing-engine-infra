# Subtask-03: Passar ARN do SNS do root main.tf ao módulo orchestration

## Descrição
Adicionar o argumento `topic_video_processing_error_arn` na invocação do módulo `orchestration` em `terraform/main.tf`, passando o valor do output `module.messaging.topic_video_processing_error_arn`.

## Arquivo afetado
`terraform/main.tf`

## Contexto atual
O bloco `module "orchestration"` em `terraform/main.tf` não passa o ARN do SNS ao módulo `70-orchestration`. O output `topic_video_processing_error_arn` já existe em `terraform/30-messaging/outputs.tf`.

## Passos de implementação

1. Abrir `terraform/main.tf`.
2. Localizar o bloco `module "orchestration" { ... }`.
3. Adicionar a linha abaixo dos argumentos existentes de SQS (`q_video_status_update_url`):
   ```hcl
   topic_video_processing_error_arn = module.messaging.topic_video_processing_error_arn
   ```
4. Garantir que a linha fica alinhada com os demais argumentos do bloco (indentação com 2 espaços).
5. Não alterar nenhum outro bloco de módulo no arquivo.

## Formas de teste

1. Executar `terraform validate` na raiz — deve retornar "The configuration is valid."
2. Executar `terraform plan` — deve mostrar no diff apenas a atualização da policy `sfn_exec` do módulo orchestration; nenhum outro recurso deve ser afetado.
3. Verificar que `module.messaging.topic_video_processing_error_arn` resolve corretamente para o ARN do tópico SNS no output do `plan`.

## Critérios de aceite

- [ ] Argumento `topic_video_processing_error_arn = module.messaging.topic_video_processing_error_arn` adicionado ao bloco `module "orchestration"` em `terraform/main.tf`.
- [ ] Nenhum outro bloco de módulo alterado.
- [ ] `terraform validate` na raiz retorna "The configuration is valid."
- [ ] `terraform plan` resolve o ARN do SNS corretamente (sem erro de variável indefinida).
