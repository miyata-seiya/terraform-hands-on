terraform {
  backend "s3" {
    # 指定のバケット名に置き換えてください
    bucket = "existing-terraform-state-bucket"
    # 指定のkey値に置き換えてください
    key    = "terraform-hands-on/<your-name>/development/terraform.tfstate"
    region = "ap-northeast-1"
    # 指定のprofile名に置き換えてください
    # profile = "リモートステート用S3バケットを指定してください。"
    # 以下はオプションですが、本番環境では推奨されます
    # encrypt = true
    # dynamodb_table = "terraform-state-lock"
  }
}
