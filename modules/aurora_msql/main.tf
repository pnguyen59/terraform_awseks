locals {
  azs= var.azs
  db_subnet_group_name=var.db_subnet_group
}


resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier = "aurora-cluster"
  engine = "aurora-mysql"
  availability_zones = local.azs
  database_name = "mydb"
  master_password = "test12345"
  master_username = "admin"
  db_subnet_group_name = local.db_subnet_group_name
}

resource "aws_rds_cluster_instance" "primary" {
  identifier = "my-primary"
  cluster_identifier = aws_rds_cluster.aurora_cluster.id
  engine = aws_rds_cluster.aurora_cluster.engine
  instance_class = "db.t3.medium"
  db_subnet_group_name = local.db_subnet_group_name
}
resource "aws_rds_cluster_instance" "reader" {
  identifier           = "my-reader"
  cluster_identifier   = aws_rds_cluster.aurora_cluster.id
  instance_class       = "db.t3.medium"
  engine               = aws_rds_cluster.aurora_cluster.engine
  engine_version       = aws_rds_cluster.aurora_cluster.engine_version
}

resource "aws_rds_cluster_endpoint" "reader" {
  cluster_identifier          = aws_rds_cluster.aurora_cluster.id
  cluster_endpoint_identifier = "reader"
  custom_endpoint_type        = "READER"

  excluded_members = [
    aws_rds_cluster_instance.primary.id
  ]
}