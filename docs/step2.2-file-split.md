# Step 2.2: tfファイルの分割

このステップでは、Terraformコードの可読性と保守性を向上させるために、ファイルを論理的な単位に分割する方法を学びます。  
Terraformは単一ディレクトリ内のすべての`.tf`ファイルを一つの設定として読み込むため、コードを複数のファイルに分割しても機能的な影響はありません。

## 1. ファイル分割の目的と利点

### 1.1 ファイル分割の目的

ファイル分割には以下のような目的があります：

- **可読性の向上**: 関連するリソースをグループ化し、コードを見つけやすくする
- **保守性の向上**: 特定のリソースタイプに関連する変更を行いやすくする
- **チーム開発の効率化**: 異なるファイルで作業することで、マージコンフリクトを減らす
- **再利用性の向上**: 共通のパターンを特定のファイルに分離することで、他のプロジェクトで再利用しやすくなる

### 1.2 ファイル分割の利点

適切なファイル分割には以下のような利点があります：

- **コードナビゲーションの改善**: 大規模なプロジェクトでも目的のコードをすぐに見つけられる
- **関心の分離**: 各ファイルは特定の役割や目的に集中できる
- **変更管理の簡素化**: ファイル単位でのバージョン管理がしやすくなる
- **コードレビューの効率化**: 関連する変更が特定のファイルに集中するため、レビューが容易になる

## 2. ファイル分割の考え方

基本的にはすべてのIaCに共通する考え方となります。  
ファイルの命名、分割単位はHashiCorp社のスタイルガイドに従います。

[Style Guide - Configuration Language | Terraform | HashiCorp Developer](https://developer.hashicorp.com/terraform/language/style#file-names)によると、次のようなファイル命名規則が推奨されています：

> ## ファイル命名規則
> 
> 以下のファイル命名規則を推奨します。
> 
> * `backend.tf` ファイルには、バックエンドの設定を含めます。複数の `terraform` ブロックを定義することで、バックエンドの設定とTerraformおよびプロバイダーのバージョン管理設定を分離できます。
> * `main.tf` ファイルには、すべての `resource` および `data` ソースブロックを含めます。
> * `outputs.tf` ファイルには、すべての `output` ブロックをアルファベット順で定義します。
> * `providers.tf` ファイルには、すべての `provider` ブロックとその設定を含めます。
> * `terraform.tf` ファイルには、`required_version` および `required_providers` を定義する単一の `terraform` ブロックを含めます。
> * `variables.tf` ファイルには、すべての `variable` ブロックをアルファベット順で定義します。
> * `locals.tf` ファイルには、ローカル値 (`local values`) を定義します。詳細はローカル値を参照してください。
> * `override.tf` ファイルには、設定の上書き定義を含めます。Terraformはこのファイルと `_override.tf` で終わるすべてのファイルを最後に読み込みます。上書き設定はコードの可読性を損なう可能性があるため、慎重に使用し、元のリソース定義にコメントを追加してください。詳細はオーバーライドファイルを参照してください。
> 
> プロジェクトが成長すると、これらのファイルだけでコードを管理するのが難しくなる場合があります。コードが大きくなり、ナビゲーションが困難になった場合は、リソースやデータソースを論理的なグループごとに分割することを推奨します。例えば、Webアプリケーションにネットワーク、ストレージ、コンピュートリソースが必要な場合、以下のようなファイルを作成できます。
> 
> * `network.tf` ファイルには、VPC、サブネット、ロードバランサー、その他のネットワークリソースを定義します。
> * `storage.tf` ファイルには、オブジェクトストレージと関連する権限設定を定義します。
> * `compute.tf` ファイルには、コンピュートインスタンスを定義します。
> 
> どのようにコードを分割しても、メンテナが特定のリソースやデータソースの定義をすぐに見つけられるようにすることが重要です。
> 
> 設定がさらに大規模になる場合、複数の状態ファイル (`state file`) に分割する必要が生じることがあります。詳細なガイドラインについては、HashiCorp Well-Architected Framework を参照してください。

## 3. ワーキングディレクトリの変更

まず、カレントディレクトリを作業用ディレクトリに変更します。  
Step2（もしくはStep2.1）から続けて実施する場合はスキップしてください。

```bash
cd src/
```

## 4. 分割先ファイルの作成

定義したリソースを各種ファイルに分割するため、分割先ファイルを作成します。

```bash
touch terraform.tf &&\
touch providers.tf &&\
touch s3.tf &&\
touch iam.tf &&\
touch random.tf &&\
touch outputs.tf
```

これにより、以下のファイル構造が作成されます：

```
src/
├── terraform.tf   # Terraformの設定とバージョン制約
├── providers.tf   # プロバイダー設定
├── s3.tf          # S3バケットリソース
├── iam.tf         # IAMリソース（ユーザー、ポリシー、アクセスキーなど）
├── random.tf      # 乱数生成リソース
├── outputs.tf     # 出力値
└── main.tf        # 既存のファイル（内容を移動後に削除予定）
```

## 5. コードの分割

既存の`main.tf`ファイルから各リソースを適切なファイルに移動します。

### 5.1 terraform.tf

`main.tf`に記述された`terraform`ブロックを`terraform.tf`に移動します。

```hcl
terraform {
  required_version = "v1.10.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.90.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }
  }
}
```

### 5.2 providers.tf

`main.tf`に記述された`provider`ブロックを`providers.tf`に移動します。

```hcl
provider "aws" {
  # Configuration options
  region  = "ap-northeast-1"
  profile = "リソースデプロイ先AWSアカウントのProfileを指定してください。"
}
```

### 5.3 s3.tf

`main.tf`に記述された`aws_s3_bucket`リソースを`s3.tf`に移動します。

```hcl
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
```

### 5.4 iam.tf

`main.tf`に記述されたIAM関連リソースを`iam.tf`に移動します。

```hcl
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
```

### 5.5 random.tf

`main.tf`に記述された`random_id`リソースを`random.tf`に移動します。

```hcl
# S3バケットのユニーク名を作成するためのランダム文字列を生成
resource "random_id" "this" {
  keepers = {
    "name" = "seed値として自身の名前を記入してください"
  }
  byte_length = 8
}
```

### 5.6 outputs.tf

`main.tf`に記述された`output`ブロックを`outputs.tf`に移動します。

```hcl
output "bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.this.bucket
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.this.arn
}

output "iam_user_name" {
  description = "The name of the IAM user"
  value       = aws_iam_user.this.name
}

# IAMアクセスキーIDの出力
# CAUTION!!! Terraformの体験を優先するためアクセスキーを出力していますが、通常はやってはいけません。
# ハンズオン完了後、リソース削除を忘れないようにしましょう。
output "accesskey_id" {
  value = aws_iam_access_key.this.id
}

# IAMアクセスキーシークレットの出力
# CAUTION!!! Terraformの体験を優先するためアクセスキーを出力していますが、通常はやってはいけません。
# ハンズオン完了後、リソース削除を忘れないようにしましょう。
output "accesskey_secret" {
  value     = aws_iam_access_key.this.secret
  sensitive = true
}
```

### 5.7 不要ファイルの削除

すべてのコードを適切なファイルに移動したら、ブランクとなった`main.tf`を削除します。

```sh
rm main.tf
```

## 6. ファイル分割の検証

ファイル分割後、コードの機能が変わっていないことを確認するために、以下のコマンドを実行します。

### 6.1 コードフォーマット

```bash
terraform fmt
```

このコマンドは、すべての`.tf`ファイルを標準的なフォーマットに整形します。分割したファイルにフォーマットの問題がある場合、このコマンドで修正されます。

### 6.2 コード検証

```bash
terraform validate
```

このコマンドは、Terraformコードの構文的な問題を検出します。すべてのファイルが正しく分割され、参照が適切に更新されていれば、検証はパスするはずです。

### 6.3 プラン確認

```bash
terraform plan
```

このコマンドは、状態ファイルとコードを比較して変更点を表示します。ファイル分割のみでリソースの定義自体は変更していないため、出力に「No changes. Infrastructure is up-to-date.」と表示されるはずです。

もし変更が検出された場合は、ファイル分割の過程でコードが誤って変更された可能性があります。

次のステップでは、状態ファイルをリモートに保存する方法を学びます。
