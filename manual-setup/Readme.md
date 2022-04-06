# Steps for deploying karpenter.sh Cluster AutoScaler on your existing EKS Clusters.

### **1. Create tags for your EKS Cluster**
Go to EKS Console > Select Cluster > Configuration > Tag > Manage Tags
    
Add `karpenter.sh/discovery=YOUR-EKS-CLUSTER-NAME`

<br>

### **2. Create tags for your VPC Subnets**

Go to VPC Console > Select Subnets >  Tags > Manage Tags
    
Add `karpenter.sh/discovery=YOUR-EKS-CLUSTER-NAME`

Add tags for the VPC Subnets in which you are planning to provision the EKS Worker Nodes.

<br>

### **3. Create IAM Resources**
    
    

| Resource | Description| 
| -------- | -------- | 
| KarpenterNodeInstanceProfile     | IAM Instance Profile for EC2 Instances provisioned by Karpenter     |
| KarpenterNodeRole     | IAM Role for connecting EC2 instances into EKS Cluster     |
| KarpenterControllerPolicy     | IAM Policy for Karpenter Controller     |
| KarpenterControllerRole     | IAM Role for Karpenter Controller     |

Make sure to follow the naming convention when you creating the IAM Resources.
    
```
KarpenterControllerRole = KarpenterControllerRole-YOUR-EKS-CLUSTER-NAME
KarpenterControllerPolicy = KarpenterControllerPolicy-YOUR-EKS-CLUSTER-NAME
KarpenterNodeInstanceProfile = KarpenterNodeInstanceProfile-YOUR-EKS-CLUSTER-NAME
KarpenterNodeRole = KarpenterNodeRole-YOUR-EKS-CLUSTER-NAME
```

- User this [cloudformation template](https://raw.githubusercontent.com/dijeesh/eks-karpenter-workshop/main/src/karpenter-iam-cloudformation.yamlhttps://raw.githubusercontent.com/dijeesh/eks-karpenter-workshop/main/src/karpenter-iam-cloudformation.yaml) to provision IAM resources except KarpenterControllerRole
- Make sure to update your EKS Cluster Name. Replace `YOUR-EKS-CLUSTER-NAME` with your Cluster Name.
<br>

### **4. Edit aws-config configMap** 

Edit aws-config configMap in kube-system namespace and provide enough permission for KarpenterNodeRole IAM Role

```
  mapRoles: |
    - groups:
      - system:bootstrappers
      - system:nodes
      rolearn: arn:aws:iam::YOUR-ACCOUNT-ID:role/KarpenterNodeRole-YOUR-EKS-CLUSTER-NAME
      username: system:node:{{EC2PrivateDNSName}} 
```

Replace `YOUR-EKS-CLUSTER-NAME` and `YOUR-ACCOUNT-ID` and append the above snippet under mapRoles.

### **5. Create the KarpenterController IAM Role**

IAM role to be associated with the Kubernetes service account used by Karpenter.

Go to IAM Console > Roles > Create Role > KarpenterControllerRole-YOUR-EKS-CLUSTER-NAME

- OpenID Connect provider URL for your EKS Cluster.

- Set Trusted relationship for the IAM Role as follows ( Replace your YOUR-ACCOUNT-ID, and YOUR-EKS-OPENID-URL without https://)
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::YOUR-ACCOUNT-ID:YOUR-EKS-OPENID-URL"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "YOUR-EKS-OPENID-URL:sub": "system:serviceaccount:karpenter:karpenter"
                }
            }
        }
    ]
}
```
- In the permissions, select KarpenterControllerPolicy-YOUR-EKS-CLUSTER-NAME	IAM policy we created in Step 3.

### **6. Create the EC2 Spot Service Linked Role**

```
aws iam create-service-linked-role --aws-service-name spot.amazonaws.com || true
```

### **7. Install Karpenter Helm Chart**

```
helm repo add karpenter https://charts.karpenter.sh/
helm repo update
```
- Get your EKS Cluster API Endpoint.
```


helm upgrade --install --namespace karpenter --create-namespace \
  karpenter karpenter/karpenter \
  --version v0.8.0 \
  --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"=arn:aws:iam::YOUR-ACCOUNT-ID:role/KarpenterControllerRole-YOUR-EKS-CLUSTER-NAME \
  --set clusterName=YOUR-EKS-CLUSTER-NAME \
  --set clusterEndpoint=YOUR-EKS-API-ENDPOINT \
  --set aws.defaultInstanceProfile=KarpenterNodeInstanceProfile-YOUR-EKS-CLUSTER-NAME \
  --wait  
```

Make sure to replace the values for YOUR-EKS-CLUSTER-NAME, YOUR-ACCOUNT-ID, YOUR-EKS-API-ENDPOINT

Make sure to set the latest version for Karpenter Chart.

### **8. Deploy Provisioner**

Here is sample provisioner. Please tweak the file as per your requirement.

```
---
apiVersion: karpenter.sh/v1alpha5
kind: Provisioner
metadata:
  name: karpenter
spec:
  requirements:
    - key: karpenter.sh/capacity-type
      operator: In
      values: ["spot", "on-demand"]
    - key: "kubernetes.io/arch"
      operator: In
      values: ["arm64", "amd64"]
  limits:
    resources:
      cpu: 100
  provider:
    subnetSelector:
      karpenter.sh/discovery: YOUR-EKS-CLUSTER-NAME
    securityGroupSelector:
      kubernetes.io/cluster/YOUR-EKS-CLUSTER-NAME: '*'
  ttlSecondsAfterEmpty: 5
  ttlSecondsUntilExpired: 259200
```  

Make sure to replace YOUR-EKS-CLUSTER-NAME with your Cluster Name.


Done. Karpenter will be now ready to provision instances for your EKS Cluster.