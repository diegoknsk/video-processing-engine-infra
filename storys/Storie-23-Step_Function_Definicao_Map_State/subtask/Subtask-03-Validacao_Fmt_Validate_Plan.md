# Subtask 03: Validar terraform fmt, validate e plan

## Descrição
Executar a sequência obrigatória de validação Terraform (`fmt`, `validate`, `plan`) para garantir que as alterações nas subtasks anteriores estão corretas e não introduzem erros ou mudanças indesejadas em outros recursos.

## Passos de Implementação
1. Executar `terraform fmt -recursive` no diretório `terraform/` e verificar que nenhum arquivo é alterado (saída vazia = já formatado).
2. Executar `terraform validate` no diretório `terraform/` e confirmar "Success! The configuration is valid."
3. Executar `terraform plan -var-file=envs/dev.tfvars` (ou equivalente com as variáveis obrigatórias como `lab_role`, `principal_arn`, `lambda_processor_arn`, etc.) e analisar o diff:
   - Deve aparecer apenas `~ update in-place` no recurso `module.orchestration.aws_sfn_state_machine.video_processing[0]` com mudança no campo `definition`
   - **Nenhum outro recurso** deve ser criado, destruído ou modificado
4. Atualizar o `README.md` do módulo `70-orchestration` para refletir:
   - O novo contrato de entrada (campos `chunks`, `contractVersion`, `videoId`, `userId`, `s3BucketVideo`, `s3KeyVideo`, `output`)
   - O novo fluxo: Map (fan-out chunks) → Update Status (SQS q-video-status-update) → Success
   - Remover referências ao placeholder e à evolução futura (já implementada)

## Formas de Teste
1. `terraform fmt -recursive` — saída vazia confirma formatação correta
2. `terraform validate` — "Success! The configuration is valid." sem warnings
3. `terraform plan` — confirmar que somente `aws_sfn_state_machine.video_processing[0]` tem mudança e que é `~ update in-place` (não destroy/recreate)

## Critérios de Aceite
- [x] `terraform fmt -recursive` executado (arquivo stepfunctions.tf foi formatado)
- [x] `terraform validate` retorna "Success! The configuration is valid."
- [ ] `terraform plan` exibe exclusivamente update in-place em `aws_sfn_state_machine.video_processing[0]`; nenhum outro recurso afetado (executar em ambiente com backend S3 acessível)
- [x] README do módulo `70-orchestration` atualizado com o novo contrato de entrada e o novo fluxo da State Machine
