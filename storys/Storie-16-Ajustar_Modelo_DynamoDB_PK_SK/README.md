# 📚 Storie-16: Ajustar Modelo DynamoDB para Padrão pk/sk

## 🎯 Visão Geral

Esta story ajusta a tabela DynamoDB do módulo `terraform/20-data` para usar nomenclatura correta de chaves (`pk`/`sk` em minúsculas) com padrão `USER#{userId}` e `VIDEO#{videoId}`, suportando operações idempotentes, processamento paralelo e consultas otimizadas.

---

## 📂 Estrutura da Story

```
Storie-16-Ajustar_Modelo_DynamoDB_PK_SK/
├── README.md                          ← Você está aqui (índice geral)
├── story.md                           ← Story completa (descrição, critérios de aceite)
├── RESUMO.md                          ← Resumo visual rápido (ideal para apresentação)
├── MODELO.md                          ← Diagrama antes/depois do modelo de dados
├── DECISOES.md                        ← Decisões técnicas a serem tomadas
└── subtask/
    ├── Subtask-01-Analise_Impacto.md
    ├── Subtask-02-Ajuste_Schema_DynamoDB.md
    ├── Subtask-03-Atualizacao_GSI.md
    ├── Subtask-04-Documentacao_Modelo.md
    └── Subtask-05-Validacao_Execucao.md
```

---

## 📖 Guia de Leitura Rápida

### 🚀 Se você quer começar AGORA
1. Leia: `RESUMO.md` (3-5 minutos)
2. Revise: `MODELO.md` (entender antes/depois)
3. Inicie: `Subtask-01-Analise_Impacto.md`

### 🔍 Se você quer ENTENDER TUDO
1. Leia: `story.md` (completo, ~15 minutos)
2. Revise: `DECISOES.md` (decisões técnicas)
3. Consulte: `MODELO.md` (diagrama detalhado)
4. Execute: subtasks na ordem (01 → 05)

### 📊 Se você vai APRESENTAR ao time
1. Abra: `RESUMO.md` (formatação visual)
2. Use: `MODELO.md` (diagrama antes/depois)
3. Destaque: critérios de aceite em `story.md`

---

## 🎯 Problema e Solução

### ❌ Problema
A tabela DynamoDB atual usa `PK`/`SK` (maiúsculas), mas a especificação requer `pk`/`sk` (minúsculas) com padrão `USER#{userId}` e `VIDEO#{videoId}`.

### ✅ Solução
Ajustar schema Terraform para:
- `hash_key = "pk"` (minúscula)
- `range_key = "sk"` (minúscula)
- Padrão de valores: `pk: USER#{userId}`, `sk: VIDEO#{videoId}`

### ⚠️ Impacto
- Recriação de tabela (destroy + create)
- Downtime: ~2-5 minutos
- Perda de dados (aceitável em hackathon)

---

## 📋 Subtasks (Resumo)

| # | Subtask | Estimativa | Descrição |
|---|---------|------------|-----------|
| 01 | Análise de Impacto | 1-2h | Buscar referências PK/SK no código; decidir nomenclatura GSI |
| 02 | Ajuste Schema | 30min | Trocar `PK`→`pk`, `SK`→`sk` em `dynamodb.tf` |
| 03 | Atualização GSI | 30min | Ajustar GSI (minúsculas ou manter maiúsculas) |
| 04 | Documentação | 2-3h | README completo com modelo, padrões, exemplos |
| 05 | Validação/Execução | 1-2h | `terraform plan`, `apply`, `describe-table`, testes |

**Total estimado:** 5-8 horas

---

## ✅ Critérios de Aceite (Principais)

- [ ] Schema DynamoDB usa `pk`/`sk` (minúsculas)
- [ ] GSI nomenclatura definida e implementada
- [ ] README documenta modelo completo (padrões USER#/VIDEO#)
- [ ] README explica vantagens (idempotência, paralelismo)
- [ ] `terraform validate` passa sem erros
- [ ] `terraform apply` executado com sucesso
- [ ] `describe-table` confirma schema correto
- [ ] Código Lambda ajustado (se necessário)

**Ver `story.md` para lista completa de critérios (15 itens).**

---

## 🚦 Status

- **Estado:** 🔄 Em Progresso
- **Criada em:** 14/02/2026
- **Início dev:** — (preencher quando iniciar)
- **Fim dev:** — (preencher quando concluir)

---

## 🔗 Links Rápidos

- [Story Completa](./story.md) — Descrição detalhada, escopo técnico, critérios de aceite
- [Resumo Visual](./RESUMO.md) — Ideal para apresentação ao time
- [Modelo de Dados](./MODELO.md) — Diagrama antes/depois, exemplos de código
- [Decisões Técnicas](./DECISOES.md) — Decisões a serem tomadas (GSI, backup, ordem de execução)
- [Subtask 01](./subtask/Subtask-01-Analise_Impacto.md) — Primeira subtask (análise de impacto)

---

## 📝 Notas Importantes

### ⚠️ Antes de Implementar
1. **Revisar código Lambda:** buscar referências a `PK`, `SK`, `GSI1PK`, `GSI1SK`
2. **Decidir nomenclatura GSI:** minúsculas (consistência) ou maiúsculas (menor impacto)?
3. **Confirmar ambiente:** é hackathon/efêmero? (recriação de tabela é aceitável?)

### ✅ Durante Implementação
1. **Seguir ordem das subtasks:** 01 → 02 → 03 → 04 → 05
2. **Documentar decisões:** atualizar `DECISOES.md` com escolhas feitas
3. **Validar cada etapa:** `terraform validate` após cada mudança

### 🎯 Após Conclusão
1. **Validar schema:** `aws dynamodb describe-table`
2. **Testar operações:** PutItem, GetItem, Query (tabela + GSI)
3. **Atualizar status:** marcar story como ✅ Concluída com data

---

## 🤝 Contribuindo

Se você identificar melhorias ou erros:
1. Revise a subtask correspondente
2. Atualize a documentação relevante
3. Valide com `terraform validate` e `terraform plan`

---

## 📞 Suporte

- **Dúvidas sobre modelo de dados:** ver `MODELO.md`
- **Dúvidas sobre decisões técnicas:** ver `DECISOES.md`
- **Dúvidas sobre implementação:** ver subtasks em `subtask/`

---

**Última atualização:** 14/02/2026  
**Versão:** 1.0
