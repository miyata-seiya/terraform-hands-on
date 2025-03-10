terraform {
  required_version = "v1.10.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.90.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "ap-northeast-1"
}

data "aws_caller_identity" "this" {}

# S3バケットのユニーク名を作成するためのランダム文字列を生成
resource "random_id" "suffix" {
  keepers = {
    "name" = "your-name"
  }
  byte_length = 8
}

# S3バケットの定義
resource "aws_s3_bucket" "example" {
  bucket = "terraform-handson-${random_id.suffix.hex}"

  tags = {
    Name        = "Terraform Handson Bucket"
    Environment = "Training"
    # 誰が作ったか分かりづらくなるので自身の名前を記入してください。
    CreatedBy = "your-name"
  }
}

# IAMユーザーの作成
resource "aws_iam_user" "s3_user" {
  name = "terraform-handson-s3-user-${random_id.suffix.hex}"

  tags = {
    Description = "User for S3 access"
    # 誰が作ったか分かりづらくなるので自身の名前を記入してください。
    CreatedBy = "your-name"
  }
}

# IAMポリシーの作成
resource "aws_iam_policy" "s3_access" {
  name        = "terraform-handson-s3-access-policy-${random_id.suffix.hex}"
  description = "Policy allowing access to our handson S3 bucket"

  policy = data.aws_iam_policy_document.s3_access_policy.json

  # data aws_iam_policy_documentを使わない場合はjsonencode関数を使用します。
  # policy = jsonencode({
  #   Version = "2012-10-17",
  #   Statement = [
  #     {
  #       Action = [
  #         "s3:Get*",
  #         "s3:List*",
  #         "s3:PutObject",
  #         "s3:AbortMultipartUpload"
  #       ],
  #       Effect = "Allow",
  #       Resource = [
  #         "${aws_s3_bucket.example.arn}"
  #         "${aws_s3_bucket.example.arn}/*"
  #       ]
  #     }
  #   ]
  # })
}

data "aws_iam_policy_document" "s3_access_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:Get*",
      "s3:List*",
      "s3:PutObject",
      "s3:AbortMultipartUpload"
    ]
    resources = [
      "${aws_s3_bucket.example.arn}",
      "${aws_s3_bucket.example.arn}/*"
    ]
  }
}

# IAMポリシーをユーザーにアタッチ
resource "aws_iam_user_policy_attachment" "s3_user_attach" {
  user       = aws_iam_user.s3_user.name
  policy_arn = aws_iam_policy.s3_access.arn
}

# アクセスキーの作成（注：本番環境では推奨されません）
resource "aws_iam_access_key" "s3_user_key" {
  user = aws_iam_user.s3_user.name
}

output "bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.example.bucket
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.example.arn
}

output "iam_user_name" {
  description = "The name of the IAM user"
  value       = aws_iam_user.s3_user.name
}

# IAMアクセスキーIDの出力
# CAUTION!!! Terraformの体験を優先するためアクセスキーを出力していますが、通常はやってはいけません。
# ハンズオン完了後、リソース削除を忘れないようにしましょう。
output "accesskey_id" {
  value = aws_iam_access_key.s3_user_key.id
}

# IAMアクセスキーシークレットの出力
# CAUTION!!! Terraformの体験を優先するためアクセスキーを出力していますが、通常はやってはいけません。
# ハンズオン完了後、リソース削除を忘れないようにしましょう。
output "accesskey_secret" {
  value     = aws_iam_access_key.s3_user_key.secret
  sensitive = true
}
