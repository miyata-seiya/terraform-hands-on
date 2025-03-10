# S3バケットのユニーク名を作成するためのランダム文字列を生成
resource "random_id" "this" {
  keepers = {
    "name" = "your-name"
  }
  byte_length = 8
}
