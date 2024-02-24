#terraform {
#  backend "s3" {
#    bucket = "sqlscriptflask"
#    key = "terraform/terraform.tfstate"
#    region = "us-east-1"
#    encrypt = true
#  }
#}

terraform {
  backend "http" {
  }
}
