# Subtask 03: Versioning opcional e lifecycle configurável

## Descrição
Adicionar versioning opcional aos buckets (controlado por variável enable_versioning) e regras de lifecycle para expirar objetos antigos quando retention_days > 0 e enable_lifecycle_expiration = true. A regra de lifecycle deve ser configurável (ex.: expiração após N dias) sem quebrar o plan quando retention_days for 0 ou null.

## Passos de implementação
1. Para cada um dos três buckets, criar recurso `aws_s3_bucket_versioning` com status = "Enabled" ou "Suspended" conforme var.enable_versioning: usar blocos dinâmicos ou count/for_each para que versioning seja habilitado apenas quando var.enable_versioning = true; caso false, usar status "Suspended" ou omitir versioning conforme documentação AWS.
2. Criar recurso `aws_s3_bucket_lifecycle_configuration` para cada bucket, condicionado a var.enable_lifecycle_expiration e var.retention_days > 0: rule com filter (ex.: prefix vazio ou específico), expiration { days = var.retention_days }, e opcionalmente noncurrent_version_expiration para versionados. Se retention_days for 0 ou null, não criar regra de expiração ou criar regra vazia que não expire (evitar erro de configuração).
3. Garantir que a lógica seja válida em Terraform: lifecycle_configuration com expiration days deve receber número > 0; usar dynamic block ou count para não aplicar expiração quando retention_days <= 0.
4. Documentar em comentário no código ou em README: versioning opcional via enable_versioning; lifecycle de expiração configurável via retention_days e enable_lifecycle_expiration.

## Formas de teste
1. Executar `terraform plan` com enable_versioning = true e retention_days = 30; verificar que versioning e lifecycle com expiration 30 dias aparecem no plano.
2. Executar `terraform plan` com enable_versioning = false e retention_days = 0; verificar que não há erro e que lifecycle de expiração não é aplicada (ou regra inativa).
3. Validar sintaxe: terraform validate no módulo 10-storage deve passar; nenhuma referência a var.retention_days em contexto que exija número > 0 sem tratamento (ex.: conditional).

## Critérios de aceite da subtask
- [ ] Versioning dos buckets é controlado por variável (enable_versioning); quando true, versioning habilitado; quando false, suspended ou equivalente.
- [ ] Lifecycle para expirar objetos antigos é configurável (retention_days e enable_lifecycle_expiration); quando retention_days > 0 e enable_lifecycle_expiration = true, regra de expiration aplicada.
- [ ] terraform plan não falha quando retention_days = 0 ou enable_lifecycle_expiration = false; terraform validate passa.
