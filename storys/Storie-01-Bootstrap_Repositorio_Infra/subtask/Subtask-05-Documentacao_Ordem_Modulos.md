# Subtask 05: Documentar ordem de execução das stories e conexão dos módulos ao Processador Video MVP + Fan-out

## Descrição
Documentar a ordem de execução das stories (módulos Terraform) e como cada módulo (00-foundation até 70-orchestration) se conecta ao desenho "Processador Video MVP + Fan-out" descrito no documento de contexto arquitetural. A documentação pode ficar no README principal, em `docs/` ou em arquivo dedicado no foundation, garantindo rastreabilidade entre infra e arquitetura.

## Passos de implementação
1. Criar ou atualizar documentação (README ou `docs/plano-modulos.md` / `docs/ordem-execucao-stories.md`) com uma seção que liste a ordem recomendada de execução dos módulos: 00-foundation → 10-storage → 20-data → 30-messaging → 40-auth → 50-lambdas-shell → 60-api → 70-orchestration, e opcionalmente as stories correspondentes (Storie-01 Bootstrap, Storie-02 Foundation, etc.).
2. Para cada módulo (00 a 70), descrever em uma linha ou parágrafo curto como ele se conecta ao fluxo do Processador Video MVP + Fan-out (ex.: 10-storage = S3 vídeos/imagens/zip; 20-data = DynamoDB; 30-messaging = SNS/SQS; 40-auth = Cognito; 50-lambdas-shell = cascas das Lambdas; 60-api = API Gateway; 70-orchestration = Step Functions), com referência ao [contexto-arquitetural.md](../../docs/contexto-arquitetural.md).
3. Incluir um diagrama em texto (ASCII) ou referência ao fluxo: Upload → S3 → SNS/SQS → Orchestrator → Processor → Finalizer → SNS/notificação, alinhado ao contexto arquitetural.
4. Garantir que a documentação esteja em português e seja clara para onboarding e para as próximas stories.

## Formas de teste
1. Ler a documentação e verificar que a ordem de execução dos módulos está explícita.
2. Conferir que cada módulo (00 a 70) tem descrição de conexão com o desenho Processador Video MVP + Fan-out.
3. Validar que há referência ao documento de contexto arquitetural e que o fluxo ponta a ponta (upload, processamento, finalização) está coberto na narrativa.

## Critérios de aceite da subtask
- [ ] A ordem de execução das stories/módulos (00 → 10 → 20 → 30 → 40 → 50 → 60 → 70) está documentada.
- [ ] Cada módulo tem descrição de como se conecta ao desenho Processador Video MVP + Fan-out (S3, DynamoDB, SNS/SQS, Cognito, Lambdas, API Gateway, Step Functions).
- [ ] Há referência ao contexto arquitetural e ao fluxo ponta a ponta (upload, orquestração, processamento, finalização, notificação); documentação em português.
