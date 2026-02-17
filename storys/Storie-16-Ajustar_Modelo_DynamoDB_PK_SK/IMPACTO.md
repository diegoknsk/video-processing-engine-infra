# Análise de Impacto - Story 16 (pk/sk DynamoDB)

## 1. Referências encontradas

| Arquivo | Linha | Uso | Classificação |
|---------|-------|-----|---------------|
| `terraform/20-data/dynamodb.tf` | 2-36 | Definição de hash_key, range_key, attributes, GSI | **Ajuste necessário** (Subtask 02 e 03) |
| `terraform/20-data/README.md` | 9-23, 51 | Documentação do modelo PK/SK | **Ajuste necessário** (Subtask 04) |

## 2. Código Lambda

- **Repositório:** O código Lambda **não está** neste repositório de infraestrutura.
- **Módulo 50-lambdas-shell:** Usa `artifact_path` (empty.zip) — Lambdas em casca; artefato real vem de outro repo.
- **Funções que usam DynamoDB:** `video_management`, `video_processor`, `video_finalizer` recebem `TABLE_NAME` via variável de ambiente.
- **Conclusão:** O código Lambda que acessa a tabela está em repositório separado. **Ajuste necessário na aplicação:** trocar `PK`/`SK` por `pk`/`sk` e `GSI1PK`/`GSI1SK` por `gsi1pk`/`gsi1sk` em operações DynamoDB (PutItem, GetItem, Query, UpdateItem).

## 3. Decisão de GSI

**Opção escolhida: A (Consistência total — minúsculas)**

- **Justificativa:** Código Lambda não está neste repo; não há referências hardcoded a `GSI1PK`/`GSI1SK` na infra. Priorizar nomenclatura consistente (`gsi1pk`/`gsi1sk`) para padrão single-table design. Projeto em fase MVP/hackathon; aplicação será ajustada junto com o deploy.

## 4. Estratégia de migração

1. Ajustar Terraform (`dynamodb.tf`) — pk/sk, gsi1pk/gsi1sk
2. Atualizar README com modelo correto
3. Executar `terraform plan` e revisar recriação (destroy + create)
4. Executar `terraform apply` (aprovado pelo time)
5. Validar schema com `aws dynamodb describe-table`
6. **Aplicação:** Ajustar código Lambda no repo de aplicação para usar `pk`/`sk` e `gsi1pk`/`gsi1sk` antes ou logo após o apply

**Downtime esperado:** ~2-5 minutos (recriação de tabela vazia)

**Backup:** Não necessário (ambiente hackathon, dados efêmeros)

## 5. Arquivos impactados

- `terraform/20-data/dynamodb.tf` — schema
- `terraform/20-data/README.md` — documentação
- Código Lambda (repo externo) — operações DynamoDB

## 6. Comandos para validação e execução (com credenciais AWS)

```bash
cd terraform
terraform init
terraform fmt -recursive
terraform validate
terraform plan -var-file=envs/dev.tfvars
# Revisar plano (deve mostrar: aws_dynamodb_table.videos must be replaced)
terraform apply -var-file=envs/dev.tfvars
# Validar schema após apply:
aws dynamodb describe-table --table-name video-processing-engine-dev-videos --region us-east-1
```
