# 1. TERRAFORM SETTINGS BLOCK
# Configures core Terraform behaviors: required binary/provider versions and the state backend.
terraform {
  required_version = ">= 1.5.0" # Constrains the Terraform CLI version

  required_providers {
    # Declares which plugins (providers) are needed and where to fetch them
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Defines where the terraform.tfstate file is stored (e.g., S3, Terraform Cloud, Azure Blob)
  backend "s3" {
    bucket         = "my-tf-state-bucket"
    key            = "prod/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks" # Used for state locking to prevent concurrent writes
  }
}

# 2. PROVIDER BLOCK
# Configures the target platform API plugin (e.g., AWS, Azure, GCP, Kubernetes).
provider "aws" {
  region = var.aws_region # Ingests input from an input variable

  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# 3. VARIABLE BLOCK (Input Variables)
# Serves as customizable parameters passed into the configuration at runtime.
variable "aws_region" {
  description = "Target AWS region for infrastructure deployment"
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
  default     = "production"

  # Enforces value constraints before execution
  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "The environment must be development, staging, or production."
  }
}

variable "db_password" {
  description = "Root password for the database"
  type        = string
  sensitive   = true # Prevents the value from displaying in CLI logs and console output
}

# 4. LOCALS BLOCK (Local Values)
# Defines internal computed values and reusable expressions to avoid repeating code.
locals {
  name_prefix = "${var.environment}-app"
  common_tags = {
    Owner     = "DevOps"
    CreatedAt = "2026"
  }
}

# 5. DATA BLOCK (Data Sources)
# Queries and fetches information from existing infrastructure outside this Terraform state.
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical AWS Account ID
}

# 6. RESOURCE BLOCK
# Declares the actual infrastructure components to create, update, or destroy.
resource "aws_instance" "web_server" {
  ami           = data.aws_ami.ubuntu.id # References output from the data block
  instance_type = "t3.micro"

  tags = merge(
    local.common_tags, # Injects values from the locals block
    {
      Name = "${local.name_prefix}-web"
    }
  )

  # Lifecycle rules manage custom behavior during apply operations
  lifecycle {
    create_before_destroy = true # Creates a new resource before deleting the old one during replacement
    prevent_destroy       = false # Set to true in production to prevent accidental deletions
    ignore_changes = [
      tags["CreatedAt"], # Ignores drifts in specific attributes during subsequent applies
    ]
  }
}

# 7. MODULE BLOCK
# Packages reusable Terraform code from local directories or remote registries.
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws" # Module source (Public Registry)
  version = "5.0.0"

  name = "${local.name_prefix}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-south-1a", "ap-south-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = false
}

# 8. OUTPUT BLOCK
# Exposes values from the root module to the CLI, downstream modules, or CI/CD pipelines.
output "web_server_public_ip" {
  description = "Public IP address of the deployed EC2 instance"
  value       = aws_instance.web_server.public_ip # References the created resource attribute
}

output "database_secret_key" {
  description = "Database connection key"
  value       = var.db_password
  sensitive   = true # Hides the output in standard terraform apply CLI output
}
