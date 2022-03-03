# Require TF version to be same as or greater than 0.12.13
terraform {
  # required_version = ">=0.12.13"
  #backend "s3" {
  #  bucket         = "your_globally_unique_bucket_name"
  #  key            = "terraform.tfstate"
  #  region         = "us-east-1"
  #  dynamodb_table = "aws-locks"
  #  encrypt        = true
  #}
}

# Download any stable version in AWS provider of 2.36.0 or higher in 2.36 train
provider "aws" {
  region  = "us-east-1"
  version = "~> 2.36.0"
}

##
# Define variables for AWS DevOps Seed Module
##

variable "name_of_s3_bucket" {
  type    = string
  default = "github-actions-terraform-tfstate-12345"
}

variable "dynamo_db_table_name" {
  type    = string
  default = "aws-terraform-lock"
}

variable "iam_user_name" {
  type    = string
  default = "GitHubActionsIamUser"
}

variable "ado_iam_role_name" {
  type    = string
  default = "GitHubActionsIamRole"
}

variable "aws_iam_policy_permits_name" {
  type    = string
  default = "GitHubActionsIamPolicyPermits"
}

variable "aws_iam_policy_assume_name" {
  type    = string
  default = "GitHubActionsIamPolicyAssume"
}

##
#Below are sample resources to have terraform provision
##

# Build an S3 bucket to store TF state
resource "aws_s3_bucket" "state_bucket" {
  bucket = var.name_of_s3_bucket

  # Tells AWS to encrypt the S3 bucket at rest by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  # Prevents Terraform from destroying or replacing this object - a great safety mechanism
  lifecycle {
    prevent_destroy = true
  }

  # Tells AWS to keep a version history of the state file
  versioning {
    enabled = true
  }

  tags = {
    Terraform = "true"
  }
}

# Build a DynamoDB to use for terraform state locking
resource "aws_dynamodb_table" "tf_lock_state" {
  name = var.dynamo_db_table_name

  # Pay per request is cheaper for low-i/o applications, like our TF lock state
  billing_mode = "PAY_PER_REQUEST"

  # Hash key is required, and must be an attribute
  hash_key = "LockID"

  # Attribute LockID is required for TF to use this table for lock state
  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name    = var.dynamo_db_table_name
    BuiltBy = "Terraform"
  }
}
