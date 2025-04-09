#This Terraform Code Deploys Basic VPC Infra.
provider "aws" {
  alias  = "eastus"
  region = "us-east-1"
}

provider "aws" {
  alias  = "india"
  region = "ap-south-1"
}

provider "aws" {
  alias  = "ireland"
  region = "eu-west-1"
}

terraform {
  required_version = "<= 2.3.14" #Forcing which version of Terraform needs to be used
  required_providers {
    aws = {
      version = "<= 6.0.0" #Forcing which version of plugin needs to be used.
      source  = "hashicorp/aws"
    }
  }
}

