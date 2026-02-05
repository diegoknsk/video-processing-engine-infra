# Subtask 03: Preparar scaffold GitHub Actions (workflows placeholder)

## Descrição
Criar a estrutura do diretório `.github/workflows/` e pelo menos um workflow YAML placeholder para Terraform (ex.: validação ou plan), sem executar `terraform apply` nem provisionar recursos. O workflow pode ser desabilitado ou conter apenas jobs de lint/validate/plan em modo dry-run, sem credenciais reais commitadas.

## Passos de implementação
1. Criar o diretório `.github/workflows/` na raiz do repositório.
2. Adicionar um workflow placeholder (ex.: `terraform-validate.yml` ou `bootstrap.yml`) com um job que: faça checkout do repo, opcionalmente configure Terraform (init em diretório específico ou skip), e deixe preparado para futura inclusão de steps de plan/apply; não incluir step de apply real nem secrets hardcoded.
3. Documentar no próprio workflow ou em comentário que credenciais AWS devem ser injetadas via GitHub Secrets (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN quando aplicável), alinhado às infrarules.
4. Garantir que o workflow seja sintaticamente válido (YAML válido) e que não provisione nenhum recurso AWS.

## Formas de teste
1. Verificar que `.github/workflows/` existe e contém pelo menos um arquivo `.yml` ou `.yaml`.
2. Validar sintaxe YAML do workflow (ex.: ferramenta online ou `yamllint` se disponível).
3. Confirmar que não há step com `terraform apply -auto-approve` ou equivalente que execute apply real; opcionalmente rodar workflow em modo dry-run ou apenas verificar conteúdo do arquivo.

## Critérios de aceite da subtask
- [ ] O diretório `.github/workflows/` existe e contém pelo menos um workflow (arquivo YAML) placeholder.
- [ ] O workflow não executa `terraform apply` real; pode conter jobs de checkout, init ou validate.
- [ ] Documentação ou comentários indicam que credenciais AWS virão de GitHub Secrets; nenhuma credencial está commitada.
