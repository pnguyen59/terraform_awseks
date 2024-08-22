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

resource "aws_rds_cluster_instance" "cluster_instances" {
  count = 3
  identifier = "aurora-cluster-demo-${count.index}"
  cluster_identifier = aws_rds_cluster.aurora_cluster.id

  engine = aws_rds_cluster.aurora_cluster.engine
  instance_class = "db.t3.medium"
  db_subnet_group_name = local.db_subnet_group_name
}
# resource "aws_rds_cluster_instance" "reader" {
#   identifier           = "my-reader"
#   cluster_identifier   = aws_rds_cluster.aurora_cluster.id
#   instance_class       = "db.t3.medium"
#   engine               = aws_rds_cluster.aurora_cluster.engine
#   engine_version       = aws_rds_cluster.aurora_cluster.engine_version
# }

# data "aws_rds_cluster_instances" "aurora_readers"{
#   cluster_identifier = aws_rds_cluster.aurora_cluster.id
#   filter {
#     name   = "is_cluster_writer"
#     values = ["false"]
#   }
# } 
# resource "aws_rds_cluster_endpoint" "reader" {
#   cluster_identifier          = aws_rds_cluster.aurora_cluster.id
#   cluster_endpoint_identifier = "reader"
#   custom_endpoint_type        = "READER"
#   static_members = data.aws_rds_cluster_instances.aurora_readers.
# }