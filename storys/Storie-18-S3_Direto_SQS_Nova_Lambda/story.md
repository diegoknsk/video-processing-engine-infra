# Storie-18: S3 Direto para SQS e Nova Lambda Dispatcher

## Status
- **Estado:** 🔄 Em desenvolvimento
- **Data de Conclusão:** [DD/MM/AAAA]

## Rastreamento (dev tracking)
- **Início:** dia 22/02/2025 (Brasília) — horário a confirmar pelo usuário
- **Fim:** —
- **Tempo total de desenvolvimento:** —

## Descrição
Como engenheiro de infraestrutura, quero remover o SNS do fluxo de upload de vídeos e conectar o bucket S3 diretamente à fila SQS `q-video-process` com filtro de prefixo/sufixo, e criar uma nova Lambda casca `LambdaVideoDispatcher` para consumir essa fila, para simplificar o pipeline de entrada, reduzir latência e custo, e garantir rastreabilidade fim a fim do objeto S3 (bucket + key completos) até o consumer.

## Objetivo
Refatorar o fluxo de entrada do pipeline de processamento de vídeo: (1) remover os recursos SNS envolvidos no evento de upload (`aws_s3_bucket_notification → SNS` e `aws_sns_topic_policy` associada); (2) criar notificação S3 → SQS direta com filtros `prefix = "videos/"` e `suffix = "original"`, eventos `ObjectCreated:Put` e `ObjectCreated:CompleteMultipartUpload`; (3) criar a IAM policy na fila `q-video-process` permitindo que o bucket S3 videos publique com `Condition: aws:SourceArn`; (4) criar a Lambda casca `LambdaVideoDispatcher` (função, role, log group, event source mapping); (5) migrar o event source mapping de `q-video-process` para a nova Lambda, garantindo que o mapeamento antigo seja removido.

---

## Sugestão de Nome para a Nova Lambda (item D)

### Nome proposto pelo requisito
`LambdaUpdateStatusVideo`

### Análise das 3 melhores opções

| Opção | Prós | Contras |
|-------|------|---------|
| **`LambdaVideoDispatcher`** | Segue padrão `Lambda + Video + [Papel]`; "Dispatcher" descreve com precisão receber evento S3 e despachar o pipeline | — |
| `LambdaVideoIngestor` | Segue padrão; comunica entrada de dados | "Ingestor" remete a ETL/dados, pode confundir |
| `LambdaVideoTrigger` | Segue padrão; intuitivo | "Trigger" é termo nativo AWS para recursos, gera ambiguidade |

### ✅ Recomendação: `LambdaVideoDispatcher`

> **Justificativa (2 linhas):**
> Segue o padrão `Lambda + Video + [Papel]` idêntico às funções existentes (`LambdaVideoOrchestrator`, `LambdaVideoProcessor`, `LambdaVideoFinalizer`), mantendo consistência imediata no módulo `50-lambdas-shell`.
> "Dispatcher" reflete com precisão a responsabilidade da função: receber o evento S3 da fila `q-video-process` e despachar (iniciar) o pipeline de processamento — sem ser confundido com "trigger" (conceito AWS) nem com "update status" (papel do `LambdaVideoManagement`).

---

## Contexto: Fluxo Atual vs Fluxo Novo

### Fluxo atual (a ser removido/alterado)
```
Upload S3 (bucket videos)
  → aws_s3_bucket_notification → SNS topic-video-submitted
  → [SQS subscription — nunca implementada em infra]
  → q-video-process
  → LambdaVideoManagement (event source mapping)
```

> **Nota:** O arquivo `terraform/50-lambdas-shell/event_source_mapping.tf` atualmente contém um mapeamento `q-video-process → LambdaVideoOrchestrator`. O estado deployado pode divergir do código. Esta story define que **o mapeamento ativo na fila `q-video-process` deve ser removido** (independente de qual Lambda o consumia) e substituído pelo novo mapeamento para `LambdaVideoDispatcher`.

### Fluxo novo (a ser implementado)
```
Upload S3 (bucket videos, prefix "videos/", suffix "original")
  → aws_s3_bucket_notification → SQS q-video-process (direto)
  → LambdaVideoDispatcher (novo event source mapping)
```

---

## Escopo Técnico

- **Tecnologias:** Terraform >= 1.0, AWS Provider (~> 6.0)
- **Arquivos afetados:**
  - `terraform/upload_integration.tf` — remover recursos SNS; adicionar `aws_s3_bucket_notification` (S3 → SQS) e `aws_sqs_queue_policy` (permite S3 publicar na fila)
  - `terraform/30-messaging/sqs.tf` — sem alteração nos recursos de fila; policy na fila adicionada no root (`upload_integration.tf`)
  - `terraform/30-messaging/variables.tf` — verificar/remover variáveis `trigger_mode` e `videos_bucket_arn` se não usadas pelo módulo; ou manter e deixar de usar
  - `terraform/30-messaging/outputs.tf` — garantir que `q_video_process_arn` está exposto (já existente)
  - `terraform/50-lambdas-shell/lambdas.tf` — adicionar `aws_lambda_function.video_dispatcher`
  - `terraform/50-lambdas-shell/event_source_mapping.tf` — remover mapeamento antigo de `q-video-process`; adicionar novo para `LambdaVideoDispatcher`
  - `terraform/50-lambdas-shell/variables.tf` — adicionar variáveis necessárias para a nova Lambda
  - `terraform/50-lambdas-shell/outputs.tf` — adicionar outputs da nova Lambda
  - `terraform/variables.tf` — ajustar/remover `trigger_mode` se obsoleto; adicionar novas variáveis se necessário
  - `terraform/main.tf` — ajustar passagem de variáveis para os módulos afetados
- **Componentes/Recursos criados/modificados:**
  - `aws_s3_bucket_notification.videos_to_sqs` (novo — S3 → SQS, com filtro)
  - `aws_sqs_queue_policy.q_video_process_allow_s3` (novo — SQS policy com Condition SourceArn)
  - `aws_lambda_function.video_dispatcher` (novo — casca)
  - `aws_lambda_event_source_mapping.video_dispatcher_q_video_process` (novo)
  - `aws_lambda_permission.sqs_invoke_video_dispatcher` (novo)
  - `aws_s3_bucket_notification.videos_to_sns` (removido)
  - `aws_sns_topic_policy.topic_video_submitted_s3` (removido)
  - `aws_lambda_event_source_mapping.orchestrator_q_video_process` (removido ou substituído)
  - `aws_lambda_permission.sqs_invoke_orchestrator` (removido ou substituído)
- **Pacotes/Dependências:** Nenhum pacote externo; apenas recursos HCL e AWS Provider existente.

---

## Formato da Mensagem S3 → SQS (item C)

Quando o S3 publica diretamente em uma fila SQS, o corpo da mensagem (`body`) é um JSON com o envelope de evento S3 padrão:

```json
{
  "Records": [
    {
      "eventVersion": "2.1",
      "eventSource": "aws:s3",
      "awsRegion": "us-east-1",
      "eventName": "ObjectCreated:Put",
      "s3": {
        "bucket": {
          "name": "video-processing-engine-dev-videos",
          "arn": "arn:aws:s3:::video-processing-engine-dev-videos"
        },
        "object": {
          "key": "videos/USER%23abc123/VIDEO%23xyz456/original",
          "size": 104857600
        }
      }
    }
  ]
}
```

### Como o consumer extrai bucket e key

| Campo | Caminho no JSON | Observação |
|-------|-----------------|------------|
| **bucket** | `Records[0].s3.bucket.name` | Nome do bucket sem ARN |
| **key** | `Records[0].s3.object.key` | **URL-encoded**: `#` → `%23`; consumer deve aplicar URL-decode antes de usar |
| **key decodificado** | `urldecode(Records[0].s3.object.key)` | Resultado: `videos/USER#abc123/VIDEO#xyz456/original` |

> **Importante:** O `#` no key do S3 é codificado como `%23` no evento. O consumer **deve** aplicar URL-decode para recuperar o path completo, incluindo o `userId` e `videoId` com `#`.

---

## Dependências e Riscos (para estimativa)

- **Dependências:**
  - Storie-03 (10-storage): bucket `videos` existente — `videos_bucket_arn` e `videos_bucket_name` já são outputs do módulo.
  - Storie-06 (30-messaging SQS): fila `q-video-process` existente — `q_video_process_arn` e `q_video_process_url` já são outputs do módulo.
  - Storie-08 (50-lambdas-shell): módulo de Lambdas existente; `LambdaVideoManagement`/`LambdaVideoOrchestrator` já existem; `event_source_mapping.tf` já existe e precisa ser alterado.
  - Storie-07 (upload_integration.tf): arquivo existente no root — será alterado para remover recursos SNS e adicionar S3 → SQS.

- **Riscos/Pré-condições:**
  - **Risco (destrutivo):** Remover `aws_s3_bucket_notification.videos_to_sns` e `aws_sns_topic_policy.topic_video_submitted_s3` são operações destrutivas no state do Terraform — verificar com `terraform plan` antes de `apply` para confirmar quais recursos serão destruídos.
  - **Risco (event source mapping):** Remover o mapeamento `q-video-process → Lambda` atual antes de criar o novo pode gerar janela sem consumer; o ideal é remover e adicionar no mesmo `apply`.
  - **Risco (key URL-encoded):** O consumer deve tratar o URL-encoding do key S3; isso é documentação, não infra.
  - **Pré-condição:** O bucket `videos` deve existir antes do `apply` (já provisionado por Storie-03).
  - **Pré-condição:** A fila `q-video-process` deve existir antes do `apply` (já provisionada por Storie-06).
  - **AWS Academy:** Usar `lab_role_arn` para a nova Lambda; nenhuma criação de IAM Role pelo Terraform.
  - **SNS topic-video-submitted:** O tópico SNS em si não precisa ser removido (pode ter outros usos futuros); apenas os recursos que integram S3 → SNS → SQS são removidos.

---

## Subtasks

- [x] [Subtask 01: Remover recursos SNS do fluxo de upload (upload_integration.tf)](./subtask/Subtask-01-Remover_SNS_Fluxo_Upload.md)
- [x] [Subtask 02: Criar SQS queue policy e S3 bucket notification direto para SQS](./subtask/Subtask-02-S3_Notification_SQS_Policy.md)
- [x] [Subtask 03: Documentar formato de mensagem S3 e extração de bucket/key pelo consumer](./subtask/Subtask-03-Formato_Mensagem_Consumer.md)
- [x] [Subtask 04: Criar Lambda casca LambdaVideoDispatcher no módulo 50-lambdas-shell](./subtask/Subtask-04-Lambda_Casca_VideoDispatcher.md)
- [x] [Subtask 05: Migrar event source mapping q-video-process para LambdaVideoDispatcher](./subtask/Subtask-05-Migrar_Event_Source_Mapping.md)
- [x] [Subtask 06: Ajustar variáveis, root module (main.tf) e validação Terraform](./subtask/Subtask-06-Variaveis_Root_Validacao.md)

---

## Critérios de Aceite da História

- [ ] Os recursos `aws_s3_bucket_notification.videos_to_sns` e `aws_sns_topic_policy.topic_video_submitted_s3` são removidos do `upload_integration.tf`; `terraform plan` não mostra esses recursos como existentes após apply
- [ ] Um upload de teste no path `videos/<USER#...>/<VIDEO#...>/original` gera mensagem na fila `q-video-process` (verificado via AWS Console → SQS → Poll for messages ou CloudWatch Metrics)
- [ ] A mensagem na fila contém o evento S3 padrão com `Records[0].s3.bucket.name` e `Records[0].s3.object.key` completos (preservando userId e videoId no path)
- [ ] O filtro `prefix = "videos/"` e `suffix = "original"` está configurado; uploads em outros paths NÃO geram mensagem na fila `q-video-process`
- [ ] A `aws_sqs_queue_policy` na fila `q-video-process` permite que o bucket S3 publique com `Condition: aws:SourceArn = videos_bucket_arn` (sem abrir para qualquer origem)
- [ ] A Lambda `LambdaVideoDispatcher` existe no módulo `50-lambdas-shell` (casca: `empty.zip`, handler placeholder, runtime parametrizável, `lab_role_arn`)
- [ ] O event source mapping antigo de `q-video-process` (para `LambdaVideoOrchestrator` ou `LambdaVideoManagement`) é removido; `terraform plan` confirma a remoção
- [ ] O novo event source mapping `q-video-process → LambdaVideoDispatcher` está ativo; a Lambda é invocada pela fila (verificado via CloudWatch Logs do grupo `/aws/lambda/<prefix>-video-dispatcher` ou CloudWatch Metrics `Invocations`)
- [ ] O `LambdaVideoManagement` **não** é invocado por `q-video-process` (confirmar ausência de logs de invocação dessa fila no grupo da Lambda VideoManagement)
- [ ] `terraform fmt -recursive`, `terraform validate` e `terraform plan` executam sem erros nem warnings nos módulos alterados
- [ ] Nenhuma credencial, ARN de Lab Role ou valor sensível hardcoded nos arquivos `.tf` alterados
