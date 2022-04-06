# eks-karpenter-workshop

For this workshop, I have created two EKS Clusters. 



| # | Cluster | Description  |
| -------- | -------- | -------- |
| 1     | acme-ca-us-east-1 | EKS Cluster with Cluster AutoScaler     |
| 2     | acme-karpenter-us-east-1 | EKS Cluster with Karpenter AutoScaler     |


Terraform snippets for creating VPCs and EKS Cluster Resources are available in the [terraform](https://github.com/dijeesh/eks-karpenter-workshop/tree/main/terraform) directory


---

**Setup Lab Environment**

1. Clone Repo [eks-karpenter-workshop](git@github.com:dijeesh/eks-karpenter-workshop.git)

2. Update Terraform provider.tf and state.tf
    ```
    Update the following files and set your environment speicific details.
    
    terraform/acme-ca/provider.tf
    terraform/acme-ca/state.tf
    
    terraform/acme-karpenter/provider.tf
    terraform/acme-karpenter/state.tf
    ```
3. Replace your Account ID
    ```
    Update the following files and set your AWS Account ID
    
    terraform/acme-ca/acme-ca-vpc.tf
    terraform/acme-karpenter/acme-karpenter-vpc.tf
    ```
4. Provision resources
    ```
    cd terraform/acme-ca/
    terraform plan
    terraform apply

    cd terraform/acme-karpenter/
    terraform plan
    terraform apply

    ```
This will provision 2 EKS Clusters in dedicated VPCs and IAM Related resources you will require to deploy Cluster AutoScaler and Karpenter.sh

5. Configure .kube/config and deploy Cluster AutoScalers

    For acme-ca-us-east-1 Cluster,
    
    - Deploy [metrics server](https://docs.aws.amazon.com/eks/latest/userguide/metrics-server.html) 
    - Deploy [Cluster AutoScaler](https://docs.aws.amazon.com/eks/latest/userguide/autoscaling.html)

    For acme-karpenter-us-east-1 Cluster
    
    - Deploy [metrics server](https://docs.aws.amazon.com/eks/latest/userguide/metrics-server.html)
    - Deploy [Karpenter](https://karpenter.sh/v0.8.0/getting-started/getting-started-with-eksctl/#create-the-ec2-spot-service-linked-role) (Create EC2 Spot Service Linked Role, Deploy Helm Chart, Update aws-auth config, Deploy Provisioner )

