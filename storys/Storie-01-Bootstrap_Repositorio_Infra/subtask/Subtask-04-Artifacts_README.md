# Subtask 04: Criar artifacts/empty.zip e README com visão geral e plano de evolução

## Descrição
Criar o diretório `artifacts/` e o arquivo `artifacts/empty.zip` (ou placeholder que indique o uso futuro para artefatos de build/deploy). Atualizar ou criar o `README.md` na raiz do repositório com visão geral do projeto e plano de evolução contendo a lista das stories e a ordem de execução planejada.

## Passos de implementação
1. Criar o diretório `artifacts/` na raiz do repositório.
2. Gerar ou adicionar `artifacts/empty.zip`: um arquivo ZIP vazio (ou com um arquivo de texto placeholder, ex.: `.gitkeep` ou `README.txt` com texto "Placeholder para artefatos") para que o diretório seja versionado e o caminho esteja disponível para pipelines futuros.
3. Criar ou atualizar `README.md` na raiz com: título do projeto (Video Processing Engine - Infraestrutura), breve descrição do repositório (IaC Terraform para o projeto Video Processing Engine), visão geral da estrutura de pastas (`terraform/00-foundation` a `70-orchestration`, `envs/`, `.github/workflows/`, `artifacts/`).
4. Incluir no README uma seção "Plano de evolução" ou "Stories e ordem de execução" com a lista das stories planejadas (ex.: Storie-01 Bootstrap, Storie-02 Foundation, Storie-03 Storage, etc.) e a ordem recomendada de execução, sem necessidade de detalhar stories ainda não escritas.

## Formas de teste
1. Verificar que `artifacts/` existe e que `artifacts/empty.zip` existe e é um arquivo ZIP válido (ou que um placeholder está presente).
2. Ler o README e confirmar que contém visão geral e seção de plano de evolução com lista de stories e ordem.
3. Confirmar que a estrutura de pastas descrita no README coincide com a estrutura real do repo.

## Critérios de aceite da subtask
- [ ] O diretório `artifacts/` existe e contém `empty.zip` (ou placeholder equivalente) versionável.
- [ ] O `README.md` na raiz contém visão geral do repositório e descrição da estrutura (terraform, workflows, artifacts).
- [ ] O README contém plano de evolução com lista das stories e ordem de execução planejada.
