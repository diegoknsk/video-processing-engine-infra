# Subtask 05: Documentar "ativo agora" vs "preparado para depois" e validação

## Descrição
Documentar explicitamente no README (ou na story) a separação "ativo agora" vs "preparado para depois": o que é provisionado e utilizável nesta story (tópicos SNS, subscription email opcional) e o que fica preparado para depois (subscription Lambda placeholder, subscription SQS em outra story). Garantir que terraform init, terraform validate e terraform plan executem sem referências quebradas.

## Passos de implementação
1. Adicionar ao README do módulo `terraform/30-messaging` uma seção "Ativo agora vs Preparado para depois" (ou tabela): **Ativo agora:** dois tópicos SNS (topic-video-submitted, topic-video-completed); outputs dos ARNs; subscription email no topic-video-completed (configurável por variável). **Preparado para depois:** subscription Lambda no topic-video-completed (placeholder por variável); subscription SQS no topic-video-submitted (outra story). Garantir que não haja ambiguidade.
2. Verificar que a story principal (story.md) já contém a tabela ou lista ativo vs preparado; se não estiver no README, garantir que o README referencie a story ou repita a tabela.
3. Executar `terraform init` (com -backend=false se aplicável) e `terraform fmt -recursive` em `terraform/30-messaging/`; executar `terraform validate` e corrigir até "Success! The configuration is valid."
4. Executar `terraform plan` passando prefix e common_tags (via -var ou tfvars) e verificar que não há erro de referência quebrada; confirmar que nenhum recurso SQS está no plano.
5. Documentar como o caller deve passar prefix e common_tags (ex.: do output do módulo 00-foundation).

## Formas de teste
1. Ler o README e confirmar que a seção "Ativo agora vs Preparado para depois" (ou equivalente) está presente e distingue claramente tópicos + email (agora) de Lambda placeholder e SQS (depois/outra story).
2. Rodar `terraform validate` em terraform/30-messaging/ e confirmar "Success! The configuration is valid."
3. Rodar `terraform plan` com prefix e common_tags e verificar que o plano mostra apenas recursos SNS (tópicos e subscriptions opcionais); nenhum aws_sqs_queue.

## Critérios de aceite da subtask
- [ ] README (ou story) documenta explicitamente "ativo agora" (tópicos SNS, outputs, subscription email opcional) vs "preparado para depois" (subscription Lambda placeholder, SQS em outra story).
- [ ] terraform init, terraform validate e terraform plan no módulo 30-messaging executam sem referências quebradas.
- [ ] Nenhum recurso SQS no módulo; nenhum serviço inventado fora da lista (SNS, subscriptions email/Lambda).
