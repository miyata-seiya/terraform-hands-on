# S3バケットのユニーク名を作成するためのランダム文字列を生成
resource "random_id" "this" {
  keepers = {
    "name" = var.bucket_name_prefix
  }
  byte_length = 8
}
