# Step 5: Appendix

このステップでは、Terraformの高度な機能を紹介します。これらの機能を使うことで、よりメンテナンスしやすく柔軟なインフラコードを書くことができます。

**Step5については簡単な紹介のみで終わります。**

## 1. 新しいディレクトリの作成

```bash
mkdir -p terraform-handson/step5
cd terraform-handson/step5
```

前のステップのファイルをコピーします：

```bash
cp -r ../step4/modules .
mkdir -p environments/advanced
```

## 2. ローカル変数（locals）

ローカル変数を使うと、コード内で繰り返し使用される値や複雑な式を一箇所で定義できます。

`environments/advanced/locals.tf`を作成します：

```hcl
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
```

## 3. 条件式

条件式を使って、特定の条件に基づいてリソースの設定を変更できます。

`environments/advanced/conditional.tf`を作成します：

```hcl
# 環境に基づいた条件分岐
locals {
  is_production = local.environment == "prod"
  
  # 環境に応じてインスタンスタイプを選択
  instance_type = local.is_production ? "t3.medium" : "t3.micro"
  
  # 環境に応じて自動削除保護を設定
  deletion_protection = local.is_production
}

# 特定の条件でのみ作成されるリソース
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  count = local.is_production ? 1 : 0
  
  alarm_name          = "high-cpu-usage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This metric monitors ec2 cpu utilization"
}
```

## 4. for_each によるリソースの繰り返し

`for_each`を使って、マップやセットの各要素に対してリソースを作成できます。

`environments/advanced/for_each.tf`を作成します：

```hcl
# 複数のS3バケットを作成
resource "aws_s3_bucket" "multiple_buckets" {
  for_each = local.s3_buckets
  
  bucket = "${each.value.name_prefix}-${random_string.bucket_suffix.result}"
  
  tags = merge(
    local.common_tags,
    {
      Name = each.key
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
```

## 5. 動的なブロックと展開

動的なブロックを使って、リストやマップの要素に基づいてネストされたブロックを生成できます。

`environments/advanced/dynamic_blocks.tf`を作成します：

```hcl
locals {
  s3_lifecycle_rules = [
    {
      id      = "log-expiration"
      enabled = true
      prefix  = "logs/"
      
      expiration = {
        days = 90
      }
      
      transitions = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 60
          storage_class = "GLACIER"
        }
      ]
    },
    {
      id      = "temp-expiration"
      enabled = true
      prefix  = "temp/"
      
      expiration = {
        days = 7
      }
      
      transitions = []
    }
  ]
}

resource "aws_s3_bucket" "with_lifecycle" {
  bucket = "lifecycle-demo-${random_string.bucket_suffix.result}"
  
  tags = local.common_tags
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket_lifecycle" {
  bucket = aws_s3_bucket.with_lifecycle.bucket
  
  dynamic "rule" {
    for_each = local.s3_lifecycle_rules
    
    content {
      id     = rule.value.id
      status = rule.value.enabled ? "Enabled" : "Disabled"
      
      filter {
        prefix = rule.value.prefix
      }
      
      # 条件付きブロック
      dynamic "expiration" {
        for_each = rule.value.expiration != null ? [rule.value.expiration] : []
        
        content {
          days = expiration.value.days
        }
      }
      
      # リストに基づく動的ブロック
      dynamic "transition" {
        for_each = rule.value.transitions
        
        content {
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }
    }
  }
}
```

## 6. データソースの使用

データソースを使って、既存のAWSリソースの情報を取得できます。

`environments/advanced/data_sources.tf`を作成します：

```hcl
# 現在のAWSアカウントとリージョンの情報を取得
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# 特定のAMIを検索
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# データソースの出力表示
output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "region_name" {
  value = data.aws_region.current.name
}

output "latest_amazon_linux_2_ami" {
  value = data.aws_ami.amazon_linux_2.id
}
```

## 7. 依存関係の制御

`depends_on`を使って、リソース間の明示的な依存関係を定義できます。

`environments/advanced/dependencies.tf`を作成します：

```hcl
# S3バケットポリシーの例
resource "aws_s3_bucket_policy" "example" {
  bucket = aws_s3_bucket.with_lifecycle.id
  
  # 明示的な依存関係
  depends_on = [
    aws_s3_bucket_public_access_block.example
  ]
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:GetObject"]
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.with_lifecycle.arn}/*"
        Principal = {
          AWS = data.aws_caller_identity.current.account_id
        }
      }
    ]
  })
}

# パブリックアクセスブロック設定
resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.with_lifecycle.id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
```

## 8. プロバイダー設定

`environments/advanced/providers.tf`を作成します：

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.0.0"
  
  backend "s3" {
    bucket = "existing-terraform-state-bucket"  # 既存のバケット名に置き換えてください
    key    = "terraform-handson/advanced/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

provider "aws" {
  region = local.region
  
  default_tags {
    tags = {
      ManagedBy = "Terraform"
    }
  }
}
```

## 9. テンプレート機能

Terraformはテンプレート機能も提供しています。`templatefile`関数を使用して外部テンプレートファイルを読み込み、変数を置換できます。

まず、`environments/advanced/templates/bucket_policy.json.tpl`テンプレートファイルを作成します：

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${account_id}"
      },
      "Action": ${jsonencode(actions)},
      "Resource": "${bucket_arn}/*"
    }
  ]
}
```

次に、`environments/advanced/templates.tf`ファイルを作成します：

```hcl
resource "aws_s3_bucket_policy" "templated" {
  bucket = aws_s3_bucket.with_lifecycle.id
  
  policy = templatefile("${path.module}/templates/bucket_policy.json.tpl", {
    account_id = data.aws_caller_identity.current.account_id
    actions    = ["s3:GetObject", "s3:ListBucket"]
    bucket_arn = aws_s3_bucket.with_lifecycle.arn
  })
  
  depends_on = [
    aws_s3_bucket_public_access_block.example
  ]
}
```

## 10. 実行

高度な機能を使用するコードを実行します：

```bash
cd environments/advanced
terraform init
terraform plan
terraform apply
```

## 11. まとめ

このステップでは、以下のTerraformの高度な機能を学びました：

1. **ローカル変数**: 複雑な式や繰り返し使用される値を管理
2. **条件式**: 環境や他の条件に基づいてリソース設定を変更
3. **for_each**: マップやセットを使用して複数のリソースを作成
4. **動的ブロック**: リストやマップからネストされたブロックを生成
5. **データソース**: 既存のAWSリソースの情報を取得
6. **明示的な依存関係**: `depends_on`を使用してリソース間の依存関係を制御
7. **テンプレート機能**: 外部テンプレートファイルを使用してポリシーなどを生成

これらの機能を使いこなすことで、メンテナンスしやすく、柔軟性の高いTerraformコードを書くことができます。