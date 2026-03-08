# Subtask 02: Demais Lambdas — configuração intermediária para testes

## Descrição
Ajustar os recursos das Lambdas **auth**, **video_management**, **video_orchestrator**, **video_finalizer** e **update_status_video** em `terraform/50-lambdas-shell/lambdas.tf` com memory_size e ephemeral_storage explícitos, em valores intermediários para testes (elevação moderada em relação ao mínimo), conforme tabela da story principal.

## Passos de implementação

1. Para cada um dos recursos: `auth`, `video_management`, `video_orchestrator`, `update_status_video`, adicionar:
   - `memory_size = 512`
   - `ephemeral_storage { size = 1024 }` (tamanho em MB).
2. Para o recurso `video_finalizer`, adicionar:
   - `memory_size = 1024`
   - `ephemeral_storage { size = 2048 }` (tamanho em MB).
3. Garantir que todos mantêm `timeout = 900` e o bloco `snap_start { apply_on = "PublishedVersions" }` (não alterar SnapStart nas demais Lambdas).

## Formas de teste

1. Executar `terraform validate` e `terraform plan` e verificar que as mudanças planejadas correspondem apenas a memory_size e ephemeral_storage (e que timeout e snap_start permanecem para as 5 funções).
2. Comparar o diff do plan com a tabela da Storie-21 (Auth, VideoManagement, Orchestrator, UpdateStatusVideo: 512 MB / 1024 MB; VideoFinalizer: 1024 MB / 2048 MB).
3. Após apply em ambiente de teste, conferir no console AWS (ou via CLI) os valores de Memory e Ephemeral storage de cada uma das 5 funções.

## Critérios de aceite da subtask

- [x] As Lambdas auth, video_management, video_orchestrator e update_status_video possuem `memory_size = 512` e `ephemeral_storage` de 1024 MB.
- [x] A Lambda video_finalizer possui `memory_size = 1024` e `ephemeral_storage` de 2048 MB.
- [x] Nenhuma das 5 funções perdeu o bloco `snap_start` nem o `timeout = 900`; `terraform validate` e `terraform plan` passam.
