terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.44.0"
    }
  }
    backend "s3" {
    bucket = "srikanthnn"
    key    = "expense-dev-bastion"
    region = "us-east-1"
    use_lockfile = true
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}