# Subtask 05: DoD e checklist final; validação

## Descrição
Garantir que a story inclua **Definition of Done (DoD)** explícito e **checklist final**; validar que todos os itens do DoD e do checklist estão cumpridos ou documentados para cumprimento. Revisar workflows e README para consistência e completude.

## Passos de implementação
1. Incluir na **story principal (story.md)** a seção **"Definition of Done (DoD)"** com itens verificáveis: workflow terraform-apply.yml existe com triggers, steps e secrets; workflow terraform-destroy.yml existe com trigger e steps; README contém visão geral, recursos por módulo, como rodar apply/destroy, ordem recomendada, variáveis importantes, outputs/contratos; nenhuma credencial commitada; story inclui checklist final. Garantir que o DoD esteja na story (já previsto na Storie-13).
2. Incluir na story a seção **"Checklist final"** com itens: workflows criados e configurados; README completo com todas as seções obrigatórias; secrets documentados (quais configurar); ordem recomendada e outputs/contratos claros; DoD e checklist final revisados. Garantir que o checklist final esteja na story.
3. Validar que os arquivos criados nas subtasks anteriores (terraform-apply.yml, terraform-destroy.yml, README) existem e que o conteúdo do README cobre todas as seções obrigatórias (visão geral, recursos por módulo, como rodar apply/destroy, ordem recomendada, variáveis importantes, outputs/contratos).
4. Executar validação de sintaxe dos workflows YAML (se possível) e revisar README para links quebrados e consistência com os nomes dos módulos (00-foundation, 10-storage, etc.).
5. Documentar no README ou em docs quais **secrets** configurar no repositório GitHub (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN, AWS_REGION) sem expor valores; incluir aviso de que credenciais temporárias (AWS Academy) exigem renovação periódica.

## Formas de teste
1. Ler a story e confirmar que a seção DoD está presente com itens verificáveis e que o checklist final está presente.
2. Verificar que terraform-apply.yml e terraform-destroy.yml existem em .github/workflows/ e que o README na raiz contém as seções obrigatórias.
3. Percorrer o checklist final item a item e marcar (ou documentar) o que está feito e o que depende de configuração externa (secrets no GitHub).

## Critérios de aceite da subtask
- [ ] A story inclui DoD explícito com itens verificáveis (workflows, README, credenciais, checklist).
- [ ] A story inclui checklist final com itens de validação (workflows, README, secrets, ordem recomendada, outputs/contratos, revisão DoD/checklist).
- [ ] Workflows e README foram revisados para consistência e completude; secrets documentados sem expor valores; story pronta para conclusão.
