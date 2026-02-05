# Subtask 01: Variáveis do módulo e consumo de prefix/tags do foundation

## Descrição
Criar o arquivo `terraform/10-storage/variables.tf` com as variáveis necessárias para o módulo storage, garantindo que prefix e common_tags sejam consumidos do foundation (passados pelo root/caller ou via variáveis injetadas). Declarar variáveis para enable_versioning, retention_days e enable_lifecycle_expiration; não criar referências quebradas ao foundation (usar variáveis de entrada no módulo).

## Passos de implementação
1. Criar `terraform/10-storage/variables.tf` com variável obrigatória `prefix` (string, description: prefixo de naming do foundation, ex.: video-processing-engine-{env}).
2. Declarar variável `common_tags` (map(string) ou object) como obrigatória, para receber as tags do foundation (Project, Environment, ManagedBy, Owner).
3. Declarar variáveis opcionais: `enable_versioning` (bool, default = false), `retention_days` (number, default = 0 ou null), `enable_lifecycle_expiration` (bool, default = true); incluir description em cada uma.
4. Opcionalmente declarar `environment` (string) se necessário para consistência com foundation; garantir que o módulo não dependa de path absoluto ou module "foundation" sem que o caller forneça as variáveis (evitar referência quebrada quando 00-foundation estiver em outro diretório).

## Formas de teste
1. Executar `terraform validate` em `terraform/10-storage/` após criar apenas variables.tf (e providers se necessário); validar que não há erro de variável não declarada em outros arquivos que referenciem var.prefix/var.common_tags.
2. Verificar que não existe referência a `module.foundation` ou `data.terraform_remote_state` sem que o caller esteja configurado; o módulo deve receber prefix e common_tags por variável.
3. Listar as variáveis documentadas na story (prefix, common_tags, enable_versioning, retention_days, enable_lifecycle_expiration) e confirmar que todas estão declaradas em variables.tf.

## Critérios de aceite da subtask
- [x] O arquivo `terraform/10-storage/variables.tf` existe e declara prefix e common_tags como obrigatórios (ou com default compatível com foundation).
- [x] Variáveis enable_versioning, retention_days e enable_lifecycle_expiration estão declaradas com default documentado.
- [x] O módulo não possui referência quebrada ao foundation (consumo via variáveis de entrada); terraform validate passa.
