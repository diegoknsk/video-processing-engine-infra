# Cognito User Pool — configurações mínimas seguras; política de senha parametrizável.
# Atributos name e email. auto_verified_attributes parametrizável: use [] em dev para não exigir confirmação de email (Storie-15).

resource "aws_cognito_user_pool" "main" {
  name = "${var.prefix}-user-pool"
  tags = var.common_tags

  # Política de senha parametrizável
  password_policy {
    minimum_length                   = var.password_min_length
    require_lowercase                = var.password_require_lowercase
    require_uppercase                = var.password_require_uppercase
    require_numbers                  = var.password_require_numbers
    require_symbols                  = var.password_require_symbols
    temporary_password_validity_days = 7
  }

  # Schema: name (obrigatório) e email (obrigatório para login/verificação)
  schema {
    name                = "name"
    attribute_data_type = "String"
    required            = true
    mutable             = true
  }

  schema {
    name                = "email"
    attribute_data_type = "String"
    required            = true
    mutable             = true
  }

  auto_verified_attributes = var.auto_verified_attributes
  username_attributes      = ["email"]

  # Account recovery: email (sem phone nesta story)
  # Quando auto_verified_attributes = [], usar admin_only para não exigir email verificado
  account_recovery_setting {
    recovery_mechanism {
      name     = length(var.auto_verified_attributes) > 0 ? "verified_email" : "admin_only"
      priority = 1
    }
  }

  # Configuração de email: necessário mesmo quando auto_verified_attributes = []
  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  deletion_protection = "INACTIVE"
}
