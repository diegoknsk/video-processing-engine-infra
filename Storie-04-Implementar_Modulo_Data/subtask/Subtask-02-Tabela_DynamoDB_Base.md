# Subtask 02: Tabela DynamoDB com PK, SK e atributos (base)

## Descrição
Criar o recurso `aws_dynamodb_table` em `terraform/20-data/` com partition key (PK) e sort key (SK), e declarar os atributos necessários para o modelo: PK, SK, Status, CreatedAt, UpdatedAt, ZipS3Key, ErrorMessage, UserId, VideoId. Nesta subtask não é obrigatório criar o GSI (será na Subtask 03); definir nome da tabela usando prefix do foundation e tags.

## Passos de implementação
1. Criar arquivo `terraform/20-data/dynamodb.tf` (ou `main.tf`) com recurso `aws_dynamodb_table` com name = "${var.prefix}-videos" (ou equivalente), tags = var.common_tags.
2. Definir hash_key (PK) e range_key (SK): ex.: attribute { name = "PK", type = "S" }, attribute { name = "SK", type = "S" }; hash_key = "PK", range_key = "SK".
3. Declarar attribute para todos os campos usados como chave (PK, SK) e, se necessário para GSI, os atributos GSI1PK e GSI1SK (serão usados na Subtask 03); DynamoDB exige que cada chave (incluindo GSI) tenha attribute declarado.
4. Definir billing_mode = var.billing_mode (ex.: PAY_PER_REQUEST); não criar recursos IAM.

## Formas de teste
1. Executar `terraform plan` em `terraform/20-data/` passando prefix e common_tags e verificar que o plano lista criação da tabela DynamoDB com PK e SK; sem erros de atributo não declarado.
2. Verificar que não há recurso aws_iam_* no módulo.
3. Confirmar que os atributos PK e SK estão declarados no bloco attribute e referenciados em hash_key e range_key.

## Critérios de aceite da subtask
- [ ] Existe recurso aws_dynamodb_table com hash_key (PK) e range_key (SK); atributos PK e SK declarados.
- [ ] Nome da tabela usa var.prefix; tags = var.common_tags; billing_mode parametrizado.
- [ ] Nenhum recurso IAM no módulo; terraform validate e plan (com variáveis) passam.
