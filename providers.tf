terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Hard-coding the region for simplicity's sake
provider "aws" {
  region = "us-east-2"
}
