terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 6.0"
    }
    docker = {
      source = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "aws" {
  region                   = "eu-central-1"

  default_tags {
    tags = {
      Environment = "Quickstart Example"
      Owner       = "Terraform Iac"
      Project     = "terraform-aws-compute-scheduler-module"
      terraform   = "true"
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_ecr_authorization_token" "current" {}

provider "docker" {
  registry_auth {
    address  = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.region}.amazonaws.com"
    username = data.aws_ecr_authorization_token.current.user_name
    password = data.aws_ecr_authorization_token.current.password
  }
}