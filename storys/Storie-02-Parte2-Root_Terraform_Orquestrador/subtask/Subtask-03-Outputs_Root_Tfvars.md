# Subtask 03: Outputs do root e integração com tfvars

## Descrição
Criar terraform/outputs.tf que reexporte os outputs necessários dos módulos (ex.: prefix, common_tags, account_id, region do foundation; videos_bucket_name, videos_bucket_arn, images_bucket_name, images_bucket_arn, zip_bucket_name, zip_bucket_arn do storage) para consumo por CI/CD, documentação e outros repositórios. Garantir que terraform/envs/dev.tfvars (ou exemplo) contenha variáveis compatíveis com o root (project_name, environment, region, owner, etc.) e que o plan possa ser executado com -var-file=envs/dev.tfvars.

## Passos de implementação
1. Criar `terraform/outputs.tf` com outputs que referenciem module.foundation e module.storage (ex.: output "prefix" { value = module.foundation.prefix }; output "common_tags" { value = module.foundation.common_tags }; output "videos_bucket_name" { value = module.storage.videos_bucket_name }; e demais buckets e outputs do foundation).
2. Documentar em comentário ou README quais outputs são expostos pelo root e para quem (pipelines, outros repos).
3. Verificar que `terraform/envs/dev.tfvars` (ou dev.tfvars.example) contém as variáveis esperadas pelo root (project_name, environment, region, owner, retention_days, etc.); criar exemplo se não existir ou atualizar para o formato do root.
4. Garantir que nenhum output do root referencia módulo ainda não invocado (evitar module.xxx quando xxx não existir no main.tf).

## Formas de teste
1. Executar `terraform plan -var-file=envs/dev.tfvars` em terraform/ e verificar que a seção "Outputs" do plano lista os outputs definidos no root.
2. Conferir que dev.tfvars não contém credenciais e que as variáveis obrigatórias (ex.: owner) estão documentadas ou com default.
3. Validar que outputs.tf não gera erro de "reference to undeclared resource" ou "unknown module".

## Critérios de aceite da subtask
- [ ] terraform/outputs.tf existe e reexporta prefix, common_tags e outputs dos buckets (videos, images, zip) e demais relevantes do foundation
- [ ] terraform plan -var-file=envs/dev.tfvars em terraform/ exibe os outputs sem erro
- [ ] tfvars de exemplo ou existente compatível com as variáveis do root; documentação breve dos outputs para consumidores
