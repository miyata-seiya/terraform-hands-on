# IAMユーザーの作成
resource "aws_iam_user" "this" {
  name = "terraform-handson-s3-user-${random_id.this.hex}"

  tags = {
    Description = "User for S3 access"
    # 誰が作ったか分かりづらくなるので自身の名前を記入してください。
    CreatedBy = "your-name"
  }
}

# IAMポリシーの作成
resource "aws_iam_policy" "this" {
  name        = "terraform-handson-s3-access-policy-${random_id.this.hex}"
  description = "Policy allowing access to our handson S3 bucket"

  policy = data.aws_iam_policy_document.this.json

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
  #         "${aws_s3_bucket.this.arn}"
  #         "${aws_s3_bucket.this.arn}/*"
  #       ]
  #     }
  #   ]
  # })
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
