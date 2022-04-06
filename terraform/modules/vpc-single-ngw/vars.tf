

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "application_vpc_name" {
  description = "Name label for Application VPC"
  type        = string
}

#variable "tenancy" {
#  type        = string
#}

variable "availability_zone1" {
  description = "Application VPC - Availability Zone 01"
  type        = string
}

variable "availability_zone2" {
  description = "Application VPC - Availability Zone 02"
  type        = string
}

variable "application_vpc_public_subnet1_cidr" {
  description = "Application VPC - Public Subnet AZ01 CIDR"
  type        = string
}

variable "application_vpc_public_subnet1_name" {
  description = "Application VPC - Public Subnet AZ01 Name"
  type        = string
}

variable "application_vpc_public_subnet2_cidr" {
  description = "Application VPC - Public Subnet AZ02 CIDR"
  type        = string
}

variable "application_vpc_public_subnet2_name" {
  description = "Application VPC - Public Subnet AZ02 Name"
  type        = string
}

variable "application_vpc_private_subnet1_cidr" {
  description = "Application VPC - Private Subnet 01 - CIDR"
  type        = string
}

variable "application_vpc_private_subnet1_name" {
  description = "Application VPC - Private Subnet 01 - Name"
  type        = string
}

variable "application_vpc_private_subnet2_cidr" {
  description = "Application VPC - Private Subnet 02 - CIDR"
  type        = string
}

variable "application_vpc_private_subnet2_name" {
  description = "Application VPC - Private Subnet 02 - Name"
  type        = string
}

variable "application_vpc_private_subnet3_cidr" {
  description = "Application VPC - Private Subnet 03 - CIDR"
  type        = string
}

variable "application_vpc_private_subnet3_name" {
  description = "Application VPC - Private Subnet 03 - Name"
  type        = string
}

variable "application_vpc_private_subnet4_cidr" {
  description = "Application VPC - Private Subnet 04 - CIDR"
  type        = string
}

variable "application_vpc_private_subnet4_name" {
  description = "Application VPC - Private Subnet 04 - Name"
  type        = string
}

variable "application_vpc_private_subnet5_cidr" {
  description = "Application VPC - Private Subnet 05 - CIDR"
  type        = string
}

variable "application_vpc_private_subnet5_name" {
  description = "Application VPC - Private Subnet 05 - Name"
  type        = string
}

variable "application_vpc_private_subnet6_cidr" {
  description = "Application VPC - Private Subnet 06 - CIDR"
  type        = string
}

variable "application_vpc_private_subnet6_name" {
  description = "Application VPC - Private Subnet 06 - Name"
  type        = string
}

variable "application_vpc_igw" {
  description = "Application VPC - Internet Gateway"
  type        = string
}

variable "application_vpc_natgateway_az01_name" {
  description = "Application VPC - NAT Gateway AZ01"
  type        = string
}

variable "application_vpc_natgateway_az02_name" {
  description = "Application VPC - NAT Gateway AZ02"
  type        = string
}

variable "application_vpc_private_rtb_az01_name" {
  description = "Application VPC - Private Routing Table AZ01"
  type        = string
}

variable "application_vpc_private_rtb_az02_name" {
  description = "Application VPC - Private Routing Table AZ02"
  type        = string
}

variable "application_vpc_public_rtb_name" {
  description = "Application VPC - Public Routing Table"
  type        = string
}

variable "application_vpc_flowlogs_bucket" {
  description = "Application VPC - VPC Flowlogs Bucket"
  type        = string
}

variable "application_vpc_flowlogs_name" {
  description = "Application VPC - VPC Flowlogs Bucket"
  type        = string
}

variable "application_eks_cluster_name" {
  description = "EKS Cluster"
  type        = string
}
