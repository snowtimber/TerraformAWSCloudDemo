# Require TF version to be same as or greater than 0.12.13
terraform {
  # required_version = ">=0.12.13"
  backend "s3" {
    bucket         = "github-actions-terraform-tfstate-2345678"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "aws-terraform-lock"
    encrypt        = true
  }
}

# Download any stable version in AWS provider
provider "aws" {
  region  = "us-east-1"
  # version 3.74 to address issue https://github.com/hashicorp/terraform-provider-aws/issues/23106
  version = "~> 3.74"
}

# Call the "bootstrap" "module to build our AWS seed info
# The items on the right are strings you can modify
# you will need a globally unique s3 bucket name
module "bootstrap" {
  source                      = "./modules/bootstrap"
  name_of_s3_bucket           = "github-actions-terraform-tfstate-2345678"
  dynamo_db_table_name        = "aws-terraform-lock"
  iam_user_name               = "GitHubActionsIamUser"
  ado_iam_role_name           = "GitHubActionsIamRole"
  aws_iam_policy_permits_name = "GitHubActionsIamPolicyPermits"
  aws_iam_policy_assume_name  = "GitHubActionsIamPolicyAssume"
}