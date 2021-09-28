provider "aws" {
  region = "eu-central-1"
}


resource "aws_s3_bucket_object" "dist" {
  for_each = fileset("/home/pawan/Documents/Projects/", "*")

  bucket = "test-terraform-tantor-milions-of-files"
  key    = each.value
  source = "/home/pawan/Documents/Projects/${each.value}"
  etag   = filemd5("/home/pawan/Documents/Projects/${each.value}")
}
