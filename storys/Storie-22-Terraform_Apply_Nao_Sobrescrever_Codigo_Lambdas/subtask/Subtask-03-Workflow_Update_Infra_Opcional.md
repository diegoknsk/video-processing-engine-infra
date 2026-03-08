# Subtask-03: (Alternativa) Workflow Update Infra

## Descrição
**Opcional / alternativa.** Se por decisão do projeto **não** for adotado o `lifecycle { ignore_changes }` na Subtask 01, implementar uma nova GitHub Action "Update Infra" que permita atualizar a infraestrutura (tags, variáveis, outros recursos) sem redeploy do código das Lambdas. Com a Subtask 01 implementada, o `terraform apply` já cumpre esse papel; esta subtask serve como fallback ou como workflow dedicado com nome explícito "Update Infra" para uso em re-applies.

## Quando implementar
- **Implementar** se a equipe optar por **não** usar `ignore_changes` e precisar de um fluxo separado "só infra".
- **Implementar como opcional** se a equipe quiser um workflow com nome "Update Infra" (trigger manual) que execute o mesmo `terraform apply` (já seguro com ignore_changes), para deixar claro na interface do GitHub Actions qual job usar para "atualizar infra já existente".
- **Não implementar** se a Subtask 01 for suficiente e não houver demanda por um workflow com nome distinto.

## Passos de Implementação (se for aplicável)

1. **Criar `.github/workflows/terraform-update-infra.yml`**
   - Nome: "Update Infra" (ou "Terraform Update Infra").
   - Trigger: `workflow_dispatch` (manual), para uso consciente em "infra já criada, só quero aplicar mudanças de config".
   - Passos: checkout, setup Terraform, init, validate, plan, apply — idênticos ao `terraform-apply.yml` em termos de comandos, ou simplificados (ex.: apenas plan + apply com mesmo var-file).
   - Reutilizar os mesmos secrets (AWS_*, TF_VAR_*, etc.) do workflow de apply existente.
   - Documentar no próprio workflow que este job é para "atualizar infra existente" e que o código das Lambdas não é alterado (se ignore_changes estiver ativo) ou que este workflow não deve ser usado para primeiro provisionamento.

2. **Documentar no README**
   - Indicar quando usar "Terraform Apply" (primeira criação ou apply completo) vs "Update Infra" (re-aplicar apenas mudanças de infra, sem tocar código das Lambdas), se ambos existirem.

## Formas de Teste

1. Disparar o workflow manualmente e verificar que o apply conclui sem erros.
2. Confirmar que, após o run, o código das Lambdas na AWS não foi substituído por empty.zip (se já estiver deployado).

## Critérios de Aceite

- [ ] Se implementado: existe `.github/workflows/terraform-update-infra.yml` com trigger manual e passos de init/validate/plan/apply.
- [ ] Se implementado: o uso do workflow está documentado (quando usar Update Infra vs Apply).
- [ ] Se **não** implementado (decisão da equipe): a subtask está marcada como N/A e o motivo (uso da Subtask 01 como solução) registrado.
