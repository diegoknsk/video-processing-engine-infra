# Subtask 01: Variáveis do módulo e consumo de prefix/tags do foundation

## Descrição
Criar o arquivo `terraform/20-data/variables.tf` com as variáveis necessárias para o módulo data: prefix e common_tags (consumo do foundation), enable_ttl, ttl_attribute_name, billing_mode e environment. Garantir que o módulo receba prefix e common_tags por variáveis de entrada, sem referências quebradas ao foundation.

## Passos de implementação
1. Criar `terraform/20-data/variables.tf` com variável obrigatória `prefix` (string, description: prefixo de naming do foundation).
2. Declarar variável `common_tags` (map(string) ou object) como obrigatória para tags do foundation.
3. Declarar variáveis opcionais: `enable_ttl` (bool, default = false), `ttl_attribute_name` (string, default = "TTL"), `billing_mode` (string, default = "PAY_PER_REQUEST"), `environment` (string, opcional); incluir description em cada uma.
4. Garantir que o módulo não dependa de path absoluto ou module "foundation" sem que o caller forneça as variáveis; consumo apenas via variáveis de entrada.

## Formas de teste
1. Executar `terraform validate` em `terraform/20-data/` após criar variables.tf (e providers se necessário); validar que não há erro de variável não declarada.
2. Verificar que não existe referência a module.foundation ou remote_state sem caller configurado; módulo deve receber prefix e common_tags por variável.
3. Listar variáveis documentadas na story (prefix, common_tags, enable_ttl, ttl_attribute_name, billing_mode, environment) e confirmar que estão declaradas em variables.tf.

## Critérios de aceite da subtask
- [x] O arquivo `terraform/20-data/variables.tf` existe e declara prefix e common_tags (obrigatórios ou com default compatível).
- [x] Variáveis enable_ttl, ttl_attribute_name e billing_mode estão declaradas com default documentado.
- [x] O módulo não possui referência quebrada ao foundation; terraform validate passa.
