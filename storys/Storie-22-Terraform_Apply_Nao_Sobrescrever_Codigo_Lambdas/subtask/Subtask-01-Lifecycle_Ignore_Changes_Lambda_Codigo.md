# Subtask-01: Adicionar lifecycle ignore_changes para código das Lambdas

## Descrição
Adicionar em cada recurso `aws_lambda_function` do módulo `terraform/50-lambdas-shell/lambdas.tf` um bloco `lifecycle { ignore_changes = [filename, source_code_hash] }`, para que o Terraform não atualize o pacote de código da Lambda em aplicações subsequentes. O código implantado (por pipeline ou outro meio) não será sobrescrito pelo placeholder `empty.zip`.

## Contexto do Problema
- No primeiro `terraform apply`, as Lambdas são criadas com `filename = var.artifact_path` (ex.: `artifacts/empty.zip`).
- Quando o código real é implantado nas Lambdas (fora do Terraform), o estado do Terraform continua referenciando o arquivo local `empty.zip`.
- Em um novo `terraform apply`, o Terraform detecta diferença (hash do arquivo vs. código atual na AWS) e "atualiza" a Lambda reenviando `empty.zip`, sobrescrevendo o código em produção.

## Passos de Implementação

1. **Abrir `terraform/50-lambdas-shell/lambdas.tf`**
   - Identificar os seis recursos: `aws_lambda_function.auth`, `video_management`, `video_orchestrator`, `video_processor`, `video_finalizer`, `update_status_video`.

2. **Incluir bloco `lifecycle` em cada recurso**
   - Dentro de cada `resource "aws_lambda_function" "..."` adicionar:
     ```hcl
     lifecycle {
       ignore_changes = [filename, source_code_hash]
     }
     ```
   - Colocar o bloco após `tags` e antes do fechamento do recurso.

3. **Considerar atributo `publish` (opcional)**
   - Se o pipeline de deploy publica novas versões e o Terraform não deve alterar isso, pode-se incluir `publish` em `ignore_changes`. Avaliar conforme uso real (ex.: `ignore_changes = [filename, source_code_hash, publish]`). Para esta story, manter apenas `filename` e `source_code_hash` salvo decisão contrária.

4. **Executar `terraform validate`**
   - No diretório `terraform/` (root) executar `terraform validate` e garantir que não há erros.

## Formas de Teste

1. Com estado já existente (Lambdas criadas e com código real): executar `terraform plan` e verificar que **não** há mudanças em `filename` ou `source_code_hash` das Lambdas.
2. Alterar uma variável de ambiente em `lambdas.tf` (ex.: `LOG_LEVEL`), rodar `terraform plan` e confirmar que apenas o `environment` aparece como mudança, não o código.
3. Rodar `terraform validate` no root e no módulo para garantir sintaxe correta.

## Critérios de Aceite

- [ ] Os seis recursos `aws_lambda_function` em `lambdas.tf` possuem `lifecycle { ignore_changes = [filename, source_code_hash] }`.
- [ ] `terraform validate` no root retorna sucesso.
- [ ] Em um cenário onde as Lambdas já existem com código deployado, `terraform plan` não propõe alteração no pacote (zip) das funções.
