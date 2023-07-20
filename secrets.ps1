# Cria um SecureString para a AWS Access Key
$env:TFVAR_aws_access_key = ConvertTo-SecureString -String "valor_sensivel_da_AWS_Access_Key" -AsPlainText -Force

# Cria um SecureString para a AWS Secret Key
$env:TFVAR_aws_secret_key = ConvertTo-SecureString -String "valor_sensivel_da_AWS_Secret_Key" -AsPlainText -Force

# Exporta as SecureStrings criptografadas para um arquivo de texto
$env:TFVAR_aws_access_key | ConvertFrom-SecureString | Out-File -FilePath "aws_access_key.txt"
$env:TFVAR_aws_secret_key | ConvertFrom-SecureString | Out-File -FilePath "aws_secret_key.txt"