# Subtask 05: Outputs (lambda names, ARNs, role ARNs) e documentação de permissões

## Descrição
Criar ou atualizar `terraform/50-lambdas-shell/outputs.tf` expondo os nomes e ARNs das 5 Lambdas e os ARNs das 5 roles IAM. Documentar no README do módulo a tabela de permissões por Lambda e a justificativa (least privilege), para que a story cumpra o critério de listar e justificar permissões.

## Passos de implementação
1. Criar `terraform/50-lambdas-shell/outputs.tf` com outputs para cada Lambda: function_name e function_arn (ex.: lambda_auth_name, lambda_auth_arn; lambda_video_management_name, lambda_video_management_arn; idem para orchestrator, processor, finalizer). Adicionar outputs para as roles: lambda_auth_role_arn, lambda_video_management_role_arn, lambda_video_orchestrator_role_arn, lambda_video_processor_role_arn, lambda_video_finalizer_role_arn. Garantir que os outputs referenciem apenas recursos existentes no módulo.
2. Criar ou atualizar `terraform/50-lambdas-shell/README.md` com seção "Permissões por Lambda (Least Privilege)": incluir tabela (ou lista) com cada Lambda e as permissões concedidas (CloudWatch Logs; S3 com bucket e ações; DynamoDB com tabela e ações; SQS com fila e ações; SNS com tópico e Publish; Step Functions StartExecution quando aplicável) e a justificativa em uma linha por Lambda (ex.: "Orchestrator: consome q-video-process e inicia Step Functions; não acessa S3/DynamoDB").
3. Incluir referência ao desenho (contexto arquitetural) e aos event source mappings (Orchestrator ← q-video-process, Finalizer ← q-video-zip-finalize, VideoManagement ← q-video-status-update quando habilitado).
4. Verificar que nenhum output referencia recursos inexistentes; terraform plan deve listar os outputs sem erro.

## Formas de teste
1. Executar `terraform plan` em 50-lambdas-shell e verificar que os outputs (lambda names, ARNs, role ARNs) aparecem no plano sem erro.
2. Ler o README e confirmar que a tabela (ou lista) de permissões por Lambda e a justificativa (least privilege) estão presentes.
3. Confirmar que os 5 nomes de Lambda, 5 ARNs de Lambda e 5 ARNs de role estão expostos nos outputs.

## Critérios de aceite da subtask
- [ ] outputs.tf expõe lambda names e ARNs das 5 funções e role ARNs das 5 roles; terraform plan lista os outputs sem referências quebradas.
- [ ] README documenta as permissões por Lambda e justifica (least privilege) conforme tabela da story.
- [ ] Referência ao desenho e aos event source mappings; documentação suficiente para revisão de segurança e onboarding.
