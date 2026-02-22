# Subtask-01: Remover Recursos SNS do Fluxo de Upload

## Descrição
Remover do arquivo `terraform/upload_integration.tf` os dois recursos que integram o bucket S3 com o SNS no fluxo de upload: `aws_s3_bucket_notification.videos_to_sns` e `aws_sns_topic_policy.topic_video_submitted_s3`. Também avaliar e ajustar a variável `trigger_mode` e demais variáveis relacionadas ao fluxo S3 → SNS que se tornaram obsoletas.

> **Escopo:** Esta subtask cobre **somente a remoção**. Os novos recursos S3 → SQS serão criados na Subtask-02.

---

## Passos de Implementação

1. **Analisar o estado atual de `upload_integration.tf`**
   - Ler o arquivo `terraform/upload_integration.tf` e identificar os dois recursos condicionais:
     - `aws_s3_bucket_notification.videos_to_sns` (count = trigger_mode == "s3_event" ? 1 : 0)
     - `aws_sns_topic_policy.topic_video_submitted_s3` (count = trigger_mode == "s3_event" ? 1 : 0)
   - Confirmar que ambos os recursos estão condicionados à variável `trigger_mode`.

2. **Remover os dois recursos do `upload_integration.tf`**
   - Deletar o bloco `resource "aws_s3_bucket_notification" "videos_to_sns"` completo.
   - Deletar o bloco `resource "aws_sns_topic_policy" "topic_video_submitted_s3"` completo.
   - O arquivo pode ficar vazio após a remoção; nesse caso, pode ser deletado ou mantido para comentário de contexto. Preferir manter com comentário descrevendo a mudança.

3. **Avaliar a variável `trigger_mode` em `terraform/variables.tf`**
   - A variável `trigger_mode` era usada para condicionar S3 → SNS. Com a remoção dos recursos SNS e a adição direta S3 → SQS (Subtask-02), ela pode se tornar obsoleta.
   - **Decisão:** Remover `trigger_mode` de `terraform/variables.tf` e de qualquer passagem nos módulos (`terraform/main.tf`), pois o novo comportamento S3 → SQS será sempre ativo (sem condicional).
   - Verificar se `trigger_mode` é passada para `module.storage` ou `module.messaging` em `main.tf` e remover essas referências.

4. **Avaliar `topic_video_submitted_arn = null` no `module.storage` em `main.tf`**
   - Essa variável era usada para passar o ARN do tópico SNS ao módulo storage quando `trigger_mode = "s3_event"`.
   - Com a remoção do fluxo SNS, verificar se `topic_video_submitted_arn` ainda é necessária no módulo `10-storage` ou se pode ser removida/simplificada.

5. **Executar `terraform fmt -recursive` e `terraform validate` após as remoções**
   - Garantir que as referências removidas não quebram o `validate`.
   - Corrigir qualquer referência órfã (ex.: variável declarada mas não usada pode gerar warning; remover se não mais necessária).

---

## Formas de Teste

1. **`terraform plan` no root (`terraform/`):** Deve mostrar os dois recursos como `# will be destroyed` (se estavam provisionados) ou simplesmente não aparecerão mais no plan se o estado estiver limpo. Confirmar que **nenhum** recurso inesperado é destruído além dos dois SNS-relacionados.
2. **`terraform validate`:** Deve retornar "Success! The configuration is valid." sem warnings de variáveis indefinidas ou referências quebradas.
3. **Revisão manual do `upload_integration.tf`:** Confirmar que o arquivo não contém mais referências a `aws_sns_topic` nem a `aws_sns_topic_policy` para o fluxo de upload.

---

## Critérios de Aceite

- [ ] `aws_s3_bucket_notification.videos_to_sns` removido de `upload_integration.tf`
- [ ] `aws_sns_topic_policy.topic_video_submitted_s3` removido de `upload_integration.tf`
- [ ] Variável `trigger_mode` removida de `variables.tf` e das passagens em `main.tf` (ou documentada como obsoleta se mantida)
- [ ] `terraform validate` retorna sucesso após as remoções
- [ ] Nenhuma referência quebrada a `topic_video_submitted_arn` ou `trigger_mode` no root após a limpeza
