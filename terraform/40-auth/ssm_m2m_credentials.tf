# Parâmetros SSM com client_id e client_secret do App Client M2M (Subtask-07 e 08).
# Apenas para ambiente acadêmico/projetinho; condicionado a m2m_expose_credentials_in_ssm.
# Em produção: use m2m_expose_credentials_in_ssm = false e grave o secret no SSM fora do Terraform.

resource "aws_ssm_parameter" "m2m_client_id" {
  count = var.enable_m2m_client && var.m2m_expose_credentials_in_ssm ? 1 : 0

  name  = "/${var.prefix}/cognito-m2m-client-id"
  type  = "String"
  value = aws_cognito_user_pool_client.m2m[0].id

  tags = var.common_tags
}

resource "aws_ssm_parameter" "m2m_client_secret" {
  count = var.enable_m2m_client && var.m2m_expose_credentials_in_ssm ? 1 : 0

  name  = "/${var.prefix}/cognito-m2m-client-secret"
  type  = "SecureString"
  value = aws_cognito_user_pool_client.m2m[0].client_secret

  tags = var.common_tags
}
