# Infrastructure-CICD for Terragrunt using Github Actions Deployted into AWS 

This repo, along with the [tf-aws-modules](https://github.com/pnjlavtech/tf-aws-modules), 
show an example file/folder structure you can use with [Terragrunt](https://github.com/gruntwork-io/terragrunt) to keep your
[Terraform](https://www.terraform.io) code DRY. For background information, 
check out the [Keep your code DRY](https://github.com/gruntwork-io/terragrunt#keep-your-terraform-code-dry) 
section of the Terragrunt documentation.

This repo shows an example of how to use the modules from the `tf-aws-modules` repo to
deploy infra (vpc, eks, iam and argocd) across three environments (qa, stage, prod) and two AWS accounts
(non-prod, prod), all with minimal duplication of code. That's because there is just a single copy of
the code, defined in the `tf-aws-modules` repo, and in this repo, we solely define
`terragrunt.hcl` files that reference that code (at a specific version, too!) and fill in variables specific to each
environment.

Be sure to read through [the Terragrunt documentation on DRY
Architectures](https://terragrunt.gruntwork.io/docs/features/keep-your-terragrunt-architecture-dry/) to understand the
features of Terragrunt used in this folder organization.

The GH Actions pipeline also makes use of tflint for linting and Checkov for SCA (policy as code)
## Tflint
[tflint action](https://github.com/marketplace/actions/setup-tflint)

## Checkov
Checkov scans cloud infrastructure configurations to find misconfigurations before they're deployed.

Checkov is a static code analysis tool for infrastructure as code (IaC) and also a software composition analysis (SCA) tool for images and open source packages.

It scans cloud infrastructure provisioned using Terraform, Terraform plan, Cloudformation, AWS SAM, Kubernetes, Helm charts, Kustomize, Dockerfile, Serverless, Bicep, OpenAPI or ARM Templates and detects security and compliance misconfigurations using graph-based scanning.

It performs Software Composition Analysis (SCA) scanning which is a scan of open source packages and images for Common Vulnerabilities and Exposures (CVEs).

[checkov action](https://github.com/marketplace/actions/checkov-github-action)


# Getting Started
## **0. Setup AWS accounts**

## **1. Setup AWS config and credentials for the accounts**


## **2. Implement Remote Terraform State Storage with AWS S3 and DynamoDB Locking**

**Objective:** Store Terraform state files remotely and prevent concurrent modifications.

### **Implementation:**
+------------------------------------------------------+
|                S3 Bucket Naming Structure            |
+------------------------------------------------------+
|  <company>-<env>-<region>-<purpose>-s3[-<unique>]    |
+---------+-----+------+---------+----+---------------+
          |     |      |         |    |
          |     |      |         |    +-- Optional Unique Suffix
          |     |      |         +------- Resource/Purpose Identifier
          |     |      +---------------- Region Code
          |     +----------------------- Environment
          +----------------------------- Company/Project


#### One time in each TF module dir
a. create terraform workspaces 
```bash
terraform workspace new dev
terraform workspace new stg
terraform workspace new prod
```



#### For Each Environment
First set WORKING_ENV env var
```bash
export WORKING_ENV=dev
# or 
export WORKING_ENV=stg
export WORKING_ENV=prod
```

a.  set AWS profile
```bash
export AWS_PROFILE=$WORKING_ENV
```

b. Create DynamoDB Table
```bash

aws dynamodb create-table \
   --table-name terraform-locks \
   --attribute-definitions AttributeName=LockID,AttributeType=S \
   --key-schema AttributeName=LockID,KeyType=HASH \
   --billing-mode PAY_PER_REQUEST
```

c. Switch TF workspace
```bash
terraform workspace select $WORKING_ENV
```

  

d. Create s3 buckets
```bash
cd ../src/tf-aws-modules/s3
tfi
tfp
tfaa
```



## **3. Implement OIDC provider and IAM role for deployment used by CICD pipeline**
a. create oidc provider


b. create iam deployment role



If 3 is not done, then tokens need to be created and a bunch of values and vars in SCM (github or gitlab), pipelines built with that, then changed later.
seemingly inefficient.



## **4. Implement CICD pipeline using OIDC provider IAM deployment role**
create 3 environments in the github repo

add an ENV var for with the iam deploy role arn value 

 



## **%. Deploy infra**






- **Configure Backend in `backend.tf`:**

  ```hcl
  terraform {
    backend "s3" {
      bucket         = "my-terraform-states"
      key            = "${var.environment}/${var.region}/terraform.tfstate"
      region         = var.region
      dynamodb_table = "terraform-locks"
      encrypt        = true
    }
  }
  ```

**Note:** This backend configuration ensures state files are stored per environment and region.




## GH Actions
CICD is using:

* Composite action
   * action.yaml
NOTE: GH Composite actions using other actions complicates things.

Cant use if 

if you want to use if then you have to use run 
 

* Workflow calling composite actions



## How do you deploy the infrastructure in this repo?


### Pre-requisites

1. Install [Terraform](https://www.terraform.io) version `1.5.3` or newer and
   [Terragrunt](https://github.com/gruntwork-io/terragrunt) version `v0.52.0` or newer.
2. Update the `bucket` parameter in the root `terragrunt.hcl`. We use S3 [as a Terraform
   backend](https://opentofu.org/docs/language/settings/backends/s3/) to store your
   state, and S3 bucket names must be globally unique. The name currently in
   the file is already taken, so you'll have to specify your own. Alternatives, you can
   set the environment variable `TG_BUCKET_PREFIX` to set a custom prefix.
3. Update the `account_name` parameters in [`non-prod/account.hcl`](/non-prod/account.hcl) and
   [`prod/account.hcl`](/prod/account.hcl) with the names of accounts you want to use for non production and 
   production workloads, respectively.
4. Create several variables in including theAWS credentials using one of the supported [authentication
   mechanisms](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html).



### Deploying a single module
1. In the tg_yaml env: section set "working_dir" to the module and location to be deployed (e.g. `cd non-prod/us-west-2/qa/vpc`).


### Deploying all modules in a region
1. In the tg_yaml env: section set "working_dir" to the location to be deployed (e.g. `cd non-prod/us-west-2`).


### Testing the infrastructure after it's deployed




## How is the code in this repo organized?

The code in this repo uses the following folder hierarchy:

```
environment
 └ _global
 └ account
    └ _global
    └ region
       └ resource
```

Where:

* **Environment**: At the top level are each of the environments. There will be one or more "environments", such as `dev`, `stg`, etc. Typically,
  an environment will correspond to a single AWS account. This isolates everything for this environment. There may also be a `_global` folder
  that defines resources that are available across all the environments, such as Route 53 A records, SNS topics, and ECR repos.

* **Account**:  AWS accounts, such as `dev-account`, `stg-account`, `prod-account`, `mgmt-account`,
  etc. If you have everything deployed in a single AWS account, there will just be a single folder at the root (e.g.
  `main-account`).

* **Region**: Within each account, there will be one or more [AWS
  regions](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html), such as
  `us-east-1`, `eu-west-1`, and `ap-southeast-2`, where you've deployed resources. There may also be a `_global`
  folder that defines resources that are available across all the AWS regions in this account, such as IAM users,
  Route 53 hosted zones, and CloudTrail.


* **Resource**: Within each region, you deploy all the resources for that environment-account-region, such as EC2 Instances, Auto
  Scaling Groups, ECS Clusters, Databases, Load Balancers, and so on. Note that the code for most of these
  resources lives in the [tf-aws-modules repo](https://github.com/pnjlavtech/tf-aws-modules).

## Creating and using root (account) level variables

In the situation where you have multiple AWS accounts or regions, you often have to pass common variables down to each
of your modules. Rather than copy/pasting the same variables into each `terragrunt.hcl` file, in every region, and in
every environment, you can inherit them from the `inputs` defined in the root `terragrunt.hcl` file.
