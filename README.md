# Terraform Notes

Terraform is an **Infrastructure as Code (IaC)** tool used to define, provision, and manage infrastructure using configuration files.

Instead of manually creating infrastructure from a cloud console, we describe the desired infrastructure in code.

```text
Terraform Code
      ↓
terraform plan
      ↓
terraform apply
      ↓
Cloud Infrastructure
```

---

## 1. Why Terraform?

Terraform helps with:

- Infrastructure automation
- Repeatable environments
- Version-controlled infrastructure
- Multi-cloud provisioning
- Infrastructure consistency
- Faster environment creation
- Reduced manual configuration
- Easier disaster recovery

Terraform can manage infrastructure across providers such as:

```text
AWS
Azure
Google Cloud
Kubernetes
GitHub
Cloudflare
Datadog
```

---

# 2. Infrastructure as Code

Without IaC:

```text
Engineer
   ↓
Cloud Console
   ↓
Create VPC
Create EC2
Create Security Group
Create Database
```

Problems:

- Manual mistakes
- Difficult to reproduce
- No change history
- Configuration drift
- Hard to maintain multiple environments

With Terraform:

```text
Terraform Code
      ↓
Git Repository
      ↓
Review
      ↓
terraform apply
      ↓
Infrastructure
```

Infrastructure becomes:

```text
Versioned
Repeatable
Reviewable
Automated
```

---

# 3. Terraform Workflow

The basic Terraform workflow is:

```text
Write
 ↓
Init
 ↓
Validate
 ↓
Plan
 ↓
Apply
 ↓
Infrastructure
```

Commands:

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

To remove infrastructure:

```bash
terraform destroy
```

---

# 4. Terraform Installation Check

Check Terraform:

```bash
terraform version
```

Get help:

```bash
terraform --help
```

Command-specific help:

```bash
terraform plan --help
```

---

# 5. Basic Terraform Project

Example structure:

```text
terraform-project/
│
├── main.tf
├── variables.tf
├── outputs.tf
├── providers.tf
├── terraform.tfvars
└── versions.tf
```

These filenames are conventions.

Terraform reads `.tf` files in the working directory as one configuration.

---

# 6. Terraform Configuration Syntax

Terraform uses **HCL — HashiCorp Configuration Language**.

Example:

```hcl
resource "aws_instance" "web" {
  ami           = "ami-xxxxxxxx"
  instance_type = "t3.micro"
}
```

General syntax:

```hcl
BLOCK_TYPE "LABEL1" "LABEL2" {

  argument = value

}
```

Example:

```hcl
resource "aws_s3_bucket" "app_bucket" {
  bucket = "my-app-bucket"
}
```

---

# 7. Terraform Provider

A **provider** allows Terraform to communicate with an external platform.

Examples:

```text
AWS
Azure
GCP
Kubernetes
GitHub
```

Example AWS provider:

```hcl
terraform {
  required_providers {

    aws = {
      source = "hashicorp/aws"
    }

  }
}

provider "aws" {

  region = "ap-south-1"

}
```

Terraform downloads providers during:

```bash
terraform init
```

---

# 8. Terraform Resources

A **resource** represents infrastructure Terraform manages.

Example:

```hcl
resource "aws_instance" "web_server" {

  ami           = "ami-xxxxxxxx"
  instance_type = "t3.micro"

}
```

Here:

```text
aws_instance
     ↓
Resource Type

web_server
     ↓
Terraform Local Name
```

Reference it using:

```hcl
aws_instance.web_server.id
```

---

# 9. Terraform Variables

Variables avoid hardcoding values.

Example:

```hcl
variable "instance_type" {

  description = "EC2 instance type"

  type = string

  default = "t3.micro"

}
```

Use it:

```hcl
resource "aws_instance" "web" {

  ami           = "ami-xxxxxxxx"
  instance_type = var.instance_type

}
```

---

# 10. Variable Types

Common Terraform variable types:

```text
string
number
bool
list
set
map
object
tuple
```

Example:

```hcl
variable "environment" {

  type    = string
  default = "dev"

}
```

List:

```hcl
variable "availability_zones" {

  type = list(string)

  default = [
    "ap-south-1a",
    "ap-south-1b"
  ]

}
```

Map:

```hcl
variable "instance_types" {

  type = map(string)

  default = {

    dev  = "t3.micro"
    prod = "t3.medium"

  }

}
```

---

# 11. terraform.tfvars

Values can be provided using:

```text
terraform.tfvars
```

Example:

```hcl
instance_type = "t3.small"

environment = "dev"
```

You can also use:

```bash
terraform apply \
  -var="instance_type=t3.micro"
```

Or another variable file:

```bash
terraform apply \
  -var-file="prod.tfvars"
```

Example:

```text
dev.tfvars
stage.tfvars
prod.tfvars
```

---

# 12. Terraform Outputs

Outputs display useful information after deployment.

Example:

```hcl
output "instance_public_ip" {

  value = aws_instance.web.public_ip

}
```

After:

```bash
terraform apply
```

Terraform may display:

```text
instance_public_ip = "13.x.x.x"
```

View outputs:

```bash
terraform output
```

---

# 13. Terraform State

Terraform keeps track of infrastructure using a **state file**.

Default:

```text
terraform.tfstate
```

Conceptually:

```text
Terraform Configuration
        ↓
Terraform State
        ↓
Actual Infrastructure
```

Terraform compares these to determine what needs to change.

---

# 14. Why Terraform State Is Important

State contains information such as:

```text
Resource IDs
Resource Attributes
Dependencies
Infrastructure Metadata
```

For example:

```text
Terraform Resource
aws_instance.web

        ↓

AWS Resource
i-0123456789
```

Terraform uses state to map these together.

---

# 15. Never Store Sensitive State Publicly

The Terraform state file may contain sensitive information.

Avoid committing:

```text
terraform.tfstate
terraform.tfstate.backup
```

to Git.

Example `.gitignore`:

```gitignore
.terraform/
*.tfstate
*.tfstate.*
.terraform.lock.hcl
crash.log
```

> Depending on your workflow, teams commonly commit `.terraform.lock.hcl` to version control to keep provider selections consistent.

So a more common `.gitignore` is:

```gitignore
.terraform/
*.tfstate
*.tfstate.*
crash.log
*.tfvars
```

Do not commit secret-containing `.tfvars` files.

---

# 16. Remote State

In team environments, local state is usually not enough.

Instead:

```text
Developer A
Developer B
CI/CD Pipeline
       ↓
Remote Terraform State
```

For AWS, a commonly used backend is S3.

Example:

```hcl
terraform {

  backend "s3" {

    bucket = "company-terraform-state"

    key = "production/network/terraform.tfstate"

    region = "ap-south-1"

  }

}
```

Remote state helps teams share the same infrastructure state.

---

# 17. Terraform Lock File

Terraform creates:

```text
.terraform.lock.hcl
```

It records provider selections and checksums.

Example:

```text
Terraform Configuration
        ↓
Provider Version Selection
        ↓
.terraform.lock.hcl
```

It is generally useful to commit this file to Git.

---

# 18. Terraform Init

Initialize a Terraform project:

```bash
terraform init
```

It performs tasks such as:

```text
Download Providers
Initialize Backend
Initialize Modules
Prepare Working Directory
```

Run it when:

```text
Cloning a Terraform repository

Adding/changing providers

Changing backend configuration

Adding modules
```

---

# 19. Terraform Validate

Check configuration syntax:

```bash
terraform validate
```

Example:

```text
Success! The configuration is valid.
```

It checks Terraform configuration structure but does not prove that the infrastructure will successfully deploy.

---

# 20. Terraform Format

Format Terraform files:

```bash
terraform fmt
```

Format recursively:

```bash
terraform fmt -recursive
```

This keeps `.tf` files consistently formatted.

---

# 21. Terraform Plan

Preview infrastructure changes:

```bash
terraform plan
```

Terraform may show:

```text
+ create
~ update
- destroy
```

Example:

```text
Plan:

2 to add
1 to change
0 to destroy
```

A good workflow is:

```text
Code Change
    ↓
terraform plan
    ↓
Review
    ↓
terraform apply
```

---

# 22. Terraform Apply

Create/update infrastructure:

```bash
terraform apply
```

Skip interactive approval:

```bash
terraform apply -auto-approve
```

Use `-auto-approve` carefully, especially in production.

---

# 23. Saved Plans

You can save a Terraform plan:

```bash
terraform plan -out=tfplan
```

Then apply exactly that plan:

```bash
terraform apply tfplan
```

This is useful in CI/CD pipelines.

```text
Pull Request
    ↓
terraform plan
    ↓
Review
    ↓
Approval
    ↓
terraform apply tfplan
```

---

# 24. Terraform Destroy

Destroy Terraform-managed resources:

```bash
terraform destroy
```

Terraform will show what resources are going to be deleted.

For production environments, destruction should generally require strong access controls and approvals.

---

# 25. Resource Dependencies

Terraform automatically creates dependencies when one resource references another.

Example:

```hcl
resource "aws_security_group" "web_sg" {

  name = "web-security-group"

}

resource "aws_instance" "web" {

  ami = "ami-xxxxxxxx"

  instance_type = "t3.micro"

  vpc_security_group_ids = [
    aws_security_group.web_sg.id
  ]

}
```

Terraform understands:

```text
Security Group
      ↓
EC2 Instance
```

The Security Group must exist first.

---

# 26. depends_on

Sometimes a dependency isn't visible through attribute references.

You can explicitly specify it:

```hcl
resource "aws_instance" "web" {

  depends_on = [
    aws_security_group.web_sg
  ]

  ami           = "ami-xxxxxxxx"
  instance_type = "t3.micro"

}
```

Use `depends_on` only when Terraform cannot infer the dependency naturally.

---

# 27. Terraform Data Sources

Resources create/manage infrastructure.

**Data sources** read existing information.

Example:

```hcl
data "aws_vpc" "default" {

  default = true

}
```

Use:

```hcl
data.aws_vpc.default.id
```

Think:

```text
resource
→ Create / Manage something

data
→ Read something that already exists
```

---

# 28. Local Values

`locals` reduce repeated expressions.

Example:

```hcl
locals {

  common_tags = {

    Environment = "production"
    Team        = "DevOps"

  }

}
```

Use:

```hcl
resource "aws_instance" "web" {

  ami           = "ami-xxxxxxxx"
  instance_type = "t3.micro"

  tags = local.common_tags

}
```

---

# 29. count

Create multiple similar resources.

Example:

```hcl
resource "aws_instance" "web" {

  count = 3

  ami           = "ami-xxxxxxxx"
  instance_type = "t3.micro"

}
```

Creates:

```text
web[0]
web[1]
web[2]
```

Reference:

```hcl
aws_instance.web[0].id
```

---

# 30. for_each

`for_each` is often more useful when resources have meaningful names.

Example:

```hcl
variable "servers" {

  default = {

    frontend = "t3.micro"
    backend  = "t3.small"

  }

}
```

```hcl
resource "aws_instance" "servers" {

  for_each = var.servers

  ami = "ami-xxxxxxxx"

  instance_type = each.value

  tags = {

    Name = each.key

  }

}
```

Creates:

```text
frontend
backend
```

---

# 31. count vs for_each

Use `count` when resources are based mainly on a number:

```text
Create 3 identical instances
```

Use `for_each` when instances have unique identities:

```text
frontend
backend
database
```

For long-lived infrastructure, `for_each` can often provide more stable resource addressing.

---

# 32. Conditional Expressions

Example:

```hcl
instance_type = var.environment == "prod" ? "t3.medium" : "t3.micro"
```

Meaning:

```text
If environment == prod

t3.medium

Otherwise

t3.micro
```

Syntax:

```hcl
condition ? true_value : false_value
```

---

# 33. Terraform Modules

Modules make Terraform reusable.

Instead of repeating:

```text
VPC Code
Subnet Code
Security Group Code
EC2 Code
```

you can create reusable modules.

Example:

```text
terraform-project/

├── modules/
│   ├── vpc/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   └── ec2/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
└── environments/
    ├── dev/
    └── prod/
```

Use a module:

```hcl
module "vpc" {

  source = "../../modules/vpc"

  vpc_cidr = "10.0.0.0/16"

}
```

Modules help with:

```text
Reusability
Standardization
Maintainability
Consistency
```

---

# 34. Root Module and Child Module

The directory where Terraform runs is the:

```text
Root Module
```

A module called by another module is a:

```text
Child Module
```

Example:

```text
Root Module
    ↓
VPC Module
    ↓
Subnet Resources
```

---

# 35. Terraform Registry Modules

Terraform modules can also come from the Terraform Registry.

Example:

```hcl
module "vpc" {

  source = "terraform-aws-modules/vpc/aws"

}
```

Before using public modules in production:

- check maintenance activity
- review the code
- pin versions
- understand what resources are created

---

# 36. Terraform Workspaces

Terraform workspaces allow multiple state instances from one configuration.

Check workspace:

```bash
terraform workspace show
```

List:

```bash
terraform workspace list
```

Create:

```bash
terraform workspace new dev
```

Switch:

```bash
terraform workspace select dev
```

Examples:

```text
default
dev
staging
production
```

For complex environments, many teams prefer separate directories/state configurations instead of relying only on CLI workspaces.

---

# 37. Environment Structure

A common structure:

```text
terraform/
│
├── modules/
│   ├── network/
│   ├── compute/
│   └── database/
│
└── environments/
    │
    ├── dev/
    │   ├── main.tf
    │   └── dev.tfvars
    │
    ├── staging/
    │
    └── production/
```

This keeps environments clearly separated.

---

# 38. Terraform Import

Suppose an AWS resource already exists but Terraform didn't create it.

You can bring it under Terraform management using import.

Conceptually:

```text
Existing Infrastructure
         ↓
terraform import
         ↓
Terraform State
```

Example:

```bash
terraform import aws_instance.web i-0123456789
```

Modern Terraform configurations can also use `import` blocks.

Example:

```hcl
import {

  to = aws_instance.web

  id = "i-0123456789"

}
```

Import does not automatically mean your configuration perfectly matches the existing resource.

Always review:

```bash
terraform plan
```

after importing.

---

# 39. Terraform State Commands

List state resources:

```bash
terraform state list
```

Show resource:

```bash
terraform state show aws_instance.web
```

Move state:

```bash
terraform state mv
```

Remove something from Terraform state:

```bash
terraform state rm
```

Be careful with state commands because incorrect state manipulation can create infrastructure-management problems.

---

# 40. Terraform Refresh

Terraform normally refreshes infrastructure information during plan/apply operations.

You will commonly use:

```bash
terraform plan
```

to detect differences between configuration, state, and real infrastructure.

---

# 41. Configuration Drift

Suppose Terraform created:

```text
EC2 Instance
Instance Type = t3.micro
```

Then someone manually changes it in AWS:

```text
t3.medium
```

Now:

```text
Terraform Code
      ≠
Actual Infrastructure
```

This is called **configuration drift**.

Running:

```bash
terraform plan
```

helps identify these differences.

Avoid unnecessary manual production changes outside Terraform.

---

# 42. Lifecycle Rules

Terraform supports lifecycle controls.

Example:

```hcl
resource "aws_instance" "web" {

  ami           = "ami-xxxxxxxx"
  instance_type = "t3.micro"

  lifecycle {

    create_before_destroy = true

  }

}
```

Useful lifecycle options include:

```text
create_before_destroy
prevent_destroy
ignore_changes
replace_triggered_by
```

Example:

```hcl
lifecycle {

  prevent_destroy = true

}
```

This can provide protection against accidental Terraform destruction of critical resources.

---

# 43. Sensitive Variables

Example:

```hcl
variable "db_password" {

  type      = string
  sensitive = true

}
```

This reduces accidental display in Terraform CLI output.

However:

> Marking a value as `sensitive` does not automatically prevent that value from being stored in Terraform state.

Therefore state security remains important.

---

# 44. Don't Hardcode Secrets

Avoid:

```hcl
db_password = "MyPassword123"
```

Prefer secret-management systems such as:

```text
AWS Secrets Manager
Azure Key Vault
Google Secret Manager
HashiCorp Vault
```

And keep credentials out of Git repositories.

---

# 45. Terraform and AWS Authentication

Avoid hardcoding:

```hcl
provider "aws" {

  access_key = "..."
  secret_key = "..."

}
```

Prefer mechanisms such as:

```text
AWS CLI profiles
IAM Roles
Environment Variables
OIDC
Workload Identity
CI/CD Identity
```

For example:

```bash
aws configure
```

Terraform can use available AWS credentials from the environment/provider credential chain.

---

# 46. Terraform in CI/CD

A common workflow:

```text
Developer
    ↓
Git Push
    ↓
Pull Request
    ↓
terraform fmt
    ↓
terraform validate
    ↓
terraform plan
    ↓
Review
    ↓
Merge / Approval
    ↓
terraform apply
```

Example commands:

```bash
terraform fmt -check
terraform init
terraform validate
terraform plan
```

Production `apply` should usually happen only after appropriate review/approval.

---

# 47. Terraform + Jenkins Example

Typical Jenkins stages:

```text
Checkout
   ↓
Terraform Init
   ↓
Terraform Validate
   ↓
Terraform Plan
   ↓
Approval
   ↓
Terraform Apply
```

Example idea:

```groovy
stage('Terraform Init') {

    steps {

        sh 'terraform init'

    }

}

stage('Terraform Validate') {

    steps {

        sh 'terraform validate'

    }

}

stage('Terraform Plan') {

    steps {

        sh 'terraform plan -out=tfplan'

    }

}

stage('Terraform Apply') {

    steps {

        sh 'terraform apply tfplan'

    }

}
```

---

# 48. Terraform Dependency Graph

Terraform builds a dependency graph.

Example:

```text
VPC
 ↓
Subnet
 ↓
Security Group
 ↓
EC2
```

View the graph:

```bash
terraform graph
```

Terraform can create independent resources in parallel where possible.

---

# 49. Terraform Provisioners

Terraform supports provisioners such as:

```text
local-exec
remote-exec
file
```

Example:

```hcl
provisioner "local-exec" {

  command = "echo Infrastructure created"

}
```

However, provisioners should generally be treated as a **last resort**.

Prefer:

```text
Cloud-init
AMI/Image building
Ansible
Configuration Management
Kubernetes
Native Cloud Services
```

when appropriate.

---

# 50. Terraform Taint / Replace

If a resource needs to be recreated, modern Terraform workflows can use:

```bash
terraform apply -replace="aws_instance.web"
```

Terraform will plan a replacement of the specified resource.

---

# 51. Useful Terraform Commands

```bash
terraform version
```

Check Terraform version.

```bash
terraform init
```

Initialize project.

```bash
terraform fmt
```

Format code.

```bash
terraform validate
```

Validate configuration.

```bash
terraform plan
```

Preview changes.

```bash
terraform apply
```

Apply changes.

```bash
terraform destroy
```

Destroy infrastructure.

```bash
terraform output
```

Display outputs.

```bash
terraform show
```

Inspect state/plan information.

```bash
terraform state list
```

List managed resources.

```bash
terraform workspace list
```

List workspaces.

```bash
terraform providers
```

Display providers used.

---

# 52. Terraform Best Practices

### Keep Terraform code in Git

```text
Terraform Code
     ↓
Git
     ↓
Pull Request
     ↓
Review
```

### Use remote state

Avoid relying only on local state for team environments.

### Separate environments

```text
dev
staging
production
```

should have clearly separated state.

### Use modules

Reuse infrastructure instead of copying large blocks of Terraform code.

### Pin provider/module versions

Avoid unexpected breaking changes.

### Run `terraform plan`

Always understand what Terraform wants to change before applying.

### Protect production

Use:

```text
Code Review
Approval
Access Control
Remote State
State Locking
CI/CD
```

### Never expose secrets

Do not commit:

```text
Passwords
API Keys
Cloud Credentials
Sensitive tfvars
```

### Avoid unnecessary manual changes

Manual console changes can introduce configuration drift.

---

# 53. Terraform Production Architecture

A real-world workflow may look like:

```text
Developer
    ↓
Terraform Code
    ↓
Git Repository
    ↓
Pull Request
    ↓
CI Pipeline
    ↓
terraform fmt
    ↓
terraform validate
    ↓
terraform plan
    ↓
Review / Approval
    ↓
terraform apply
    ↓
AWS / Azure / GCP
```

State lives remotely:

```text
Terraform
    ↓
Remote State Backend
```

Secrets and authentication are provided securely:

```text
CI/CD
  ↓
OIDC / IAM Role
  ↓
Cloud Provider
```

---

# 54. Example AWS Infrastructure

Terraform can create:

```text
VPC
 │
 ├── Public Subnet
 │      ↓
 │     ALB
 │
 └── Private Subnet
        ↓
       EC2 / EKS
        ↓
       RDS
```

Supporting services might include:

```text
Route 53
S3
ECR
IAM
CloudWatch
Security Groups
NAT Gateway
```

Terraform allows all of this infrastructure to be managed as code.

---

# 55. Terraform vs Ansible

These tools solve different problems.

```text
Terraform
→ Infrastructure Provisioning

Ansible
→ Configuration Management
```

Example:

```text
Terraform
   ↓
Create EC2 Server

Ansible
   ↓
Install Nginx
Configure Application
```

They can also be used together.

---

# 56. Terraform vs Kubernetes

Terraform manages infrastructure.

Kubernetes orchestrates containerized applications.

Example:

```text
Terraform
    ↓
Create EKS Cluster
    ↓
Kubernetes
    ↓
Deploy Applications
```

Terraform can also manage Kubernetes resources, but the responsibilities are conceptually different.

---

# 57. Terraform vs Docker

Docker:

```text
Package Application
       ↓
Container
```

Terraform:

```text
Provision Infrastructure
       ↓
Cloud Resources
```

Example:

```text
Terraform
    ↓
Create EKS + ECR
    ↓
Docker Image
    ↓
ECR
    ↓
Kubernetes Deployment
```

---

# 58. Terraform vs CloudFormation

Both can provision AWS infrastructure.

```text
Terraform
→ Multi-cloud ecosystem

CloudFormation
→ AWS-native Infrastructure as Code
```

Terraform can manage:

```text
AWS
Azure
GCP
Kubernetes
GitHub
Many SaaS Platforms
```

CloudFormation focuses specifically on AWS resources.

---

# 59. Important Terraform Files

```text
main.tf
```

Main infrastructure resources.

```text
variables.tf
```

Input variables.

```text
outputs.tf
```

Output values.

```text
providers.tf
```

Provider configurations.

```text
versions.tf
```

Terraform/provider requirements.

```text
terraform.tfvars
```

Variable values.

```text
terraform.tfstate
```

Terraform state.

```text
.terraform.lock.hcl
```

Provider dependency lock information.

---

# 60. Quick Revision

```text
Provider
→ Connect Terraform to AWS/Azure/GCP/etc.

Resource
→ Infrastructure Terraform creates/manages.

Data Source
→ Reads existing information.

Variable
→ Input to Terraform.

Output
→ Value returned by Terraform.

Local
→ Reusable internal expression.

State
→ Terraform's infrastructure mapping.

Backend
→ Where state is stored.

Module
→ Reusable Terraform code.

Plan
→ Preview changes.

Apply
→ Execute changes.

Destroy
→ Remove managed infrastructure.

Import
→ Bring existing infrastructure under Terraform state management.
```

---

# Terraform Flow to Remember

```text
Write Terraform
      ↓
terraform fmt
      ↓
terraform init
      ↓
terraform validate
      ↓
terraform plan
      ↓
Review
      ↓
terraform apply
      ↓
Infrastructure Created
      ↓
Monitor / Maintain
      ↓
Update Terraform
      ↓
Plan + Apply Again
```

---

# Final Thought

Terraform is not just about writing `.tf` files.

The real goal is:

```text
Infrastructure
      ↓
Code
      ↓
Git
      ↓
Review
      ↓
Automation
      ↓
Repeatable Infrastructure
```

Once infrastructure is managed this way, environments become easier to reproduce, review, automate, and maintain.

**Terraform turns infrastructure from manual cloud-console operations into an engineering workflow.**
