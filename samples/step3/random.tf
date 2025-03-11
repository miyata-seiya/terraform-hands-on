# S3バケットのユニーク名を作成するためのランダム文字列を生成
resource "random_id" "this" {
  keepers = {
    "name" = "seed値として自身の名前を記入してください"
  }
  byte_length = 8
}
