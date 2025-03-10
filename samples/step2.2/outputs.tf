output "bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.this.bucket
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.this.arn
}

output "iam_user_name" {
  description = "The name of the IAM user"
  value       = aws_iam_user.this.name
}

# IAMアクセスキーIDの出力
# CAUTION!!! Terraformの体験を優先するためアクセスキーを出力していますが、通常はやってはいけません。
# ハンズオン完了後、リソース削除を忘れないようにしましょう。
output "accesskey_id" {
  value = aws_iam_access_key.this.id
}

# IAMアクセスキーシークレットの出力
# CAUTION!!! Terraformの体験を優先するためアクセスキーを出力していますが、通常はやってはいけません。
# ハンズオン完了後、リソース削除を忘れないようにしましょう。
output "accesskey_secret" {
  value     = aws_iam_access_key.this.secret
  sensitive = true
}
