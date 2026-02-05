# Subtask 01: Estrutura do root (providers, backend, variables, main)

## Descrição
Criar a estrutura base do root Terraform em `terraform/`: providers.tf (required_version, required_providers aws ~> 5.0, provider aws com region), backend.tf (S3 com key e opcional DynamoDB para lock; documentar uso de -backend=false localmente), variables.tf com variáveis globais (project_name, environment, region, owner, retention_days, enable_* conforme foundation e demais módulos). Garantir que não haja conflito com arquivos já existentes nos subdiretórios (00-foundation, 10-storage, etc.); os arquivos do root ficam em `terraform/*.tf` no mesmo nível das pastas dos módulos.

## Passos de implementação
1. Criar `terraform/providers.tf` com bloco terraform (required_version >= "1.0", required_providers aws ~> 5.0) e provider "aws" { region = var.region }.
2. Criar `terraform/backend.tf` com backend "s3" (bucket, key, region, opcional dynamodb_table para lock, encrypt = true); adicionar comentário ou documentação de que para execução local sem backend pode-se usar `terraform init -backend=false`.
3. Criar `terraform/variables.tf` com variáveis: project_name, environment, region, owner, retention_days, enable_cloudwatch_retention (e outras flags globais usadas pelo foundation ou repassadas aos módulos); incluir description e default quando aplicável.
4. Criar `terraform/main.tf` (ou modules.tf) inicialmente vazio ou com comentário indicando que as chamadas aos módulos serão adicionadas na Subtask 02; manter organização clara para não duplicar recursos.

## Formas de teste
1. Executar `terraform init -backend=false` em `terraform/` e verificar que providers são baixados e que não há erro de configuração.
2. Executar `terraform validate` em `terraform/` (após Subtask 02 ter pelo menos um module block) e confirmar que não há erro de variável não declarada.
3. Verificar que nenhum arquivo em 00-foundation, 10-storage, etc. foi alterado nesta subtask (apenas criação de arquivos em terraform/ no nível raiz dos módulos).

## Critérios de aceite da subtask
- [ ] terraform/providers.tf existe com required_version >= "1.0", required_providers aws ~> 5.0 e provider aws com region = var.region
- [ ] terraform/backend.tf existe com backend s3 (e opcional DynamoDB); está documentado o uso de -backend=false para ambiente local
- [ ] terraform/variables.tf declara variáveis globais alinhadas ao foundation (project_name, environment, region, owner, retention_days, enable_cloudwatch_retention)
- [ ] terraform/main.tf existe (pode estar com comentário ou primeiro module block); terraform init -backend=false em terraform/ executa com sucesso
