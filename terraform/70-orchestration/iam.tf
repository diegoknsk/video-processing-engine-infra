# IAM: em ambiente AWS Academy o Terraform não tem permissão para criar IAM roles (iam:CreateRole).
# A State Machine Step Functions usa a role existente informada em var.lab_role_arn (Lab Role).
# A Lab Role deve ter trust policy permitindo states.amazonaws.com e permissões para
# logs (log group da SFN), lambda:InvokeFunction (Processor e opcionalmente Finalizer), sqs:SendMessage (quando finalization_mode = sqs).
