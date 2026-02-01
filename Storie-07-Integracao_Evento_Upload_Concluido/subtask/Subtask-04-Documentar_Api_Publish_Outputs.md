# Subtask 04: Documentar api_publish e garantir outputs/variáveis para Lambda

## Descrição
Documentar o modo **api_publish**: a Lambda Video Management (via API) publica no SNS topic-video-submitted após confirmação de upload; nesta story não se implementa código de Lambda, apenas se documenta o fluxo e se garante que o output topic_video_submitted_arn (e variáveis necessárias) esteja disponível para o caller e para a aplicação Lambda usar.

## Passos de implementação
1. No README do módulo **terraform/30-messaging** (ou em docs do repo), adicionar seção "Modo api_publish (upload concluído)": explicar que quando trigger_mode = "api_publish", o evento de upload concluído não é disparado pelo S3; a **Lambda Video Management** (ou API) deve publicar uma mensagem no SNS topic-video-submitted após confirmar que o upload foi concluído (ex.: após callback ou polling). A Lambda usa o ARN do tópico (output topic_video_submitted_arn) para publicar; código da Lambda fica no repositório de aplicação, não neste repo de infra.
2. Garantir que o módulo 30-messaging já expõe o output **topic_video_submitted_arn** (Storie-05); se não existir, adicionar ao outputs.tf. Documentar no README que este output deve ser injetado na Lambda (variável de ambiente ou parâmetro) para que ela publique no SNS quando api_publish.
3. Opcionalmente documentar no README do módulo 10-storage que quando trigger_mode = "api_publish", nenhuma notificação S3 é criada; o fluxo depende da aplicação (Lambda/API) publicar no SNS.
4. Não criar nenhum recurso Terraform novo para api_publish (nenhuma Lambda, nenhum event mapping); apenas documentação e verificação de outputs.

## Formas de teste
1. Ler o README (30-messaging e/ou docs) e confirmar que o modo api_publish está descrito e que topic_video_submitted_arn é o output a ser usado pela Lambda.
2. Verificar que outputs.tf do 30-messaging contém topic_video_submitted_arn (ou equivalente).
3. Buscar no escopo desta story por aws_lambda ou event_source_mapping e confirmar que não há criação de Lambda nem event mapping para api_publish.

## Critérios de aceite da subtask
- [ ] O modo api_publish está documentado: Lambda Video Management (ou API) publica no SNS após confirmação de upload; código da Lambda em outro repo.
- [ ] O output topic_video_submitted_arn está disponível no módulo 30-messaging e documentado para uso pela Lambda quando api_publish.
- [ ] Nenhum código de Lambda nem event mapping criado nesta story para api_publish.
