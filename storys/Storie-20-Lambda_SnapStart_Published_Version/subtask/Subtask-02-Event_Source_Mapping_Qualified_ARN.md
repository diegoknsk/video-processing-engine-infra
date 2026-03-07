# Subtask 02: Event source mappings e permissions com qualified ARN

## Descrição
Em `terraform/50-lambdas-shell/event_source_mapping.tf`, atualizar os event source mappings e as `aws_lambda_permission` para usar o **qualified ARN** da função (versão publicada), em vez do nome ou ARN não qualificado.

- Trocar `function_name = aws_lambda_function.xxx.function_name` por `function_name = aws_lambda_function.xxx.qualified_arn` nos recursos que invocam: video_orchestrator, video_finalizer, update_status_video (tanto no event_source_mapping quanto na permission correspondente).

Assim a SQS passará a invocar a versão publicada (com SnapStart), e não `$LATEST`.

## Critério de conclusão
- [x] Os 3 event source mappings e as 3 lambda permissions usam `qualified_arn`; `terraform plan` mostra alteração apenas nos recursos esperados.
