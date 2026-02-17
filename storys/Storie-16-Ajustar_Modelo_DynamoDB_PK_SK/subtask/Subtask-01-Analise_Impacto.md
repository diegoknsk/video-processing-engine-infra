# Subtask 01: Análise de impacto (código Lambdas, referências PK/SK/GSI)

## Descrição
Analisar o impacto da mudança de nomenclatura de chaves DynamoDB (`PK`/`SK` → `pk`/`sk`) no código de Lambdas existente (módulo 50-lambdas-shell) e em outros módulos que referenciam a tabela. Identificar todos os pontos de ajuste necessários (código Lambda, IAM policies, documentação) e documentar estratégia de migração. Decidir nomenclatura de GSI (manter maiúsculas ou migrar para minúsculas).

## Contexto
A tabela DynamoDB atual usa:
- `hash_key = "PK"`, `range_key = "SK"` (maiúsculas)
- GSI: `GSI1PK`, `GSI1SK` (maiúsculas)

A mudança para `pk`/`sk` (minúsculas) força recriação da tabela (destroy + create). Código de Lambdas que usa `PK`/`SK` diretamente (ex.: em operações de DynamoDB SDK) precisa ser ajustado.

## Passos de implementação
1. **Buscar referências a PK/SK no código:**
   - Executar grep/busca em `terraform/50-lambdas-shell/` e outros módulos para identificar menções a `PK`, `SK`, `GSI1PK`, `GSI1SK`
   - Verificar código de Lambdas (se houver inline code, ou referências em variáveis de ambiente, policies IAM)
   - Verificar README e documentação de módulos (ex.: `terraform/50-lambdas-shell/README.md`, `terraform/70-orchestration/README.md`)

2. **Analisar código Lambda (se aplicável):**
   - Se código Lambda está em repositório separado (não neste repo de infra), documentar que ajuste será necessário na aplicação
   - Se código Lambda está inline ou em `lambda/` neste repo, listar arquivos a serem ajustados
   - Identificar operações DynamoDB: `getItem({ Key: { PK, SK } })`, `query({ KeyConditionExpression: "PK = :pk" })`, etc.

3. **Decidir nomenclatura de GSI:**
   - **Opção A:** migrar GSI para minúsculas (`gsi1pk`, `gsi1sk`) — consistência total
   - **Opção B:** manter GSI em maiúsculas (`GSI1PK`, `GSI1SK`) — menor impacto no código Lambda
   - **Critério de decisão:** se código Lambda ainda não está implementado ou é fácil ajustar → Opção A; se código Lambda já está hardcoded e complexo → Opção B
   - Documentar decisão no arquivo `DECISION.md` (ou neste subtask)

4. **Documentar estratégia de migração:**
   - **Ambiente:** hackathon (efêmero), recriação de tabela é aceitável
   - **Downtime:** tabela será destruída e recriada; aplicação deve ter retry logic (ou aceitar erro temporário)
   - **Ordem de execução:**
     1. Ajustar código Lambda (se necessário) e commitar/deploy
     2. Ajustar Terraform (`dynamodb.tf`)
     3. Executar `terraform plan` e revisar plano de recriação
     4. Executar `terraform apply`
     5. Validar schema com `aws dynamodb describe-table`
   - **Backup:** não necessário em hackathon; em produção, criar snapshot antes de apply

5. **Listar arquivos impactados:**
   - `terraform/20-data/dynamodb.tf` (schema)
   - `terraform/20-data/README.md` (documentação)
   - Código Lambda (se houver): `lambda/<função>/index.js` ou repositório externo
   - Possivelmente: `terraform/50-lambdas-shell/iam.tf` (se policies referenciam attribute names — improvável)
   - Possivelmente: `terraform/70-orchestration/README.md` (exemplos de payload)

## Formas de teste
1. Executar busca por `"PK"`, `"SK"`, `"GSI1PK"`, `"GSI1SK"` em:
   - `terraform/` (grep recursivo)
   - Repositório de aplicação/Lambda (se separado)
2. Revisar resultados e classificar:
   - **Ajuste necessário:** código que usa chaves diretamente (ex.: `Key: { PK, SK }`)
   - **Ajuste opcional:** documentação/comentários
   - **Sem ajuste:** referências em `dynamodb.tf` (serão ajustadas na Subtask 02)
3. Validar que nenhum código crítico será quebrado sem ajuste (ou documentar que ajuste na aplicação é pré-requisito)

## Critérios de aceite da subtask
- [ ] Busca por `PK`, `SK`, `GSI1PK`, `GSI1SK` executada em `terraform/` e resultados documentados
- [ ] Lista de arquivos/módulos impactados pela mudança documentada (ex.: Lambda functions, IAM policies, README)
- [ ] Decisão sobre nomenclatura de GSI tomada e justificada (Opção A: minúsculas / Opção B: maiúsculas)
- [ ] Estratégia de migração documentada (ordem de execução, downtime esperado, backup)
- [ ] Se código Lambda precisa ajuste, está documentado qual ajuste (ex.: trocar `PK` por `pk` em operações DynamoDB)
- [ ] Arquivo `IMPACTO.md` ou seção no README da story com resumo da análise

## Saída esperada
Documento de análise de impacto (pode ser adicionado ao `story.md` ou em arquivo separado `IMPACTO.md`) contendo:

1. **Referências encontradas:**
   - Arquivo/linha: descrição do uso (ex.: `dynamodb.tf:10` — definição de hash_key)
   - Classificação: ajuste necessário / ajuste opcional / sem ajuste

2. **Código Lambda (se aplicável):**
   - Lista de funções que usam DynamoDB
   - Operações que precisam ajuste (ex.: `getItem`, `putItem`, `query`)
   - Exemplo de código antes/depois (opcional)

3. **Decisão de GSI:**
   - Opção escolhida (A ou B)
   - Justificativa (ex.: "Opção A escolhida pois código Lambda ainda não está implementado; priorizar consistência")

4. **Estratégia de migração:**
   - Checklist de passos
   - Estimativa de downtime (ex.: "~2-5 minutos para recriação da tabela vazia")
   - Plano de rollback (ex.: reverter commit Terraform e executar `terraform apply` novamente)

5. **Recomendações:**
   - Ex.: "Executar `terraform apply` fora de horário de pico (se aplicável)"
   - Ex.: "Garantir que Lambdas têm retry logic para tolerar erro temporário de tabela inexistente"
