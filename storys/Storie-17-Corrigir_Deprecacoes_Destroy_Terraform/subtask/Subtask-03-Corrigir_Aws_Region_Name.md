# Subtask-03: Corrigir aws_region.current.name deprecated

## Descrição
Substituir o acesso ao atributo deprecated `.name` do data source `data "aws_region" "current"` nos dois módulos afetados (`40-auth` e `50-lambdas-shell`), usando o atributo correto conforme a documentação do provider AWS 5.x vigente.

## Contexto do Problema
O `terraform destroy` (e qualquer `plan`/`apply`) emite dois warnings:
```
Warning: Deprecated attribute
  on 40-auth/datasource.tf line 6, in locals:
   6:   region = coalesce(var.region, data.aws_region.current.name)
The attribute "name" is deprecated. Refer to the provider documentation for details.

Warning: Deprecated attribute
  on 50-lambdas-shell/datasource.tf line 6, in locals:
   6:   region = data.aws_region.current.name
```

Arquivos afetados:
- `terraform/40-auth/datasource.tf` — local `region` usa `data.aws_region.current.name`
- `terraform/50-lambdas-shell/datasource.tf` — local `region` usa `data.aws_region.current.name`

## Passos de Implementação

1. **Confirmar o atributo não-deprecated no provider AWS 5.x**
   - Consultar a documentação do data source `aws_region` na versão do provider em uso (verificar `providers.tf` de cada módulo para a versão exata)
   - No provider AWS 5.x recente, o atributo substituto do `.name` é `.region` (ou verificar na doc se manteve `.name` — o warning indicará a alternativa correta)
   - Rodar `terraform plan` com o código atual e ler o warning completo; às vezes o Terraform indica o atributo substituto na mensagem

2. **Atualizar `terraform/40-auth/datasource.tf`**
   - Substituir `data.aws_region.current.name` pelo atributo não-deprecated (ex.: `data.aws_region.current.region` se for o caso):
     ```hcl
     locals {
       region = coalesce(var.region, data.aws_region.current.region)
     }
     ```

3. **Atualizar `terraform/50-lambdas-shell/datasource.tf`**
   - Substituir `data.aws_region.current.name` pelo mesmo atributo identificado no passo anterior:
     ```hcl
     locals {
       account_id = data.aws_caller_identity.current.account_id
       region     = data.aws_region.current.region
     }
     ```

4. **Verificar se há outros módulos usando `.name` no mesmo data source**
   - Buscar no repositório: `rg "aws_region\.current\.name" terraform/`
   - Corrigir quaisquer ocorrências adicionais encontradas

## Formas de Teste

1. Rodar `terraform plan` nos módulos `40-auth` e `50-lambdas-shell` e confirmar ausência do warning `The attribute "name" is deprecated`
2. Rodar `terraform validate` nos dois módulos e confirmar "Success!"
3. Verificar que o valor do local `region` ainda resolve corretamente para a região AWS esperada (ex.: `us-east-1`) inspecionando o output do plan ou adicionando um output temporário

## Critérios de Aceite

- [ ] Nenhum warning `The attribute "name" is deprecated` nos módulos `40-auth` e `50-lambdas-shell`
- [ ] `terraform validate` retorna sucesso nos dois módulos alterados
- [ ] O local `region` continua resolvendo corretamente para a região AWS em uso
- [ ] Busca em todo o repositório por `aws_region\.current\.name` não retorna ocorrências restantes
