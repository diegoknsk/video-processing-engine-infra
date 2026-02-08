# Subtask 03: IAM role da SFN com permissões mínimas (Processor + finalização)

## Descrição
Criar a role IAM da State Machine Step Functions no módulo `terraform/70-orchestration` com permissões mínimas: (1) CloudWatch Logs (CreateLogStream, PutLogEvents no log group da SFN); (2) lambda:InvokeFunction na Lambda Video Processor; (3) conforme finalization_mode: quando "sqs", sqs:SendMessage na fila q-video-zip-finalize; quando "lambda", lambda:InvokeFunction na Lambda Video Finalizer. A role deve ser criada apenas quando enable_stepfunctions = true.

## Passos de implementação
1. Criar arquivo `terraform/70-orchestration/iam.tf` com recurso aws_iam_role para a SFN: assume_role_policy permitindo states.amazonaws.com (Step Functions service principal). Condicionar a role a var.enable_stepfunctions (count = var.enable_stepfunctions ? 1 : 0).
2. Criar aws_iam_role_policy (inline ou attached) com: (a) logs:CreateLogStream e logs:PutLogEvents no ARN do log group da SFN (criado na Subtask 02); (b) lambda:InvokeFunction no ARN da Lambda Video Processor (var.lambda_processor_arn); (c) conforme finalization_mode: se "sqs", sqs:SendMessage no ARN da fila q-video-zip-finalize (var.q_video_zip_finalize_arn); se "lambda", lambda:InvokeFunction no ARN da Lambda Video Finalizer (var.lambda_finalizer_arn). Usar dynamic block ou policy condicional para não conceder permissão SQS quando finalization_mode = "lambda" nem Lambda Finalizer quando finalization_mode = "sqs".
3. Garantir que não haja permissões amplas (ex.: lambda:*, sqs:*); apenas os recursos e ações necessários.
4. Documentar em comentário: "Permissões mínimas: SFN invoca Processor; encaminha finalização via SQS ou Lambda conforme finalization_mode."

## Formas de teste
1. Executar `terraform plan` com enable_stepfunctions = true e finalization_mode = "sqs"; verificar que a policy inclui lambda:InvokeFunction (Processor) e sqs:SendMessage (q-video-zip-finalize); não inclui lambda:InvokeFunction para Finalizer.
2. Executar `terraform plan` com finalization_mode = "lambda"; verificar que a policy inclui lambda:InvokeFunction para Processor e para Finalizer; não inclui sqs:SendMessage.
3. Buscar na policy por "lambda:*" ou "sqs:*" e confirmar que não existem; permissões granulares por recurso.

## Critérios de aceite da subtask
- [ ] Em ambiente com permissão IAM: existe aws_iam_role para a SFN com assume_role_policy para states.amazonaws.com; role criada apenas quando enable_stepfunctions = true. **Em AWS Academy:** o módulo usa **lab_role_arn** (role existente); nenhuma role é criada (ver story.md, seção "AWS Academy / Lab Role").
- [ ] A policy da role (ou a Lab Role em Academy) inclui: CloudWatch Logs no log group da SFN; lambda:InvokeFunction na Lambda Video Processor; e conforme finalization_mode: sqs:SendMessage em q-video-zip-finalize ou lambda:InvokeFunction na Lambda Video Finalizer.
- [ ] Nenhuma permissão ampla (lambda:*, sqs:*); terraform validate e plan passam.
