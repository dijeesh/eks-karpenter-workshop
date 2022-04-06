terraform {
  backend "s3" {
    bucket                  = "XXXX-terraform-state-bucket"
    key                     = "XXXX/ca-environment.tfstate"
    region                  = "us-east-1"
    shared_credentials_file = "~/.aws/credentials"
  }
}

