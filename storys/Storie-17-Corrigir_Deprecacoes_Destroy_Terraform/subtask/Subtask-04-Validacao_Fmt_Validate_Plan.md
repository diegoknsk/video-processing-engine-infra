# Subtask-04: Validação terraform fmt, validate e plan

## Descrição
Após a conclusão das subtasks 01, 02 e 03, executar a sequência completa de validação (`fmt`, `validate`, `plan`) em todos os módulos alterados para garantir que o código está correto, formatado e sem warnings antes do commit.

## Módulos a validar
- `terraform/10-storage` — força de destruição dos buckets (Subtask-02)
- `terraform/20-data` — migração `key_schema` DynamoDB (Subtask-01)
- `terraform/40-auth` — deprecação `aws_region.current.name` (Subtask-03)
- `terraform/50-lambdas-shell` — deprecação `aws_region.current.name` (Subtask-03)

## Passos de Implementação

1. **Formatar o código**
   - Na raiz do repositório Terraform (ou em cada módulo), executar:
     ```bash
     terraform fmt -recursive terraform/
     ```
   - Verificar se algum arquivo foi reformatado (saída com nomes de arquivo indica mudança)
   - Se houver mudanças, revisar e confirmar que são apenas de formatação

2. **Validar cada módulo alterado**
   - Para cada módulo listado acima, executar dentro da pasta do módulo:
     ```bash
     terraform init -backend=false
     terraform validate
     ```
   - Resultado esperado: `Success! The configuration is valid.`
   - Corrigir quaisquer erros antes de prosseguir

3. **Executar `terraform plan` e revisar warnings**
   - Executar `terraform plan` (com credenciais e variáveis necessárias) nos módulos alterados
   - Confirmar ausência dos três tipos de warning:
     - `range_key is deprecated`
     - `hash_key is deprecated`
     - `The attribute "name" is deprecated`
   - Revisar o diff do plan para confirmar que não há replaces inesperados (especialmente na tabela DynamoDB)
   - Documentar qualquer mudança de infraestrutura identificada

4. **Registrar resultado da validação**
   - Anotar quais módulos passaram em `fmt`, `validate` e `plan` sem erros/warnings
   - Se houver algum replace inesperado na DynamoDB, documentar e discutir antes de fazer apply

## Formas de Teste

1. Output de `terraform fmt -recursive` não lista arquivos alterados (ou lista apenas arquivos com mudanças de espaçamento esperadas)
2. `terraform validate` retorna `Success!` em cada um dos quatro módulos
3. `terraform plan` não exibe nenhum dos warnings de deprecação descritos na história

## Critérios de Aceite

- [ ] `terraform fmt -recursive` executado; quaisquer mudanças de formatação aplicadas e revisadas
- [ ] `terraform validate` passa sem erros em `10-storage`, `20-data`, `40-auth` e `50-lambdas-shell`
- [ ] `terraform plan` executado sem warnings de deprecação (`range_key`, `hash_key`, `aws_region.name`)
- [ ] O resultado do plan foi revisado e não há replaces inesperados ou impactos não documentados
- [ ] Story pronta para commit
