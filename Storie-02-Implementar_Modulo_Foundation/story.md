# Storie-02: Implementar Módulo Terraform 00-Foundation

## Status
- **Estado:** 🔄 Em desenvolvimento
- **Data de Conclusão:** [DD/MM/AAAA]

## Descrição
Como desenvolvedor de infraestrutura, quero que o módulo `terraform/00-foundation` esteja implementado com providers, locals (tags e naming), variáveis globais, outputs base e backend opcional, para que os demais módulos possam reutilizar convenções e o Terraform seja compilável e validável sem criar recursos AWS além do necessário.

## Objetivo
Implementar o módulo `terraform/00-foundation` com: `providers.tf` (AWS provider, required_version, required_providers), `locals.tf` (tags padrão e convenção de naming com prefixo `video-processing-engine-${var.environment}`), `variables.tf` (variáveis globais: environment, region, owner, retention_days, enable_* flags), `outputs.tf` (account_id, region, prefix, common_tags) e backend remoto opcional e configurável que não impeça execução local. Garantir `terraform fmt` e `terraform validate`. Nenhum recurso AWS além do necessário para provider/locals (sem S3 backend obrigatório).

## Escopo Técnico
- Tecnologias: Terraform >= 1.0, AWS Provider (família ~> 5.0)
- Arquivos afetados:
  - `terraform/00-foundation/providers.tf`
  - `terraform/00-foundation/locals.tf`
  - `terraform/00-foundation/variables.tf`
  - `terraform/00-foundation/outputs.tf`
  - `terraform/00-foundation/backend.tf` (opcional)
- Componentes/Recursos: Blocos terraform (required_version, required_providers), provider aws, locals (common_tags, naming prefix), variáveis e outputs; nenhum recurso aws_* além do estritamente necessário (ex.: data sources para account_id se necessário).
- Pacotes/Dependências: Nenhum pacote externo; apenas Terraform e provider AWS via required_providers.

## Dependências e Riscos (para estimativa)
- Dependências: Storie-01 (Bootstrap) concluída ou ao menos a árvore `terraform/00-foundation/` e `terraform/envs/dev.tfvars` existentes.
- Riscos/Pré-condições: Backend S3 opcional exige bucket e DynamoDB existentes se habilitado; execução local deve funcionar sem backend remoto (backend vazio ou -backend=false).

## Modelo de execução (root único)
O diretório `terraform/00-foundation/` é um **módulo** consumido pelo **root** em `terraform/` (Storie-02-Parte2). Init/plan/apply são executados **uma vez** a partir de `terraform/`; o root repassa variáveis ao módulo foundation e usa seus outputs (prefix, common_tags) nos demais módulos.

## Subtasks
- [Subtask 01: Criar providers.tf com required_version, required_providers e AWS provider](./subtask/Subtask-01-Providers_Tf.md)
- [Subtask 02: Implementar locals.tf com tags padrão e convenção de naming](./subtask/Subtask-02-Locals_Tags_Naming.md)
- [Subtask 03: Definir variables.tf (globais) e outputs.tf (base)](./subtask/Subtask-03-Variables_Outputs.md)
- [Subtask 04: Configurar backend remoto opcional sem bloquear execução local](./subtask/Subtask-04-Backend_Opcional.md)
- [Subtask 05: Validar módulo com terraform fmt e terraform validate e garantir reutilização](./subtask/Subtask-05-Validacao_Reutilizacao.md)

## Critérios de Aceite da História
- [ ] `terraform/00-foundation/providers.tf` existe com required_version >= "1.0", required_providers (aws ~> 5.0) e provider aws com region = var.region
- [ ] `terraform/00-foundation/locals.tf` define tags padrão (Project, Environment, ManagedBy, Owner) e prefixo de naming `video-processing-engine-${var.environment}`
- [ ] `terraform/00-foundation/variables.tf` declara variáveis globais: environment, region, owner, retention_days e pelo menos um enable_* flag; sem valores sensíveis
- [ ] `terraform/00-foundation/outputs.tf` expõe account_id, region, prefix (naming), common_tags; módulo consumível por outros módulos
- [ ] Backend remoto é opcional e configurável; execução local possível sem backend (init -backend=false ou backend vazio/comentado)
- [ ] Nenhum recurso AWS criado além do necessário para provider/locals (ex.: data "aws_caller_identity" para account_id é permitido)
- [ ] `terraform fmt -recursive` e `terraform validate` executados no root (`terraform/`) ou em `terraform/00-foundation/` retornam sucesso
- [ ] Módulo é consumido pelo root (Storie-02-Parte2) e reutilizável pelos demais módulos (outputs e variáveis documentados ou autoexplicativos)

## Checklist de Conclusão
- [ ] Todos os arquivos .tf do módulo 00-foundation criados/atualizados
- [ ] terraform init (com -backend=false localmente) executa sem erro
- [ ] terraform fmt -recursive aplicado
- [ ] terraform validate retorna "Success! The configuration is valid."
- [ ] Nenhuma credencial ou ARN hardcoded; região e environment parametrizados
