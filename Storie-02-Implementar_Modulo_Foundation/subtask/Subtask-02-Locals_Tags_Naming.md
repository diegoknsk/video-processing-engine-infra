# Subtask 02: Implementar locals.tf com tags padrão e convenção de naming

## Descrição
Criar ou atualizar o arquivo `terraform/00-foundation/locals.tf` com um bloco `locals` que defina as tags padrão (Project, Environment, ManagedBy, Owner) e a convenção de naming usando o prefixo `video-processing-engine-${var.environment}`, reutilizável por todos os recursos dos módulos subsequentes e alinhado às infrarules (tags mínimas em todos os recursos).

## Passos de implementação
1. Criar ou atualizar `terraform/00-foundation/locals.tf` com um bloco `locals`.
2. Definir um map de tags padrão (ex.: `common_tags`) contendo: `Project` (ex.: "video-processing-engine" ou `var.project_name` se existir), `Environment` = `var.environment`, `ManagedBy` = "Terraform", `Owner` = `var.owner`; todos referenciando variáveis, sem valores sensíveis.
3. Definir o prefixo de naming (ex.: `naming_prefix` ou `name_prefix`) como `"video-processing-engine-${var.environment}"`, para que os demais módulos possam usar em nomes de recursos (ex.: `"${local.naming_prefix}-s3-bucket"`).
4. Garantir que não haja recursos AWS declarados neste arquivo; apenas locals.

## Formas de teste
1. Após Subtask 03 (variables.tf com environment, owner), executar `terraform validate` em `terraform/00-foundation/` e confirmar que os locals são resolvidos (variáveis devem ter default ou ser passadas via tfvars).
2. Verificar que os nomes das chaves de tags (Project, Environment, ManagedBy, Owner) estão presentes no map de tags e que o prefixo inclui `var.environment`.
3. Buscar no arquivo por "video-processing-engine" e "${var.environment}" para confirmar a convenção de naming.

## Critérios de aceite da subtask
- [ ] O arquivo `terraform/00-foundation/locals.tf` existe e contém um map de tags com Project, Environment, ManagedBy, Owner referenciando variáveis.
- [ ] O prefixo de naming está definido como `video-processing-engine-${var.environment}` (ou equivalente em local).
- [ ] Nenhum recurso `resource "aws_*"` está declarado em locals.tf; apenas blocos `locals`.
