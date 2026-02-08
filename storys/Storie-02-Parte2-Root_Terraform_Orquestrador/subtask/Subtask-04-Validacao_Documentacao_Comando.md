# Subtask 04: Validação (init, fmt, validate, plan) e documentação do comando

## Descrição
Executar terraform init (com -backend=false quando backend S3 não estiver disponível), terraform fmt -recursive em terraform/, terraform validate e terraform plan com -var-file ou -var, e documentar de forma explícita que a execução padrão do Terraform neste repositório é a partir do diretório terraform/ (um único init, um único plan, um único apply). Atualizar README na raiz do repo ou documentação em docs/ com a seção "Como executar o Terraform" apontando para cd terraform && terraform init && terraform plan -var-file=envs/dev.tfvars.

## Passos de implementação
1. Executar terraform init -backend=false em terraform/ (ou com backend configurado se bucket e DynamoDB existirem) e registrar qualquer ajuste necessário (ex.: backend config via -backend-config).
2. Executar terraform fmt -recursive em terraform/ e garantir que todos os .tf do root e dos módulos estejam formatados.
3. Executar terraform validate em terraform/ e corrigir até obter "Success! The configuration is valid."
4. Executar terraform plan -var-file=envs/dev.tfvars (ou variáveis obrigatórias via -var) em terraform/ e verificar que o plano é gerado sem erros de referência; documentar que credenciais AWS devem estar configuradas (variáveis de ambiente ou profile).
5. Adicionar ao README.md (raiz) ou a docs/ uma seção "Execução do Terraform" com: diretório de trabalho = terraform/; comandos: terraform init [-backend=false], terraform plan -var-file=envs/dev.tfvars, terraform apply -var-file=envs/dev.tfvars; menção a que init/plan/apply são únicos e que cada subpasta (00-foundation, 10-storage, etc.) é um módulo chamado pelo root.

## Formas de teste
1. Repetir init, fmt, validate e plan em terraform/ e confirmar que todos passam (plan pode falhar por credenciais AWS expiradas; a configuração deve ser válida).
2. Ler a documentação criada e confirmar que um novo desenvolvedor seguiria os passos corretos (cd terraform; init; plan com tfvars).
3. Verificar que não há instrução para rodar init/plan em 00-foundation ou 10-storage como diretório de trabalho para uso normal (apenas root).

## Critérios de aceite da subtask
- [ ] terraform init, terraform fmt -recursive, terraform validate executados em terraform/ com sucesso
- [ ] terraform plan em terraform/ com variáveis fornecidas não apresenta erros de referência (falha apenas por credenciais ou backend quando aplicável)
- [ ] README ou docs explicita: execução a partir de terraform/; comandos init, plan, apply com -var-file=envs/dev.tfvars; um único Terraform orquestrando todos os módulos
