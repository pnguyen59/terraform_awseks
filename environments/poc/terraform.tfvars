vpc_cidr     = "10.0.0.0/16"
vpc_id = "vpc-68f0ee0f" //vpc id here
private_subnet_ids = ["subnet-0c61f464c49fbb2b0", "subnet-0906b627599c21662","subnet-0a918c1df2a568096"] //list of subnet ids here (for redis, app, msk)
public_subnet_ids = [""]
eks_subnet_ids = ["subnet-0f98d3d7b5737fead","subnet-0467ebd27d2e6d24c","subnet-0428e81a33cf520a6"] //list of subnet ids for eks here (for eks node group)
environment_name = "poc"
aws_region = "ap-southeast-1"