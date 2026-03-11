# Subtask 01: Adicionar variável q_video_status_update_url e passar no root

## Descrição
Adicionar a variável `q_video_status_update_url` no módulo `70-orchestration` e conectá-la ao root `main.tf`, consumindo o output `q_video_status_update_url` já existente no módulo `30-messaging`.

## Passos de Implementação
1. Em `terraform/70-orchestration/variables.tf`, adicionar variável:
   ```hcl
   variable "q_video_status_update_url" {
     description = "URL da fila SQS q-video-status-update (para SendMessage na State Machine após processamento dos chunks)."
     type        = string
   }
   ```
2. Em `terraform/main.tf`, no bloco `module "orchestration"`, adicionar o argumento:
   ```hcl
   q_video_status_update_url = module.messaging.q_video_status_update_url
   ```
3. Verificar que `module.messaging.q_video_status_update_url` existe em `terraform/30-messaging/outputs.tf` (já confirmado: output `q_video_status_update_url` retorna `aws_sqs_queue.q_video_status_update.url`).

## Formas de Teste
1. Executar `terraform validate` no diretório `terraform/` — deve retornar "Success!" sem erro de variável não declarada
2. Executar `terraform plan` e confirmar que não há erro de tipo ou referência ao `module.messaging.q_video_status_update_url`
3. Verificar no plano que o módulo `orchestration` recebe o argumento `q_video_status_update_url` sem warnings

## Critérios de Aceite
- [x] Variável `q_video_status_update_url` declarada em `terraform/70-orchestration/variables.tf` com `type = string` e `description` clara
- [x] Argumento `q_video_status_update_url = module.messaging.q_video_status_update_url` presente no bloco `module "orchestration"` em `terraform/main.tf`
- [x] `terraform validate` passa sem erros após a adição
