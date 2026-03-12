# Subtask 01: Análise do Módulo 20-data e Planejamento da Nova Tabela

## Descrição
Revisar os arquivos existentes do módulo `terraform/20-data` para entender a estrutura atual, identificar onde e como a nova tabela de chunks será adicionada sem afetar a tabela principal `{prefix}-videos`, e definir a estrutura de arquivos a ser criada.

## Passos de Implementação

1. **Ler os arquivos atuais do módulo `terraform/20-data`:**
   - `variables.tf` — identificar variáveis existentes (prefix, common_tags, enable_ttl, billing_mode, etc.) para não duplicar
   - `dynamodb.tf` (ou `main.tf`) — entender o recurso `aws_dynamodb_table.videos` existente
   - `outputs.tf` — identificar outputs já declarados (`table_name`, `table_arn`, `gsi_names`)
   - `README.md` — entender a documentação atual do modelo pk/sk

2. **Verificar referências no root `terraform/main.tf`:**
   - Confirmar quais outputs do módulo `20-data` já são consumidos pelo root
   - Identificar o padrão de passagem de variáveis ao módulo (prefix, common_tags, etc.)

3. **Definir a estratégia de adição:**
   - Criar arquivo separado `dynamodb-chunks.tf` para o novo recurso (isolamento total da tabela principal)
   - Adicionar novas variáveis com prefixo `chunks_` em `variables.tf` para evitar colisão com variáveis existentes
   - Adicionar outputs com prefixo `chunks_` em `outputs.tf`
   - Confirmar que nenhuma linha da tabela `{prefix}-videos` será modificada

4. **Documentar o modelo de dados planejado:**
   - Definir nomes exatos de variáveis, outputs e atributos antes de codificar
   - Confirmar padrão de naming da tabela: `{prefix}-video-chunks`

## Formas de Teste

1. Leitura dos arquivos do módulo `20-data` confirma que nenhum atributo existente conflita com os planejados para a nova tabela
2. Revisão do `terraform/main.tf` confirma que a passagem de variáveis ao módulo `20-data` não precisa de alterações para suportar os novos parâmetros (optional com defaults)
3. Checklist de isolamento: listar todos os recursos existentes e confirmar que nenhum deles será tocado pela nova adição

## Critérios de Aceite da Subtask
- [ ] Arquivos do módulo `20-data` lidos e estrutura documentada (nomes de recursos, variáveis e outputs existentes)
- [ ] Estratégia de adição definida: arquivo `dynamodb-chunks.tf` separado; novas variáveis com prefixo `chunks_`; nenhuma linha da tabela `{prefix}-videos` modificada
- [ ] Nomes finais das variáveis, outputs e do recurso Terraform definidos antes de codificar (ex.: `aws_dynamodb_table.video_chunks`, `var.chunks_billing_mode`, `output.chunks_table_name`)
