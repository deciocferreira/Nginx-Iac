aws_region        = "us-east-1"
aws_access_key    = "your aws access key"
aws_secret_key    = "your aws secret key"

# these are zones and subnets examples
availability_zones = ["us-east-1a", "us-east-1b"]
public_subnets     = ["10.10.100.0/24", "10.10.101.0/24"]
private_subnets    = ["10.10.0.0/24", "10.10.1.0/24"]

# these are used for tags
app_name        = "node-js-app"
app_environment = "production"