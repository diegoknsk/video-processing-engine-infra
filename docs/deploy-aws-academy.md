# Deploy via GitHub Actions — AWS Academy

Documentação mínima para executar **deploy**, **validate** e **destroy** da infraestrutura via GitHub Actions usando credenciais temporárias da **AWS Academy**.

---

## 🎯 Objetivo

Este guia é voltado para **pós-graduação/laboratório** onde a infraestrutura será criada e destruída múltiplas vezes. Foco em **GitHub Actions** com credenciais temporárias da AWS Academy.

---

## ⚙️ Pré-requisitos

1. **Conta AWS Academy** ativa com credenciais temporárias (Access Key, Secret Key e Session Token).
2. **Repositório GitHub** configurado com o código deste projeto.
3. **Permissões de administrador** no repositório GitHub (para configurar Secrets).

---

## 🔐 Passo 1: Configurar Secrets no GitHub

As credenciais AWS devem ser configuradas como **Secrets** no repositório GitHub. **NUNCA commite credenciais no código**.

### 1.1. Acessar configuração de Secrets

1. No repositório GitHub, vá em: **Settings** → **Secrets and variables** → **Actions**
2. Clique em **New repository secret**

### 1.2. Secrets obrigatórios

Configure os seguintes secrets:

| Secret | Descrição | Onde obter | Exemplo |
|--------|-----------|------------|---------|
| `AWS_ACCESS_KEY_ID` | Access Key ID da AWS Academy | Portal AWS Academy → AWS Details → Show | `ASIAXXX...` |
| `AWS_SECRET_ACCESS_KEY` | Secret Access Key da AWS Academy | Portal AWS Academy → AWS Details → Show | `wJalrXUtn...` |
| `AWS_SESSION_TOKEN` | Session Token (obrigatório para credenciais temporárias) | Portal AWS Academy → AWS Details → Show | `IQoJb3JpZ...` |
| `LAB_ROLE_ARN` | ARN da Lab Role (necessário para criar recursos) | Já está em `envs/dev.tfvars` ou obter no IAM | `arn:aws:iam::ACCOUNT_ID:role/LabRole` |

**Opcional:**
| Secret | Descrição | Valor padrão |
|--------|-----------|--------------|
| `AWS_REGION` | Região AWS | `us-east-1` (já está como default no código) |

### 1.3. Como obter credenciais da AWS Academy

1. Acesse o **AWS Academy Learner Lab**
2. Clique em **AWS Details**
3. Clique em **Show** ao lado de "AWS CLI"
4. Copie os valores de:
   - `aws_access_key_id`
   - `aws_secret_access_key`
   - `aws_session_token`

⚠️ **IMPORTANTE:** As credenciais da AWS Academy **expiram**. Antes de cada execução de workflow, verifique se as credenciais ainda estão válidas e atualize os Secrets se necessário.

### 1.4. Como obter o Lab Role ARN

O ARN da Lab Role já está configurado em `terraform/envs/dev.tfvars`:

```hcl
lab_role_arn = "arn:aws:iam::804879632477:role/LabRole"
```

Se você estiver usando uma **conta diferente**, obtenha o ARN correto:

1. No console AWS, vá em **IAM** → **Roles**
2. Procure por **LabRole**
3. Copie o ARN (formato: `arn:aws:iam::ACCOUNT_ID:role/LabRole`)
4. Atualize o valor em `terraform/envs/dev.tfvars` **OU** crie um Secret `LAB_ROLE_ARN` no GitHub

---

## 🚀 Passo 2: Executar Deploy (Terraform Apply)

### 2.1. Via GitHub Actions (Manual)

1. No repositório GitHub, vá em: **Actions** → **Terraform Apply**
2. Clique em **Run workflow**
3. Selecione o branch (ex: `main` ou `dev`)
4. Clique em **Run workflow** (botão verde)

O workflow irá:
- ✅ Fazer checkout do código
- ✅ Configurar Terraform
- ✅ Executar `terraform init -backend=false` (sem backend remoto)
- ✅ Executar `terraform validate`
- ✅ Executar `terraform plan -var-file=envs/dev.tfvars`
- ✅ Executar `terraform apply -auto-approve`

### 2.2. Acompanhar execução

- Durante a execução, você pode acompanhar os logs em tempo real na aba **Actions**
- O apply pode levar **10-15 minutos** (criação de EKS, Cognito, Step Functions, etc.)

### 2.3. Outputs

Após o `terraform apply` concluir com sucesso, você pode visualizar os outputs importantes nos logs, como:
- API Gateway invoke URL
- Cognito User Pool ID e Client ID
- Bucket S3 names
- Step Functions ARN

---

## ✅ Passo 3: Validar Infraestrutura (Terraform Validate)

### 3.1. Via GitHub Actions (Automático)

O workflow **Terraform Validate** é executado automaticamente em:
- **Push** para branches `main` ou `dev`
- **Pull Requests** para `main` ou `dev`

### 3.2. Via GitHub Actions (Manual)

1. No repositório GitHub, vá em: **Actions** → **Terraform Validate**
2. Clique em **Run workflow**
3. Selecione o branch
4. Clique em **Run workflow**

O workflow irá:
- ✅ Fazer checkout do código
- ✅ Configurar Terraform
- ✅ Executar `terraform init -backend=false`
- ✅ Executar `terraform validate`

⚠️ **Nota:** O validate **não cria recursos** na AWS, apenas valida a sintaxe do código Terraform.

---

## 🗑️ Passo 4: Destruir Infraestrutura (Terraform Destroy)

### 4.1. Via GitHub Actions (Manual)

⚠️ **ATENÇÃO:** Este comando **destrói TODOS os recursos** criados. Use com cuidado.

1. No repositório GitHub, vá em: **Actions** → **Terraform Destroy**
2. Clique em **Run workflow**
3. Selecione o branch (ex: `main` ou `dev`)
4. Clique em **Run workflow** (botão verde)

O workflow irá:
- ✅ Fazer checkout do código
- ✅ Configurar Terraform
- ✅ Executar `terraform init -backend=false`
- ✅ Executar `terraform destroy -auto-approve -var-file=envs/dev.tfvars`

### 4.2. Tempo de execução

O destroy pode levar **5-10 minutos** dependendo da quantidade de recursos criados.

---

## 🔄 Fluxo Típico de Trabalho (Pós-Graduação)

Para ambientes de **laboratório/pós-graduação**, o fluxo típico é:

1. **Atualizar credenciais AWS Academy** (a cada sessão de lab, pois expiram)
   - Obter novas credenciais no portal AWS Academy
   - Atualizar Secrets no GitHub (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`)

2. **Deploy da infraestrutura**
   - Executar workflow **Terraform Apply**
   - Aguardar conclusão (~10-15 min)
   - Anotar outputs (API URL, Cognito IDs, etc.)

3. **Testar/Desenvolver**
   - Usar a infraestrutura criada
   - Fazer testes, validações, experimentos

4. **Destruir infraestrutura** (economizar créditos)
   - Executar workflow **Terraform Destroy**
   - Aguardar conclusão (~5-10 min)

5. **Repetir** para próxima sessão de lab

---

## 📋 Checklist Rápido

Antes de executar o deploy:

- [ ] Credenciais AWS Academy atualizadas (não expiradas)
- [ ] Secrets configurados no GitHub:
  - [ ] `AWS_ACCESS_KEY_ID`
  - [ ] `AWS_SECRET_ACCESS_KEY`
  - [ ] `AWS_SESSION_TOKEN`
  - [ ] `LAB_ROLE_ARN` (ou verificar `envs/dev.tfvars`)
- [ ] Branch correto selecionado (main/dev)
- [ ] Código Terraform válido (sem erros de sintaxe)

---

## ⚠️ Troubleshooting

### Erro: "ExpiredToken"

**Causa:** As credenciais da AWS Academy expiraram.

**Solução:**
1. Obtenha novas credenciais no portal AWS Academy
2. Atualize os Secrets no GitHub (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`)
3. Execute o workflow novamente

### Erro: "User is not authorized to perform: iam:CreateRole"

**Causa:** A AWS Academy não permite criar roles IAM.

**Solução:** Verificar se a variável `lab_role_arn` está corretamente configurada em `terraform/envs/dev.tfvars` com o ARN da LabRole existente.

### Erro: "Backend initialization required"

**Causa:** O workflow está tentando usar backend remoto S3, mas as credenciais não têm permissão ou o bucket não existe.

**Solução:** Os workflows já usam `terraform init -backend=false` por padrão. Se o erro persistir, verifique se não há configuração de backend conflitante.

### Workflow falha no "Terraform Init"

**Causa:** Secrets não configurados ou inválidos.

**Solução:**
1. Verificar se todos os Secrets obrigatórios estão configurados
2. Verificar se as credenciais estão válidas (não expiraram)
3. Verificar os logs do workflow para detalhes do erro

---

## 📚 Referências

- [README.md](../README.md) — Visão geral da arquitetura
- [Contexto Arquitetural](contexto-arquitetural.md) — Detalhes dos fluxos e módulos
- [Regras de Infraestrutura](../.cursor/rules/infrarules.mdc) — Convenções e boas práticas
- [AWS Academy Learner Lab](https://awsacademy.instructure.com/) — Portal para obter credenciais

---

## 💡 Dicas

1. **Créditos AWS Academy:** Sempre execute `terraform destroy` após finalizar os testes para economizar créditos da AWS Academy.

2. **Validade das credenciais:** As credenciais da AWS Academy expiram após algumas horas. Sempre verifique a validade antes de executar workflows.

3. **Monitoramento:** Durante o `terraform apply`, você pode acompanhar a criação de recursos no console AWS (se necessário).

4. **Ordem de execução:** O Terraform gerencia automaticamente as dependências entre os módulos. Não é necessário executar cada módulo separadamente.

5. **Backend local:** Por padrão, os workflows usam backend local (`-backend=false`). Se você quiser usar backend remoto S3, ajuste os workflows e garanta que o bucket S3 existe e as credenciais têm permissão de acesso.

---

**Última atualização:** Fevereiro 2026  
**Versão:** 1.0 (AWS Academy)
