# Variáveis para ambiente dev (Foundation - Storie-02).
# Sem credenciais; valores reais serão ajustados conforme ambiente.

project_name                = "video-processing-engine"
environment                 = "dev"
region                      = "us-east-1"
owner                       = "team"
retention_days              = 7
enable_cloudwatch_retention = true

# AWS Academy: descomente e preencha lab_role_arn quando usar AWS Academy (sem iam:CreateRole)
# Em conta AWS regular, deixar comentado — roles IAM são criadas automaticamente.
#lab_role_arn = "arn:aws:iam::ACCOUNT_ID:role/LabRole"
# Cognito: sem confirmação de email (default); política de senha relaxada em dev
auth_password_min_length      = 6
auth_password_require_symbols = false
auth_auto_verified_attributes = []