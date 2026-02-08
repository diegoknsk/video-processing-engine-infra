# Subtask 03: Definir variables.tf (globais) e outputs.tf (base)

## Descrição
Criar ou atualizar `terraform/00-foundation/variables.tf` com as variáveis globais: environment, region, owner, retention_days e pelo menos um enable_* flag (ex.: enable_cloudwatch_retention). Criar ou atualizar `terraform/00-foundation/outputs.tf` com os outputs base: account_id, region, prefix (naming), common_tags, para que os demais módulos possam consumir o foundation via outputs ou data sources.

## Passos de implementação
1. Em `terraform/00-foundation/variables.tf`, declarar: `environment` (string, ex.: default "dev"), `region` (string, ex.: default "us-east-1"), `owner` (string), `retention_days` (number, opcional), e pelo menos uma variável `enable_*` (bool, ex.: enable_cloudwatch_retention ou enable_xray); todas com description quando possível; nenhum valor sensível.
2. Em `terraform/00-foundation/outputs.tf`, declarar: `account_id` (pode usar `data.aws_caller_identity.current.account_id` — data source a ser declarada no módulo se necessário), `region` (value = var.region ou provider), `prefix` (value = local.naming_prefix do locals.tf), `common_tags` (value = local.common_tags).
3. Se account_id depender de data source, adicionar em `terraform/00-foundation/datasource.tf` (ou no próprio providers/variables) um `data "aws_caller_identity" "current" {}` para expor account_id sem criar recursos; é o único uso de recurso/data permitido além de provider/locals.
4. Garantir que outputs sejam exportáveis e que outros módulos possam referenciar o módulo foundation (via módulo ou copiando convenção); documentar em comentário se necessário.

## Formas de teste
1. Executar `terraform init -backend=false` e `terraform validate` em `terraform/00-foundation/`; variáveis sem default podem ser passadas via `-var` ou tfvars.
2. Executar `terraform plan` (sem apply) e verificar que os outputs aparecem no plano (account_id, region, prefix, common_tags) sem erros.
3. Verificar que variables.tf contém environment, region, owner, retention_days e pelo menos um enable_*; e que outputs.tf contém account_id, region, prefix, common_tags.

## Critérios de aceite da subtask
- [ ] `variables.tf` declara environment, region, owner, retention_days e pelo menos um enable_* (bool); sem credenciais.
- [ ] `outputs.tf` declara outputs: account_id, region, prefix, common_tags; account_id pode vir de data "aws_caller_identity".
- [ ] `terraform plan` (sem apply) executa sem erro e lista os outputs; módulo é consumível por outros (outputs disponíveis).
