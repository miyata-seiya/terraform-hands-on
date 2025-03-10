# IAMユーザーの作成
resource "aws_iam_user" "this" {
  name = "${var.iam_user_name}-${var.environment}-${random_id.this.hex}"

  tags = merge(
    {
      Description = "User for S3 access"
      Environment = var.environment
    },
    var.tags
  )
}

# IAMポリシーの作成
resource "aws_iam_policy" "this" {
  name        = "${var.bucket_name_prefix}-${var.environment}-s3-access-policy-${random_id.this.hex}"
  description = "Policy allowing access to the ${var.environment} S3 bucket"

  policy = data.aws_iam_policy_document.this.json
}

data "aws_iam_policy_document" "this" {
  statement {
    effect = "Allow"
    actions = [
      "s3:Get*",
      "s3:List*",
      "s3:PutObject",
      "s3:AbortMultipartUpload"
    ]
    resources = [
      "${aws_s3_bucket.this.arn}",
      "${aws_s3_bucket.this.arn}/*"
    ]
  }
}

# IAMポリシーをユーザーにアタッチ
resource "aws_iam_user_policy_attachment" "this" {
  user       = aws_iam_user.this.name
  policy_arn = aws_iam_policy.this.arn
}

# アクセスキーの作成（注：本番環境では推奨されません）
resource "aws_iam_access_key" "this" {
  user = aws_iam_user.this.name
}
