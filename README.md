# Infrastructure setup using Terraform

# Assignment9
# Terraform Setup
This repository contains the Terraform code to deploy an infrastructure setup for an application in the AWS cloud.

# Prerequisites
Before running the Terraform code, you need to have the following prerequisites installed:

1. [Terraform](https://developer.hashicorp.com/terraform/downloads)
2. https://aws.amazon.com/cli/
You also need to have an AWS account and configure your AWS CLI access key ID and secret access key.

# How to use the project

1. Clone the repository:
   https://github.com/CSYE6225-cloud-computing-neu/aws-infra.git
2. Change into the repository directory:
   cd aws-infra
3. Initialize the Terraform project:
   terraform init
4. Review the Terraform plan:
   terraform plan
5. Apply the Terraform code:
   terraform apply

# Variables

The Terraform code uses variables to allow customization of the deployment. You can set the variables in terraform.tfvars file, or by using environment variables or command line arguments. The following variables are available:

region (required): the AWS region to deploy to
instance_type (optional): the instance type for the EC2 instances (default: t2.micro)
environment (optional): the environment name to use for resource names (default: dev)
For example, to set the region variable to us-east-1, you can create a terraform.tfvars file with the following content:

region = "us-east-1"

# Cleaning up
To remove the resources created by Terraform, you can run:
terraform destroy

# AWS Resources
VPC, Subnets, Route table, Route table association, EC2, RDS, Route53 domain, EC2 security group, RDS security group

# Import certificate from CLI command
aws acm import-certificate --profile demo --region us-east-1 --certificate fileb://demo_vrushaliphaltankar_me.crt --private-key fileb://vrushaliphaltankar.me.key