# Região, Acces Key e Secret Key da AWS
aws_region        = "us-east-1"
aws_access_key    = var.TF_aws_access_key
aws_secret_key    = var.TF_aws_secret_key

# AZ e subnets
availability_zones = ["us-east-1a", "us-east-1b"]
public_subnets     = ["10.10.100.0/24", "10.10.101.0/24"]
private_subnets    = ["10.10.0.0/24", "10.10.1.0/24"]

# Tags
app_name        = "nginx-app"
app_environment = "dev"