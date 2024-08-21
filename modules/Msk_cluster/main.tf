locals{
    subnets= var.private_subnets
}


resource "aws_msk_cluster" "example" {
  cluster_name           = "example-msk-cluster"
  kafka_version          = "3.3.1"
  number_of_broker_nodes = 3

  broker_node_group_info {
    instance_type   = "kafka.m5.large"
    storage_info {
      ebs_storage_info {
        volume_size = 1000
      }
    }
    client_subnets = var.private_subnets
    security_groups = [aws_security_group.example.id]
  }

  encryption_info {
    encryption_at_rest_kms_key_arn = aws_kms_key.example.arn
  }

  configuration_info {
    arn      = aws_msk_configuration.example.arn
    revision = aws_msk_configuration.example.latest_revision
  }
}

resource "aws_kms_key" "example" {
  description             = "Example KMS Key for MSK"
  deletion_window_in_days = 7
}

resource "aws_msk_configuration" "example" {
  kafka_versions = ["3.3.1"]
  name           = "example-msk-configuration"

  server_properties = <<PROPERTIES
auto.create.topics.enable=true
delete.topic.enable=true
PROPERTIES
}

resource "aws_security_group" "example" {
  name_prefix = "example-msk-"
  vpc_id      = "vpc-68f0ee0f"

  ingress {
    from_port       = 9094
    to_port         = 9094
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
