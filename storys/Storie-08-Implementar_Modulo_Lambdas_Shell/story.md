# Storie-08: Implementar Módulo Terraform 50-Lambdas-Shell

## Status
- **Estado:** ✅ Concluída
- **Data de Conclusão:** 05/02/2026

## Rastreamento (dev tracking)
- **Início:** dia 05/02/2026, às 14:00 (Brasília)
- **Fim:** dia 05/02/2026, às 15:45 (Brasília)
- **Tempo total de desenvolvimento:** 1h 45min

## Descrição
Como desenvolvedor de infraestrutura, quero que o módulo `terraform/50-lambdas-shell` provisione as cinco Lambdas "casca" do Processador Video MVP (Auth, VideoManagement, VideoOrchestrator, VideoProcessor, VideoFinalizer) com runtime parametrizável, handler placeholder, artefato `artifacts/empty.zip`, IAM separado por função (least privilege), variáveis de ambiente por Lambda e event source mappings alinhados ao desenho, para que os repositórios de aplicação possam fazer deploy do código depois sem alterar a infra base.

## Objetivo
Criar o módulo `terraform/50-lambdas-shell` com cinco funções Lambda em casca: **LambdaAuth**, **LambdaVideoManagement**, **LambdaVideoOrchestrator**, **LambdaVideoProcessor**, **LambdaVideoFinalizer**. Requisitos: runtime parametrizável (default seguro), handler placeholder, uso de `artifacts/empty.zip`; IAM separado por função (least privilege): CloudWatch Logs, acesso mínimo a S3/DynamoDB/SQS/SNS/StepFunctions conforme o papel de cada Lambda; variáveis de ambiente por Lambda (table, buckets, queue urls, topic arns, stepfunction arn); event source mappings: Orchestrator acionada por SQS q-video-process, Finalizer acionada por SQS q-video-zip-finalize, e estratégia para q-video-status-update (preferir mapear Lambda consumer, ex.: VideoManagement). Outputs: lambda names, ARNs e role ARNs. A story lista e justifica as permissões por Lambda (least privilege).

## Escopo Técnico
- Tecnologias: Terraform >= 1.0, AWS Provider (~> 5.0)
- Arquivos afetados:
  - `terraform/50-lambdas-shell/variables.tf` (prefix, common_tags, runtime, handler, artifact path; ARNs/URLs de table, buckets, queues, topics, stepfunction)
  - `terraform/50-lambdas-shell/lambdas.tf` ou um arquivo por Lambda (aws_lambda_function, aws_iam_role, aws_iam_role_policy)
  - `terraform/50-lambdas-shell/event_source_mapping.tf` (aws_lambda_event_source_mapping para SQS)
  - `terraform/50-lambdas-shell/outputs.tf`
  - `terraform/50-lambdas-shell/README.md` (permissões por Lambda e justificativa)
- Componentes/Recursos: 5x aws_lambda_function, 5x aws_iam_role, políticas IAM por função (CloudWatch, S3, DynamoDB, SQS, SNS, Step Functions conforme necessidade), event_source_mapping para Orchestrator (q-video-process) e Finalizer (q-video-zip-finalize) e, conforme estratégia, para q-video-status-update (ex.: VideoManagement).
- Pacotes/Dependências: Nenhum; consumo de prefix/common_tags e de outputs dos módulos storage (bucket ARNs), data (table name/ARN), messaging (queue URLs/ARNs, topic ARNs); Step Function ARN (módulo 70-orchestration, pode ser variável placeholder).

## Dependências e Riscos (para estimativa)
- Dependências: Storie-02 (foundation), Storie-03 (storage), Storie-04 (data), Storie-05 e Storie-06 (messaging SNS/SQS); Storie de Step Functions (70-orchestration) desejável para stepfunction_arn, ou variável placeholder.
- Riscos/Pré-condições: Políticas IAM devem ser mínimas; event source mapping exige permissão da fila SQS para invocar a Lambda (resource-based policy na Lambda ou queue policy). Artefato `artifacts/empty.zip` deve existir (Storie-01).

## Modelo de execução (root único)
O diretório `terraform/50-lambdas-shell/` é um **módulo** consumido pelo **root** em `terraform/` (Storie-02-Parte2). O root passa prefix, common_tags e outputs dos módulos storage, data, messaging e orchestration. Init/plan/apply são executados uma vez em `terraform/`; validar com `terraform plan` no root.

---

## Permissões por Lambda (Least Privilege)

| Lambda | CloudWatch Logs | S3 | DynamoDB | SQS | SNS | Step Functions | Justificativa (least privilege) |
|--------|-----------------|-----|----------|-----|-----|----------------|----------------------------------|
| **LambdaAuth** | ✅ CreateLogStream, PutLogEvents | — | — (ou leitura Cognito/user se necessário) | — | — | — | Apenas logs para observabilidade; autenticação via Cognito/API Gateway; sem acesso a dados de vídeo. |
| **LambdaVideoManagement** | ✅ | ✅ videos: PutObject, GetObject | ✅ PutItem, GetItem, UpdateItem (tabela vídeos) | ✅ q-video-status-update: ReceiveMessage, DeleteMessage, GetQueueAttributes (se consumer) | ✅ topic-video-submitted: Publish (api_publish) | — | API: cria registro, gera presigned URL (S3 videos); opcionalmente publica no SNS. Se consumer de q-video-status-update: atualiza status no DynamoDB a partir da fila. |
| **LambdaVideoOrchestrator** | ✅ | — | — | ✅ q-video-process: ReceiveMessage, DeleteMessage, GetQueueAttributes | — | ✅ StartExecution | Consome q-video-process e inicia Step Functions; não acessa S3/DynamoDB. |
| **LambdaVideoProcessor** | ✅ | ✅ videos: GetObject; images: PutObject | ✅ UpdateItem (tabela vídeos, status) | ✅ q-video-status-update: SendMessage; q-video-zip-finalize: SendMessage | — | — | Invocada pela Step Function: lê vídeo do S3, grava frames no S3 images, atualiza status, envia mensagens para status-update e zip-finalize. |
| **LambdaVideoFinalizer** | ✅ | ✅ images: GetObject; zip: PutObject | ✅ UpdateItem (ZipS3Key, status) | ✅ q-video-zip-finalize: ReceiveMessage, DeleteMessage, GetQueueAttributes | ✅ topic-video-completed: Publish | — | Consome q-video-zip-finalize: lê imagens, gera zip, grava no S3 zip, atualiza DynamoDB, publica no SNS completed. |

- **Princípio:** Cada função recebe apenas as permissões necessárias para seu papel no desenho; nenhuma política ampla (ex.: s3:* ou dynamodb:*).
- **Event source mapping:** A fila SQS precisa poder invocar a Lambda (permission na Lambda via aws_lambda_permission para sqs.amazonaws.com); o módulo deve criar essa permissão quando houver event source mapping.

---

## Variáveis de Ambiente por Lambda

| Lambda | Variáveis de ambiente (exemplos) |
|--------|----------------------------------|
| **LambdaAuth** | LOG_LEVEL, COGNITO_USER_POOL_ID (se aplicável) |
| **LambdaVideoManagement** | TABLE_NAME, VIDEOS_BUCKET, TOPIC_VIDEO_SUBMITTED_ARN, QUEUE_STATUS_UPDATE_URL (se consumer) |
| **LambdaVideoOrchestrator** | QUEUE_VIDEO_PROCESS_URL, STEP_FUNCTION_ARN |
| **LambdaVideoProcessor** | TABLE_NAME, VIDEOS_BUCKET, IMAGES_BUCKET, QUEUE_STATUS_UPDATE_URL, QUEUE_ZIP_FINALIZE_URL |
| **LambdaVideoFinalizer** | TABLE_NAME, IMAGES_BUCKET, ZIP_BUCKET, TOPIC_VIDEO_COMPLETED_ARN |

Todas recebem valores via variáveis do módulo (outputs de storage, data, messaging, orchestration).

---

## Event Source Mappings (alinhado ao desenho)

| Fila SQS | Lambda acionada | Justificativa |
|----------|-----------------|---------------|
| **q-video-process** | LambdaVideoOrchestrator | Desenho: mensagem de vídeo enviado → orquestrador inicia Step Functions. |
| **q-video-zip-finalize** | LambdaVideoFinalizer | Desenho: sinal de conclusão → finalizador gera zip e publica SNS completed. |
| **q-video-status-update** | LambdaVideoManagement (estratégia preferida) | Uma Lambda já exposta à API e que atualiza DynamoDB pode consumir a fila de status e atualizar o registro; evita nova Lambda. Alternativa: documentar consumo futuro e não mapear. **Preferir mapear** VideoManagement se fizer sentido (mesma Lambda que cria registro e pode atualizar status). |

- Implementar event source mappings para q-video-process → Orchestrator e q-video-zip-finalize → Finalizer.
- Para q-video-status-update: implementar mapeamento para LambdaVideoManagement (consumer de status update) ou documentar "a ser consumido depois" conforme variável/flag (ex.: enable_status_update_consumer); **critério:** preferir já mapear se fizer sentido (VideoManagement com acesso a DynamoDB e sem dependência de Step Functions).

---

## Variáveis do Módulo
- **prefix**, **common_tags**: do foundation.
- **runtime** (string, default ex.: "python3.12" ou "nodejs20.x"): runtime parametrizável; default seguro e suportado.
- **handler** (string, default ex.: "index.handler"): placeholder; aplicação substitui no deploy.
- **artifact_path** (string, default "artifacts/empty.zip"): caminho do zip da casca.
- **table_name**, **table_arn**: DynamoDB (módulo data).
- **videos_bucket_name**, **images_bucket_name**, **zip_bucket_name** (ou ARNs): módulo storage.
- **q_video_process_url**, **q_video_status_update_url**, **q_video_zip_finalize_url**: módulo messaging.
- **topic_video_submitted_arn**, **topic_video_completed_arn**: módulo messaging SNS.
- **step_function_arn**: módulo 70-orchestration (ou placeholder).
- **enable_status_update_consumer** (bool, opcional): se true, mapeia LambdaVideoManagement a q-video-status-update; se false, apenas documenta consumo futuro.
- **lab_role_arn** (string, obrigatório em AWS Academy): ARN da role existente (Lab Role) usada por todas as Lambdas quando o executor do Terraform não tem iam:CreateRole. O root repassa var.lab_role_arn.

## AWS Academy / Lab Role
Em ambiente **AWS Academy** o usuário não tem permissão `iam:CreateRole`. O módulo foi adaptado para usar uma **role existente** (Lab Role) informada em **lab_role_arn**: todas as cinco Lambdas usam essa mesma role. A Lab Role deve ter trust policy permitindo `lambda.amazonaws.com` e as permissões necessárias (CloudWatch Logs, S3, DynamoDB, SQS, SNS, Step Functions conforme cada função). Sem `lab_role_arn` o apply falha; definir no root (ex.: em `envs/dev.tfvars`) com o ARN da Lab Role (ex.: `arn:aws:iam::ACCOUNT_ID:role/LabRole`).

## Decisões Técnicas
- **Casca:** Lambdas criadas com empty.zip e handler placeholder; código real em repositórios de aplicação e deploy via pipeline.
- **IAM:** Em ambiente com permissão IAM: uma role por Lambda com políticas mínimas. Em **AWS Academy**: uso de **lab_role_arn** (uma role existente para todas as Lambdas); nenhuma criação de role nem policy no Terraform.
- **Event source:** aws_lambda_event_source_mapping para SQS; aws_lambda_permission para permitir que SQS invoque a Lambda.
- **Variáveis de ambiente:** Injetadas por Terraform (var.*); sem segredos em texto plano (usar referência a Secret Manager ou variável de pipeline em story futura se necessário).

## Subtasks
- [x] [Subtask 01: Variáveis do módulo e consumo de outputs (table, buckets, queues, topics, stepfunction)](./subtask/Subtask-01-Variaveis_Outputs_Consumo.md)
- [x] [Subtask 02: IAM roles e políticas por Lambda (least privilege)](./subtask/Subtask-02-IAM_Roles_Policies.md)
- [x] [Subtask 03: Recursos Lambda (casca) com runtime, handler, empty.zip e env vars](./subtask/Subtask-03-Lambdas_Casca_Env.md)
- [x] [Subtask 04: Event source mappings (Orchestrator, Finalizer, status-update)](./subtask/Subtask-04-Event_Source_Mappings.md)
- [x] [Subtask 05: Outputs (lambda names, ARNs, role ARNs) e documentação de permissões](./subtask/Subtask-05-Outputs_Documentacao.md)

## Critérios de Aceite da História
- [ ] O módulo `terraform/50-lambdas-shell` cria cinco Lambdas (Auth, VideoManagement, VideoOrchestrator, VideoProcessor, VideoFinalizer) com runtime parametrizável (default seguro), handler placeholder e artefato `artifacts/empty.zip`
- [ ] IAM: em ambiente padrão, role por Lambda com políticas mínimas; em **AWS Academy**, todas as Lambdas usam **lab_role_arn** (role existente) e nenhuma role é criada pelo Terraform
- [ ] Variáveis de ambiente por Lambda incluem table, buckets, queue urls, topic arns e stepfunction arn conforme necessidade de cada uma
- [ ] Event source mappings implementados: Orchestrator acionada por SQS q-video-process; Finalizer acionada por SQS q-video-zip-finalize; estratégia para q-video-status-update definida e implementada (preferir mapear LambdaVideoManagement) ou documentada
- [ ] Outputs expõem lambda names, lambda ARNs e role ARNs (em Academy, role ARN = lab_role_arn)
- [ ] A story lista as permissões por Lambda e justifica (least privilege) na tabela e no README
- [ ] Consumo de prefix/common_tags e dos outputs dos módulos storage, data, messaging (e orchestration quando existir); terraform plan sem referências quebradas

## Checklist de Conclusão
- [ ] Cinco Lambdas criadas com empty.zip e handler placeholder; nenhuma policy IAM ampla (s3:*, dynamodb:*)
- [ ] Event source mappings para q-video-process e q-video-zip-finalize; estratégia q-video-status-update implementada ou documentada
- [ ] README com tabela de permissões por Lambda e justificativa (least privilege)
- [ ] terraform init, validate e plan com variáveis fornecidas passam
