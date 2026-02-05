# Subtask 03: README – visão geral, recursos por módulo, como rodar apply/destroy

## Descrição
Atualizar ou criar o README.md na raiz do repositório com: (1) **Visão geral da arquitetura** alinhada ao desenho "Processador Video MVP + Fan-out" (entrada API Gateway + Cognito; upload S3 → SNS → SQS → Orchestrator → Step Functions → Processor → Finalizer → SNS completed; DynamoDB, S3, SQS, SNS); (2) **Lista de recursos criados por módulo** (00-foundation até 75-observability); (3) **Como rodar apply/destroy** (localmente e via GitHub Actions). Referência a docs/contexto-arquitetural.md.

## Passos de implementação
1. Abrir ou criar `README.md` na raiz; adicionar seção **"Visão geral da arquitetura"**: descrever o fluxo Processador Video MVP + Fan-out em poucos parágrafos (usuário → API Gateway → Lambdas; upload S3 → SNS → SQS → Orchestrator → Step Functions → Processor → Finalizer → SNS completed; DynamoDB para estado; S3 videos/images/zip; Cognito para auth). Incluir referência a [docs/contexto-arquitetural.md](docs/contexto-arquitetural.md) para detalhes.
2. Adicionar seção **"Recursos criados por módulo"**: tabela ou lista com cada módulo Terraform (00-foundation, 10-storage, 20-data, 30-messaging, 40-auth, 50-lambdas-shell, 60-api, 70-orchestration, 75-observability) e resumo dos recursos (ex.: 00-foundation = providers, locals, variables, outputs, backend opcional; 10-storage = 3 buckets S3; 20-data = tabela DynamoDB; etc.).
3. Adicionar seção **"Como rodar apply/destroy"**: **Localmente:** pré-requisitos (Terraform instalado, credenciais AWS configuradas — variáveis de ambiente AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN, AWS_REGION); comandos terraform init, terraform plan -var-file=terraform/envs/dev.tfvars (ou equivalente), terraform apply; terraform destroy quando necessário. **Via GitHub Actions:** configurar secrets no repositório (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN, AWS_REGION); executar workflow "Terraform Apply" ou "Terraform Destroy" manualmente (workflow_dispatch). Incluir aviso: nunca commitar credenciais.
4. Garantir que o README seja legível (títulos, listas, tabelas) e que não haja informações sensíveis.

## Formas de teste
1. Ler o README e confirmar que a visão geral da arquitetura está alinhada ao desenho Processador Video MVP + Fan-out e que há referência ao contexto arquitetural.
2. Verificar que a lista de recursos por módulo cobre todos os módulos (00 a 75) com resumo correto.
3. Verificar que a seção "Como rodar apply/destroy" descreve passos locais e via GitHub Actions; comandos e secrets documentados sem expor valores.

## Critérios de aceite da subtask
- [ ] README contém visão geral da arquitetura alinhada ao desenho Processador Video MVP + Fan-out e referência a docs/contexto-arquitetural.md.
- [ ] README contém lista de recursos criados por módulo (00-foundation até 75-observability).
- [ ] README contém como rodar apply/destroy (local e GitHub Actions); comandos e secrets documentados; nenhuma credencial em texto.
