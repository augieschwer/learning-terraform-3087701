terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "localstack"
  endpoints {
    sts            = "http://localhost:4566"
    secretsmanager = "http://localhost:4566"
    ec2            = "http://localhost:4566"
  }
}
