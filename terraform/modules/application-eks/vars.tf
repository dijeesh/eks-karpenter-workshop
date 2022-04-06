variable "cluster_name" {
  type        = string
  description = "EKS Cluster Name"
}

variable "cluster_version" {
  type        = string
  description = "EKS Cluster Version"
}

variable "eks_cluster_iam_role" {
  type        = string
  description = "IAM Role for EKS Cluster"
}

variable "eks_cluster_node_role" {
  type        = string
  description = "IAM Role for EKS Cluster Nodes"
}

variable "eks_cluster_eks_cni_role" {
  type        = string
  description = "IAM Role for EKS CNI"
}

variable "eks_cluster_autoscaler_role" {
  type        = string
  description = "IAM Role for EKS Cluster AutoScaler"
}

variable "eks_cluster_loadbalancer_controller_role" {
  type        = string
  description = "IAM Role for EKS Load Balancer Controller"
}

variable "eks_cluster_loadbalancer_controller_policy" {
  type        = string
  description = "IAM Policy for EKS Load Balancer Controller"
}

variable "eks_cluster_loadbalancer_controller_additional_policy" {
  type        = string
  description = "Additional IAM Policy for EKS Load Balancer Controller"
}

variable "eks_public_subnets" {
  type        = list(any)
  description = "Public Subnets for EKS Control Plane"
}

variable "eks_public_access_cidrs" {
  type        = list(any)
  description = "Public IP Address Whitelist for API Access"
}



variable "eks_managed_worker_nodes_name" {
  type        = string
  description = "Name for EKS Worker Nodes"
}

variable "eks_private_subnets" {
  type        = list(any)
  description = "Private Subnets for EKS Worker Nodes"
}

variable "eks_managed_worker_nodes_desired_size" {
  type        = number
  description = "EKS Worker Node Desired Size"
}

variable "eks_managed_worker_nodes_max_size" {
  type        = number
  description = "EKS Worker Node Max Size"
}

variable "eks_managed_worker_nodes_min_size" {
  type        = number
  description = "EKS Worker Node Minimum Size"
}

variable "eks_managed_worker_nodes_ami_type" {
  type        = string
  description = "EKS Worker Node AMI Type"
}

variable "eks_managed_worker_nodes_disk_size" {
  type        = string
  description = "EKS Worker Node Disk Size"
}

variable "eks_managed_worker_nodes_instance_type" {
  type        = list(any)
  description = "EKS Worker Node Type"
}

variable "eks_managed_worker_nodes_capacity_type" {
  type        = string
  description = "EKS Worker Node Capacity Type"
}


variable "eks_iam_autoscaling_workernode" {
  type        = string
  description = "Autoscaling policy for worker role"
}

variable "eks_iam_secrets_read_workernode" {
  type        = string
  description = "Secrets read policy for worker role"
}

variable "KarpenterControllerRole" {
  type        = string
  description = "KarpenterControllerRole"
}

variable "KarpenterControllerPolicy" {
  type        = string
  description = "KarpenterControllerPolicy"
}

variable "KarpenterNodeRole" {
  type        = string
  description = "KarpenterNodeRole"
}

variable "KarpenterNodeInstanceProfile" {
  type        = string
  description = "KarpenterNodeInstanceProfile"
}
