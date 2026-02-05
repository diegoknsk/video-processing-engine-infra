# Subtask 05: Checklist pós-apply e documentação

## Descrição
Incluir na story e no README do módulo de observabilidade um **checklist do que validar após apply**: invocar cada uma das 5 Lambdas e a Step Function e verificar que os logs aparecem nos log groups corretos do CloudWatch. Documentar o padrão de naming, a variável global de retenção e que não se usam ferramentas pagas (apenas CloudWatch).

## Passos de implementação
1. Criar ou atualizar README do módulo de observabilidade (75-observability ou seção em docs) com seção **"Checklist pós-apply (validar logs ao invocar)"**: (1) Lambda Auth: invocar (API Gateway /auth ou teste direto) → verificar log group /aws/lambda/{prefix}-auth com log stream e eventos recentes. (2) Lambda VideoManagement: invocar (API /videos ou teste direto) → verificar /aws/lambda/{prefix}-video-management. (3) Lambda VideoOrchestrator: enviar mensagem para q-video-process ou invocar direto → verificar /aws/lambda/{prefix}-video-orchestrator. (4) Lambda VideoProcessor: disparar Step Function ou invocar direto → verificar /aws/lambda/{prefix}-video-processor. (5) Lambda VideoFinalizer: enviar mensagem para q-video-zip-finalize ou invocar direto → verificar /aws/lambda/{prefix}-video-finalizer. (6) Step Functions: iniciar execução da state machine → verificar log group /aws/stepfunctions/{prefix}-video-processing (ou nome configurado) com log stream da execução. Incluir critério de sucesso: "Em cada recurso invocado, o log group correspondente deve ter pelo menos um log stream com eventos gerados após a invocação; retenção (retention_in_days) aplicada."
2. Documentar no README: padrão de naming (prefix + environment em prefix; sufixos para cada Lambda e SFN); variável global log_retention_days; apenas CloudWatch (sem ferramentas pagas).
3. Incluir na story principal (story.md) o mesmo checklist ou referência ao README, para que o critério "Story inclui checklist do que validar após apply" seja cumprido.
4. Executar terraform init e terraform validate no(s) módulo(s) afetado(s); executar terraform plan e verificar que não há erro de referência quebrada.
5. Opcional: adicionar ao README instruções de como invocar cada Lambda (ex.: aws lambda invoke, URL da API, etc.) para facilitar o checklist.

## Formas de teste
1. Ler o README e a story e confirmar que o checklist pós-apply está presente com os 6 itens (5 Lambdas + Step Function) e critério de sucesso (logs aparecendo e retenção aplicada).
2. Rodar terraform validate no(s) módulo(s); confirmar "Success! The configuration is valid."
3. Verificar que a documentação menciona "apenas CloudWatch" e "sem ferramentas pagas"; checklist utilizável por quem for validar após apply.

## Critérios de aceite da subtask
- [ ] README (e/ou story) contém checklist pós-apply: invocar cada uma das 5 Lambdas e a Step Function e verificar que logs aparecem nos log groups corretos; critério de sucesso definido (log stream com eventos recentes; retenção aplicada).
- [ ] Documentação inclui padrão de naming e variável global de retenção; apenas CloudWatch (sem ferramentas pagas).
- [ ] terraform init e terraform validate passam; story cumpre critério "Story inclui checklist do que validar após apply".
