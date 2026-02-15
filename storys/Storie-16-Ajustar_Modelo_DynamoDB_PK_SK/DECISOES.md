# Decisões a Serem Tomadas Durante Implementação

Este arquivo documenta as principais decisões que devem ser tomadas durante a implementação da Storie-16.

## Decisão 1: Nomenclatura de GSI

**Quando:** Subtask 01 (Análise de Impacto)

**Opções:**

### Opção A: Consistência total (minúsculas)
- GSI usa `gsi1pk` e `gsi1sk` (minúsculas)
- **Prós:**
  - Nomenclatura 100% consistente com `pk`/`sk`
  - Padrão moderno (single-table design)
  - Melhor para projetos greenfield
- **Contras:**
  - Requer ajuste em código Lambda que já usa `GSI1PK`/`GSI1SK`

### Opção B: Mudança mínima (manter maiúsculas)
- GSI mantém `GSI1PK` e `GSI1SK` (maiúsculas)
- **Prós:**
  - Menor impacto no código Lambda
  - Apenas `pk`/`sk` mudam (tabela principal)
- **Contras:**
  - Inconsistência de nomenclatura

**Critério de decisão:**
- Se código Lambda ainda não está implementado ou é fácil ajustar → **Opção A**
- Se código Lambda já está em produção/staging → **Opção B**

**Documentar em:** `Subtask-01-Analise_Impacto.md` (seção "Decisão de GSI")

---

## Decisão 2: Estratégia de Backup (se necessário)

**Quando:** Subtask 05 (Validação e Execução)

**Opções:**

### Opção A: Sem backup (hackathon)
- Não criar snapshot antes de apply
- **Prós:** mais rápido, sem custo adicional
- **Contras:** dados não recuperáveis se algo der errado
- **Contexto:** dados efêmeros (hackathon/MVP)

### Opção B: Com backup
- Criar snapshot antes de apply: `aws dynamodb create-backup --table-name <nome> --backup-name pre-migration-backup`
- **Prós:** dados recuperáveis
- **Contras:** tempo adicional (~5-10 min), custo de storage do backup
- **Contexto:** ambiente com dados importantes

**Critério de decisão:**
- Ambiente de hackathon/MVP → **Opção A**
- Ambiente de produção/staging com dados críticos → **Opção B**

**Documentar em:** `Subtask-05-Validacao_Execucao.md` (seção "Checklist pré-apply")

---

## Decisão 3: Ordem de Execução (ajuste de código Lambda)

**Quando:** Subtask 01 (Análise de Impacto) e Subtask 05 (Validação e Execução)

**Opções:**

### Opção A: Lambda primeiro, depois infra
1. Ajustar código Lambda para usar `pk`/`sk`
2. Fazer deploy do código Lambda
3. Executar `terraform apply` (recriação da tabela)
- **Prós:** Lambda já está preparado quando tabela for recriada; sem downtime de código incorreto
- **Contras:** Lambda pode ter erro temporário (tabela ainda usa `PK`/`SK` por alguns minutos)

### Opção B: Infra primeiro, depois Lambda
1. Executar `terraform apply` (recriação da tabela)
2. Ajustar código Lambda para usar `pk`/`sk`
3. Fazer deploy do código Lambda
- **Prós:** menos passos
- **Contras:** Lambda terá erro (usa `PK`/`SK` mas tabela usa `pk`/`sk`) até deploy do código

### Opção C: Simultâneo (ideal para hackathon)
- Ajustar código Lambda e commitar
- Executar `terraform apply`
- Deploy automático do Lambda (via CI/CD)
- **Prós:** downtime mínimo
- **Contras:** requer CI/CD configurado

**Critério de decisão:**
- Se código Lambda precisa ajuste e CI/CD está configurado → **Opção C**
- Se código Lambda precisa ajuste e deploy é manual → **Opção A**
- Se código Lambda não existe ou não precisa ajuste → executar apenas Terraform

**Documentar em:** `Subtask-01-Analise_Impacto.md` (seção "Estratégia de migração")

---

## Decisão 4: Point-in-Time Recovery (PITR)

**Quando:** Durante revisão de `terraform/20-data/variables.tf` e `dynamodb.tf`

**Status atual:** PITR não está habilitado (AWS default)

**Opções:**

### Opção A: Não habilitar (padrão)
- Sem backup automático
- **Prós:** sem custo adicional (~20% do storage)
- **Contras:** recuperação requer snapshot manual
- **Contexto:** hackathon, dados efêmeros

### Opção B: Habilitar (produção)
- Adicionar variável `var.enable_pitr` (default = false)
- Adicionar bloco em `dynamodb.tf`:
  ```hcl
  point_in_time_recovery {
    enabled = var.enable_pitr
  }
  ```
- **Prós:** recuperação para qualquer ponto nos últimos 35 dias
- **Contras:** custo adicional
- **Contexto:** produção, dados críticos

**Critério de decisão:**
- Hackathon/MVP → **Opção A** (não habilitar)
- Produção → **Opção B** (adicionar variável para habilitar quando necessário)

**Documentar em:** `story.md` (seção "Decisões Técnicas") e `README.md` (seção "Point-in-Time Recovery")

---

## Resumo de Decisões Obrigatórias

| # | Decisão | Quando | Documentar em |
|---|---------|--------|---------------|
| 1 | Nomenclatura de GSI (minúsculas ou maiúsculas) | Subtask 01 | Subtask-01 + story.md |
| 2 | Backup antes de apply (sim ou não) | Subtask 05 | Subtask-05 |
| 3 | Ordem de execução (Lambda antes/depois/simultâneo) | Subtask 01 | Subtask-01 |

## Resumo de Decisões Opcionais

| # | Decisão | Quando | Documentar em |
|---|---------|--------|---------------|
| 4 | Habilitar PITR (sim ou não) | Durante revisão de código | README.md |

---

## Checklist de Decisões

- [ ] **Decisão 1 (GSI):** Opção A ou B escolhida e documentada
- [ ] **Decisão 2 (Backup):** Estratégia definida (com ou sem snapshot)
- [ ] **Decisão 3 (Ordem):** Ordem de execução definida (Lambda antes/depois/simultâneo)
- [ ] **Decisão 4 (PITR):** Decisão tomada (habilitar ou não; adicionar variável ou deixar para futuro)

---

**Nota:** Todas as decisões devem ser documentadas nos arquivos apropriados (subtasks, story.md, README.md) para rastreabilidade.
