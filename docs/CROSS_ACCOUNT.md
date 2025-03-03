
# Cross Account Access
The AWS Security Token Service (STS) AssumeRole API allows you to grant temporary security credentials to trusted entities (such as IAM users, roles, or AWS services) so they can access AWS resources in another account. 



## How AssumeRole Works
* Trust Relationship: The role in the target account (management account) must trust the entity (e.g., a role in the DEV account) that will assume it. This is defined in the role's trust policy.
* Assume Role: The entity in the source account (DEV account) uses the sts:AssumeRole API to obtain temporary security credentials for the role in the target account (management account).
* Use Temporary Credentials: The entity uses the temporary credentials to perform actions in the target account.


## Setting Up Cross-Account Access


### Step 1: Create a Role in the Management Account
Create a role in the management account that trusts the role in the other account.


### Step 2: Create a Role in the Other Account
Create a role in the other account that will assume the role in the management account.



### Step 3: Assume the Role in the Management Account
Use the sts:AssumeRole API to assume the role in the management account from the other account. 


Example Using GitHub Actions

In your GitHub Actions workflow, you can configure the AWS credentials using the aws-actions/configure-aws-credentials action.

```yaml
- name: Configure AWS Credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: arn:aws:iam::<MANAGEMENT_ACCOUNT_ID>:role/management-role
    aws-region: us-west-2
    role-session-name: github-actions
    role-duration-seconds: 900

```