provider "aws" {
  region = "eu-central-1"
}

resource "aws_s3_bucket" "b" {
  bucket = "${terraform.workspace}-tf-tantor"
  acl    = "private"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}