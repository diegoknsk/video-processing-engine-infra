# Subtask 04: Garantir IAM para escrita em logs (onde aplicável)

## Descrição
Garantir que as roles IAM das 5 Lambdas (50-lambdas-shell) e da Step Functions (70-orchestration) tenham permissão para escrever nos respectivos log groups: logs:CreateLogStream e logs:PutLogEvents. Onde aplicável: verificar que as políticas existentes cobrem os nomes/ARNs dos log groups criados; opcionalmente restringir o resource da policy ao ARN dos log groups específicos (least privilege) em vez de "*" ou /aws/lambda/*.

## Passos de implementação
1. No módulo **50-lambdas-shell**, verificar que cada role Lambda possui política com logs:CreateLogStream e logs:PutLogEvents. Se a policy atual usar resource "arn:aws:logs:*:*:log-group:/aws/lambda/*", já cobre os 5 log groups criados; não é obrigatório alterar. Para least privilege, opcionalmente alterar o resource para "arn:aws:logs:${region}:${account}:log-group:/aws/lambda/${prefix}-*" (ou lista dos 5 ARNs) para restringir às funções do projeto.
2. No módulo **70-orchestration**, verificar que a role da SFN possui política com logs:CreateLogStream e logs:PutLogEvents no log group da SFN (resource = ARN do log group ou /aws/stepfunctions/${prefix}-*). A Storie-09 já define permissão de logs no log group da SFN; garantir que o ARN/nome do log group na policy corresponda ao log group criado.
3. Documentar no README da observabilidade: "Lambda roles (50-lambdas-shell) e SFN role (70-orchestration) já possuem permissão de escrita em CloudWatch Logs nos respectivos log groups; os nomes dos log groups seguem o padrão /aws/lambda/{prefix}-* e /aws/stepfunctions/{prefix}-*."
4. Se algum módulo não tiver permissão explícita para o log group, adicionar à policy o resource correspondente (ARN do log group); garantir que não haja regressão (Lambdas/SFN continuam podendo escrever após apply).
5. Não criar novas roles; apenas garantir/ajustar políticas existentes onde aplicável.

## Formas de teste
1. Após apply, invocar uma Lambda e verificar que o log stream é criado e que eventos aparecem no log group (se a Lambda não tiver permissão, não haverá logs).
2. Verificar nos módulos 50-lambdas-shell e 70-orchestration que as policies de logs referenciam recurso que inclui os log groups criados (/aws/lambda/* ou ARNs específicos).
3. Executar terraform plan e confirmar que não há remoção de permissões necessárias; terraform validate passa.

## Critérios de aceite da subtask
- [ ] As 5 roles Lambda (50-lambdas-shell) possuem permissão de escrita (CreateLogStream, PutLogEvents) em log groups que cobrem /aws/lambda/{prefix}-auth, etc.; SFN role possui permissão no log group da SFN. **Em AWS Academy:** as Lambdas e a SFN usam **lab_role_arn**; a Lab Role deve ter essas permissões de logs (não criamos policies no Terraform; documentar requisito para a Lab Role).
- [ ] Onde aplicável, policy ajustada ou documentada; nenhuma regressão (logs continuam sendo escritos após apply); terraform validate e plan passam.
