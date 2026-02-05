# Subtask 01: Criar providers.tf com required_version, required_providers e AWS provider

## Descrição
Criar o arquivo `terraform/00-foundation/providers.tf` com bloco `terraform` contendo `required_version >= "1.0"` e `required_providers` (AWS na família ~> 5.0), e bloco `provider "aws"` com região parametrizada (`var.region`), alinhado às infrarules (provider com região sempre parametrizada, nunca hardcoded).

## Passos de implementação
1. Criar o arquivo `terraform/00-foundation/providers.tf` na raiz do módulo 00-foundation.
2. Declarar o bloco `terraform` com `required_version = ">= 1.0"` e `required_providers` com entrada `aws` na versão `~> 5.0` (ou equivalente estável).
3. Declarar o bloco `provider "aws"` com `region = var.region`, garantindo que a variável `region` seja definida em `variables.tf` (Subtask 03); não hardcodar nome da região.
4. Garantir que o arquivo siga o padrão de formatação (será validado com `terraform fmt` na Subtask 05).

## Formas de teste
1. Com `variables.tf` já contendo a variável `region` (ou criando placeholder), executar `terraform init` em `terraform/00-foundation/` com `-backend=false` e verificar que o provider é baixado e inicializado.
2. Executar `terraform validate` no diretório do módulo e confirmar que não há erro de sintaxe ou provider ausente.
3. Verificar manualmente que não existe região hardcoded (ex.: "us-east-1") no bloco provider; apenas `var.region`.

## Critérios de aceite da subtask
- [ ] O arquivo `terraform/00-foundation/providers.tf` existe e contém bloco `terraform` com `required_version >= "1.0"` e `required_providers.aws` (~> 5.0).
- [ ] O bloco `provider "aws"` está declarado com `region = var.region` (sem valor literal de região).
- [ ] `terraform init -backend=false` e `terraform validate` executados no módulo não falham por causa do providers.tf.
