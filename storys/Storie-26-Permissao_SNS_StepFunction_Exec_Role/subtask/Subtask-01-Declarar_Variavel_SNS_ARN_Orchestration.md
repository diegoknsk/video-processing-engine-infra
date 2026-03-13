# Subtask-01: Declarar variável topic_video_processing_error_arn no módulo 70-orchestration

## Descrição
Declarar a variável `topic_video_processing_error_arn` em `terraform/70-orchestration/variables.tf`.
A variável já é referenciada no `stepfunctions.tf` via `templatefile`, mas não está declarada — isso causa erro no `terraform validate`.

## Arquivo afetado
`terraform/70-orchestration/variables.tf`

## Passos de implementação

1. Abrir `terraform/70-orchestration/variables.tf`.
2. Adicionar ao final do arquivo, na seção de integração com outputs dos módulos, o bloco:
   ```hcl
   variable "topic_video_processing_error_arn" {
     description = "ARN do tópico SNS topic-video-processing-error (output do módulo 30-messaging); usado pela State Machine para publicar erros."
     type        = string
   }
   ```
3. Não adicionar `default = null` — a variável é obrigatória; se não for passada, o `terraform plan` deve falhar com mensagem clara.
4. Executar `terraform validate` no diretório `terraform/70-orchestration` para confirmar que a variável é reconhecida.

## Formas de teste

1. Executar `terraform validate` em `terraform/70-orchestration` — deve retornar "The configuration is valid."
2. Executar `terraform plan` na raiz sem passar a variável — deve retornar erro de variável obrigatória ausente (confirma que é required).
3. Verificar que o `stepfunctions.tf` não apresenta mais erro de variável indefinida no `templatefile`.

## Critérios de aceite

- [ ] Variável `topic_video_processing_error_arn` declarada em `variables.tf` com `type = string` e sem `default`.
- [ ] `terraform validate` no módulo `70-orchestration` retorna "The configuration is valid."
- [ ] Nenhum outro arquivo do módulo alterado nesta subtask.
