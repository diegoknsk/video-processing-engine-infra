# Subtask 05: Revisão de todas as stories 01 a 13 (root e módulos)

## Descrição
Revisar **todas** as stories existentes (Storie-01 a Storie-13) para deixar explícito que: (1) os diretórios terraform/00-foundation, terraform/10-storage, terraform/20-data, etc. são **módulos** consumidos por um **root** Terraform em terraform/; (2) a execução padrão de init, plan e apply é **uma única vez** a partir do diretório terraform/; (3) não é necessário (para uso normal) rodar terraform init ou plan dentro de cada subpasta. A revisão deve ser feita no story.md de cada história, adicionando uma seção ou parágrafo "Modelo de execução" ou atualizando "Escopo Técnico" / "Critérios de Aceite" para referenciar o root. Opcionalmente atualizar subtasks que mencionem "executar terraform plan no módulo X" para "o módulo X é invocado pelo root; validar com terraform plan no root".

## Passos de implementação
1. Listar todas as pastas Storie-01 até Storie-13 e abrir o story.md de cada uma.
2. Em cada story.md, adicionar uma seção **"Modelo de execução (root único)"** ou equivalente (pode ser um parágrafo no Escopo Técnico ou em Dependências) com o texto: "Os diretórios terraform/00-XX, 10-XX, … são módulos Terraform consumidos pelo **root** em terraform/. A execução padrão é: cd terraform && terraform init && terraform plan -var-file=envs/dev.tfvars (e apply). Não é necessário rodar init/plan/apply em cada subpasta para uso normal."
3. Ajustar critérios de aceite ou checklist que digam "terraform plan no módulo 10-storage" para "terraform plan no root (terraform/) inclui o módulo 10-storage e não apresenta referências quebradas".
4. Storie-01: mencionar que a árvore de diretórios abriga **módulos** e que um root em terraform/ orquestrará todos (story 02-Parte2). Storie-02 (Foundation): já diz "módulo consumível por outros"; reforçar "consumido pelo root". Storie-03 (Storage): idem. Storie-04 a 13: mesmo padrão — módulo consumido pelo root; validação via plan no root.
5. Garantir consistência de termos: "root" = configuração em terraform/ que chama os módulos; "módulo" = cada subpasta 00-foundation, 10-storage, etc.

## Formas de teste
1. Ler cada story.md revisada e confirmar que um leitor entende que há um único ponto de execução (terraform/) e que as pastas são módulos.
2. Verificar que não restou menção contraditória do tipo "execute terraform apply em cada módulo" como fluxo padrão.
3. Checar Storie-13 (CI/CD): workflows devem usar working-directory: terraform/ (ou equivalente) para init, plan, apply; ajustar se a revisão da story 13 indicar isso na documentação.

## Critérios de aceite da subtask
- [ ] Todas as stories 01, 02, 03, 04, 05, 06, 07, 08, 09, 10, 11, 12 e 13 tiveram o story.md revisado com menção ao root e ao modelo "um único Terraform orquestrando; execução a partir de terraform/"
- [ ] Terminologia consistente: root em terraform/; módulos em subpastas; init/plan/apply uma vez no root
- [ ] Storie-13 (CI/CD) e README alinhados ao uso de working-directory terraform/ para os comandos Terraform (quando aplicável)
