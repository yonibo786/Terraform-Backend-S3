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

output "s3_bucket_id" {
    value = aws_s3_bucket.s3_bucket.id
}
