# Subtask-06: Documentação e critérios de aceite (README, obtenção de token, SSM)

## Descrição
Documentar no README do módulo 40-auth (ou em doc central do repo) como as Lambdas e serviços internos obtêm o access_token via OAuth2 client_credentials, qual URL e body usar, e onde armazenar o client_secret (SSM Parameter Store recomendado, com path/placeholder). Incluir decisão SSM vs Secrets Manager e instruções para validação manual do token (curl ou script) e verificação dos scopes no token. Garantir que os critérios de aceite da história estejam cobertos por passos de validação.

> **Escopo:** Documentação e checklist de validação manual; nenhuma alteração de recurso Terraform além de comentários se necessário.

---

## Passos de Implementação

1. **Atualizar `terraform/40-auth/README.md` (ou docs do repo):**
   - Seção **"App Client M2M (client_credentials)"** descrevendo: propósito (chamadas internas Lambdas/APIs sem usuário), nome do client (`${prefix}-internal-m2m-client`), Resource Server e scopes.
   - Subseção **"Como obter o token":** método POST, URL (token_endpoint output), Content-Type application/x-www-form-urlencoded, body: grant_type=client_credentials&client_id=...&client_secret=...&scope=<scope1>+<scope2> (formato identifier/scope_name separados por +). Exemplo de scope: `video-processing-engine/analyze:run+video-processing-engine/videos:update_status`.
   - Subseção **"Onde armazenar client_secret":** decisão: **SSM Parameter Store (SecureString)** recomendado (custo zero, IAM, KMS). O Terraform não grava o secret no SSM; o pipeline ou operador, após o primeiro apply, deve: (1) ler `terraform output -raw cognito_m2m_client_secret`; (2) gravar no SSM (ex.: `/video-processing-engine/dev/cognito-m2m-client-secret`). Documentar o path sugerido e a variável placeholder `m2m_secret_ssm_parameter_name` para as Lambdas lerem o secret.
   - Breve justificativa: "Secrets Manager preferível quando há rotação automática ou auditoria avançada; para M2M interno no hackathon, SSM é suficiente."
   - Instrução de **validação manual:** exemplo curl para POST no token_endpoint e verificação de access_token e expires_in; como decodificar o JWT (base64) para verificar claim de scope se presente.

2. **Story.md:** Garantir que a seção "Como as Lambdas obtêm o token" está alinhada ao README (já descrita no story.md; o README detalha com exemplos).

3. **Critérios de aceite da história (checklist de validação):**
   - Documentar no README ou em docs/testes que o aceite inclui: (1) terraform apply cria Resource Server + App Client M2M + Domain; (2) obter access_token via POST client_credentials; (3) token contém scopes esperados; (4) outputs disponíveis para pipeline.

4. **Opcional:** Script ou comando de exemplo (ex.: script shell ou doc com curl) para teste de token, sem commitar credenciais.

---

## Formas de Teste

1. **Revisão de documentação:** README contém todas as seções acima; links e nomes de outputs corretos.
2. **Validação manual (executor):** Seguir a documentação e executar POST no token_endpoint com client_id e client_secret (obtidos via terraform output); verificar resposta 200 e presença de access_token; decodificar JWT e verificar scope se aplicável.
3. **terraform validate** e **terraform plan** sem alteração de recursos (apenas doc); confirmação de que nenhum recurso é alterado.

---

## Critérios de Aceite

- [ ] README (ou doc) do 40-auth inclui seção "App Client M2M" com descrição do fluxo client_credentials
- [ ] Documentado: URL do token endpoint, método POST, body (grant_type, client_id, client_secret, scope) e formato do scope (identifier/scope_name)
- [ ] Documentado: armazenamento do client_secret em SSM Parameter Store (path sugerido e variável m2m_secret_ssm_parameter_name); decisão SSM vs Secrets Manager justificada
- [ ] Instruções de validação manual: como obter token via curl (ou equivalente) e como verificar scopes no token
- [ ] Critérios de aceite da história cobertos por documentação ou checklist de validação
- [ ] Nenhuma credencial ou secret real na documentação versionada; apenas placeholders e exemplos genéricos
