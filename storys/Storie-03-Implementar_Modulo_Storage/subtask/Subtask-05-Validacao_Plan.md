# Subtask 05: Validação (terraform plan sem referências quebradas)

## Descrição
Garantir que o módulo `terraform/10-storage` seja validado com `terraform init`, `terraform fmt`, `terraform validate` e `terraform plan` sem referências quebradas. O plan deve ser executado com variáveis do foundation (prefix, common_tags) fornecidas via tfvars ou -var, demonstrando que o módulo está pronto para uso pelo root ou por pipelines.

## Passos de implementação
1. Executar `terraform init` (com -backend=false se não houver backend configurado) no diretório `terraform/10-storage/` e corrigir erros de provider ou módulo até init concluir com sucesso.
2. Executar `terraform fmt -recursive` em `terraform/10-storage/` (ou no repo) e garantir que todos os .tf do módulo estejam formatados.
3. Executar `terraform validate` em `terraform/10-storage/` e corrigir até obter "Success! The configuration is valid."
4. Criar um arquivo tfvars de exemplo (ex.: `terraform/10-storage/example.tfvars` ou usar `terraform/envs/dev.tfvars`) com valores para prefix e common_tags compatíveis com o foundation; executar `terraform plan -var-file=...` (ou -var) e verificar que não há erro de "reference to undeclared resource", "variable not defined" ou "missing required variable".
5. Documentar na story ou no README que o caller deve passar prefix e common_tags (ex.: do output do módulo 00-foundation) para que o plan não tenha referências quebradas.

## Formas de teste
1. Rodar `terraform validate` em terraform/10-storage/ e confirmar saída "Success! The configuration is valid."
2. Rodar `terraform plan -var="prefix=video-processing-engine-dev" -var='common_tags={"Project"="video-processing-engine","Environment"="dev","ManagedBy"="Terraform","Owner"="infra"}'` (ou com tfvars) e verificar que o plano mostra criação/alteração dos recursos S3 e dos outputs, sem erros.
3. Verificar que nenhuma mensagem de erro menciona "reference", "undefined", "missing" para variáveis ou recursos do módulo.

## Critérios de aceite da subtask
- [x] terraform init e terraform validate em terraform/10-storage/ executam com sucesso.
- [x] terraform plan no módulo 10-storage não apresenta referências quebradas (todas as variáveis obrigatórias fornecidas; recursos referenciados existem no módulo).
- [x] Está documentado como fornecer prefix e common_tags ao módulo (tfvars ou variáveis do root que consuma o foundation).
