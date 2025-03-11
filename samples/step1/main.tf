terraform {
  required_version = "v1.10.5"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.90.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region  = "ap-northeast-1"
  profile = "リソースデプロイ先AWSアカウントのProfileを指定してください。"
}
