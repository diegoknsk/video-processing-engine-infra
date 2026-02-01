# Storie-01: Bootstrap do Repositório de Infraestrutura

## Status
- **Estado:** 🔄 Em desenvolvimento
- **Data de Conclusão:** [DD/MM/AAAA]

## Descrição
Como arquiteto/DevOps, quero que o repositório `video-processing-engine-infra` tenha estrutura de diretórios, padrões, placeholders e pipelines base definidos, para que as próximas stories possam provisionar módulos de forma consistente sem criar recursos AWS nesta etapa.

## Objetivo
Deixar o repositório pronto para receber os módulos Terraform e GitHub Actions: árvore de diretórios, arquivos-base vazios ou placeholder, convenções de naming/tags/variáveis/outputs, scaffold de workflows e README com visão geral e plano de evolução. Nenhum recurso AWS será criado nesta story.

## Escopo Técnico
- Tecnologias: Terraform (estrutura e convenções), GitHub Actions (scaffold YAML), Markdown
- Arquivos afetados:
  - `terraform/00-foundation/`, `10-storage/`, `20-data/`, `30-messaging/`, `40-auth/`, `50-lambdas-shell/`, `60-api/`, `70-orchestration/`
  - `terraform/envs/dev.tfvars`
  - `.github/workflows/` (placeholders)
  - `README.md`
  - `artifacts/empty.zip`
- Componentes/Recursos: Estrutura de pastas, `locals.tf` (tags padrão), `variables.tf` e `outputs.tf` de convenção no foundation, arquivos `.tf` e `.tfvars` placeholder, workflows placeholder
- Pacotes/Dependências: Nenhum pacote externo (apenas estrutura e arquivos de configuração)

## Dependências e Riscos (para estimativa)
- Dependências: Nenhuma outra story; depende apenas do documento [docs/contexto-arquitetural.md](../docs/contexto-arquitetural.md).
- Riscos/Pré-condições: Nenhum crítico; pré-condição: repositório clonado e contexto arquitetural lido.

## Ordem de Execução das Stories (visão para documentação)
A ordem planejada dos módulos, alinhada ao desenho **Processador Video MVP + Fan-out** (contexto arquitetural), será documentada no README e na Subtask 05. Resumo: Foundation → Storage → Data → Messaging → Auth → Lambdas (shell) → API → Orchestration.

## Subtasks
- [Subtask 01: Criar árvore de diretórios Terraform e arquivos-base placeholder](./subtask/Subtask-01-Arvore_Diretorios_Placeholders.md)
- [Subtask 02: Definir padrões naming, tags, variáveis globais e convenções de outputs](./subtask/Subtask-02-Padroes_Naming_Tags_Variaveis.md)
- [Subtask 03: Preparar scaffold GitHub Actions (workflows placeholder)](./subtask/Subtask-03-Scaffold_GitHub_Actions.md)
- [Subtask 04: Criar artifacts/empty.zip e README com visão geral e plano de evolução](./subtask/Subtask-04-Artifacts_README.md)
- [Subtask 05: Documentar ordem de execução das stories e conexão dos módulos ao Processador Video MVP + Fan-out](./subtask/Subtask-05-Documentacao_Ordem_Modulos.md)

## Critérios de Aceite da História
- [ ] Existe a árvore completa `terraform/00-foundation/` até `70-orchestration/` e `terraform/envs/dev.tfvars`, cada módulo com pelo menos um arquivo `.tf` ou placeholder conforme infrarules
- [ ] Padrão de naming `video-processing-engine-{env}-*` e tags padrão (Project, Environment, ManagedBy, Owner) definidos em locals no foundation (placeholder ou arquivo de convenção)
- [ ] Variáveis globais e convenções de outputs documentadas ou declaradas no foundation (variables.tf/outputs.tf ou README do módulo)
- [ ] `.github/workflows/` contém pelo menos um workflow placeholder (ex.: terraform-plan.yml ou bootstrap.yml) sem apply real
- [ ] `artifacts/empty.zip` existe no repositório (ou placeholder que indique uso futuro)
- [ ] README.md na raiz contém visão geral do repo e plano de evolução com lista das stories e ordem de execução
- [ ] Documentação descreve como cada módulo (00 a 70) se conecta ao desenho Processador Video MVP + Fan-out do contexto arquitetural
- [ ] `terraform validate` não é obrigatório nesta story (estrutura pode ter apenas placeholders); nenhum recurso AWS é provisionado
