# Subtask 04: TTL opcional e outputs (table name, arn, GSI names)

## Descrição
Configurar TTL na tabela DynamoDB de forma opcional (variável enable_ttl) e criar `terraform/20-data/outputs.tf` expondo table name, table arn e nomes dos GSIs (ex.: gsi1_name). O atributo TTL deve ter nome configurável (ttl_attribute_name); quando enable_ttl = false, não habilitar TTL ou desabilitar explicitamente.

## Passos de implementação
1. No recurso aws_dynamodb_table, adicionar bloco dynamic "ttl" ou bloco ttl condicional: quando var.enable_ttl = true, definir ttl { enabled = true, attribute_name = var.ttl_attribute_name }; quando false, enabled = false ou omitir (conforme provider). Usar count ou dynamic block para condicionar à variável.
2. Criar `terraform/20-data/outputs.tf` com outputs: `table_name` (value = aws_dynamodb_table.videos.name ou id), `table_arn` (value = aws_dynamodb_table.videos.arn), `gsi_names` (value = [aws_dynamodb_table.videos.global_secondary_index[*].name] ou lista explícita do nome do GSI1). Garantir que os outputs referenciem apenas recursos do módulo.
3. Opcionalmente output `gsi1_name` (string) para consumo direto pelas Lambdas; ou `gsi_names` (list) para múltiplos GSIs futuros.
4. Verificar que nenhum output referencia módulo foundation nem recursos inexistentes.

## Formas de teste
1. Executar `terraform plan` com enable_ttl = true e verificar que o plano inclui ttl habilitado com attribute_name configurado; com enable_ttl = false, plano não deve falhar.
2. Verificar que outputs.tf expõe table_name, table_arn e gsi_names (ou gsi1_name); terraform plan deve listar os outputs sem erro.
3. Validar que a aplicação pode usar o atributo TTL (epoch em segundos) quando enable_ttl = true; documentar nome do atributo no README.

## Critérios de aceite da subtask
- [x] TTL é opcional: quando enable_ttl = true, ttl habilitado com attribute_name = var.ttl_attribute_name; quando false, ttl desabilitado ou não aplicado.
- [x] outputs.tf expõe table_name, table_arn e gsi names (ex.: gsi1_name ou gsi_names como list).
- [x] terraform plan lista os outputs sem referências quebradas; nenhum recurso IAM no módulo.
