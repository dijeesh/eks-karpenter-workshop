locals {
  environment          = "acme-ca" 
  account-id           = "XXXXXXXXXXXX"
  vpc_cidr             = "10.101.0.0/16"
  application_vpc_name = "vpc-acme-ca-us-east-1"
  tenancy              = "dedicated"
  availability_zone1   = "us-east-1a"
  availability_zone2   = "us-east-1b"

  application_vpc_public_subnet1_cidr   = "10.101.0.0/20"
  application_vpc_public_subnet1_name   = "subnet-acme-ca-public-us-east-1-az1"
  application_vpc_public_subnet2_cidr   = "10.101.16.0/20"
  application_vpc_public_subnet2_name   = "subnet-acme-ca-public-us-east-1-az2"
  application_vpc_private_subnet1_cidr  = "10.101.32.0/20"
  application_vpc_private_subnet1_name  = "subnet-acme-ca-private-eks-us-east-1-az1"
  application_vpc_private_subnet2_cidr  = "10.101.48.0/20"
  application_vpc_private_subnet2_name  = "subnet-acme-ca-private-eks-us-east-1-az2"
  application_vpc_private_subnet3_cidr  = "10.101.64.0/20"
  application_vpc_private_subnet3_name  = "subnet-acme-ca-private-rds-us-east-1-az1"
  application_vpc_private_subnet4_cidr  = "10.101.80.0/20"
  application_vpc_private_subnet4_name  = "subnet-acme-ca-private-rds-us-east-1-az2"
  application_vpc_private_subnet5_cidr  = "10.101.96.0/20"
  application_vpc_private_subnet5_name  = "subnet-acme-ca-private-lambda-us-east-1-az1"
  application_vpc_private_subnet6_cidr  = "10.101.112.0/20"
  application_vpc_private_subnet6_name  = "subnet-acme-ca-private-lambda-us-east-1-az2"
  application_vpc_igw                   = "igw-acme-ca-us-east-1"
  application_vpc_natgateway_az01_name  = "nat-acme-ca-us-east-1-az-01"
  application_vpc_natgateway_az02_name  = "nat-acme-ca-us-east-1-az-01"
  application_vpc_private_rtb_az01_name = "rtb-acme-ca-private-us-east-1-az-01"
  application_vpc_private_rtb_az02_name = "rtb-acme-ca-private-us-east-1-az-02"
  application_vpc_public_rtb_name       = "rtb-acme-ca-public-us-east-1"
  application_vpc_flowlogs_bucket       = "acme-ca-vpc-flowlogs"
  application_vpc_flowlogs_name         = "flowlogs-acme-ca-vpc-us-east-1"
  application_eks_cluster_name          = "acme-ca-us-east-1"


}
module "application_vpc" {
  source                                = "../modules/vpc-single-ngw"
  vpc_cidr                              = local.vpc_cidr
  application_vpc_name                  = local.application_vpc_name
  availability_zone1                    = local.availability_zone1
  availability_zone2                    = local.availability_zone2
  application_vpc_public_subnet1_name   = local.application_vpc_public_subnet1_name
  application_vpc_public_subnet1_cidr   = local.application_vpc_public_subnet1_cidr
  application_vpc_public_subnet2_name   = local.application_vpc_public_subnet2_name
  application_vpc_public_subnet2_cidr   = local.application_vpc_public_subnet2_cidr
  application_vpc_private_subnet1_cidr  = local.application_vpc_private_subnet1_cidr
  application_vpc_private_subnet1_name  = local.application_vpc_private_subnet1_name
  application_vpc_private_subnet2_cidr  = local.application_vpc_private_subnet2_cidr
  application_vpc_private_subnet2_name  = local.application_vpc_private_subnet2_name
  application_vpc_private_subnet3_cidr  = local.application_vpc_private_subnet3_cidr
  application_vpc_private_subnet3_name  = local.application_vpc_private_subnet3_name
  application_vpc_private_subnet4_cidr  = local.application_vpc_private_subnet4_cidr
  application_vpc_private_subnet4_name  = local.application_vpc_private_subnet4_name
  application_vpc_private_subnet5_cidr  = local.application_vpc_private_subnet5_cidr
  application_vpc_private_subnet5_name  = local.application_vpc_private_subnet5_name
  application_vpc_private_subnet6_cidr  = local.application_vpc_private_subnet6_cidr
  application_vpc_private_subnet6_name  = local.application_vpc_private_subnet6_name
  application_vpc_igw                   = local.application_vpc_igw
  application_vpc_natgateway_az01_name  = local.application_vpc_natgateway_az01_name
  application_vpc_natgateway_az02_name  = local.application_vpc_natgateway_az02_name  
  application_vpc_private_rtb_az01_name = local.application_vpc_private_rtb_az01_name
  application_vpc_private_rtb_az02_name = local.application_vpc_private_rtb_az02_name
  application_vpc_public_rtb_name       = local.application_vpc_public_rtb_name
  application_vpc_flowlogs_bucket       = local.application_vpc_flowlogs_bucket
  application_vpc_flowlogs_name         = local.application_vpc_flowlogs_name
  application_eks_cluster_name          = local.application_eks_cluster_name
}
