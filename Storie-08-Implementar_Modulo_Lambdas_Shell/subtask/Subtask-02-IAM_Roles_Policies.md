# Subtask 02: IAM roles e políticas por Lambda (least privilege)

## Descrição
Criar uma role IAM por Lambda (5 roles) e políticas mínimas (least privilege) para cada uma: CloudWatch Logs (CreateLogStream, PutLogEvents); acesso mínimo a S3 (por bucket e ação conforme tabela da story); acesso mínimo a DynamoDB (PutItem, GetItem, UpdateItem na tabela de vídeos quando aplicável); acesso a SQS (ReceiveMessage, DeleteMessage, GetQueueAttributes ou SendMessage conforme papel); acesso a SNS (Publish nos tópicos necessários) e Step Functions (StartExecution para Orchestrator). Nenhuma política ampla (s3:*, dynamodb:*); cada política justificada pelo papel da Lambda no desenho.

## Passos de implementação
1. Criar arquivo `terraform/50-lambdas-shell/iam.tf` (ou um arquivo por Lambda) com 5 recursos aws_iam_role (lambda_auth_role, lambda_video_management_role, lambda_video_orchestrator_role, lambda_video_processor_role, lambda_video_finalizer_role), cada uma com assume_role_policy permitindo lambda.amazonaws.com.
2. Para cada Lambda, criar aws_iam_role_policy (inline ou attached) com: (a) CloudWatch Logs (logs:CreateLogStream, logs:PutLogEvents no log group da função); (b) S3, DynamoDB, SQS, SNS, Step Functions conforme tabela da story — apenas os recursos e ações necessários (ex.: s3:GetObject no bucket videos para Processor, s3:PutObject no bucket images; dynamodb:UpdateItem na table para Processor e Finalizer).
3. Garantir que LambdaAuth tenha apenas logs (e opcionalmente Cognito se documentado); VideoManagement tenha logs, S3 videos, DynamoDB table, SQS q-video-status-update se consumer, SNS topic-video-submitted; Orchestrator logs, SQS q-video-process, Step Functions StartExecution; Processor logs, S3 videos/images, DynamoDB, SQS SendMessage para status-update e zip-finalize; Finalizer logs, S3 images/zip, DynamoDB, SQS q-video-zip-finalize, SNS topic-video-completed.
4. Documentar em comentário no código ou README a justificativa (least privilege) por Lambda; nenhuma política com "*" em Action para s3 ou dynamodb.

## Formas de teste
1. Buscar em `terraform/50-lambdas-shell/*.tf` por "s3:*" e "dynamodb:*" e confirmar que não existem; políticas devem ser granulares.
2. Verificar que cada uma das 5 Lambdas tem exatamente uma role e que as políticas referenciam apenas os recursos necessários (ARNs dos buckets, table, filas, tópicos, state machine).
3. Executar `terraform plan` com variáveis preenchidas e verificar que as 5 roles e políticas são criadas sem erro.

## Critérios de aceite da subtask
- [ ] Existem 5 aws_iam_role (uma por Lambda) com assume_role_policy para lambda.amazonaws.com.
- [ ] Cada Lambda tem políticas IAM mínimas: CloudWatch Logs; S3/DynamoDB/SQS/SNS/StepFunctions conforme tabela da story (least privilege); nenhuma política s3:* ou dynamodb:*.
- [ ] Justificativa (least privilege) documentada no código ou README por Lambda; terraform validate e plan passam.
