# Subtask 01: Criar árvore de diretórios Terraform e arquivos-base placeholder

## Descrição
Criar a árvore completa de diretórios do Terraform conforme estrutura obrigatória do repositório e adicionar arquivos-base vazios ou com conteúdo placeholder em cada módulo, sem criar recursos AWS. Cada módulo deve ter pelo menos um arquivo que permita evolução posterior alinhada às infrarules (ex.: `main.tf` ou `README.md` com propósito do módulo).

## Passos de implementação
1. Criar os diretórios: `terraform/00-foundation/`, `terraform/10-storage/`, `terraform/20-data/`, `terraform/30-messaging/`, `terraform/40-auth/`, `terraform/50-lambdas-shell/`, `terraform/60-api/`, `terraform/70-orchestration/`.
2. Criar o diretório de ambientes: `terraform/envs/` e o arquivo `terraform/envs/dev.tfvars` com variáveis placeholder (ex.: `env = "dev"`, `project_name = "video-processing-engine"`), sem valores sensíveis.
3. Em cada módulo (00 a 70), adicionar pelo menos um arquivo: `main.tf` com comentário descrevendo o propósito do módulo e que recursos serão criados nas stories futuras (placeholder), ou um `README.md` equivalente, seguindo a organização um-arquivo-por-responsabilidade das infrarules quando houver código real.
4. Garantir que nenhum bloco `resource "aws_*"` seja criado; apenas comentários, variáveis vazias ou blocos vazios/placeholder.

## Formas de teste
1. Listar recursivamente `terraform/` e verificar que todos os diretórios e arquivos existem (ex.: `Get-ChildItem -Recurse` ou `find terraform -type f`).
2. Conferir que `terraform/envs/dev.tfvars` existe e contém apenas variáveis de ambiente/identificação (sem credenciais).
3. Buscar por `resource "aws_` em todos os `.tf` do repo e confirmar que não há ocorrências (nenhum recurso AWS criado).

## Critérios de aceite da subtask
- [ ] Existem os diretórios `terraform/00-foundation/`, `10-storage/`, `20-data/`, `30-messaging/`, `40-auth/`, `50-lambdas-shell/`, `60-api/`, `70-orchestration/` e `terraform/envs/`.
- [ ] Existe o arquivo `terraform/envs/dev.tfvars` com conteúdo placeholder (env, project_name ou equivalente), sem credenciais.
- [ ] Cada módulo 00 a 70 possui pelo menos um arquivo (`.tf` ou `README.md`) descrevendo o propósito do módulo; nenhum recurso AWS está declarado.
