# Subtask-01: Remover Tópico SNS topic_video_completed do módulo 30-messaging

## Descrição
Remover o recurso `aws_sns_topic.topic_video_completed` e as suas duas subscriptions (`completed_email` e `completed_lambda`) do arquivo `terraform/30-messaging/sns.tf`. Após a remoção, o arquivo deve conter apenas o comentário de cabeçalho e os recursos do novo tópico (criado na Subtask-02).

## Arquivos Afetados
- `terraform/30-messaging/sns.tf`

## Passos de Implementação

1. **Abrir `terraform/30-messaging/sns.tf`** e identificar os blocos a remover:
   - `resource "aws_sns_topic" "topic_video_completed"` (linhas do tópico)
   - `resource "aws_sns_topic_subscription" "completed_email"` (subscription de e-mail)
   - `resource "aws_sns_topic_subscription" "completed_lambda"` (subscription Lambda placeholder)
   - Comentários associados a esses blocos

2. **Remover todos os blocos acima** do arquivo `sns.tf`. O arquivo ficará com apenas o cabeçalho e espaço para os novos recursos (Subtask-02).

3. **Executar `terraform fmt`** no diretório `terraform/30-messaging/` para garantir formatação correta.

4. **Executar `terraform validate`** de forma isolada no módulo `30-messaging` (usando `terraform init` local se necessário) para confirmar que não há erros de sintaxe no módulo após a remoção.

## Formas de Teste

1. Verificar manualmente que os três blocos de recurso não existem mais em `sns.tf` após a edição.
2. Executar `terraform validate` dentro de `terraform/30-messaging/`: deve retornar "Success! The configuration is valid." (considerando que outputs e variáveis ainda referenciarão o recurso removido — validar após Subtask-03 também estar concluída).
3. Executar `terraform plan` (com credenciais válidas) e confirmar que o plan mostra `destroy` para `aws_sns_topic.topic_video_completed`, `aws_sns_topic_subscription.completed_email[0]` e `aws_sns_topic_subscription.completed_lambda[0]` (se estiverem provisionados).

## Critérios de Aceite
- [ ] Nenhum bloco `aws_sns_topic "topic_video_completed"` existe em `sns.tf`
- [ ] Nenhum bloco `aws_sns_topic_subscription "completed_email"` existe em `sns.tf`
- [ ] Nenhum bloco `aws_sns_topic_subscription "completed_lambda"` existe em `sns.tf`
- [ ] `terraform fmt` não reporta diff de formatação em `sns.tf`
- [ ] Após a conclusão de Subtask-01, Subtask-03 (remoção de outputs/variáveis), a referência `aws_sns_topic.topic_video_completed` não existe em nenhum arquivo de `terraform/30-messaging/`
