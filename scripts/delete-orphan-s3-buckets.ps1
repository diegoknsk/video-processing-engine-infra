# Remove recursos órfãos do projeto (existem na AWS mas não no state).
# Execute quando o state foi perdido (ex.: reinício) e o Terraform falha com AlreadyExists.
# Requer: AWS CLI configurado (credenciais e região).

$ErrorActionPreference = "Stop"
$Prefix = "video-processing-engine-dev"
$Region = if ($env:AWS_REGION) { $env:AWS_REGION } else { "us-east-1" }

# --- 1. API Gateway HTTP API (obter id pelo nome e deletar) ---
Write-Host "API Gateway: buscando e removendo $Prefix-api ..."
$ApiId = aws apigatewayv2 get-apis --region $Region --query "Items[?Name=='$Prefix-api'].ApiId" --output text 2>$null
if ($ApiId) {
    aws apigatewayv2 delete-api --api-id $ApiId --region $Region
    Write-Host "  OK: API $Prefix-api removida."
} else {
    Write-Host "  Aviso: API nao encontrada ou ja removida."
}

# --- 2. Cognito: domínio primeiro, depois User Pool ---
Write-Host "Cognito: removendo dominio e user pool $Prefix-user-pool ..."
$UserPoolId = aws cognito-idp list-user-pools --max-results 20 --region $Region --query "UserPools[?Name=='$Prefix-user-pool'].Id" --output text 2>$null
if ($UserPoolId) {
    aws cognito-idp delete-user-pool-domain --user-pool-id $UserPoolId --domain "$Prefix-auth" --region $Region 2>$null
    aws cognito-idp delete-user-pool --user-pool-id $UserPoolId --region $Region
    Write-Host "  OK: User Pool e dominio removidos."
} else {
    Write-Host "  Aviso: User Pool nao encontrado ou ja removido."
}

# --- 3. DynamoDB ---
Write-Host "DynamoDB: removendo tabela $Prefix-videos ..."
aws dynamodb delete-table --table-name "$Prefix-videos" --region $Region 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "  OK: Tabela $Prefix-videos removida."
} else {
    Write-Host "  Aviso: Tabela nao encontrada ou ja removida."
}

# --- 4. S3 buckets ---
$Buckets = @("$Prefix-videos", "$Prefix-images", "$Prefix-zip")
foreach ($Bucket in $Buckets) {
    Write-Host "S3: esvaziando e removendo $Bucket ..."
    aws s3 rb "s3://$Bucket" --force 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  OK: $Bucket removido."
    } else {
        Write-Host "  Aviso: $Bucket nao encontrado ou ja removido."
    }
}

Write-Host "Concluido. Rode 'terraform apply' novamente."
