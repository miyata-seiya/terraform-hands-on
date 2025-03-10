# 複数のS3バケットを作成
resource "aws_s3_bucket" "multiple_buckets" {
  for_each = local.s3_buckets
  
  bucket = "${each.value.name_prefix}-${random_string.bucket_suffix.result}"
  
  tags = merge(
    local.common_tags,
    {
      Name = "Example ${each.key} Bucket"
    }
  )
}

# 各バケットのバージョニング設定
resource "aws_s3_bucket_versioning" "bucket_versioning" {
  for_each = aws_s3_bucket.multiple_buckets
  
  bucket = each.value.bucket
  versioning_configuration {
    status = local.s3_buckets[each.key].versioning ? "Enabled" : "Disabled"
  }
}

# 各バケットの暗号化設定
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
  for_each = {
    for name, bucket in aws_s3_bucket.multiple_buckets : 
    name => bucket if local.s3_buckets[name].encryption
  }
  
  bucket = each.value.bucket
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# 乱数生成
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}
