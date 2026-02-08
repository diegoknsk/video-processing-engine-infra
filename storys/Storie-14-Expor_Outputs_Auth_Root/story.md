# Storie-14: Expor outputs do módulo Auth (Cognito) no root do Terraform

## Status
- **Estado:** ✅ Concluída
- **Data de Conclusão:** 07/02/2026

## Rastreamento (dev tracking)
- **Início:** dia 08/02/2026, às 16:00 (Brasília)
- **Fim:** —
- **Tempo total de desenvolvimento:** —

## Descrição
Como desenvolvedor de infraestrutura, quero que os outputs do módulo 40-auth (Cognito) sejam reexportados no root do Terraform (`terraform/outputs.tf`), para que ao executar `terraform output` na raiz eu obtenha user_pool_id, client_id, issuer (e opcionalmente jwks_url), permitindo consumo por CI/CD, pipelines no GitHub e configuração da API sem depender do terraform console ou do state interno do módulo.

## Objetivo
Reexportar no **root** (`terraform/outputs.tf`) os outputs do módulo **40-auth** (Cognito): **cognito_user_pool_id**, **cognito_client_id**, **cognito_issuer** e, quando aplicável, **cognito_jwks_url**. Manter o padrão já usado para foundation, storage, data, orchestration e api: um único ponto de saída para quem roda Terraform na raiz.

## Escopo Técnico
- Tecnologias: Terraform >= 1.0 (sem mudança de provider)
- Arquivos afetados:
  - `terraform/outputs.tf` (adição de bloco "Auth (Cognito)" com outputs que referenciam `module.auth.*`)
- Componentes: Nenhum recurso novo na AWS; apenas outputs do root que repassam valores do módulo 40-auth.
- Pacotes/Dependências: Nenhum. Depende do módulo `auth` já invocado no root (Storie-11).

## Dependências e Riscos (para estimativa)
- Dependências: Storie-11 (módulo 40-auth) concluída e módulo `auth` invocado no `terraform/main.tf`.
- Riscos/Pré-condições: Se o módulo auth não estiver presente no root, os novos outputs gerarão erro até que o bloco `module "auth"` exista; validar com `terraform validate` e `terraform plan` no root.

## Modelo de execução
Execução no **root** (`terraform/`). Após a alteração, `terraform plan` e `terraform output` na raiz devem listar os novos outputs (cognito_user_pool_id, cognito_client_id, cognito_issuer, cognito_jwks_url). Região para configuração Cognito já está disponível como output `region` do foundation.

## Subtasks
- [x] [Subtask 01: Outputs Cognito no outputs.tf do root](./subtask/Subtask-01-Outputs_Cognito_Root.md)
- [x] [Subtask 02: Validação e documentação](./subtask/Subtask-02-Validacao_Documentacao.md)

## Critérios de Aceite da História
- [x] O arquivo `terraform/outputs.tf` contém uma seção "Auth (Cognito)" com outputs que reexportam `module.auth.user_pool_id`, `module.auth.client_id`, `module.auth.issuer` e `module.auth.jwks_url` (nomes sugeridos: cognito_user_pool_id, cognito_client_id, cognito_issuer, cognito_jwks_url).
- [x] Ao executar `terraform output` no diretório `terraform/` (root), os outputs do Cognito são exibidos junto com os demais (foundation, storage, data, api, etc.).
- [x] `terraform validate` e `terraform plan -var-file=envs/dev.tfvars` no root executam sem erro.
- [x] Comentário ou documentação breve no outputs.tf indica que os outputs do Cognito são consumidos por CI/CD, API e pipelines (ex.: GitHub Actions).

## Checklist de Conclusão
- [x] Outputs do auth reexportados no root; terraform output na raiz exibe cognito_user_pool_id, cognito_client_id, cognito_issuer, cognito_jwks_url
- [x] terraform init, validate e plan no root passam
