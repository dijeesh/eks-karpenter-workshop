# IAM Role for EKS Cluster

resource "aws_iam_role" "eks_iam_role" {
  name               = var.eks_cluster_iam_role
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

#autoscaling policy for worker role
resource "aws_iam_policy" "eks_iam_autoscaling_workernode" {
  name        = var.eks_iam_autoscaling_workernode
  description = "autoscaling policy for worker role"
  policy      = file("../modules/application-eks-v2/files/eks_iam_autoscaling_workernode.json")
}

#aws secret read policy for worker role

resource "aws_iam_policy" "eks_iam_secrets_read_workernode" {
  name        = var.eks_iam_secrets_read_workernode
  description = "secrets read policy for worker role"
  policy      = file("../modules/application-eks-v2/files/eks_iam_secrets_read_workernode.json")
}

# IAM Policy Attachments

data "aws_iam_policy" "AmazonEKSClusterPolicy" {
  arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

data "aws_iam_policy" "AmazonEKSVPCResourceController" {
  arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = data.aws_iam_policy.AmazonEKSClusterPolicy.arn
  role       = aws_iam_role.eks_iam_role.name
  depends_on = [
    aws_iam_role.eks_iam_role
  ]
}

resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController" {
  policy_arn = data.aws_iam_policy.AmazonEKSVPCResourceController.arn
  role       = aws_iam_role.eks_iam_role.name
  depends_on = [
    aws_iam_role.eks_iam_role
  ]
}

resource "aws_kms_key" "eks_cluster_kms" {
  tags = {
    "Cluster" = "${var.cluster_name}"
  }
}

resource "aws_cloudwatch_log_group" "eks_controlplane_logs" {
  name = "/aws/eks/${var.cluster_name}/cluster"
}

# EKS Cluster

resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_iam_role.arn
  version  = var.cluster_version
  vpc_config {
    subnet_ids              = var.eks_public_subnets
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = var.eks_public_access_cidrs
  }
  encryption_config {
    provider {
      key_arn = aws_kms_key.eks_cluster_kms.arn
    }
    resources = ["secrets"]
  }

  lifecycle {
    ignore_changes = [vpc_config[0].public_access_cidrs]
  }

  tags = {
    "karpenter.sh/discovery" = var.cluster_name
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController,
    aws_kms_key.eks_cluster_kms,
    aws_cloudwatch_log_group.eks_controlplane_logs
  ]
}


# OIDC Provider

data "tls_certificate" "eks_cluster_tls" {
  url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks_cluster_openid" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_cluster_tls.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}



# VPC CNI Role

data "aws_iam_policy_document" "AmazonEKSCNIRoleFederation" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks_cluster_openid.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-node"]
    }
    principals {
      identifiers = [aws_iam_openid_connect_provider.eks_cluster_openid.arn]
      type        = "Federated"

    }
  }
}


resource "aws_iam_role" "AmazonEKSCNIRole" {
  assume_role_policy = data.aws_iam_policy_document.AmazonEKSCNIRoleFederation.json
  name               = var.eks_cluster_eks_cni_role
}

resource "aws_iam_role_policy_attachment" "AmazonEKSCNIPolicyAttachment" {
  role       = aws_iam_role.AmazonEKSCNIRole.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}


# EKS Worker Node Role
resource "aws_iam_role" "AmazonEKSNodeRole" {
  name = var.eks_cluster_node_role

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.AmazonEKSNodeRole.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerautoscalingpolicy" {
  policy_arn = aws_iam_policy.eks_iam_autoscaling_workernode.arn
  role       = aws_iam_role.AmazonEKSNodeRole.name
}
resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerSecretsReadpolicy" {
  policy_arn = aws_iam_policy.eks_iam_secrets_read_workernode.arn
  role       = aws_iam_role.AmazonEKSNodeRole.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.AmazonEKSNodeRole.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.AmazonEKSNodeRole.name
}

# Cluster Autoscaler Role

data "aws_iam_policy_document" "AmazonEKSClusterAutoscalerFederation" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks_cluster_openid.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:cluster-autoscaler"]
    }
    principals {
      identifiers = [aws_iam_openid_connect_provider.eks_cluster_openid.arn]
      type        = "Federated"

    }
  }
}

resource "aws_iam_role" "AmazonEKSClusterAutoscalerRole" {
  assume_role_policy = data.aws_iam_policy_document.AmazonEKSClusterAutoscalerFederation.json
  name               = var.eks_cluster_autoscaler_role
}

resource "aws_iam_role_policy" "AmazonEKSClusterAutoscalerPolicy" {
  name   = "AmazonEKSClusterAutoscalerPolicy"
  role   = aws_iam_role.AmazonEKSClusterAutoscalerRole.name
  policy = file("../modules/application-eks-v2/files/AmazonEKSClusterAutoscalerPolicy.json")
  depends_on = [
  aws_iam_role.AmazonEKSClusterAutoscalerRole]
}



# EKS Worker Node - Managed Node Group

resource "aws_eks_node_group" "eks_managed_worker_nodes" {
  node_role_arn   = aws_iam_role.AmazonEKSNodeRole.arn
  cluster_name    = var.cluster_name
  node_group_name = var.eks_managed_worker_nodes_name
  subnet_ids      = var.eks_private_subnets
  ami_type        = var.eks_managed_worker_nodes_ami_type
  disk_size       = var.eks_managed_worker_nodes_disk_size
  instance_types  = var.eks_managed_worker_nodes_instance_type
  capacity_type   = var.eks_managed_worker_nodes_capacity_type

  scaling_config {
    desired_size = var.eks_managed_worker_nodes_desired_size
    max_size     = var.eks_managed_worker_nodes_max_size
    min_size     = var.eks_managed_worker_nodes_min_size
  }

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_eks_cluster.eks_cluster
  ]
  tags = {
    Name = "${var.cluster_name}-worker-node"
  }
}

# AmazonEKSLoadBalancerControllerRole 

data "aws_iam_policy_document" "AmazonEKSLoadBalancerControllerFederation" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks_cluster_openid.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
    principals {
      identifiers = [aws_iam_openid_connect_provider.eks_cluster_openid.arn]
      type        = "Federated"

    }
  }
}

resource "aws_iam_role" "AmazonEKSLoadBalancerControllerRole" {
  assume_role_policy = data.aws_iam_policy_document.AmazonEKSLoadBalancerControllerFederation.json
  name               = var.eks_cluster_loadbalancer_controller_role
}

resource "aws_iam_policy" "AmazonEKSLoadBalancerControllerPolicy" {
  name   = var.eks_cluster_loadbalancer_controller_policy
  policy = file("../modules/application-eks-v2/files/AmazonEKSLoadBalancerControllerPolicy.json")
}

resource "aws_iam_role_policy_attachment" "AmazonEKSLoadBalancerControllerRoleAttachment" {
  policy_arn = aws_iam_policy.AmazonEKSLoadBalancerControllerPolicy.arn
  role       = aws_iam_role.AmazonEKSLoadBalancerControllerRole.name
  depends_on = [
    aws_iam_role.AmazonEKSLoadBalancerControllerRole
  ]
}

resource "aws_iam_policy" "AWSLoadBalancerControllerAdditionalIAMPolicy" {
  name   = var.eks_cluster_loadbalancer_controller_additional_policy
  policy = file("../modules/application-eks-v2/files/eks_cluster_loadbalancer_controller_additional_policy.json")
}

resource "aws_iam_role_policy_attachment" "AWSLoadBalancerControllerAdditionalIAMPolicyAttachment" {
  policy_arn = aws_iam_policy.AWSLoadBalancerControllerAdditionalIAMPolicy.arn
  role       = aws_iam_role.AmazonEKSLoadBalancerControllerRole.name
  depends_on = [
    aws_iam_role.AmazonEKSLoadBalancerControllerRole
  ]
}

resource "aws_iam_role_policy_attachment" "eks_iam_roleAttachment" {
  policy_arn = aws_iam_policy.AmazonEKSLoadBalancerControllerPolicy.arn
  role       = aws_iam_role.eks_iam_role.name
  depends_on = [
    aws_iam_role.eks_iam_role
  ]
}

# Karpenter Controller Role

data "aws_iam_policy_document" "KarpenterControllerPolicyFederation" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks_cluster_openid.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:karpenter:karpenter"]
    }
    principals {
      identifiers = [aws_iam_openid_connect_provider.eks_cluster_openid.arn]
      type        = "Federated"

    }
  }
}

resource "aws_iam_role" "KarpenterControllerRole" {
  assume_role_policy = data.aws_iam_policy_document.KarpenterControllerPolicyFederation.json
  name               = var.KarpenterControllerRole
}

resource "aws_iam_policy" "KarpenterControllerPolicy" {
  name   = var.KarpenterControllerPolicy
  policy = file("../modules/application-eks-v2/files/KarpenterControllerPolicy.json")
}

resource "aws_iam_role_policy_attachment" "KarpenterControllerPolicyAttachment" {
  policy_arn = aws_iam_policy.KarpenterControllerPolicy.arn
  role       = aws_iam_role.KarpenterControllerRole.name
}

# Karpenter Node Role

data "aws_iam_policy" "AmazonEKS_CNI_Policy" {
  arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

data "aws_iam_policy" "AmazonEKSWorkerNodePolicy" {
  arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

data "aws_iam_policy" "AmazonEC2ContainerRegistryReadOnly" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

data "aws_iam_policy" "AmazonSSMManagedInstanceCore" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "KarpenterNodeInstanceProfile" {
  name = var.KarpenterNodeInstanceProfile
  role = aws_iam_role.KarpenterNodeRole.name
}

resource "aws_iam_role" "KarpenterNodeRole" {
  name               = var.KarpenterNodeRole
  assume_role_policy = file("../modules/application-eks-v2/files/KarpenterNodeRole.json")
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_PolicyAttachment" {
  policy_arn = data.aws_iam_policy.AmazonEKS_CNI_Policy.arn
  role       = aws_iam_role.KarpenterNodeRole.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicyAttachment" {
  policy_arn = data.aws_iam_policy.AmazonEKSWorkerNodePolicy.arn
  role       = aws_iam_role.KarpenterNodeRole.name
}
resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnlyAttachment" {
  policy_arn = data.aws_iam_policy.AmazonEC2ContainerRegistryReadOnly.arn
  role       = aws_iam_role.KarpenterNodeRole.name
}
resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCoreAttachment" {
  policy_arn = data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn
  role       = aws_iam_role.KarpenterNodeRole.name
}