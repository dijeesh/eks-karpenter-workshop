terraform {
  backend "s3" {
    bucket                  = "XXXX-terraform-state-bucket"
    key                     = "XXXX/karpenter-environment.tfstate"
    region                  = "us-east-1"
    shared_credentials_file = "~/.aws/credentials"
  }
}

