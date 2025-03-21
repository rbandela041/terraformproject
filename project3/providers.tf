terraform {
  required_version = "1.11.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.91.0"
    }
  }

  backend "s3" {
    bucket = "terraformstatefileb1"
    key    = "terraform/trm.tfstate"
    region = "us-west-2"
  }
}

provider "aws" {
  region = var.region
  assume_role {
    role_arn = var.env == "test" ? var.test_role_arn : var.qa_role_arn
  }
}
