# Storie-24: DynamoDB — Tabela de Status de Chunks de Vídeo

## Status
- **Estado:** 🔄 Em desenvolvimento
- **Data de Conclusão:** —

## Descrição
Como engenheiro de infraestrutura, quero provisionar uma nova tabela DynamoDB para persistir o status individual de cada chunk de processamento de vídeo, para que o progresso do vídeo possa ser calculado por contagem de chunks concluídos sem modificar a tabela principal de vídeos.

## Objetivo
Criar uma nova tabela DynamoDB `{prefix}-video-chunks` no módulo `terraform/20-data`, com chave composta `pk` (videoId) + `sk` (chunkId), campos básicos de rastreamento de status por chunk, TTL opcional e outputs necessários para consumo futuro pelo Lambda Update Status. A tabela principal de vídeos **não deve ser alterada**.

---

## Contexto Arquitetural

O orquestrador (Step Function com Map State — Storie-23) divide o vídeo em `n` chunks e os processa em paralelo. Cada execução do Lambda `video-processor` processa um chunk e, no futuro, o Lambda `update-status` precisará registrar o resultado de cada chunk individualmente. O progresso geral do vídeo será derivado da razão `chunks_concluídos / total_chunks`.

Fluxo de escrita esperado (futuro):
```
Map State (parallel) ──► Lambda video-processor ──► Lambda update-status
                                                         └──► PutItem / UpdateItem em {prefix}-video-chunks
                                                         └──► Calcula progresso (count COMPLETED / total)
                                                         └──► Atualiza status em {prefix}-videos (tabela principal)
```

---

## Modelagem da Tabela

### Chaves
| Atributo | Tipo | Papel | Formato |
|----------|------|-------|---------|
| `pk` | String | Partition Key (HASH) | `VIDEO#{videoId}` |
| `sk` | String | Sort Key (RANGE) | `CHUNK#{chunkIndex}` |

### Campos básicos do item
```json
{
  "pk":           "VIDEO#<uuid>",
  "sk":           "CHUNK#<índice>",
  "videoId":      "<uuid>",
  "chunkIndex":   0,
  "totalChunks":  10,
  "status":       "PENDING | PROCESSING | COMPLETED | FAILED",
  "createdAt":    "2026-03-12T10:00:00Z",
  "updatedAt":    "2026-03-12T10:05:00Z",
  "errorMessage": "mensagem descritiva (apenas quando FAILED)",
  "TTL":          1234567890
}
```

> `videoId` e `chunkIndex` são repetidos como atributos escalares para facilitar projeções e acesso direto; `TTL` é opcional e ativado por variável.

### Padrões de acesso suportados
| Operação | Chave | Caso de uso |
|----------|-------|-------------|
| `Query` por videoId | `pk = VIDEO#{videoId}` | Listar todos os chunks de um vídeo (calcular progresso) |
| `GetItem` específico | `pk = VIDEO#{videoId}`, `sk = CHUNK#{idx}` | Verificar status de um chunk específico |
| `UpdateItem` condicional | `pk = VIDEO#{videoId}`, `sk = CHUNK#{idx}` | Atualizar status de chunk (idempotente) |
| `Query` com filter | `pk = VIDEO#{videoId}`, `filter status = COMPLETED` | Contar chunks concluídos para calcular progresso |

> Nenhum GSI é necessário nesta story: o acesso sempre parte do `videoId`, que é o Partition Key.

---

## Escopo Técnico
- **Tecnologias:** Terraform >= 1.0, AWS Provider (~> 5.0), AWS DynamoDB
- **Arquivos afetados:**
  - `terraform/20-data/dynamodb-chunks.tf` — novo arquivo com `aws_dynamodb_table.video_chunks`
  - `terraform/20-data/variables.tf` — novas variáveis para a tabela de chunks
  - `terraform/20-data/outputs.tf` — novos outputs (`chunks_table_name`, `chunks_table_arn`)
  - `terraform/20-data/README.md` — documentação do modelo pk/sk da nova tabela
  - `terraform/main.tf` — expor outputs do módulo `20-data` no root (se necessário)
- **Componentes/Recursos:**
  - `aws_dynamodb_table.video_chunks` — novo recurso; tabela independente da `aws_dynamodb_table.videos`
  - Outputs: `chunks_table_name`, `chunks_table_arn`
- **Pacotes/Dependências:** Nenhum; sem dependências externas novas.

---

## Dependências e Riscos (para estimativa)
- **Dependências:**
  - Storie-04 (módulo `20-data` base) — concluída
  - Storie-16 (ajuste pk/sk da tabela principal) — concluída; padrão de nomenclatura `pk`/`sk` já estabelecido
  - Storie-23 (Map State Step Function) — fornece o contexto de chunks; não é bloqueante para esta story
- **Riscos/Pré-condições:**
  - Nenhuma alteração na tabela `{prefix}-videos` existente; risco de impacto na tabela principal é zero
  - A tabela de chunks não possui dados em produção; criação é pura adição de recurso novo
  - IAM para o Lambda Update Status acessar a nova tabela fica fora do escopo desta story (será endereçado na story de integração do Lambda)
  - Credenciais AWS (Access Key + Secret + Session Token) são necessárias para `terraform validate` e `terraform plan`

---

## Subtasks
- [x] [Subtask 01: Análise do módulo 20-data e definição da estrutura da nova tabela](./subtask/Subtask-01-Analise_Modulo_Data_Planejamento.md)
- [x] [Subtask 02: Criar recurso aws_dynamodb_table video-chunks](./subtask/Subtask-02-Recurso_DynamoDB_Video_Chunks.md)
- [x] [Subtask 03: Variáveis, outputs e integração com o root](./subtask/Subtask-03-Variaveis_Outputs_Root.md)
- [x] [Subtask 04: Documentação do modelo e validação Terraform](./subtask/Subtask-04-Documentacao_Validacao.md)

---

## Critérios de Aceite da História
- [x] Nova tabela `{prefix}-video-chunks` criada pelo Terraform com `hash_key = "pk"` (S) e `range_key = "sk"` (S), sem alterar a tabela `{prefix}-videos`
- [x] Atributos declarados no `attribute` block: `pk` (S) e `sk` (S); campos adicionais (`videoId`, `chunkIndex`, `totalChunks`, `status`, `createdAt`, `updatedAt`, `errorMessage`, `TTL`) documentados mas não declarados como atributos de chave
- [x] TTL opcional: variável `enable_chunks_ttl` (bool, default = false) controla a ativação; atributo `TTL` configurável via `chunks_ttl_attribute_name`
- [x] Billing mode configurável via variável `chunks_billing_mode` (default = `PAY_PER_REQUEST`)
- [x] Tags obrigatórias aplicadas: `Name`, `Environment`, `Project` (via `var.common_tags` do foundation)
- [x] Outputs adicionados ao módulo `20-data`: `chunks_table_name` (string) e `chunks_table_arn` (string)
- [x] `README.md` do módulo `20-data` atualizado com modelo de item da nova tabela, padrões `VIDEO#{videoId}` / `CHUNK#{chunkIndex}` e padrões de acesso
- [x] `terraform fmt -recursive` executado sem alterações (código já formatado)
- [x] `terraform validate` no root (`terraform/`) retorna "Success! The configuration is valid."
- [x] `terraform plan` no root não apresenta erros; mostra `+ create` apenas para `aws_dynamodb_table.video_chunks`; nenhum `destroy` ou `update` em outros recursos

---

## Rastreamento (dev tracking)
- **Início:** dia 12/03/2026 (Brasília) — [preencher horário real ao iniciar a sessão]
- **Fim:** —
- **Tempo total de desenvolvimento:** —
