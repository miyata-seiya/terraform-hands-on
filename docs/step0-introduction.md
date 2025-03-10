# Step 0: Terraformの基本

## Terraformとは

Terraformは、HashiCorp社が開発したインフラストラクチャをコードとして管理するためのオープンソースツールです。  
TerraformはTerraform Providerを通じて、複数のクラウドプロバイダーやサービスのAPIコールを実現し、統一的な構文で宣言的に記述できます。  

## CloudFormationとTerraformの比較

| 特徴 | CloudFormation | Terraform |
|------|---------------|-----------|
| 対応クラウド | AWSのみ | マルチクラウド（AWS, Azure, GCP, etc） |
| 構文 | JSON/YAML | HCL (HashiCorp Configuration Language) |
| ステート管理 | 自動（AWSが管理） | 明示的（ステートファイル） |
| 依存関係 | 暗黙的な依存関係と明示的なDependsOn | 暗黙的な依存関係と明示的なdepends_on |
| 変更検出 | 変更セットを作成・確認 | terraform planコマンド |
| プロビジョナー | CloudFormation独自の機能 | 複数のプロビジョナーをサポート |
| モジュール性 | ネスト化スタック | モジュールシステム |

## Terraformの基本概念

### リソース

インフラの構成要素（EC2インスタンス、S3バケット、IAMロールなど）を表します。

```hcl
# resource "リソースタイプ" "リソースID"
resource "aws_s3_bucket" "example" {
  bucket = "example-bucket"
}
```

#### 参考: CloudFormationでの記述例

```yml
Resources:
  Example:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: example-bucket
```

### プロバイダー

`terraform`ブロック内の`required_providers`プロパティで利用するプロバイダーを定義し、定義した各プロバイダーの設定を`provider`ブロックで行います。

```hcl
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.89.0"
    }
  }
}
```

```hcl
provider "aws" {
  region = "ap-northeast-1"
}
```

### 変数

コードをパラメータ化するための仕組みです。

```hcl
variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
  default     = "my-default-bucket"
}
```

### 出力値

Terraformの実行結果を外部から参照するための仕組みです。

```hcl
output "bucket_name" {
  value = aws_s3_bucket.example.bucket
}
```

### モジュール

再利用可能なTerraformコードのパッケージです。

```hcl
module "s3_bucket" {
  source = "./modules/s3"
  
  bucket_name = "my-bucket"
}
```

### ステートファイル

Terraformは実際に作成したリソースの状態を「tfstate」というファイルに保存します。  
Terraformはtfstateファイルを参照し、実際の変更内容を決定します。

## Terraformのワークフロー

1. **init**: プロジェクトの初期化（プロバイダーのダウンロードなど）
2. **plan**: 実行計画の作成（何が追加/変更/削除されるかを表示）
3. **apply**: 実際にインフラを変更
4. **destroy**: 作成したリソースを削除

## このハンズオンで学ぶこと

1. Terraformの基本的な使い方
2. AWS上でS3バケットとIAMリソースの作成
3. リモートバックエンドの設定
4. モジュール化によるコードの再利用
5. 高度なTerraform機能（ローカル変数、ループなど）

次のステップでは、実際にTerraformコードを書き始めます。
