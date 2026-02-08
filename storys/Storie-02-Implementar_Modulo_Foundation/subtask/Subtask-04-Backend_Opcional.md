# Subtask 04: Configurar backend remoto opcional sem bloquear execução local

## Descrição
Configurar o backend remoto (S3 + DynamoDB para lock, conforme infrarules) de forma opcional e configurável, de modo que a execução local não seja impedida quando o backend não estiver configurado ou quando o usuário usar `-backend=false`. O arquivo `backend.tf` pode conter backend S3 comentado, ou usar partial configuration / backend config file externo, garantindo que `terraform init` funcione localmente sem obrigar criação de bucket ou tabela.

## Passos de implementação
1. Criar o arquivo `terraform/00-foundation/backend.tf` (ou manter configuração de backend em arquivo separado, conforme infrarules: backend.tf é o dono único da config do backend).
2. Declarar o bloco `terraform { backend "s3" { ... } }` com parâmetros parametrizáveis (bucket, key, region, dynamodb_table, encrypt) — ou deixar o bloco comentado/alternativo com backend "local" implícito quando não configurado. Alternativa: usar backend "s3" com valores em arquivo de backend config (ex.: `-backend-config=backend.hcl`) não versionado, de forma que init sem esse arquivo use backend local ou exija -backend=false.
3. Documentar no próprio arquivo ou em README que: para execução local, usar `terraform init -backend=false` ou fornecer backend-config; para CI/CD, configurar backend com bucket e DynamoDB existentes.
4. Garantir que `terraform init -backend=false` em `terraform/00-foundation/` complete com sucesso e que `terraform validate` continue funcionando.

## Formas de teste
1. Executar `terraform init -backend=false` em `terraform/00-foundation/` e confirmar que termina sem erro (nenhuma solicitação de bucket S3 obrigatória).
2. Se backend S3 estiver ativo no arquivo, testar com backend-config vazio ou inexistente e verificar que há mensagem clara ou que init com -backend=false ignora backend remoto.
3. Verificar que a documentação (comentário ou README) descreve como usar localmente (-backend=false) e como configurar backend remoto para equipe/CI.

## Critérios de aceite da subtask
- [ ] Existe `backend.tf` (ou configuração de backend em arquivo dedicado); backend remoto é opcional/configurável.
- [ ] Execução local é possível: `terraform init -backend=false` no módulo 00-foundation completa com sucesso.
- [ ] Está documentado (no código ou README) como executar localmente e como configurar backend S3 para uso remoto.
