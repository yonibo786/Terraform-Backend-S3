terraform {
  backend "s3" {
    bucket         = "terraform-state-tantor"
    region         = "eu-central-1"
    dynamodb_table = "terraform-state-locking"
    key            = "main/terraform-first.tfstate"
  }
}
