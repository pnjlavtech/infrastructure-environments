
1. deploy vpc, eks, then karpenter.

2. if it is the first time run in the AWS account then 
a. make sure this block in karpenter main is uncommented

```bash
# This is needed one time per account, only once at initial run.
# resource "aws_iam_service_linked_role" "spot" {
#   aws_service_name = "spot.amazonaws.com"
#   # custom_suffix    = "--karpenter-spot"
# }
```


b. 
https://github.com/pnjlavtech/tf-aws-modules/blob/18f7b98e9e28c4d24cfa54d554d03a48f8aa49a3/karpenter/README.md
```bash
aws iam create-service-linked-role --aws-service-name spot.amazonaws.com
```



```


3. alb 
https://docs.aws.amazon.com/eks/latest/userguide/lbc-helm.html


One time setup
a. manual

```bash
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.7.2/docs/install/iam_policy.json
```


```bash
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json
```

Replace my-cluster with the name of your cluster, 111122223333 with your account ID, and then run the command. 
```bash
eksctl create iamserviceaccount \
  --cluster=my-cluster \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn=arn:aws:iam::111122223333:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve

```




b. with terraform 

```bash

```







