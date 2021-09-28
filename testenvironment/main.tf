provider "aws" {
  region = "us-east-1"
}


resource "aws_s3_bucket_object" "dist" {
  for_each = fileset("./todo-list/", "*")

  bucket = "${terraform.workspace}-tantor-milions-of-files"
  key    = each.value
  source = "./todo-list/${each.value}"
  etag   = filemd5("./todo-list/${each.value}")
  acl    = "public-read"
  depends_on = [aws_s3_bucket.b]

}

# resource "null_resource" "remove_and_upload_to_s3" {
#   provisioner "local-exec" {
#     command = "export AWS_PROFILE=default && aws s3 sync /var/lib/jenkins/workspace/Terraform-S3-Backend/testenvironment/todo-list s3://${terraform.workspace}-tantor-milions-of-files"
#   }
# }


resource "aws_s3_bucket" "b" {
  
  policy = data.aws_iam_policy_document.website_policy.json

  bucket = "${terraform.workspace}-tantor-milions-of-files"
  acl    = "public-read"
  force_destroy = true


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

resource "aws_s3_bucket_object" "index" {
  bucket       = "${terraform.workspace}-tantor-milions-of-files"
  key          = "index.html"
  source       = "index.html"
  content_type = "text/html"
  etag         = "${md5(file("index.html"))}"
  acl          = "public-read"
  depends_on = [aws_s3_bucket.b]
}

resource "aws_s3_bucket_object" "error" {
  bucket       = "${aws_s3_bucket.static_site.bucket}"
  key          = "index.html"
  source       = "index.html"
  content_type = "text/html"
  etag         = "${md5(file("index.html"))}"
  acl          = "public-read"
  depends_on = [aws_s3_bucket.b]
}
