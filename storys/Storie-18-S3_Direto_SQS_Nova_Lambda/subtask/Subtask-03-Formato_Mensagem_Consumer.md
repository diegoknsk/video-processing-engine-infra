# Subtask-03: Documentar Formato da Mensagem S3 e Extração de Bucket/Key pelo Consumer

## Descrição
Documentar (sem implementar código) o formato exato da mensagem que o S3 entrega na fila SQS e a estratégia que o consumer `LambdaVideoDispatcher` deve adotar para extrair `bucket` e `key` completos, incluindo o tratamento de URL-encoding do key. Esta subtask é de especificação e serve como contrato entre a equipe de infra e a equipe de desenvolvimento da Lambda.

---

## Passos de Implementação

1. **Documentar o formato da mensagem SQS (corpo/body)**

   Quando o S3 publica diretamente em uma fila SQS, a mensagem SQS tem o seguinte formato:

   ```
   SQSMessage
   ├── MessageId: "..."
   ├── ReceiptHandle: "..."
   ├── Body: (string JSON — evento S3)
   └── Attributes: {...}
   ```

   O `Body` deserializado tem a estrutura:

   ```json
   {
     "Records": [
       {
         "eventVersion": "2.1",
         "eventSource": "aws:s3",
         "awsRegion": "us-east-1",
         "eventTime": "2026-02-22T12:00:00.000Z",
         "eventName": "ObjectCreated:Put",
         "s3": {
           "s3SchemaVersion": "1.0",
           "configurationId": "videos-to-sqs",
           "bucket": {
             "name": "video-processing-engine-dev-videos",
             "ownerIdentity": { "principalId": "XXXXXXX" },
             "arn": "arn:aws:s3:::video-processing-engine-dev-videos"
           },
           "object": {
             "key": "videos/USER%23abc123/VIDEO%23xyz456/original",
             "size": 104857600,
             "eTag": "abc123...",
             "sequencer": "..."
           }
         }
       }
     ]
   }
   ```

   > **Nota:** O S3 pode agrupar até 10 registros em um único evento, mas para o filtro configurado (prefix + suffix específicos) é esperado sempre 1 record por upload.

2. **Documentar a extração de bucket e key**

   | Campo | Caminho no JSON do Body | Tipo | Observação |
   |-------|-------------------------|------|------------|
   | **bucket** | `Records[0].s3.bucket.name` | string | Nome do bucket; sem prefixo `arn:aws:s3:::` |
   | **key (raw)** | `Records[0].s3.object.key` | string | **URL-encoded**: `#` → `%23`; espaços → `+` ou `%20` |
   | **key (decodificado)** | `urldecode(Records[0].s3.object.key)` | string | Resultado esperado: `videos/USER#abc123/VIDEO#xyz456/original` |
   | **userId** | extrair do key decodificado | string | Segmento após `videos/`, antes do segundo `/`; ex.: `USER#abc123` |
   | **videoId** | extrair do key decodificado | string | Segmento após userId/; ex.: `VIDEO#xyz456` |

3. **Documentar os edge cases que o consumer deve tratar**

   | Situação | Comportamento esperado |
   |----------|------------------------|
   | `Records` vazio ou nulo | Rejeitar mensagem (log de erro + não deletar da fila para DLQ) |
   | `Records` com mais de 1 item | Processar cada record individualmente; cada um representa um objeto diferente |
   | `key` com caracteres especiais além de `#` (ex.: espaço, `+`) | Aplicar URL-decode completo (RFC 3986) antes de usar o key |
   | `eventName` diferente de `ObjectCreated:*` | Ignorar (pode ocorrer se o filtro S3 for ampliado no futuro); logar como warning |
   | Tamanho do arquivo (`s3.object.size`) igual a 0 | Logar warning; pode ser um arquivo de teste ou placeholder |

4. **Registrar o contrato de entrada da Lambda no arquivo de documentação**

   Criar ou atualizar `terraform/50-lambdas-shell/README.md` com uma seção "Contrato de entrada — LambdaVideoDispatcher" contendo:
   - Origem: SQS `q-video-process`, populada por S3 event notification
   - Estrutura do `Body` (resumo acima)
   - Campos obrigatórios: `bucket.name` e `object.key` (decodificado)
   - Dependência de URL-decode antes de usar o key

---

## Formas de Teste

1. **Verificação manual via console:** Após o apply da Subtask-02, fazer upload de teste e inspecionar a mensagem na fila via "Poll for messages" no console SQS — conferir que `Records[0].s3.bucket.name` e `Records[0].s3.object.key` estão presentes no body.
2. **Verificação do URL-encoding:** O key `videos/USER#abc123/VIDEO#xyz456/original` deve aparecer no body como `videos/USER%23abc123%2FVIDEO%23xyz456/original` (confirmar que `%23` está presente para o `#`).
3. **Revisão de documentação:** Revisar o README do módulo `50-lambdas-shell` para confirmar que a seção de contrato está presente e compreensível para a equipe de desenvolvimento.

---

## Critérios de Aceite

- [ ] O formato completo da mensagem SQS (envelope + body S3) está documentado nesta subtask e/ou no README do módulo `50-lambdas-shell`
- [ ] Os caminhos `Records[0].s3.bucket.name` e `Records[0].s3.object.key` estão identificados como os campos obrigatórios para o consumer
- [ ] O URL-encoding do key (`#` → `%23`) está documentado com a instrução de aplicar URL-decode
- [ ] Os edge cases (Records vazio, múltiplos records, eventName diferente) estão documentados com o comportamento esperado
- [ ] O contrato serve como especificação suficiente para o time de desenvolvimento da Lambda implementar sem consulta adicional à equipe de infra
