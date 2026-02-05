# Subtask 02: Workflow terraform-destroy.yml (trigger, destroy, secrets)

## Descrição
Criar o workflow `.github/workflows/terraform-destroy.yml` com trigger **workflow_dispatch** (apenas manual); steps: checkout, setup Terraform, terraform init, terraform destroy (com -auto-approve ou confirmação manual); uso dos mesmos secrets AWS (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN, AWS_REGION) para autenticação na AWS. Destroy não deve ser disparado automaticamente em push.

## Passos de implementação
1. Criar arquivo `.github/workflows/terraform-destroy.yml` com job que rode em ubuntu-latest (ou runner padrão).
2. Configurar trigger: **workflow_dispatch** apenas (sem push, sem pull_request); destroy só sob demanda manual.
3. Adicionar step checkout (actions/checkout). Adicionar step setup Terraform (hashicorp/setup-terraform) e working-directory consistente com terraform-apply.yml.
4. Adicionar steps: (a) terraform init (com -backend-config se necessário, igual ao apply); (b) terraform destroy -auto-approve (ou -input=false; conforme política do time, pode exigir input manual). Garantir que init/destroy usem o mesmo working-directory e backend que o apply.
5. Configurar secrets como variáveis de ambiente do job: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN, AWS_REGION (mesmos do terraform-apply.yml).
6. Documentar no README que o destroy é manual (workflow_dispatch) e que os mesmos secrets do apply são necessários.

## Formas de teste
1. Verificar sintaxe YAML do workflow; trigger workflow_dispatch presente; nenhum trigger push/pull_request.
2. Listar os steps e confirmar: checkout → setup Terraform → init → destroy; secrets usados como env.
3. Confirmar que não há valor literal de credencial no arquivo; apenas referência a secrets.

## Critérios de aceite da subtask
- [ ] O arquivo `.github/workflows/terraform-destroy.yml` existe com trigger workflow_dispatch (apenas manual).
- [ ] Steps incluem init e destroy; secrets AWS configurados como env do job (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN, AWS_REGION).
- [ ] Nenhuma credencial commitada; destroy não disparado em push; terraform destroy executável após configurar secrets.
