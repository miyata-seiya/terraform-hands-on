resource "aws_s3_bucket" "this" {
  bucket = "${var.bucket_name_prefix}-${var.environment}-${random_id.this.hex}"

  tags = merge(
    {
      Name        = "${var.bucket_name_prefix}-${var.environment}"
      Environment = var.environment
    },
    var.tags
  )
}
