# Storie-21: Ajustar configuração dos Lambdas para capacidade de teste e benchmark (MVP)

## Status
- **Estado:** 🚧 Em desenvolvimento
- **Data de Conclusão:** —

## Rastreamento (dev tracking)
- **Início:** dia 07/03/2025, às — (Brasília)
- **Fim:** —
- **Tempo total de desenvolvimento:** —

## Descrição
Como engenheiro de infraestrutura, quero ajustar a configuração de recursos (memória, armazenamento efêmero, timeout e SnapStart) das Lambdas do módulo `50-lambdas-shell` na IaC, para melhorar a capacidade de teste e permitir benchmark/validação técnica do MVP, com foco no Lambda Processor de vídeo para testes com arquivos grandes, sem que isso represente a configuração final de produção.

## Objetivo
Formalizar em código (Terraform), documentação e critérios de teste uma configuração **temporária e voltada para testes/benchmark do MVP**:

1. **Lambda Processor de vídeo:** configuração robusta para testes com vídeos grandes (ex.: até ~1–1,2 GB em cenário controlado), sem constituir garantia absoluta de suporte a qualquer tamanho.
2. **Demais Lambdas:** elevação moderada de capacidade em relação ao mínimo atual, dando folga suficiente para testes, sem superdimensionar.

A mudança é explícita como **configuração de teste/validação**, não como configuração final de produção.

---

## Contexto: configuração de teste vs. produção

- O Lambda Processor já foi validado manualmente com aumento de memória e desempenho adequado em testes.
- Esta story registra essa configuração na IaC e estende critérios de teste e documentação.
- **Não** se trata de definir limites rígidos de tamanho de vídeo; a configuração visa **permitir** testes com arquivos grandes (ex.: 1 GB até aproximadamente 1,2 GB em cenário controlado), sem transformar isso em garantia absoluta para todos os cenários.

---

## Configuração solicitada

### Lambda Processor de vídeo (teste robusto)

| Recurso              | Valor        | Observação |
|----------------------|-------------|------------|
| **Memory**           | 3072 MB     | Validado em testes manuais. |
| **Ephemeral storage (/tmp)** | 8192 MB | Necessário para manipulação de arquivos grandes. |
| **Timeout**          | 15 min (900 s) | Já é o máximo permitido para Lambda. |
| **SnapStart**        | None        | Desabilitado para este Lambda na configuração de teste (evitar interferência em benchmarks de cold start ou uso de /tmp). |

### Demais Lambdas (configuração intermediária para testes)

Elevação **moderada** em relação ao mínimo (128 MB, 512 MB /tmp), suficiente para testes sem exagero:

| Lambda                | Memory (MB) | Ephemeral storage (MB) | Timeout | SnapStart   |
|-----------------------|-------------|------------------------|---------|-------------|
| Auth                  | 512         | 1024                   | 15 min  | Mantido (PublishedVersions) |
| VideoManagement       | 512         | 1024                   | 15 min  | Mantido     |
| VideoOrchestrator     | 512         | 1024                   | 15 min  | Mantido     |
| VideoFinalizer        | 1024        | 2048                   | 15 min  | Mantido     |
| UpdateStatusVideo     | 512         | 1024                   | 15 min  | Mantido     |

- **VideoFinalizer** recebe um pouco mais (1024 MB / 2048 MB) por poder manipular múltiplos artefatos (imagens/zip).
- As demais ficam com 512 MB / 1024 MB para sair do mínimo e dar folga em testes.

---

## Escopo Técnico

- **Tecnologias:** Terraform >= 1.0, AWS Provider (~> 5.x / 6.x)
- **Arquivos afetados:**

| Arquivo | Ação |
|---------|------|
| `terraform/50-lambdas-shell/lambdas.tf` | Definir `memory_size`, `ephemeral_storage` e `timeout` por Lambda; no `video_processor`, remover bloco `snap_start` (SnapStart = None). |
| `terraform/50-lambdas-shell/variables.tf` | (Opcional) Incluir variáveis para memory/storage/timeout por função ou por “perfil” (ex.: teste vs. produção), se o time preferir parametrizar. |
| `terraform/50-lambdas-shell/README.md` | Documentar que a configuração atual é para **teste/benchmark MVP**, listar valores por Lambda e mencionar que não é configuração final de produção. |

- **Recursos alterados:** Os 6× `aws_lambda_function` em `lambdas.tf`.
- **Componentes:** Nenhum recurso novo; apenas alteração de argumentos existentes e documentação.
- **Pacotes/Dependências:** Nenhum.

---

## Dependências e Riscos (para estimativa)

- **Dependências:** Módulo `50-lambdas-shell` existente (Storie-08, Storie-18.1). Event source mappings e invocadores (ex.: Storie-20) continuam usando as mesmas funções; se o Processor deixar de usar SnapStart, invocadores que usam qualified ARN continuam válidos para as demais Lambdas.
- **Riscos:** Aumento de memória e armazenamento efêmero impacta custo por invocação/tempo; aceitável como configuração temporária de teste. Remover SnapStart do Processor pode aumentar cold start apenas para essa função.
- **Pré-condição:** Nenhuma; a story apenas ajusta parâmetros já suportados pelo recurso `aws_lambda_function`.

---

## Subtasks

- [x] [Subtask 01: Lambda Processor — memória, ephemeral storage, timeout e SnapStart None](./subtask/Subtask-01-Processor_Config_Teste.md)
- [x] [Subtask 02: Demais Lambdas — configuração intermediária para testes](./subtask/Subtask-02-Demais_Lambdas_Config_Intermediaria.md)
- [x] [Subtask 03: Documentação e critérios de teste](./subtask/Subtask-03-Documentacao_Criterios_Teste.md)

---

## Critérios de Aceite da História

- [x] O Lambda **video_processor** em `lambdas.tf` está configurado com: memory 3072 MB, ephemeral_storage 8192 MB, timeout 900 (15 min), e **sem** bloco `snap_start` (SnapStart = None).
- [x] As Lambdas **auth**, **video_management**, **video_orchestrator**, **video_finalizer** e **update_status_video** possuem memory_size e ephemeral_storage explícitos conforme tabela desta story (Auth, VideoManagement, Orchestrator, UpdateStatusVideo: 512 MB / 1024 MB; VideoFinalizer: 1024 MB / 2048 MB), com timeout 900 quando aplicável.
- [x] O README do módulo `50-lambdas-shell` documenta que a configuração atual é para **teste/benchmark do MVP**, lista os valores por Lambda e deixa explícito que não se trata da configuração final de produção.
- [x] Na story ou no README está explícito que a configuração do Processor visa **permitir** testes com vídeos grandes (ex.: 1 GB até ~1,2 GB em cenário controlado), sem constituir garantia absoluta para qualquer tamanho ou cenário.
- [x] `terraform fmt -recursive`, `terraform validate` e `terraform plan` executam sem erros no módulo ou no root que invoca o módulo.
- [x] Nenhuma credencial ou valor sensível é adicionado nos arquivos alterados.
