terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  # Hard-coding the region for simplicity's sake
  region = "us-east-2"
}
