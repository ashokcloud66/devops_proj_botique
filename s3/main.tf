provider "aws" {
  region = "us-east-1"
}
resource "aws_s3_bucket" "terraform_state" {
  bucket = "techit-eks-terraform-state-us-east-1"
  force_destroy = true
}


resource "aws_dynamodb_table" "dynamodb_terraform_state_lock" {
  name           = "terraform-lock"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"
  
  attribute {
    name = "LockID"
    type = "S"
  }
}
terraform {
  backend "local" {
    path = "/var/lib/jenkins/s3state/terraform.state"
  }
}