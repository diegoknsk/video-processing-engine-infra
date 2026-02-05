# Subtask 01: Workflow terraform-apply.yml (triggers, steps, secrets)

## Descrição
Criar o workflow `.github/workflows/terraform-apply.yml` com trigger workflow_dispatch (obrigatório) e opcional push main; steps: checkout, setup Terraform, terraform fmt -recursive, terraform validate, terraform plan, terraform apply; uso de secrets AWS Academy (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN, AWS_REGION) para autenticação na AWS. Nunca commitar credenciais; apenas referência a GitHub Secrets.

## Passos de implementação
1. Criar arquivo `.github/workflows/terraform-apply.yml` com job que rode em ubuntu-latest (ou runner padrão).
2. Configurar triggers: **workflow_dispatch** (obrigatório); opcionalmente **push** com branches main (conforme decisão do time — push main pode disparar plan ou apply com confirmação).
3. Adicionar step checkout (actions/checkout). Adicionar step setup Terraform (hashicorp/setup-terraform com version) e working-directory se o Terraform estiver em subdiretório (ex.: terraform/ ou root).
4. Adicionar steps: (a) terraform fmt -recursive (opcional -check para falhar se não formatado); (b) terraform init (com -backend-config se necessário); (c) terraform validate; (d) terraform plan (com -var-file ou -var); (e) terraform apply -auto-approve (ou -input=false e aprovação manual conforme política). Garantir que init/plan/apply usem o mesmo working-directory e backend.
5. Configurar secrets como variáveis de ambiente do job: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN (obrigatório para credenciais temporárias AWS Academy), AWS_REGION. Usar env: no job com secrets.GITHUB_SECRET_NAME. Nunca escrever valores de secrets no log (mask).
6. Documentar no README ou no próprio workflow quais secrets configurar no repositório (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN, AWS_REGION).

## Formas de teste
1. Verificar sintaxe YAML do workflow (yamllint ou validação manual); workflow_dispatch e steps presentes.
2. Listar os steps e confirmar ordem: checkout → setup Terraform → fmt → init → validate → plan → apply; secrets usados como env.
3. Confirmar que não há valor literal de credencial no arquivo; apenas ${{ secrets.AWS_ACCESS_KEY_ID }} etc.

## Critérios de aceite da subtask
- [ ] O arquivo `.github/workflows/terraform-apply.yml` existe com trigger workflow_dispatch (e opcional push main).
- [ ] Steps incluem fmt, validate, plan, apply (e init antes de plan/apply); secrets AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN, AWS_REGION configurados como env do job.
- [ ] Nenhuma credencial commitada; apenas referência a GitHub Secrets; terraform apply executável após configurar secrets.
