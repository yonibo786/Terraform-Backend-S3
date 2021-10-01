provider "aws" {
  region = "us-east-1"
}


resource "aws_s3_bucket_object" "dist" {
  for_each = fileset("./todo-list/", "*")

  bucket = "${terraform.workspace}"
  key    = each.value
  source = "./todo-list/${each.value}"
  etag   = filemd5("./todo-list/${each.value}")
  acl    = "public-read"
  depends_on = [aws_s3_bucket.b]

}

resource "aws_s3_bucket_object" "todo-list" {
  for_each = fileset("./todo-list/assets/", "*")

  bucket = "${terraform.workspace}"
  key    = "assets/${each.value}"
  source = "./todo-list/assets/${each.value}"
  etag   = filemd5("./todo-list/assets/${each.value}")
  acl    = "public-read"
  content_type = "application/json"
  depends_on = [aws_s3_bucket.b]

}


resource "aws_s3_bucket" "b" {
  
  policy = data.aws_iam_policy_document.website_policy.json

  bucket = "${terraform.workspace}"
  acl    = "public-read"
  force_destroy = true


  tags = {
    Name        = "My bucket"
    Environment = var.plan
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
      "arn:aws:s3:::${terraform.workspace}/*"
    ]
  }
}

resource "aws_s3_bucket_object" "index" {
  bucket       = "${terraform.workspace}"
  key          = "index.html"
  source       = "index.html"
  content_type = "text/html"
  etag         = "${md5(file("index.html"))}"
  acl          = "public-read"
  depends_on = [aws_s3_bucket.b]
}

resource "aws_s3_bucket_object" "error" {
  bucket       = "${terraform.workspace}"
  key          = "index.html"
  source       = "index.html"
  content_type = "text/html"
  etag         = "${md5(file("index.html"))}"
  acl          = "public-read"
  depends_on = [aws_s3_bucket.b]
}

resource "aws_s3_bucket_object" "cssfile" {
  bucket       = "${terraform.workspace}"
  key          = "styles.c54309772107e2fdab6d.css"
  source       = "styles.c54309772107e2fdab6d.css"
  content_type = "text/css"
  etag         = "${md5(file("styles.c54309772107e2fdab6d.css"))}"
  acl          = "public-read"
  depends_on = [aws_s3_bucket.b]
}

