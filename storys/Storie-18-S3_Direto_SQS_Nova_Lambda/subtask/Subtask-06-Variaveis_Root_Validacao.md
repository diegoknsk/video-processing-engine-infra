# Subtask-06: Ajustar Variáveis, Root Module (main.tf) e Validação Terraform

## Descrição
Consolidar todos os ajustes de variáveis no root e nos módulos afetados, atualizar o `terraform/main.tf` para passar os novos outputs/variáveis necessários ao módulo `50-lambdas-shell`, e executar a validação completa (`terraform fmt`, `terraform validate`, `terraform plan`) para garantir que o estado do código é válido e pronto para apply.

---

## Passos de Implementação

1. **Ajustar passagem de variáveis no `terraform/main.tf` para o módulo `lambdas`**

   Verificar o bloco `module "lambdas"` em `main.tf` e confirmar/adicionar os seguintes pontos:

   - O módulo já recebe `q_video_process_url` e `q_video_process_arn` de `module.messaging` — confirmar que continuam passados (não foram removidos por engano na Subtask-01).
   - **Nenhuma variável nova é necessária para o novo lambda** além das já existentes; todas são compartilhadas (prefix, common_tags, lab_role_arn, table_name, videos_bucket_name, q_video_process_url).

2. **Verificar e remover referências obsoletas de `trigger_mode` em `main.tf`**

   Após a Subtask-01, o `module.storage` e `module.messaging` podem ainda ter `trigger_mode = var.trigger_mode` sendo passado. Se a variável `trigger_mode` foi removida de `variables.tf`:
   - Remover `trigger_mode = var.trigger_mode` do bloco `module "storage"` em `main.tf`.
   - Remover `trigger_mode = var.trigger_mode` do bloco `module "messaging"` em `main.tf`.
   - Remover `topic_video_submitted_arn = null` do bloco `module "storage"` se não mais necessário.
   - Remover `videos_bucket_arn = null` do bloco `module "messaging"` se não mais necessário.

3. **Verificar módulos `10-storage` e `30-messaging` quanto a variáveis orphans**

   - `terraform/10-storage/variables.tf`: verificar se `trigger_mode` e `topic_video_submitted_arn` ainda estão declarados. Se não são mais usados no módulo (após Subtask-01 remover os recursos SNS do root, o módulo em si nunca criou esses recursos), avaliar se devem ser removidos ou mantidos com comentário de "legado/não utilizado".
   - `terraform/30-messaging/variables.tf`: verificar `trigger_mode` e `videos_bucket_arn`. Mesma avaliação.
   - **Regra:** Variáveis declaradas mas não usadas geram warnings no Terraform; remover ou justificar com comentário.

4. **Executar `terraform fmt -recursive` no root**

   ```powershell
   cd terraform
   terraform fmt -recursive
   ```

   Confirmar que nenhum arquivo foi formatado (se já estavam formatados) ou que os arquivos alterados foram formatados corretamente.

5. **Executar `terraform validate` no root**

   ```powershell
   terraform validate
   ```

   Deve retornar: `Success! The configuration is valid.`

   Se retornar erros:
   - `Reference to undeclared variable`: variável usada mas não declarada — adicionar em `variables.tf` do módulo correspondente.
   - `An argument named "X" is not expected here`: variável passada ao módulo mas não declarada no módulo — remover do `main.tf` ou adicionar ao módulo.
   - `The root module output value is set to an unknown value`: output usando referência a recurso removido — remover o output correspondente.

6. **Executar `terraform plan` com variáveis de ambiente ou tfvars**

   ```powershell
   terraform plan -var="lab_role_arn=arn:aws:iam::ACCOUNT_ID:role/LabRole" -var="owner=dev"
   ```

   Revisar o plan cuidadosamente:
   - Recursos a criar: `aws_sqs_queue_policy`, `aws_s3_bucket_notification`, `aws_lambda_function.video_dispatcher`, `aws_lambda_permission.sqs_invoke_video_dispatcher`, `aws_lambda_event_source_mapping.video_dispatcher_q_video_process`, log group da nova Lambda.
   - Recursos a destruir: `aws_s3_bucket_notification.videos_to_sns` (se existia), `aws_sns_topic_policy.topic_video_submitted_s3` (se existia), `aws_lambda_permission.sqs_invoke_orchestrator`, `aws_lambda_event_source_mapping.orchestrator_q_video_process`.
   - Nenhum recurso não esperado deve aparecer como alterado ou destruído.

---

## Formas de Teste

1. **`terraform fmt -recursive` sem saída:** Se o comando não produz output (ou lista apenas arquivos alterados pela formatação), os arquivos estão corretos.
2. **`terraform validate` retorna sucesso:** "Success! The configuration is valid." — sem erros.
3. **`terraform plan` sem surpresas:** Revisar o plan linha a linha; confirmar que somente os recursos esperados aparecem como criados/destruídos.
4. **Checklist de arquivos alterados:** Confirmar que apenas os arquivos listados no Escopo Técnico da story foram modificados; nenhum arquivo fora do escopo deve aparecer como alterado.

---

## Critérios de Aceite

- [ ] `terraform/main.tf` atualizado: referências a `trigger_mode` e variáveis SNS obsoletas removidas dos módulos `storage` e `messaging`
- [ ] Variáveis orphans (`trigger_mode`, `videos_bucket_arn` de módulos se não usadas) removidas ou comentadas com justificativa
- [ ] `terraform fmt -recursive` executado e sem diferenças de formatação pendentes
- [ ] `terraform validate` retorna "Success! The configuration is valid." em todos os módulos alterados
- [ ] `terraform plan` lista **somente** os recursos esperados como criados/destruídos — sem surpresas
- [ ] Nenhum recurso fora do escopo desta story aparece como alterado no plan
- [ ] Nenhuma credencial, ARN hardcoded ou valor sensível introduzido nos arquivos `.tf` alterados
