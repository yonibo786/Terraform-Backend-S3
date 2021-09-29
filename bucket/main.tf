provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "b" {
  bucket = "${terraform.workspace}"
  acl    = "private"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
  
  force_destroy = true

}

