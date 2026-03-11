# Subtask 02: Substituir sfn_definition pelo Map State completo

## Descrição
Substituir o `local.sfn_definition` em `terraform/70-orchestration/stepfunctions.tf` pela definição completa com Map State, replicando o JSON do backup da AWS sem ARNs ou URLs hardcoded.

## Estrutura da Definição (referência)

A nova definição deve implementar o seguinte fluxo:

```
StartAt: Map
  └─ Map (Type: Map, Mode: INLINE)
       ItemsPath: $.chunks
       ItemSelector: { contractVersion, videoId, userId, s3BucketVideo, s3KeyVideo, output, chunk }
       StartAt: Processor Video
         └─ Processor Video (Type: Task → Lambda invoke → var.lambda_processor_arn)
              OutputPath: $.Payload
              Retry: [Lambda.ServiceException, Lambda.AWSLambdaException, Lambda.SdkClientException, Lambda.TooManyRequestsException]
              End: true
       ResultPath: $.chunkResults
       Next: Update Status
  └─ Update Status (Type: Task → SQS SendMessage → var.q_video_status_update_url)
       Parameters: { videoId, userId, status=2, progressPercent=100, s3BucketFrames, framesPrefix }
       Next: Success
  └─ Success (Type: Succeed)
```

## Passos de Implementação

1. Em `terraform/70-orchestration/stepfunctions.tf`, substituir o bloco `locals { sfn_definition = ... }` existente pelo novo `jsonencode` que reproduz a estrutura acima, usando:
   - `FunctionName = "${var.lambda_processor_arn}:$LATEST"` no estado `Processor Video`
   - `QueueUrl = var.q_video_status_update_url` no estado `Update Status`
   - Todos os campos de payload/selector usando notação `.$` (JSONPath) do Step Functions

2. Garantir que os campos do `ItemSelector` cubram todos os campos necessários ao `Processor Video`:
   - `contractVersion.$`, `videoId.$`, `userId.$`, `s3BucketVideo.$`, `s3KeyVideo.$`, `output.$`, `chunk.$` (via `$$.Map.Item.Value`)

3. Garantir que os campos do `MessageBody` em `Update Status` cubram:
   - `videoId.$`, `userId.$`, `status = 2` (literal numérico), `progressPercent = 100` (literal), `s3BucketFrames.$` (de `$.output.framesBucket`), `framesPrefix.$` (de `$.output.framesBasePrefix`)

4. Remover o comentário desatualizado sobre "placeholder" no topo do arquivo e atualizar para refletir a definição real.

## Formas de Teste
1. Executar `terraform fmt -recursive` — arquivo deve sair sem alteração (código bem formatado)
2. Executar `terraform validate` — deve retornar "Success!"
3. Executar `terraform plan` — deve exibir somente `~ update in-place` em `aws_sfn_state_machine.video_processing[0]`, com diff no campo `definition`
4. Inspecionar o JSON gerado via `terraform show` ou console AWS após apply e comparar com o backup original — campos, tipos e paths devem coincidir

## Critérios de Aceite
- [x] `local.sfn_definition` não contém nenhum ARN ou URL hardcoded; usa apenas variáveis Terraform
- [x] O fluxo Map → PrepareUpdateMessage → Update Status → Success está corretamente definido com os tipos (`Map`, `Pass`, `Task`, `Succeed`); PrepareUpdateMessage monta o body para SQS.
- [x] O Retry no estado `Processor Video` cobre os quatro erros Lambda (`ServiceException`, `AWSLambdaException`, `SdkClientException`, `TooManyRequestsException`) com `IntervalSeconds=1`, `MaxAttempts=3`, `BackoffRate=2`, `JitterStrategy=FULL`
- [x] `terraform validate` passa sem erros após a alteração
- [ ] `terraform plan` mostra apenas update in-place no recurso `aws_sfn_state_machine.video_processing[0]` (executar em ambiente com backend configurado)
