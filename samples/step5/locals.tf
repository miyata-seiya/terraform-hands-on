locals {
  project     = "terraform-handson"
  environment = "advanced"
  region      = "ap-northeast-1"
  
  # 共通タグの定義
  common_tags = {
    Project     = local.project
    Environment = local.environment
    ManagedBy   = "Terraform"
    Owner       = "Infrastructure Team"
    CostCenter  = "123456"
  }
  
  # S3バケット設定
  s3_buckets = {
    data = {
      name_prefix = "${local.project}-data"
      versioning  = true
      encryption  = true
    },
    logs = {
      name_prefix = "${local.project}-logs"
      versioning  = false
      encryption  = true
    }
  }
}
