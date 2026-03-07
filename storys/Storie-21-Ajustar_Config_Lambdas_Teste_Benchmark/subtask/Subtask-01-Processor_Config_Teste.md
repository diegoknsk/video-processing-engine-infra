# Subtask 01: Lambda Processor — memória, ephemeral storage, timeout e SnapStart None

## Descrição
Ajustar o recurso `aws_lambda_function.video_processor` em `terraform/50-lambdas-shell/lambdas.tf` para a configuração robusta de teste: 3072 MB de memória, 8192 MB de armazenamento efêmero (/tmp), timeout 15 min (900 s) e SnapStart desabilitado (remover o bloco `snap_start`).

## Passos de implementação

1. Em `terraform/50-lambdas-shell/lambdas.tf`, no recurso `aws_lambda_function.video_processor`, adicionar os argumentos:
   - `memory_size = 3072`
   - `ephemeral_storage { size = 8192 }` (tamanho em MB; provider AWS usa o argumento `size` dentro do bloco `ephemeral_storage`).
   - Manter `timeout = 900` (já existente).
2. Remover o bloco `snap_start { apply_on = "PublishedVersions" }` do recurso `video_processor`, para que SnapStart fique desabilitado (None).
3. Executar `terraform validate` para garantir que a sintaxe está correta para a versão do provider em uso.

## Formas de teste

1. Executar `terraform validate` no diretório do módulo (ou no root) e confirmar que não há erros.
2. Executar `terraform plan` com as variáveis necessárias e verificar que a única mudança no `video_processor` é a adição de `memory_size`, `ephemeral_storage` e a remoção de `snap_start` (e que `timeout` permanece 900).
3. Após apply (em ambiente de teste), inspecionar no console AWS (ou via CLI) a função `video_processor`: Memory 3072 MB, Ephemeral storage 8192 MB, Timeout 15 min, SnapStart "None".

## Critérios de aceite da subtask

- [x] O recurso `aws_lambda_function.video_processor` possui `memory_size = 3072` e bloco `ephemeral_storage` com tamanho 8192 MB.
- [x] O recurso `video_processor` não possui bloco `snap_start` (SnapStart efetivamente None).
- [x] `terraform validate` e `terraform plan` executam sem erros.
