# Subtask 08: Validação Terraform (fmt, validate, plan)

## Descrição
Executar a sequência de validação obrigatória (`terraform fmt -recursive`, `terraform validate`, `terraform plan`) nos módulos alterados pela story (`30-messaging`, `50-lambdas-shell` e root), confirmando que todas as mudanças são válidas, os recursos corretos aparecem no plan e nenhuma credencial está hardcoded.

## Resumo do que deve aparecer no terraform plan

| Recurso | Ação esperada |
|---------|--------------|
| `aws_lambda_function.video_dispatcher` | `-` destroy |
| `aws_lambda_permission.sqs_invoke_video_dispatcher` | `-` destroy |
| `aws_lambda_event_source_mapping.video_dispatcher_q_video_process` | `-` destroy |
| `aws_sns_topic.topic_video_submitted` | `-` destroy |
| `aws_lambda_permission.sqs_invoke_video_management[0]` | `-` destroy |
| `aws_lambda_event_source_mapping.video_management_q_video_status_update[0]` | `-` destroy |
| `aws_lambda_function.update_status_video` | `+` create |
| `aws_lambda_permission.sqs_invoke_update_status_video` | `+` create |
| `aws_lambda_event_source_mapping.update_status_video_q_video_status_update` | `+` create |
| `aws_lambda_permission.sqs_invoke_orchestrator` | `+` create |
| `aws_lambda_event_source_mapping.orchestrator_q_video_process` | `+` create |

> Recursos marcados como destroy podem aparecer como "no-op" se nunca foram deployados no state.

## Passos de implementação

1. No diretório `terraform/30-messaging/`, executar:
   ```bash
   terraform fmt -recursive
   terraform validate
   ```

2. No diretório `terraform/50-lambdas-shell/`, executar:
   ```bash
   terraform fmt -recursive
   terraform validate
   ```

3. No diretório `terraform/` (root), executar:
   ```bash
   terraform fmt -recursive
   terraform validate
   terraform plan -var-file="terraform.tfvars"
   ```

4. Revisar o output do `terraform plan`:
   - Confirmar os recursos criados e destruídos conforme tabela acima.
   - Confirmar ausência de erros de variáveis não declaradas (`enable_status_update_consumer`, `topic_video_submitted_arn`).
   - Confirmar que `topic-video-completed` e suas subscriptions **não aparecem como alterados**.
   - Confirmar que `upload_integration.tf` (S3 → SQS) **não aparece como alterado**.

5. Inspecionar o plan e confirmar:
   - Nenhum ARN de Lab Role hardcoded.
   - Nenhuma credencial ou valor sensível exposto.
   - Nomes de recursos seguem o padrão `${prefix}-*`.

## Formas de teste

1. `terraform fmt -recursive` sem diff (arquivos já formatados).
2. `terraform validate` retorna "Success! The configuration is valid." em todos os módulos.
3. `terraform plan` exibe exatamente os recursos esperados na tabela acima, sem warnings de deprecação.

## Critérios de aceite

- [ ] `terraform fmt -recursive` executado sem erros em `30-messaging/`, `50-lambdas-shell/` e root
- [ ] `terraform validate` retorna "Success! The configuration is valid." nos três módulos
- [ ] `terraform plan` lista os 5 recursos novos como `+ create` e os 6 recursos obsoletos como `- destroy` (ou confirma que não estavam no state)
- [ ] Nenhum erro de variável não declarada (`enable_status_update_consumer` e `topic_video_submitted_arn` removidas sem referências pendentes)
- [ ] `topic-video-completed`, subscriptions e `upload_integration.tf` não aparecem como alterados no plan
- [ ] Nenhuma credencial ou ARN hardcoded detectado nos arquivos modificados
