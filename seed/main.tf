# Initialise Variables and AWS Resources for future terraform use.
# This terraform file to be run with definitions within terraform block commented out
# so that these resources are provisioned and does not throw an error when looking for them.

# Require TF version to be same as or greater than 0.12.13

terraform {
  # Below items to be commented out during seed initialization
  # required_version = ">=0.12.13"
  #backend "s3" {
  #  bucket         = "your_globally_unique_bucket_name"
  #  key            = "terraform.tfstate"
  #  region         = "us-east-1"
  #  dynamodb_table = "aws-locks"
  #  encrypt        = true
  #}
}

provider "aws" {
  region  = "us-east-1"
  # version 3.74 to address issue https://github.com/hashicorp/terraform-provider-aws/issues/23106
  version = "~> 3.74"
}

# Call the "seed" "module to build our AWS seed info
# The items on the right are strings you can modify
# you will need a globally unique s3 bucket name
module "seed" {
  source                      = "../modules/seed"
  name_of_s3_bucket           = "github-actions-terraform-tfstate-x123"
  dynamo_db_table_name        = "aws-terraform-lock"
  iam_user_name               = "GitHubActionsIamUser"
  ado_iam_role_name           = "GitHubActionsIamRole"
  aws_iam_policy_permits_name = "GitHubActionsIamPolicyPermits"
  aws_iam_policy_assume_name  = "GitHubActionsIamPolicyAssume"
}