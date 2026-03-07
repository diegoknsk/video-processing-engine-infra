# Subtask 03: Documentação e critérios de teste

## Descrição
Atualizar o README do módulo `50-lambdas-shell` (e, se necessário, a própria story) para documentar que a configuração atual das Lambdas é voltada para **teste e benchmark do MVP**, listar os valores por Lambda, deixar explícito que não é configuração final de produção e que o Processor visa permitir testes com vídeos grandes (ex.: 1 GB até ~1,2 GB em cenário controlado), sem garantia absoluta.

## Passos de implementação

1. No `terraform/50-lambdas-shell/README.md`, adicionar ou atualizar uma seção (ex.: "Configuração para testes / benchmark MVP") que:
   - Indique que os valores de memory, ephemeral_storage e timeout atuais são para **teste e validação técnica do MVP**, não para produção.
   - Inclua uma tabela resumindo a configuração por Lambda (Processor: 3072 MB / 8192 MB / 15 min / SnapStart None; demais conforme Storie-21).
   - Mencione que o Lambda Processor está dimensionado para **permitir** testes com vídeos grandes (ex.: 1 GB até aproximadamente 1,2 GB em cenário controlado), sem que isso constitua garantia absoluta para qualquer tamanho ou cenário.
2. Garantir que a story principal (Storie-21) já contém o contexto e os critérios de aceite referentes a essa documentação (verificação de consistência).
3. Se existir documento de critérios de teste ou checklist de validação do MVP no repositório, adicionar item que exija a execução de `terraform plan` (e, quando aplicável, apply) e a conferência dos valores no console/CLI conforme esta story.

## Formas de teste

1. Ler o README atualizado e confirmar que um desenvolvedor consegue entender que a configuração é temporária e para testes/benchmark.
2. Verificar que a tabela de configuração no README está alinhada aos valores aplicados em Subtask-01 e Subtask-02.
3. Validar que não há afirmação de "garantia" de suporte a qualquer tamanho de vídeo; apenas "permitir testes" com faixa indicativa (ex.: 1 GB até ~1,2 GB em cenário controlado).

## Critérios de aceite da subtask

- [x] O README do módulo `50-lambdas-shell` contém seção que explicita configuração para teste/benchmark MVP, com tabela por Lambda e aviso de que não é configuração final de produção.
- [x] Está documentado que o Processor visa permitir testes com vídeos grandes (ex.: 1 GB até ~1,2 GB em cenário controlado), sem garantia absoluta.
- [x] A documentação está consistente com os valores definidos na Storie-21 e implementados nas Subtask-01 e Subtask-02.
