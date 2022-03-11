# TerraformAWSCloudSeed

This repo can create a "seed" or "bootstrapped" AWS Terraform Environment:

Terraform requires a state file (to store the state) and a lock file to store the lock status.  To have a completely cloud based environment, these need to be stored with a cloud provider, in our case within an AWS s3 bucket for the state file and a dynamo db table for the lock status.

A key catch-22 is that the s3 bucket and dynamo db needs to pre-exist, in order for Terraform to be able to 'init' and later 'apply' any new changes.

This project allows the necessary S3 bucket and Dynamo DB table to be provisioned once initially using github actions 'run workflow' button on the Terraform AWS Setup workflow, and then a user can run any follow up CI/CD within the modules and main.tf file on push to 'main' as they would any regular Terraform development IaC workflow.

Special thanks to KyMidd for the great walkthroughs below.
This repo simply combines these 2 articles by KyMidd into 1 simple github action workflow to seed any AWS Terraform project:

An Intro to Bootstrapping AWS to Your Terraform CI/CD:

https://medium.com/swlh/lets-do-devops-bootstrap-aws-to-your-terraform-ci-cd-azure-devops-github-actions-etc-b3cc5a636dce

An Intro to GitHub Actions + Terraform + AWS:

https://medium.com/@kymidd/lets-do-devops-github-actions-terraform-aws-77ef6078e4f2

# How it Works

There are 2 workflows `terraform-aws-setup.yml` and 'terraform-cicd-apply.yml'.

'Terraform AWS Setup' github action can be manually ran within the Actions tab of Github and will set up the necessary AWS resources.
```
on: [workflow_dispatch]
```

'Terraform Apply' will run and cause deployment of main.tf in the root file when changes land into the `main` branch. This is seen within the `.github/workflows/terraform-cicd-apply.yml` file:
```
on:
  push:
    branches: [ main ]
```


# How To Configure
* Fork this repo
* Within the Repository settings for your fork or repo, create the following `Secrets` to configure the permissions to be used by the GitHub Actions pipeline:

```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
```

See KyMidd's walkthrough for step by step instructions:

https://medium.com/swlh/lets-do-devops-bootstrap-aws-to-your-terraform-ci-cd-azure-devops-github-actions-etc-b3cc5a636dce


* Update the the S3 bucket name to a globally unique s3 bucket name of your choice within:


main.tf, seed/main.tf and seed/main-replace/main-with-remote-backend.tf
'''
terraform {
  backend "s3" {
    bucket         = "github-actions-terraform-globaly-unique"
'''
'''
module "seed" {
  source                      = "./modules/seed"
  name_of_s3_bucket           = "github-actions-terraform-globaly-unique"
'''

* Run 'Terraform AWS Setup' github action manually within the Actions tab of Github and will set up (bootstrap) the necessary AWS resources.

* Modify, Create, Build main.tf and TF modules/ as you would any other Terraform project.  Changes pushed to main will automagically deploy IaC to AWS Cloud.  

## Future
-add Terraform Destroy commands for any orphan resources created
-add unit tests to Github Actions CI/CD Terraform Apply for a more versatile seed