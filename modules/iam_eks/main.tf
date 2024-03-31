data "aws_availability_zones" "available" {}

locals {
  name   = var.name

  tags = merge(
    {Template = "base iam module"},
    var.tags
  ) 
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam" {
  name               = local.name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "iam-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.iam.name
}