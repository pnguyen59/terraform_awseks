resource "aws_iam_role" "rds_proxy_role" {
  name = "rds_proxy_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "rds_proxy_policy" {
  name   = "rds_proxy_policy"
  role   = aws_iam_role.rds_proxy_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
          "rds:DescribeDBProxies",
          "rds:DescribeDBProxyTargets",
          "rds:ModifyDBProxyTargetGroup"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}
resource "aws_db_proxy" "my_rds_proxy" {
  name               = "my-rds-proxy"
  engine_family      = "MYSQL"  # or "POSTGRESQL" depending on your DB engine
  role_arn           = aws_iam_role.rds_proxy_role.arn
  vpc_security_group_ids = ["sg-12345678"]  # Replace with your security group ID
  vpc_subnet_ids     = var.subnet_ids  # Use your subnet IDs
  idle_client_timeout = 1800
  require_tls       = true

  auth {
    auth_scheme = "SECRETS"
    secret_arn  = "arn:aws:secretsmanager:us-east-1:123456789012:secret:rds-secrets-arn"  # Replace with your secret ARN
    iam_auth    = "DISABLED"  # Set to "ENABLED" if using IAM authentication
  }
}

resource "aws_db_proxy_target" "my_proxy_target" {
  db_proxy_name      = aws_db_proxy.my_rds_proxy.name
  target_group_name  = "default"  # You can create custom target groups if needed
  db_cluster_identifier = aws_rds_cluster.my_aurora_cluster.id  # Link to your Aurora cluster
}

output "rds_proxy_endpoint" {
  value = aws_db_proxy.my_rds_proxy.endpoint
}