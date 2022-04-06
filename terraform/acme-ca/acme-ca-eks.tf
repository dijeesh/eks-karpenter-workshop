locals {
  cluster_name                                          = "acme-ca-us-east-1"
  cluster_version                                       = "1.21"
  eks_cluster_iam_role                                  = "iam-role-acme-ca-eks-cluster"
  eks_cluster_node_role                                 = "iam-role-acme-ca-eks-cluster-nodes"
  eks_cluster_eks_cni_role                              = "iam-role-acme-ca-eks-cni"
  eks_cluster_autoscaler_role                           = "iam-role-acme-ca-eks-cluster-autoscaler"
  eks_cluster_loadbalancer_controller_role              = "iam-role-acme-ca-eks-cluster-lb-controller"
  eks_cluster_loadbalancer_controller_policy            = "iam-policy-acme-ca-eks-cluster-lb-controller"
  eks_cluster_loadbalancer_controller_additional_policy = "iam-policy-acme-ca-eks-cluster-lb-controller-additional"
  eks_managed_worker_nodes_name                         = "workernodes-acme-ca-us-east-1"
  eks_iam_autoscaling_workernode                        = "iam-policy-acme-ca-eks-cluster-autoscaling"
  eks_iam_secrets_read_workernode                       = "iam-policy-acme-ca-eks-secrets-readonly"
  eks_managed_worker_nodes_desired_size                 = 1
  eks_managed_worker_nodes_max_size                     = 10
  eks_managed_worker_nodes_min_size                     = 1
  eks_managed_worker_nodes_ami_type                     = "AL2_x86_64"
  eks_managed_worker_nodes_disk_size                    = "40"
  eks_managed_worker_nodes_instance_type                = ["t3.medium"]
  eks_managed_worker_nodes_capacity_type                = "SPOT"
  eks_public_access_cidrs                               = ["3.111.235.200/32"]
  KarpenterControllerRole                               = "KarpenterControllerRole-acme-ca-us-east-1"
  KarpenterControllerPolicy                             = "KarpenterControllerPolicy-acme-ca-us-east-1"
  KarpenterNodeInstanceProfile                          = "KarpenterNodeInstanceProfile-acme-ca-us-east-1"
  KarpenterNodeRole                                     = "KarpenterNodeRole-acme-ca-us-east-1"
}

module "eks_cluster" {
  source                                                = "../modules/application-eks"
  cluster_name                                          = local.cluster_name
  cluster_version                                       = local.cluster_version
  eks_cluster_iam_role                                  = local.eks_cluster_iam_role
  eks_cluster_node_role                                 = local.eks_cluster_node_role
  eks_cluster_eks_cni_role                              = local.eks_cluster_eks_cni_role
  eks_cluster_autoscaler_role                           = local.eks_cluster_autoscaler_role
  eks_cluster_loadbalancer_controller_role              = local.eks_cluster_loadbalancer_controller_role
  eks_cluster_loadbalancer_controller_policy            = local.eks_cluster_loadbalancer_controller_policy
  eks_cluster_loadbalancer_controller_additional_policy = local.eks_cluster_loadbalancer_controller_additional_policy
  eks_public_subnets                                    = ["${module.application_vpc.application_vpc_public_subnet1}", "${module.application_vpc.application_vpc_public_subnet2}"]
  eks_private_subnets                                   = ["${module.application_vpc.application_vpc_private_subnet1}", "${module.application_vpc.application_vpc_private_subnet2}"]
  eks_public_access_cidrs                               = local.eks_public_access_cidrs
  eks_managed_worker_nodes_name                         = local.eks_managed_worker_nodes_name
  eks_managed_worker_nodes_desired_size                 = local.eks_managed_worker_nodes_desired_size
  eks_managed_worker_nodes_max_size                     = local.eks_managed_worker_nodes_max_size
  eks_managed_worker_nodes_min_size                     = local.eks_managed_worker_nodes_min_size
  eks_managed_worker_nodes_ami_type                     = local.eks_managed_worker_nodes_ami_type
  eks_managed_worker_nodes_disk_size                    = local.eks_managed_worker_nodes_disk_size
  eks_managed_worker_nodes_instance_type                = local.eks_managed_worker_nodes_instance_type
  eks_managed_worker_nodes_capacity_type                = local.eks_managed_worker_nodes_capacity_type

  eks_iam_autoscaling_workernode                        = local.eks_iam_autoscaling_workernode
  eks_iam_secrets_read_workernode                       = local.eks_iam_secrets_read_workernode
  KarpenterControllerRole                               = local.KarpenterControllerRole
  KarpenterControllerPolicy                             = local.KarpenterControllerPolicy
  KarpenterNodeInstanceProfile                          = local.KarpenterNodeInstanceProfile
  KarpenterNodeRole                                     = local.KarpenterNodeRole
}