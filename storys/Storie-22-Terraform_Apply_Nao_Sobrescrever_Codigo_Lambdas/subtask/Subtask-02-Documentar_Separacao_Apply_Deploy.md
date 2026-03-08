# Subtask-02: Documentar separação Apply Infra vs Deploy Código

## Descrição
Documentar de forma explícita que o `terraform apply` gerencia a **infraestrutura** e a **configuração** das Lambdas (variáveis de ambiente, memória, timeout, permissões, etc.), mas **não** o código (pacote/zip) das funções. O deploy do código das Lambdas é responsabilidade do pipeline de aplicação ou processo equivalente.

## Passos de Implementação

1. **Definir onde documentar**
   - Opção A: adicionar seção no `README.md` na raiz do repositório.
   - Opção B: criar ou atualizar `terraform/50-lambdas-shell/README.md` com essa informação.
   - Opção C: ambos (breve menção no README raiz e detalhe no módulo lambdas-shell).

2. **Conteúdo a incluir**
   - O Terraform cria as Lambdas na primeira aplicação com o artefato placeholder (`empty.zip`).
   - A partir daí, o Terraform **ignora** alterações no código (filename/source_code_hash) para não sobrescrever o código implantado.
   - O **deploy do código** das Lambdas (pacote real da aplicação) deve ser feito pelo pipeline de build/deploy da aplicação (ex.: GitHub Actions que faz build e atualiza a função via AWS CLI ou SDK), e não pelo `terraform apply`.
   - Re-executar `terraform apply` é seguro para: alterar variáveis de ambiente, memória, timeout, políticas, event source mappings, etc.; não altera o código já implantado.

3. **Manter alinhado às infrarules**
   - Garantir que a redação esteja alinhada às regras do repositório (nenhuma credencial, separação infra vs aplicação).

## Formas de Teste

1. Revisar o texto para clareza e consistência com o comportamento implementado na Subtask 01.
2. Verificar que um novo desenvolvedor consegue entender quem faz o quê (Terraform = infra/config; pipeline = código).

## Critérios de Aceite

- [ ] Existe documentação (README ou equivalente) que explica que o Terraform não gerencia o código das Lambdas após a criação inicial.
- [ ] Fica explícito que o deploy do código é responsabilidade do pipeline de aplicação (ou processo equivalente).
- [ ] A documentação não contém credenciais nem dados sensíveis.
