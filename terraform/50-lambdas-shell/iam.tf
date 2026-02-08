# IAM: em ambiente AWS Academy o Terraform não tem permissão para criar IAM roles (iam:CreateRole).
# Todas as Lambdas usam a role existente informada em var.lab_role_arn (Lab Role).
# A Lab Role deve ter trust policy permitindo lambda.amazonaws.com e as permissões necessárias
# (logs, S3, DynamoDB, SQS, SNS, states:StartExecution conforme cada função).
