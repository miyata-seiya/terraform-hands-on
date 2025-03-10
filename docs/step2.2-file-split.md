# Step 2.2: tfファイルの分割

このステップでは、可読性を高めるためのファイル分割を行います。

## 1. ファイル分割の考え方

基本的にはすべてのIaCに共通する考え方となります。  
ファイルの命名、分割単位はHashicorp社のスタイルガイドに従います。

[Style Guide - Configuration Language | Terraform | HashiCorp Developer](https://developer.hashicorp.com/terraform/language/style#file-names)

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

## 1. ワーキングディレクトリの変更

まず、カレントディレクトリを作業用ディレクトリに変更します。  
Step2（もしくはStep2.1）から続けて実施する場合はスキップしてください。

```bash
cd src/
```

## 2. 分割先ファイルの作成

定義したリソースを各種ファイルに分割するため、分割先ファイルを作成します。

```bash
touch terraform.tf &&\
touch providers.tf &&\
touch s3.tf &&\
touch iam.tf &&\
touch random.tf &&\
touch outputs.tf
```

## 3. コードの分割

### 3.1 terraform.tf

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

### 3.2 providers.tf

`main.tf`に記述された`provider`ブロックを`providers.tf`に移動します。

```hcl
provider "aws" {
  # Configuration options
  region = "ap-northeast-1"
}
```

### 3.3 s3.tf

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

### 3.4 iam.tf

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

### 3.5 random.tf

`main.tf`に記述された`random_id`リソースを`random.tf`に移動します。

```hcl
# S3バケットのユニーク名を作成するためのランダム文字列を生成
resource "random_id" "this" {
  keepers = {
    "name" = "your-name"
  }
  byte_length = 8
}
```

### 3.6 outputs.tf

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
# TODO: accesskeyを拾うコマンド
output "accesskey_id" {
  value = aws_iam_access_key.this.id
}

# IAMアクセスキーシークレットの出力
# CAUTION!!! Terraformの体験を優先するためアクセスキーを出力していますが、通常はやってはいけません。
output "accesskey_secret" {
  value     = aws_iam_access_key.this.secret
  sensitive = true
}
```

### 3.7 不要ファイルの削除

ブランクとなった`main.tf`を削除します。

```sh
rm main.tf
```

## 4. Terraformコマンドの実行

まず、プロジェクトを初期化します：

```bash
terraform init
```

次に、コードをフォーマットします：

```bash
terraform fmt
```

シンタックスを検証します：

```bash
terraform validate
```

実行計画をで差分が発生していないことを確認します：

```bash
terraform plan
```
