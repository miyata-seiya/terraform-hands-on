# Step 0: Terraformの基本

## 1. Terraformとは

Terraformは、HashiCorp社が開発したインフラストラクチャをコードとして管理するためのオープンソースツールです。Infrastructure as Code（IaC）のアプローチにより、クラウドリソースの作成、変更、管理をコード化し、バージョン管理されたリポジトリで共有可能なものにします。

### 1.1 Terraformの主な特徴

- **宣言型言語**: あるべき状態を宣言し、その状態に到達する方法はTerraformが判断します
- **プロバイダーシステム**: AWS、Azure、GCPなど多数のプラットフォームに対応
- **状態管理**: リソースの現在の状態を追跡し、必要な変更を計算
- **変更計画**: 適用前に変更内容を確認できる
- **モジュール化**: コードの再利用と共有が容易
- **コミュニティ**: 豊富なモジュールとプロバイダーエコシステム

### 1.2 なぜTerraformを使うのか

- **一貫性**: 環境間での構成の一貫性を確保
- **効率性**: インフラのプロビジョニングを自動化して効率化
- **バージョン管理**: インフラの変更履歴を追跡可能
- **協業**: チームでのインフラ管理を容易にする
- **複数プロバイダー対応**: マルチクラウド環境を単一のツールで管理

## 2. CloudFormationとTerraformの比較

AWSを使用しているチームにとって、CloudFormationとTerraformはどちらも選択肢となります。以下は両者の詳細な比較です。

| 特徴 | CloudFormation | Terraform |
|------|---------------|-----------|
| 対応クラウド | AWSのみ | マルチクラウド（AWS, Azure, GCP, etc） |
| 構文 | JSON/YAML | HCL (HashiCorp Configuration Language) |
| ステート管理 | 自動（AWSが管理） | 明示的（ステートファイル） |
| 依存関係 | 暗黙的な依存関係と明示的なDependsOn | 暗黙的な依存関係と明示的なdepends_on |
| 変更検出 | 変更セットを作成・確認 | terraform planコマンド |
| プロビジョナー | CloudFormation独自の機能 | 複数のプロビジョナーをサポート |
| モジュール性 | ネスト化スタック | モジュールシステム |
| コミュニティ | AWS中心 | 多様なプラットフォーム |
| ドリフト検出 | サポート | 部分的サポート（terraform plan） |

### 2.1 CloudFormationユーザーにとってのTerraformの利点

- **マルチクラウド対応**: AWS以外のクラウドも同じツールで管理可能
- **より柔軟な言語**: HCLは条件や関数などの機能が豊富
- **モジュールエコシステム**: 再利用可能なコンポーネントの大規模なコレクション
- **より詳細な変更計画**: terraform planで変更の詳細を確認可能
- **より強力な依存関係管理**: リソース間の依存関係をより明示的に制御

## 3. Terraformの基本概念

### 3.1 リソース

リソースはTerraformの基本的な構成要素で、実際に作成される個々のインフラコンポーネントを表します。

```hcl
resource "aws_s3_bucket" "example" {
  bucket = "example-bucket"
  
  tags = {
    Name = "Example Bucket"
    Environment = "Development"
  }
}
```

#### Resource Blocks の構文

```
resource "TYPE" "NAME" {
  [CONFIG ...]
}
```

- **TYPE**: リソースの種類（例: aws_s3_bucket）
- **NAME**: リソースの識別子（同じタイプの他のリソースと区別するための名前）
- **CONFIG**: リソースの設定（属性やネストされたブロック）

#### 参考: CloudFormationでの記述例

```yml
Resources:
  Example:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: example-bucket
      Tags:
        - Key: Name
          Value: Example Bucket
        - Key: Environment
          Value: Development
```

### 3.2 プロバイダー

プロバイダーは特定のインフラプラットフォーム（AWS、Azure、GCPなど）とTerraformの間のインターフェースです。

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
  profile = "dev"
}
```

#### Provider Blocks の仕組み

- **認証情報**: プロバイダーが特定のアカウントやプロジェクトにアクセスするための認証情報
- **バージョン制約**: 特定のバージョンやバージョン範囲を指定
- **設定パラメータ**: プロバイダー固有の設定（リージョンなど）

#### プロバイダーのバージョン管理

```hcl
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"  # 5.x の最新バージョン
    }
  }
}
```

バージョン制約の書き方:
- `= 5.89.0`: 完全に一致するバージョン
- `>= 5.0.0`: 指定バージョン以上
- `~> 5.0`: パッチリリースのみ自動更新（5.0.0, 5.0.1, 5.1.0など）
- `>= 5.0.0, < 6.0.0`: バージョン範囲

### 3.3 変数と出力

#### 変数（Input Variables）

変数はTerraformコードをパラメータ化するための仕組みです。

```hcl
variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
  default     = "my-default-bucket"
}
```

変数の属性:

- **description**: 変数の目的を説明
- **type**: 変数の型（string, number, bool, list, map, object, any）
- **default**: 省略時のデフォルト値
- **validation**: 入力値の検証ルール
- **sensitive**: 出力で値を隠すかどうか

変数の参照:

```hcl
resource "aws_s3_bucket" "example" {
  bucket = var.bucket_name
}
```

##### 参考: CloudFormationでの記述例

```yml
Parameters:
  BucketName:
    Type: String
    Description: Name of the S3 bucket
    Default: my-default-bucket
```

#### 出力値（Output Values）

出力値はTerraformの実行結果を外部から参照するための仕組みです。

```hcl
output "bucket_name" {
  value = aws_s3_bucket.example.bucket
  description = "The name of the bucket"
}
```

出力値の属性:

- **value**: 出力する値
- **description**: 出力値の説明
- **sensitive**: 値を隠すかどうか
- **depends_on**: 明示的な依存関係

##### 参考: CloudFormationでの記述例

```yml
Outputs:
  BucketName:
    Description: The name of the bucket
    Value:
      Ref: Bucket
```

### 3.4 データソース

データソースは既存のリソースの情報を参照するための仕組みです。

```hcl
data "aws_caller_identity" "this" {}
data "aws_region" "this" {}
```

データソースの利用:

```hcl
resource "aws_s3_bucket" "this" {
  bucket = "tmp-${data.aws_region.this.name}-${data.aws_caller_identity.this.account_id}"
}
```

#### 参考: CloudFormationでの記述例

```yml
Resources:
  Example:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: !Sub tmp-${AWS::Region}-${AWS::AccountId}
```

### 3.5 モジュール

モジュールは再利用可能なTerraformコードのパッケージです。

```hcl
module "s3_bucket" {
  source = "./modules/s3"
  
  bucket_name = "my-bucket"
  versioning_enabled = true
}
```

モジュールの構造:
```
modules/
└── s3/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    └── README.md
```

### 3.6 ステートファイル

Terraformは実際に作成したリソースの状態を「tfstate」というファイルに保存します。名の通りterraformで管理するリソースの状態を記録します。

ステートファイルの内容:

- 作成したリソースの詳細情報
- リソース間の依存関係
- メタデータ（Terraformのバージョンなど）

ステート管理の重要性:

- 状態の共有（チーム開発）
- 状態のロック（競合防止）
- 状態のバックアップ（リカバリ）

## 4. Terraformのワークフロー

Terraformの基本的なワークフローは以下の4つのステップで構成されます。

### 4.1 init - 初期化

```bash
terraform init
```

- プロバイダーのプラグインをダウンロード
- バックエンドを初期化
- モジュールをダウンロード

### 4.2 plan - 実行計画の作成

```bash
terraform plan
```

- 現在の状態と定義の差分を表示
- 何が追加/変更/削除されるかを確認
- 実行計画を保存することも可能（`-out` オプション）

### 4.3 apply - 適用

```bash
terraform apply
```

- 実行計画に基づいてリソースを作成/変更/削除
- 実行前に確認プロンプトを表示（`-auto-approve` オプションでスキップ可能）
- 状態ファイルを更新

### 4.4 destroy - 削除

```bash
terraform destroy
```

- 管理されているすべてのリソースを削除
- 実行前に確認プロンプトを表示

### 4.5 その他の有用なコマンド

- **validate**: 構文チェック
- **fmt**: コード整形
- **state**: 状態ファイルの操作
- **import**: 既存リソースのインポート
- **refresh**: 状態の更新
- **graph**: 依存関係グラフの生成

## 5. HCL (HashiCorp Configuration Language)

TerraformはHCLという独自の言語を使用します。HCLはJSON互換でありながら、より読みやすく書きやすい構文を提供します。

### 5.1 基本構文

```hcl
# コメント
resource_type "resource_name" "resource_label" {
  attribute1 = "value1"
  attribute2 = 123
  
  nested_block {
    nested_attribute = true
  }
}
```

### 5.2 式と関数

```hcl
locals {
  common_tags = {
    Project = "Terraform Demo"
    Owner   = "Infrastructure Team"
  }
}

resource "aws_s3_bucket" "example" {
  bucket = "example-${var.environment}-${random_id.suffix.hex}"
  
  tags = merge(local.common_tags, {
    Name = "Example Bucket"
    Environment = var.environment
  })
}
```

よく使われる関数:

- **format**: 文字列フォーマット
- **join**: リストを文字列に結合
- **merge**: マップの結合
- **concat**: リストの結合
- **element**: リストから要素を取得
- **file**: ファイルの内容を読み込み

### 5.3 条件式

```hcl
resource "aws_s3_bucket_versioning" "example" {
  bucket = aws_s3_bucket.example.id
  
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Disabled"
  }
}
```

### 5.4 ループ

```hcl
# count を使用したループ
resource "aws_iam_user" "example" {
  count = length(var.user_names)
  name  = var.user_names[count.index]
}

# for_each を使用したループ
resource "aws_iam_user" "example" {
  for_each = toset(var.user_names)
  name     = each.key
}
```

## 6. このハンズオンで学ぶこと

このハンズオンでは、以下のTerraformの基本的な機能と概念を学びます：

1. **Terraformの基本的な使い方**: init, plan, apply, destroyワークフロー
2. **AWS上でのリソース定義**: S3バケットとIAMリソースの作成
3. **リモートバックエンド**: S3バケットでのステート管理
4. **モジュール化**: コードの再利用と構造化
5. **高度な機能**: ローカル変数、ループ、条件式など

### 6.1 ハンズオンで作成するリソース

- **S3バケット**: ファイル保存用のバケット
- **IAMユーザー**: S3アクセス用のユーザー
- **IAMポリシー**: S3バケットへのアクセス権限を定義

### 6.2 ハンズオンのステップ

1. **Step 0**: Terraformの基本（現在のステップ）
2. **Step 1**: プロバイダー定義とTerraform initの実行
3. **Step 2**: リソース定義とapplyの実行
4. **Step 3**: tfstateのリモート管理
5. **Step 4**: モジュール化
6. **Step 5**: 高度な機能（ローカル変数、ループなど）

次のステップでは、実際にTerraformコードを書き始めます。
