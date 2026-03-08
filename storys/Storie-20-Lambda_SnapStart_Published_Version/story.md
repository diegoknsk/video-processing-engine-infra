# Storie-20: Habilitar SnapStart e Published Version em todas as Lambdas

## Status
- **Estado:** 📋 Backlog
- **Data de Conclusão:** —

## Rastreamento (dev tracking)
- **Início:** dia 07/03/2025, início da sessão (hora Brasília a confirmar)
- **Fim:** —
- **Tempo total de desenvolvimento:** —

## Descrição
Como engenheiro de infraestrutura, quero habilitar **Lambda SnapStart** com **published version** em todas as Lambdas do módulo `50-lambdas-shell`, para reduzir cold start e deixar as funções mais rápidas quando invocadas (principalmente as acionadas por SQS e API).

## Objetivo
- Habilitar SnapStart em todas as 6 Lambdas (Auth, VideoManagement, VideoOrchestrator, VideoProcessor, VideoFinalizer, UpdateStatusVideo).
- Publicar versão ao deploy e fazer com que os invocadores (SQS event source mappings, API Gateway) usem a **versão publicada** (qualified ARN), para que o SnapStart tenha efeito.

---

## Como funciona o SnapStart (resumo)

- **Problema:** Cold start = primeira invocação (ou após idle) demora mais porque a Lambda precisa inicializar o runtime e o código.
- **SnapStart:** A AWS “fotografa” o estado da função **após a inicialização** (snapshot). Nas próximas invocações em cold start, em vez de inicializar do zero, a Lambda **restaura** a partir desse snapshot, reduzindo drasticamente o tempo de cold start (até ~90% em cenários típicos).
- **Published version:** O SnapStart **só se aplica a versões publicadas** da função, não à `$LATEST`. Por isso é necessário:
  1. Habilitar SnapStart na função (`snap_start.apply_on = "PublishedVersions"`).
  2. Publicar uma versão a cada deploy (`publish = true` no recurso da Lambda).
  3. Fazer os **invocadores** (SQS, API Gateway, etc.) chamarem a **versão publicada** (qualified ARN: `function_arn:version`), e não `$LATEST`.

**Runtimes suportados:** Java (Corretto) e .NET. O projeto usa `dotnet10` por padrão, então o SnapStart se aplica.

---

## Relação com outras stories

| Story | Relação |
|-------|---------|
| **Story 08** | Módulo onde as Lambdas (casca) foram criadas; esta story adiciona SnapStart + published version a todas elas. |
| **Story 18.1** | Inclui a Lambda `UpdateStatusVideo`; esta story aplica SnapStart também a ela, além das demais. |

Lambdas no escopo (6): **auth**, **video_management**, **video_orchestrator**, **video_processor**, **video_finalizer**, **update_status_video**.

---

## Escopo Técnico

- **Tecnologias:** Terraform >= 1.0, AWS Provider (~> 5.x / 6.x)
- **Arquivos afetados:**

| Arquivo | Ação |
|---------|------|
| `terraform/50-lambdas-shell/lambdas.tf` | Em cada `aws_lambda_function`: adicionar bloco `snap_start { apply_on = "PublishedVersions" }` e `publish = true` |
| `terraform/50-lambdas-shell/event_source_mapping.tf` | Trocar `function_name` para usar o **qualified ARN** da função (ex.: `aws_lambda_function.xxx.qualified_arn`) nos event source mappings e nas `aws_lambda_permission`, para que SQS invoque a versão publicada |
| Integração com API (Auth) | Se a API Gateway invocar a Lambda Auth por nome/ARN, ajustar para usar o qualified ARN (versão publicada) quando existir output do módulo lambdas |

- **Recursos alterados:** Os 6× `aws_lambda_function`; os 3× event source mappings e 3× `aws_lambda_permission` em `event_source_mapping.tf`; eventualmente o módulo API se receber ARN da Lambda Auth.
- **Componentes:** Nenhum recurso novo; apenas configuração (snap_start, publish) e uso de qualified ARN nos invocadores.

---

## Dependências e Riscos

- **Dependências:** Story 08 (módulo 50-lambdas-shell) e Story 18.1 (Lambda UpdateStatusVideo) concluídas.
- **Riscos:** Após `publish = true`, cada `terraform apply` que alterar código/artifact da Lambda criará uma nova versão numerada; os event source mappings passarão a apontar para a nova versão (comportamento desejado). Verificar se o módulo API (Auth) precisa receber o qualified ARN da Lambda Auth e se há outputs no root que exponham ARN qualificado.

---

## Subtasks

- [x] [Subtask 01: snap_start e publish em todas as Lambdas](./subtask/Subtask-01-SnapStart_Publish_Lambdas.md)
- [x] [Subtask 02: Event source mappings e permissions com qualified ARN](./subtask/Subtask-02-Event_Source_Mapping_Qualified_ARN.md)
- [x] [Subtask 03: API Gateway invocando Lambda Auth por qualified ARN](./subtask/Subtask-03-API_Gateway_Qualified_ARN_Auth.md)
- [x] [Subtask 04: Validação e documentação](./subtask/Subtask-04-Validacao_Documentacao.md)

---

## Critérios de Aceite

- [x] As 6 Lambdas possuem `snap_start { apply_on = "PublishedVersions" }` e `publish = true` em `lambdas.tf`
- [x] Os event source mappings SQS (Orchestrator, Finalizer, UpdateStatusVideo) e as `aws_lambda_permission` correspondentes usam o qualified ARN da função (versão publicada)
- [x] A API Gateway que invoca a Lambda Auth usa o qualified ARN (versão publicada) quando aplicável
- [x] `terraform fmt -recursive`, `terraform validate` e `terraform plan` executam sem erros
- [x] Nenhuma credencial ou valor sensível adicionado nos arquivos alterados
