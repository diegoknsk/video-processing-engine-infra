# Subtask 05: Documentar resiliência e DLQ como caixa de falhas; validação

## Descrição
Documentar explicitamente no README do módulo `terraform/30-messaging` (ou na story) o conceito de resiliência e da DLQ como "caixa de falhas": redrive policy evita perda de mensagens; após N tentativas (max_receive_count), a mensagem vai para a DLQ para inspeção e retry manual; parâmetros visibility_timeout e retention permitem ajuste por ambiente. Garantir que terraform init, terraform validate e terraform plan executem sem referências quebradas.

## Passos de implementação
1. Adicionar ao README do módulo `terraform/30-messaging` uma seção "Resiliência e DLQ (caixa de falhas)": explicar que todas as filas principais possuem redrive policy; mensagens que falham após max_receive_count tentativas são enviadas à DLQ; a DLQ funciona como caixa de falhas (não se perde mensagem; permite inspeção, análise e reprocessamento); parâmetros visibility_timeout, message_retention_seconds e max_receive_count são configuráveis por variável para ajuste por ambiente.
2. Incluir na story (ou README) a frase ou parágrafo que "reforça" resiliência e DLQ como caixa de falhas (ex.: "A DLQ é a caixa de falhas do fluxo: garante que nenhuma mensagem seja descartada sem passar por ela, permitindo diagnóstico e retry.")
3. Executar `terraform init` (com -backend=false se aplicável) e `terraform fmt -recursive` em `terraform/30-messaging/`; executar `terraform validate` e corrigir até "Success! The configuration is valid."
4. Executar `terraform plan` passando prefix, common_tags e variáveis SQS (visibility_timeout_seconds, message_retention_seconds, max_receive_count) e verificar que não há erro de referência quebrada; confirmar que nenhum recurso Lambda nem event mapping está no plano.
5. Documentar como o caller deve passar prefix e common_tags (e variáveis SQS) para uso do módulo.

## Formas de teste
1. Ler o README e confirmar que a seção "Resiliência e DLQ (caixa de falhas)" está presente e explica redrive policy, max_receive_count e o papel da DLQ como caixa de falhas.
2. Rodar `terraform validate` em terraform/30-messaging/ e confirmar "Success! The configuration is valid."
3. Rodar `terraform plan` com todas as variáveis necessárias e verificar que o plano mostra apenas recursos SQS (filas + DLQs + redrive); nenhum aws_lambda_* nem event_source_mapping.

## Critérios de aceite da subtask
- [ ] README (ou story) documenta resiliência e DLQ como "caixa de falhas" (redrive policy, sem perda de mensagens, inspeção e retry).
- [ ] terraform init, terraform validate e terraform plan no módulo 30-messaging executam sem referências quebradas.
- [ ] Nenhuma Lambda nem event mapping no escopo desta story; parâmetros essenciais (visibility, retention, maxReceiveCount) documentados como configuráveis.
