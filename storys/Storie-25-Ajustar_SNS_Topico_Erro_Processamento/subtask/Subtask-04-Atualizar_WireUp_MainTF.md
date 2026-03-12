# Subtask-04: Atualizar wiring no main.tf raiz

## Descrição
Atualizar `terraform/main.tf` para remover o input `topic_video_completed_arn` que era passado ao módulo `lambdas` (referenciando o output removido de `30-messaging`). Esta subtask garante que o `terraform validate` no root não falhe por referência a output inexistente.

**Nota:** as variáveis `topic_video_completed_arn` em `terraform/50-lambdas-shell/variables.tf`, `iam.tf` e `lambdas.tf` são deuda técnica fora do escopo desta story; serão tratadas em story subsequente de ajuste do módulo de Lambdas.

## Arquivos Afetados
- `terraform/main.tf`

## Contexto — Referência atual no main.tf
```hcl
# Trecho atual no bloco do módulo lambdas em main.tf:
topic_video_completed_arn = module.messaging.topic_video_completed_arn
```

## Passos de Implementação

1. **Localizar** no `terraform/main.tf` o bloco `module "lambdas"` (ou equivalente que passa `topic_video_completed_arn`).

2. **Remover** a linha:
   ```hcl
   topic_video_completed_arn = module.messaging.topic_video_completed_arn
   ```

3. **Verificar** se há outros usos de `module.messaging.topic_video_completed_arn` em `main.tf` (outputs do root, outros módulos) e removê-los também.

4. **Executar `terraform fmt`** no diretório `terraform/`.

5. **Executar `terraform validate`** no root `terraform/`: o validate pode ainda avisar sobre variável não utilizada em `50-lambdas-shell` (deuda técnica tolerada nesta story), mas não deve apresentar erros de referência a outputs ou recursos inexistentes.

## Formas de Teste

1. Verificar via busca textual que `topic_video_completed_arn` não aparece mais em `terraform/main.tf`.
2. Executar `terraform validate` no root `terraform/` e confirmar ausência de erros do tipo `Error: Unsupported attribute` referenciando `topic_video_completed_arn`.
3. Verificar que o módulo `messaging` ainda é chamado em `main.tf` com os inputs corretos (sem o campo removido).

## Critérios de Aceite
- [ ] A linha `topic_video_completed_arn = module.messaging.topic_video_completed_arn` foi removida de `terraform/main.tf`
- [ ] Nenhuma outra referência a `module.messaging.topic_video_completed_arn` existe em `main.tf`
- [ ] `terraform fmt` não reporta diff em `main.tf`
- [ ] `terraform validate` no root não apresenta erros de referência a `topic_video_completed_arn` ou ao output removido do módulo messaging
