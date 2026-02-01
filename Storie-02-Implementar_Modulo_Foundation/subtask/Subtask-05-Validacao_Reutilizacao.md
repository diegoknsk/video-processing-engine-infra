# Subtask 05: Validar módulo com terraform fmt e terraform validate e garantir reutilização

## Descrição
Executar `terraform fmt -recursive` no diretório do módulo (ou em terraform/), executar `terraform validate` em `terraform/00-foundation/` e garantir que o módulo seja compilável e reutilizável pelos demais módulos: outputs e variáveis coerentes, sem erros de referência circular, e documentação mínima de como consumir o foundation (opcional).

## Passos de implementação
1. No diretório do repositório (ou em `terraform/00-foundation/`), executar `terraform fmt -recursive` (ou `terraform fmt` no módulo) e garantir que todos os arquivos .tf do 00-foundation estejam formatados; corrigir formatação se necessário.
2. Executar `terraform init -backend=false` seguido de `terraform validate` dentro de `terraform/00-foundation/` e corrigir qualquer erro reportado até obter "Success! The configuration is valid."
3. Revisar que nenhum recurso AWS foi criado além do necessário: permitido data "aws_caller_identity" para account_id; não permitido criar S3, DynamoDB, IAM role, etc., nesta story.
4. Garantir reutilização: verificar que outputs (account_id, region, prefix, common_tags) estão nomeados de forma clara e que um módulo filho poderia usar esses valores (ex.: via module ou tfstate); adicionar comentário ou uma linha no README do módulo descrevendo que este módulo fornece convenções e outputs base para os demais.

## Formas de teste
1. Executar `terraform fmt -recursive` em `terraform/` e depois `terraform validate` em `terraform/00-foundation/`; ambos devem concluir sem erro.
2. Fazer um dry-run de consumo: em um diretório temporário ou em 10-storage (placeholder), declarar um module que referencie 00-foundation (path ou source) e use output "prefix" e "common_tags"; validar que não há erro de referência (opcional, se estrutura permitir).
3. Buscar em `terraform/00-foundation/*.tf` por `resource "aws_` e confirmar que não há recursos, exceto eventual uso de data source já acordado.

## Critérios de aceite da subtask
- [ ] `terraform fmt -recursive` foi executado e todos os .tf do 00-foundation estão formatados.
- [ ] `terraform validate` em `terraform/00-foundation/` retorna "Success! The configuration is valid."
- [ ] Nenhum recurso AWS criado além de data source para account_id (se aplicável); módulo compilável e reutilizável (outputs e variáveis utilizáveis por outros módulos).
