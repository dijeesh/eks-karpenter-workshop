resource "aws_vpc" "application_vpc" {
  cidr_block = var.vpc_cidr
  #  instance_tenancy = "${var.tenancy}"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "${var.application_vpc_name}"
  }
}

resource "aws_subnet" "application_vpc_public_subnet1" {
  vpc_id                  = aws_vpc.application_vpc.id
  cidr_block              = var.application_vpc_public_subnet1_cidr
  availability_zone       = var.availability_zone1
  map_public_ip_on_launch = false
  tags = {
    Name                                   = "${var.application_vpc_public_subnet1_name}"
    "kubernetes.io/cluster/${var.application_eks_cluster_name}" = "shared"
    "kubernetes.io/role/elb"               = 1
  }
}

resource "aws_subnet" "application_vpc_public_subnet2" {
  vpc_id                  = aws_vpc.application_vpc.id
  cidr_block              = var.application_vpc_public_subnet2_cidr
  availability_zone       = var.availability_zone2
  map_public_ip_on_launch = false
  tags = {
    Name                                   = "${var.application_vpc_public_subnet2_name}"
    "kubernetes.io/cluster/${var.application_eks_cluster_name}" = "shared"
    "kubernetes.io/role/elb"               = 1
  }
}

# Private Subnets for EKS Worker Nodes
resource "aws_subnet" "application_vpc_private_subnet1" {
  vpc_id                  = aws_vpc.application_vpc.id
  cidr_block              = var.application_vpc_private_subnet1_cidr
  availability_zone       = var.availability_zone1
  map_public_ip_on_launch = false
  tags = {
    Name                                   = "${var.application_vpc_private_subnet1_name}"
    "kubernetes.io/cluster/${var.application_eks_cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"      = 1
    "karpenter.sh/discovery"               = "${var.application_eks_cluster_name}"
  }
}

resource "aws_subnet" "application_vpc_private_subnet2" {
  vpc_id                  = aws_vpc.application_vpc.id
  cidr_block              = var.application_vpc_private_subnet2_cidr
  availability_zone       = var.availability_zone2
  map_public_ip_on_launch = false
  tags = {
    Name                                   = "${var.application_vpc_private_subnet2_name}"
    "kubernetes.io/cluster/${var.application_eks_cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"      = 1
    "karpenter.sh/discovery"               = "${var.application_eks_cluster_name}"
  }
}

# Private Subnets for Lambda Functions

resource "aws_subnet" "application_vpc_private_subnet3" {
  vpc_id                  = aws_vpc.application_vpc.id
  cidr_block              = var.application_vpc_private_subnet3_cidr
  availability_zone       = var.availability_zone1
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.application_vpc_private_subnet3_name}"
  }
}

resource "aws_subnet" "application_vpc_private_subnet4" {
  vpc_id                  = aws_vpc.application_vpc.id
  cidr_block              = var.application_vpc_private_subnet4_cidr
  availability_zone       = var.availability_zone2
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.application_vpc_private_subnet4_name}"

  }
}

# Private Subnets for RDS Database Clusters

resource "aws_subnet" "application_vpc_private_subnet5" {
  vpc_id                  = aws_vpc.application_vpc.id
  cidr_block              = var.application_vpc_private_subnet5_cidr
  availability_zone       = var.availability_zone1
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.application_vpc_private_subnet5_name}"
  }
}

resource "aws_subnet" "application_vpc_private_subnet6" {
  vpc_id                  = aws_vpc.application_vpc.id
  cidr_block              = var.application_vpc_private_subnet6_cidr
  availability_zone       = var.availability_zone2
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.application_vpc_private_subnet6_name}"

  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.application_vpc.id

  tags = {
    Name = "${var.application_vpc_igw}"
  }
}

resource "aws_eip" "application_vpc_natgateway_az01_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.igw]
}

# resource "aws_eip" "application_vpc_natgateway_az02_eip" {
#   vpc        = true
#   depends_on = [aws_internet_gateway.igw]
# }

resource "aws_nat_gateway" "application_vpc_natgateway_az01" {
  allocation_id = aws_eip.application_vpc_natgateway_az01_eip.id
  subnet_id     = aws_subnet.application_vpc_public_subnet1.id
  depends_on    = [aws_internet_gateway.igw]
  tags = {
    Name = "${var.application_vpc_natgateway_az01_name}"
  }
}

# resource "aws_nat_gateway" "application_vpc_natgateway_az02" {
#   allocation_id = aws_eip.application_vpc_natgateway_az02_eip.id
#   subnet_id     = aws_subnet.application_vpc_public_subnet2.id
#   depends_on    = [aws_internet_gateway.igw]
#   tags = {
#     Name = "${var.application_vpc_natgateway_az02_name}"
#   }
# }

/* Routing table for private subnet */
resource "aws_route_table" "application_vpc_private_rtb_az01" {
  vpc_id = aws_vpc.application_vpc.id
  tags = {
    Name = "${var.application_vpc_private_rtb_az01_name}"
  }
}

resource "aws_route_table" "application_vpc_private_rtb_az02" {
  vpc_id = aws_vpc.application_vpc.id
  tags = {
    Name = "${var.application_vpc_private_rtb_az02_name}"
  }
}

/* Routing table for public subnet */
resource "aws_route_table" "application_vpc_public_rtb" {
  vpc_id = aws_vpc.application_vpc.id
  tags = {
    Name = "${var.application_vpc_public_rtb_name}"
  }
}
resource "aws_route" "application_vpc_public_route" {
  route_table_id         = aws_route_table.application_vpc_public_rtb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "application_vpc_private_route_az01" {
  route_table_id         = aws_route_table.application_vpc_private_rtb_az01.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.application_vpc_natgateway_az01.id
}

resource "aws_route" "application_vpc_private_route_az02" {
  route_table_id         = aws_route_table.application_vpc_private_rtb_az02.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.application_vpc_natgateway_az01.id
}

/* Route table associations */
resource "aws_route_table_association" "application_vpc_public_rtb_association_az01" {
  subnet_id      = aws_subnet.application_vpc_public_subnet1.id
  route_table_id = aws_route_table.application_vpc_public_rtb.id
}
resource "aws_route_table_association" "application_vpc_public_rtb_association_az02" {
  subnet_id      = aws_subnet.application_vpc_public_subnet2.id
  route_table_id = aws_route_table.application_vpc_public_rtb.id
}
resource "aws_route_table_association" "application_vpc_private_rtb_association_az01_01" {
  subnet_id      = aws_subnet.application_vpc_private_subnet1.id
  route_table_id = aws_route_table.application_vpc_private_rtb_az01.id
}

resource "aws_route_table_association" "application_vpc_private_rtb_association_az02_01" {
  subnet_id      = aws_subnet.application_vpc_private_subnet2.id
  route_table_id = aws_route_table.application_vpc_private_rtb_az02.id
}

resource "aws_route_table_association" "application_vpc_private_rtb_association_az01_02" {
  subnet_id      = aws_subnet.application_vpc_private_subnet3.id
  route_table_id = aws_route_table.application_vpc_private_rtb_az01.id
}

resource "aws_route_table_association" "application_vpc_private_rtb_association_az02_02" {
  subnet_id      = aws_subnet.application_vpc_private_subnet4.id
  route_table_id = aws_route_table.application_vpc_private_rtb_az02.id
}

resource "aws_route_table_association" "application_vpc_private_rtb_association_az01_03" {
  subnet_id      = aws_subnet.application_vpc_private_subnet5.id
  route_table_id = aws_route_table.application_vpc_private_rtb_az01.id
}

resource "aws_route_table_association" "application_vpc_private_rtb_association_az02_03" {
  subnet_id      = aws_subnet.application_vpc_private_subnet6.id
  route_table_id = aws_route_table.application_vpc_private_rtb_az02.id
}

resource "aws_s3_bucket" "application_vpc_flowlogs_bucket" {
  bucket = var.application_vpc_flowlogs_bucket
}

resource "aws_flow_log" "application_vpc_flowlogs" {
  log_destination      = aws_s3_bucket.application_vpc_flowlogs_bucket.arn
  log_destination_type = "s3"
  traffic_type         = "REJECT"
  vpc_id               = aws_vpc.application_vpc.id
  tags = {
    Name = "${var.application_vpc_flowlogs_name}"
  }
}
