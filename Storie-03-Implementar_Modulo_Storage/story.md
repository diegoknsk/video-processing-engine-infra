# Storie-03: Implementar Módulo Terraform 10-Storage (Buckets S3)

## Status
- **Estado:** 🔄 Em desenvolvimento
- **Data de Conclusão:** [DD/MM/AAAA]

## Descrição
Como desenvolvedor de infraestrutura, quero que o módulo `terraform/10-storage` provisione três buckets S3 (vídeos, imagens, zip) com Block Public Access, encryption, versioning opcional e lifecycle configurável, para suportar o fluxo de upload, processamento e entrega do Processador Video MVP conforme contexto arquitetural, consumindo prefix e tags do foundation e sem criar IAM.

## Objetivo
Criar o módulo `terraform/10-storage` com três buckets S3: **videos** (upload pelo usuário), **images** (frames extraídos) e **zip** (resultado final). Requisitos mínimos: Block Public Access habilitado, encryption habilitada, versioning opcional via variável, lifecycle para expirar objetos antigos (configurável). Outputs: nomes e ARNs dos buckets. O módulo deve consumir prefix e tags do foundation; não criar recursos IAM (IAM fica na story de Lambdas/IAM). Garantir que `terraform plan` não tenha referências quebradas e que a story documente variáveis e decisões.

## Escopo Técnico
- Tecnologias: Terraform >= 1.0, AWS Provider (~> 5.0)
- Arquivos afetados:
  - `terraform/10-storage/variables.tf` (variáveis do módulo + referência ao foundation)
  - `terraform/10-storage/main.tf` ou `buckets.tf` (recursos aws_s3_bucket, aws_s3_bucket_versioning, aws_s3_bucket_server_side_encryption_configuration, aws_s3_bucket_public_access_block, aws_s3_bucket_lifecycle_configuration)
  - `terraform/10-storage/outputs.tf`
  - `terraform/10-storage/README.md` ou documentação na story (variáveis e decisões)
- Componentes/Recursos: 3x aws_s3_bucket (videos, images, zip), block_public_access, server_side_encryption (AES256 ou KMS conforme decisão), versioning condicional, lifecycle rules configuráveis; nenhum aws_iam_*.
- Pacotes/Dependências: Nenhum; consumo de outputs do módulo 00-foundation (prefix, common_tags) via variáveis passadas ou module/datasource.

## Dependências e Riscos (para estimativa)
- Dependências: Storie-02 (00-foundation) concluída, com outputs prefix e common_tags disponíveis.
- Riscos/Pré-condições: Nomes de bucket globais únicos na AWS; uso do prefix do foundation garante unicidade por ambiente. IAM para Lambdas acessarem os buckets será tratada em story dedicada.

## Variáveis do Módulo (documentação)
- **prefix** (string, obrigatório): prefixo de naming vindo do foundation (ex.: `video-processing-engine-dev`).
- **common_tags** (map, obrigatório): tags padrão do foundation (Project, Environment, ManagedBy, Owner).
- **enable_versioning** (bool, opcional, default = false): habilita versionamento nos buckets.
- **retention_days** (number, opcional): dias para expirar objetos antigos via lifecycle; 0 ou null desabilita lifecycle de expiração.
- **enable_lifecycle_expiration** (bool, opcional, default = true): habilita regra de lifecycle para expiração quando retention_days > 0.
- **environment** (string, opcional): para tags/naming consistente com foundation.

## Decisões Técnicas
- **Block Public Access:** todos os buckets com `block_public_acls`, `block_public_policy`, `ignore_public_acls`, `restrict_public_buckets` = true (recomendação AWS).
- **Encryption:** SSE-S3 (AES256) por padrão; sem KMS nesta story para simplicidade (evitar IAM de KMS).
- **Naming:** `{prefix}-videos`, `{prefix}-images`, `{prefix}-zip` para garantir unicidade e rastreabilidade.
- **IAM:** não criar políticas nem roles neste módulo; políticas de acesso aos buckets serão criadas na story de Lambdas/IAM.

## Subtasks
- [Subtask 01: Variáveis do módulo e consumo de prefix/tags do foundation](./subtask/Subtask-01-Variaveis_Consumo_Foundation.md)
- [Subtask 02: Recursos S3 (buckets) com Block Public Access e encryption](./subtask/Subtask-02-Buckets_Block_Public_Encryption.md)
- [Subtask 03: Versioning opcional e lifecycle configurável](./subtask/Subtask-03-Versioning_Lifecycle.md)
- [Subtask 04: Outputs (nomes e ARNs) e documentação de variáveis/decisões](./subtask/Subtask-04-Outputs_Documentacao.md)
- [Subtask 05: Validação (terraform plan sem referências quebradas)](./subtask/Subtask-05-Validacao_Plan.md)

## Critérios de Aceite da História
- [ ] O módulo `terraform/10-storage` cria três buckets S3: videos (upload), images (frames), zip (resultado final), com nomes derivados do prefix do foundation
- [ ] Block Public Access está habilitado em todos os buckets (quatro configurações true)
- [ ] Encryption está habilitada em todos os buckets (SSE-S3 ou equivalente)
- [ ] Versioning é opcional e controlado por variável (ex.: enable_versioning)
- [ ] Lifecycle para expirar objetos antigos é configurável (ex.: retention_days e/ou enable_lifecycle_expiration)
- [ ] Outputs expõem nomes e ARNs dos três buckets; nenhum recurso IAM criado neste módulo
- [ ] O módulo consome prefix e tags do foundation (via variáveis ou module)
- [ ] `terraform plan` no módulo 10-storage não apresenta referências quebradas (variáveis e dependências do foundation resolvidas)
- [ ] A story documenta variáveis do módulo e decisões técnicas (naming, encryption, Block Public Access, IAM fora do escopo)

## Checklist de Conclusão
- [ ] Todos os arquivos .tf do 10-storage criados; nenhum aws_iam_* no módulo
- [ ] terraform init e terraform validate executados com sucesso no 10-storage
- [ ] terraform plan executado com variáveis do foundation passadas (prefix, common_tags) e sem erros de referência
- [ ] README ou seção na story com variáveis e decisões documentadas
