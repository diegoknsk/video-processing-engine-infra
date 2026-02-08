# Subtask 02: Definir padrões naming, tags, variáveis globais e convenções de outputs

## Descrição
Definir no módulo foundation (00-foundation) os padrões de naming (`video-processing-engine-{env}-*`), as tags padrão (Project, Environment, ManagedBy, Owner) em um arquivo de locals, e as convenções de variáveis globais e outputs que os demais módulos devem seguir. Tudo em forma de placeholder ou arquivos de convenção, sem provisionar recursos AWS.

## Passos de implementação
1. No diretório `terraform/00-foundation/`, criar ou atualizar `locals.tf` (ou arquivo equivalente) com um bloco `locals` contendo as tags padrão: `Project`, `Environment`, `ManagedBy`, `Owner`, referenciando variáveis (ex.: `var.project_name`, `var.env`) e valores placeholder para ManagedBy/Owner (ex.: "Terraform", "video-processing-engine").
2. Documentar o padrão de naming: prefixo `video-processing-engine-{env}-*` para todos os recursos (bucket, filas, tabelas, etc.), garantindo que isso conste em comentário no `locals.tf` ou em `README.md` do foundation.
3. Criar ou atualizar `variables.tf` e `outputs.tf` no foundation com variáveis e outputs de convenção (ex.: `project_name`, `env`, `aws_region`; outputs como `common_tags` ou `naming_prefix`) para que outros módulos possam consumir; usar placeholders quando necessário (outputs vazios ou comentados até haver recursos).
4. Garantir alinhamento com as infrarules: tags em todos os recursos suportados, região parametrizada, sem valores sensíveis nos arquivos.

## Formas de teste
1. Abrir `terraform/00-foundation/locals.tf` e verificar a presença das chaves Project, Environment, ManagedBy, Owner no bloco de tags.
2. Verificar em `variables.tf` e `outputs.tf` do foundation que variáveis globais e convenções de outputs estão declaradas ou documentadas.
3. Buscar no repo por "video-processing-engine" e "{env}" (ou equivalente) para confirmar que o padrão de naming está documentado ou utilizado nos locals.

## Critérios de aceite da subtask
- [ ] O módulo `00-foundation` contém definição de tags padrão (Project, Environment, ManagedBy, Owner) em `locals`, referenciando variáveis.
- [ ] O padrão de naming `video-processing-engine-{env}-*` está documentado no foundation (locals ou README).
- [ ] Variáveis globais (ex.: project_name, env, aws_region) e convenções de outputs estão definidas ou documentadas no foundation; nenhuma credencial ou ARN hardcoded.
