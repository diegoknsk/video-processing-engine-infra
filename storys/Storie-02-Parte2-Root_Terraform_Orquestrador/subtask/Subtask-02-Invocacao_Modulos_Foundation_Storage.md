# Subtask 02: Invocação dos módulos (foundation, storage e demais)

## Descrição
Implementar no root (terraform/main.tf ou terraform/modules.tf) as chamadas aos módulos: module "foundation" (source = "./00-foundation") com variáveis do root; module "storage" (source = "./10-storage") recebendo prefix e common_tags do module.foundation; e, para os demais diretórios (20-data, 30-messaging, 40-auth, 50-lambdas-shell, 60-api, 70-orchestration), invocar como módulos quando já implementados ou deixar comentário/placeholder para inclusão progressiva. Garantir que 00-foundation e 10-storage sejam invocados corretamente e que o plan não apresente referências quebradas.

## Passos de implementação
1. No arquivo principal do root (main.tf ou modules.tf), adicionar module "foundation" { source = "./00-foundation"; project_name = var.project_name; environment = var.environment; region = var.region; owner = var.owner; retention_days = var.retention_days; enable_cloudwatch_retention = var.enable_cloudwatch_retention (conforme variables do 00-foundation) }.
2. Adicionar module "storage" { source = "./10-storage"; prefix = module.foundation.prefix; common_tags = module.foundation.common_tags; region = module.foundation.region (ou var.region); enable_versioning = var.enable_versioning (se existir no root); retention_days = var.retention_days; enable_lifecycle_expiration = var.enable_lifecycle_expiration (se existir) }; criar variáveis no root quando necessário para repassar ao storage.
3. Para 20-data, 30-messaging, 40-auth, 50-lambdas-shell, 60-api, 70-orchestration: se o módulo tiver apenas placeholder (main.tf vazio), não invocar ainda ou invocar com source e variáveis mínimas (prefix, common_tags) para que o root não quebre quando o módulo for implementado; documentar a ordem de inclusão.
4. Garantir que variáveis referenciadas no root (var.enable_versioning, var.enable_lifecycle_expiration) existam em terraform/variables.tf com default adequado.

## Formas de teste
1. Executar `terraform init -backend=false` e `terraform validate` em terraform/; deve retornar sucesso.
2. Executar `terraform plan -var-file=envs/dev.tfvars` (ou -var para obrigatórias) em terraform/ e verificar que o plano inclui recursos do foundation e do storage; sem erro "reference to undeclared" ou "missing required variable".
3. Verificar que module.foundation.output e module.storage.output são usados corretamente (sem referência a outputs inexistentes).

## Critérios de aceite da subtask
- [ ] module "foundation" e module "storage" estão declarados no root com source = "./00-foundation" e "./10-storage"
- [ ] Variáveis do root repassadas ao foundation e ao storage; storage recebe prefix e common_tags do module.foundation
- [ ] terraform validate e terraform plan (com variáveis fornecidas) em terraform/ executam sem erros de referência; demais módulos (20 a 70) documentados ou invocados em placeholder para inclusão futura
