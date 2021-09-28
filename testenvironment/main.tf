provider "aws" {
  region = "eu-central-1"
}


resource "aws_s3_bucket_object" "dist" {
  for_each = fileset("./todo-list/", "*")

  bucket = "test-terraform-tantor-milions-of-files"
  key    = each.value
  source = "./todo-list/${each.value}"
  etag   = filemd5("./todo-list/${each.value}")
}


resource "aws_s3_bucket" "b" {
  bucket = "test-terraform-tantor-milions-of-files"
  acl    = "public-read"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
  
   website {
    index_document = "index.html"
    error_document = "index.html"
  }
}
