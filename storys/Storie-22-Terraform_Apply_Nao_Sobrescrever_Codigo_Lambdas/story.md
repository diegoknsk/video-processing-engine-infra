# Storie-22: Terraform Apply não deve sobrescrever código das Lambdas com placeholder

## Status
- **Estado:** 🔄 Em desenvolvimento
- **Data de Conclusão:** [DD/MM/AAAA]

## Descrição
Como engenheiro de infraestrutura, quero que ao executar `terraform apply` com a infraestrutura já criada o Terraform **não substitua** o código já implantado nas Lambdas pelo placeholder (`empty.zip`), para que o ecossistema continue funcionando após re-apply e não quebre as funções já em uso.

## Objetivo
Garantir que re-execuções de `terraform apply` (por exemplo para alterar tags, variáveis de ambiente, ou outros recursos) **não sobrescrevam** o código das Lambdas com `artifacts/empty.zip`. Solução: usar `lifecycle { ignore_changes }` nos atributos de código do recurso `aws_lambda_function` (filename e source_code_hash). Não é necessária outra GitHub Action; o próprio apply passa a ser seguro para re-execução.

## Escopo Técnico
- **Tecnologias:** Terraform (já em uso), provider AWS
- **Arquivos afetados:**
  - `terraform/50-lambdas-shell/lambdas.tf` — adicionar `lifecycle { ignore_changes = [filename, source_code_hash] }` em cada `aws_lambda_function` (auth, video_management, video_orchestrator, video_processor, video_finalizer, update_status_video)
  - `terraform/50-lambdas-shell/README.md` — documentar separação "Apply Infra" vs "Deploy Código"
- **Componentes/Recursos:** Recursos `aws_lambda_function` no módulo `50-lambdas-shell`; nenhum recurso AWS novo
- **Pacotes/Dependências:** Nenhum pacote externo novo

## Dependências e Riscos (para estimativa)
- **Dependências:** Infra já provisionada pelo menos uma vez (Lambdas criadas com empty.zip); pipeline ou processo que faz deploy do código real das Lambdas fora do Terraform (ou em etapa posterior)
- **Riscos/Pré-condições:**
  - Com `ignore_changes` em filename/source_code_hash, o Terraform **nunca** atualizará o código das Lambdas a partir do estado; o deploy de código deve ser feito por outro mecanismo (pipeline de aplicação, AWS CLI, etc.)
  - Se no futuro for necessário que o Terraform gerencie o código de alguma Lambda, será preciso remover o `ignore_changes` para esse recurso e re-aplicar com o artefato desejado

## Subtasks
- [x] [Subtask 01: Adicionar lifecycle ignore_changes para código das Lambdas](./subtask/Subtask-01-Lifecycle_Ignore_Changes_Lambda_Codigo.md)
- [x] [Subtask 02: Documentar separação Apply Infra vs Deploy Código](./subtask/Subtask-02-Documentar_Separacao_Apply_Deploy.md)
- [x] [Subtask 04: Validação terraform plan e comportamento esperado](./subtask/Subtask-04-Validacao_Plan_Comportamento.md)

## Critérios de Aceite da História
- [ ] Após implementar `ignore_changes`, um segundo `terraform apply` (com infra já criada e Lambdas com código real) **não** altera o código (package) das Lambdas; o plan não deve mostrar update em `filename`/`source_code_hash`
- [ ] O primeiro `terraform apply` (criação inicial) continua criando as Lambdas com `empty.zip` conforme configurado
- [ ] Alterações em outros atributos das Lambdas (ex.: `environment`, `memory_size`, `timeout`) continuam sendo aplicadas pelo Terraform quando alterados no código
- [x] Documentação deixa claro que o deploy do código das Lambdas é responsabilidade do pipeline de aplicação (ou processo equivalente), não do terraform apply
- [x] `terraform fmt -recursive` e `terraform validate` executados sem erro no root e no módulo `50-lambdas-shell`
- [x] Nenhuma credencial ou dado sensível introduzido nos arquivos alterados

## Rastreamento (dev tracking)
- **Início:** dia 07/03/2025 (Brasília)
- **Fim:** —
- **Tempo total de desenvolvimento:** —
