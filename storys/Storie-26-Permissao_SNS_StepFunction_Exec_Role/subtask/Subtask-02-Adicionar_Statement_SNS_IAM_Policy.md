# Subtask-02: Adicionar statement SNSPublishError na policy IAM da Step Function

## Descrição
Adicionar o statement `SNSPublishError` na IAM policy inline `aws_iam_role_policy.sfn_exec` em `terraform/70-orchestration/iam.tf`, seguindo o princípio de menor privilégio: apenas `sns:Publish` no ARN específico do tópico de erro.

## Arquivo afetado
`terraform/70-orchestration/iam.tf`

## Contexto atual
A policy `sfn_exec` possui 3 statements:
- `LambdaInvoke`: `lambda:InvokeFunction` nos ARNs das Lambdas.
- `SQSSend`: `sqs:SendMessage` (Resource `["*"]` — já existente, não alterar).
- `CloudWatchLogs`: permissões de logs.

## Passos de implementação

1. Abrir `terraform/70-orchestration/iam.tf`.
2. Localizar o array `Statement` dentro do `policy = jsonencode({...})` do resource `aws_iam_role_policy.sfn_exec`.
3. Adicionar o seguinte statement **ao final do array**, após o statement `CloudWatchLogs`:
   ```hcl
   {
     Sid      = "SNSPublishError"
     Effect   = "Allow"
     Action   = ["sns:Publish"]
     Resource = [var.topic_video_processing_error_arn]
   },
   ```
4. **Não alterar** os statements `LambdaInvoke`, `SQSSend` e `CloudWatchLogs`.
5. **Não usar wildcard** `*` no `Resource` do novo statement.

## Formas de teste

1. Executar `terraform validate` — deve retornar "The configuration is valid."
2. Executar `terraform plan` — o output deve mostrar `~ update in-place` na policy `sfn_exec` com adição do statement `SNSPublishError`; nenhum outro resource deve ter mudança.
3. Verificar no output do `plan` que os statements `LambdaInvoke`, `SQSSend` e `CloudWatchLogs` permanecem idênticos.

## Critérios de aceite

- [ ] Statement `SNSPublishError` adicionado com `Effect: Allow`, `Action: ["sns:Publish"]` e `Resource: [var.topic_video_processing_error_arn]`.
- [ ] Nenhum wildcard `*` no `Resource` do statement SNS.
- [ ] Statements existentes (`LambdaInvoke`, `SQSSend`, `CloudWatchLogs`) mantidos sem alteração.
- [ ] `terraform validate` retorna "The configuration is valid."
- [ ] `terraform plan` mostra apenas atualização in-place da policy `sfn_exec`.
