# S3バケットの定義
resource "aws_s3_bucket" "this" {
  bucket = "terraform-handson-${random_id.this.hex}"

  tags = {
    Name        = "Terraform Handson Bucket"
    Environment = "Training"
    # 誰が作ったか分かりづらくなるので自身の名前を記入してください。
    CreatedBy = "your-name"
  }
}
