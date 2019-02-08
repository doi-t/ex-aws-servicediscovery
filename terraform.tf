provider "aws" {
  version = "~> 1.56.0"
  region  = "ap-northeast-1"
}

terraform {
  required_version = "= 0.11.11"

  backend "s3" {}
}
