provider "aws" {
  region = "eu-central-1"
}


resource "aws_s3_bucket_object" "dist" {
  for_each = fileset("./todo-list/", "*")

  bucket = "${terraform.workspace}-tantor-milions-of-files"
  key    = each.value
  source = "./todo-list/${each.value}"
  etag   = filemd5("./todo-list/${each.value}")
  acl    = "public-read" 

}


resource "aws_s3_bucket" "b" {
  
  policy = data.aws_iam_policy_document.website_policy.json

  bucket = "${terraform.workspace}-tantor-milions-of-files"
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


data "aws_iam_policy_document" "website_policy" {
  statement {
    actions = [
      "s3:GetObject"
    ]
    principals {
      identifiers = ["*"]
      type = "AWS"
    }
    resources = [
      "arn:aws:s3:::${terraform.workspace}-tantor-milions-of-files/*"
    ]
  }
}
