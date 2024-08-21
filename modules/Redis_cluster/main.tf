locals {
  subnets= var.private_subnets
}
resource "aws_cloudwatch_log_group" "yada" {
  name = "Yada"
}

resource "aws_cloudwatch_log_stream" "foo" {
  name           = "SampleLogStream1234"
  log_group_name = aws_cloudwatch_log_group.yada.name
}

resource "aws_elasticache_replication_group" "example" {
  replication_group_id       = "cluster-example"
  description = "redis-cluster"
  node_type            = "cache.m4.large"
  num_cache_clusters =   3
  automatic_failover_enabled = true
  engine_version       = "7.1"
  port                 = 6379
  multi_az_enabled = true
  subnet_group_name    = aws_elasticache_subnet_group.example.name
  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.yada.name
    destination_type = "cloudwatch-logs"
    log_format       = "text"
    log_type         = "slow-log"
  }
}

# resource "aws_elasticache_user" "test" {
#   user_id       = "testUserId"
#   user_name     = "testUserName"
#   access_string = "on ~app::* -@all +@read +@hash +@bitmap +@geo -setbit -bitfield -hset -hsetnx -hmset -hincrby -hincrbyfloat -hdel -bitop -geoadd -georadius -georadiusbymember"
#   engine        = "REDIS"
#   passwords     = ["password123456789"]
# }


resource "aws_elasticache_subnet_group" "example" {
  name       = "example-subnet-group"
  subnet_ids = local.subnets
}

# resource "aws_security_group" "example" {
#   name_prefix = "example-redis-"
#   vpc_id      = "vpc-68f0ee0f"

#   ingress {
#     from_port       = 6379
#     to_port         = 6379
#     protocol        = "tcp"
#     security_groups = [aws_security_group.example.id]
#   }

#   egress {
#     from_port       = 0
#     to_port         = 0
#     protocol        = "-1"
#     cidr_blocks     = ["0.0.0.0/0"]
#   }
# }
