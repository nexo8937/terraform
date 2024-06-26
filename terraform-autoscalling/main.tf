#--------Provider--------

provider "aws" {
  region = "us-east-1"
}

#--------Terraform-Remote-State--------
terraform {
  backend "s3" {
    bucket = "tfstate-brainscale"
    key    = "autoscalling"
    region = "us-east-1"
    dynamodb_table =  "terraform-lock"
  }
}
