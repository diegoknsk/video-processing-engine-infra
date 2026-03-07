# Subtask 01: Adicionar snap_start e publish em todas as Lambdas

## Descrição
Em `terraform/50-lambdas-shell/lambdas.tf`, em cada um dos 6 recursos `aws_lambda_function` (auth, video_management, video_orchestrator, video_processor, video_finalizer, update_status_video), adicionar:

1. Bloco `snap_start { apply_on = "PublishedVersions" }`
2. Argumento `publish = true`

Isso habilita o SnapStart e faz com que cada deploy publique uma nova versão numerada da função.

## Critério de conclusão
- [x] As 6 Lambdas possuem `snap_start` e `publish = true`; `terraform validate` passa.
