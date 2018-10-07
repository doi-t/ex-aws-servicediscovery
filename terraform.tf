provider "aws" {
  version = "~> 1.39.0"
  region  = "ap-northeast-1"
}

terraform {
  required_version = "= 0.11.8"

  backend "s3" {}
}
