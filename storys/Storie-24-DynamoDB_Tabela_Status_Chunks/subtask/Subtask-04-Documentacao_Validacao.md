# Subtask 04: Documentação do Modelo e Validação Terraform

## Descrição
Atualizar o `README.md` do módulo `terraform/20-data` para documentar a nova tabela `{prefix}-video-chunks` com o modelo de item, padrões de acesso e campos. Em seguida, executar o ciclo de validação Terraform (`fmt`, `validate`, `plan`) para confirmar que a infraestrutura está correta e pronta para `apply`.

## Passos de Implementação

1. **Atualizar `terraform/20-data/README.md`** com seção dedicada à nova tabela:

   Acrescentar (sem remover documentação existente da tabela de vídeos):

   ```markdown
   ## Tabela: {prefix}-video-chunks

   Tabela para persistir o status individual de cada chunk de processamento de vídeo.
   Permite calcular o progresso do vídeo por contagem de chunks concluídos.

   ### Chaves
   | Atributo | Tipo | Papel | Formato |
   |----------|------|-------|---------|
   | `pk` | String | Partition Key | `VIDEO#{videoId}` |
   | `sk` | String | Sort Key | `CHUNK#{chunkIndex}` |

   ### Modelo de item
   | Campo | Tipo | Obrigatório | Descrição |
   |-------|------|-------------|-----------|
   | `pk` | String | Sim | `VIDEO#{videoId}` |
   | `sk` | String | Sim | `CHUNK#{chunkIndex}` |
   | `videoId` | String | Sim | UUID do vídeo |
   | `chunkIndex` | Number | Sim | Índice do chunk (0-based) |
   | `totalChunks` | Number | Sim | Total de chunks do vídeo |
   | `status` | String | Sim | `PENDING`, `PROCESSING`, `COMPLETED`, `FAILED` |
   | `createdAt` | String | Sim | ISO 8601 (ex.: `2026-03-12T10:00:00Z`) |
   | `updatedAt` | String | Sim | ISO 8601 atualizado a cada mudança de status |
   | `errorMessage` | String | Não | Preenchido apenas quando `status = FAILED` |
   | `TTL` | Number | Não | Epoch seconds; ativo quando `enable_chunks_ttl = true` |

   ### Padrões de acesso
   | Operação | Chave | Caso de uso |
   |----------|-------|-------------|
   | `Query` | `pk = VIDEO#{videoId}` | Listar todos os chunks de um vídeo |
   | `GetItem` | `pk = VIDEO#{videoId}`, `sk = CHUNK#{idx}` | Status de um chunk específico |
   | `UpdateItem` condicional | `pk = VIDEO#{videoId}`, `sk = CHUNK#{idx}` | Atualizar status (idempotente) |
   | `Query` com filter | `pk = VIDEO#{videoId}` + `FilterExpression status = COMPLETED` | Calcular progresso |

   ### Variáveis relacionadas
   | Variável | Default | Descrição |
   |----------|---------|-----------|
   | `chunks_billing_mode` | `PAY_PER_REQUEST` | Billing mode da tabela |
   | `enable_chunks_ttl` | `false` | Ativa TTL na tabela |
   | `chunks_ttl_attribute_name` | `TTL` | Nome do atributo TTL |

   ### Outputs
   | Output | Descrição |
   |--------|-----------|
   | `chunks_table_name` | Nome da tabela de chunks |
   | `chunks_table_arn` | ARN da tabela de chunks |
   ```

2. **Executar `terraform fmt -recursive`** no root (`terraform/`):
   ```bash
   cd terraform
   terraform fmt -recursive
   ```
   Confirmar que nenhum arquivo foi reformatado (saída esperada: sem linhas impressas, ou apenas os arquivos modificados com diferença mínima).

3. **Executar `terraform validate`** no root:
   ```bash
   terraform validate
   ```
   Resultado esperado: `Success! The configuration is valid.`

4. **Executar `terraform plan`** no root (com credenciais AWS configuradas):
   ```bash
   terraform plan -var-file=envs/dev.tfvars
   ```
   Verificar:
   - Exibe `+ aws_dynamodb_table.video_chunks` como novo recurso a ser criado
   - Nenhum `destroy` ou `~ update` em `aws_dynamodb_table.videos`
   - Contagem de mudanças: somente adições (`n to add, 0 to change, 0 to destroy`)

## Formas de Teste

1. `terraform fmt -recursive` não altera nenhum arquivo (formatação já correta)
2. `terraform validate` retorna `"Success! The configuration is valid."`
3. `terraform plan` mostra exclusivamente `+ create` para `aws_dynamodb_table.video_chunks` e `0 to destroy`

## Critérios de Aceite da Subtask
- [ ] `README.md` do módulo `20-data` atualizado com seção da tabela `{prefix}-video-chunks`: modelo de item, chaves, padrões de acesso, variáveis e outputs
- [ ] `terraform fmt -recursive` executado sem reformatar arquivos (código já está formatado)
- [ ] `terraform validate` retorna `"Success! The configuration is valid."`
- [ ] `terraform plan` mostra `+ create` apenas para `aws_dynamodb_table.video_chunks`; `0 to destroy` confirmado (nenhum impacto na tabela principal)
