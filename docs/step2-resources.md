# Step 2: リソース定義とapplyの実行

このステップでは、S3バケット、IAMユーザー、IAMポリシーなどのAWSリソースをTerraformで定義し、実際にクラウド上にプロビジョニングします。

## 1. AWSリソースのライフサイクル

Terraformで管理するAWSリソースには、以下のようなライフサイクルがあります：

1. **定義**: `.tf`ファイルにリソースの構成を記述
2. **計画**: `terraform plan`で変更内容を確認
3. **作成**: `terraform apply`でリソースを作成
4. **更新**: 構成を変更して`terraform apply`で更新
5. **破棄**: `terraform destroy`でリソースを削除

各リソースは一意の識別子（`resource_type.resource_name`）を持ち、Terraformはこれを使って状態を追跡します。

## 2. ワーキングディレクトリの変更

まず、カレントディレクトリを作業用ディレクトリに変更します。
Step1から続けて実施する場合はスキップしてください。

```bash
cd src/
```

## 3. リソース定義の基本構文

Terraformでリソースを定義する基本構文は以下の通りです：

```hcl
resource "タイプ" "名前" {
  属性1 = 値1
  属性2 = 値2
  
  ネストされたブロック {
    ネストされた属性 = 値
  }
}
```

- **タイプ**: リソースの種類（例: `aws_s3_bucket`）
- **名前**: リソースの識別子（同じタイプの他のリソースと区別するための名前）
- **属性**: リソースの設定値
- **ネストされたブロック**: 階層構造を持つ設定

## 4. ランダム値の生成

S3バケット名はAWS全体で一意である必要があります。一意の識別子を生成するために、`random_id`リソースを使用します。

`main.tf`に以下の内容を追記してください：

```hcl
# S3バケットのユニーク名を作成するためのランダム文字列を生成
resource "random_id" "suffix" {
  keepers = {
    "name" = "seed値として自身の名前を記入してください"
  }
  byte_length = 8
}
```

### 4.1 `random_id`リソースの解説

- **keepers**: このマップの値が変更されると、新しいIDが生成されます
- **byte_length**: 生成されるランダムID（バイト単位）の長さ
- **結果の参照**: `random_id.suffix.hex`（16進数）または`random_id.suffix.dec`（10進数）

### 4.2 `random`プロバイダーの追加

`random_id`リソースを使用するには、`random`プロバイダーを追加する必要があります。`main.tf`の`terraform`ブロックを次のように修正します：

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

## 5. 現在のAWSアカウント情報の取得

現在使用しているAWSアカウント情報を取得するために、`aws_caller_identity`データソースを追加します：

```hcl
data "aws_caller_identity" "this" {}
```

データソースは`data`ブロックで定義し、既存のリソースの情報を取得するために使用します。`aws_caller_identity`は現在の認証情報のアカウントID、ユーザーIDなどを提供します。

## 6. S3バケットの定義

次に、S3バケットリソースを定義します。`main.tf`に以下の内容を追記してください：

```hcl
# S3バケットの定義
resource "aws_s3_bucket" "example" {
  bucket = "terraform-handson-${random_id.suffix.hex}"

  tags = {
    Name        = "Terraform Handson Bucket"
    Environment = "Training"
    # 誰が作ったか分からなくなるので自身の名前を記入してください。
    CreatedBy   = "your-name"
  }
}
```

## 7. IAMリソースの定義

次に、IAMユーザー、ポリシー、ポリシーアタッチメントを定義します。`main.tf`に以下の内容を追記してください：

```hcl
# IAMユーザーの作成
resource "aws_iam_user" "s3_user" {
  name = "terraform-handson-s3-user-${random_id.suffix.hex}"
  
  tags = {
    Description = "User for S3 access"
    # 誰が作ったか分かりづらくなるので自身の名前を記入してください。
    CreatedBy   = "your-name"
  }
}

# IAMポリシーの作成
resource "aws_iam_policy" "s3_access" {
  name        = "terraform-handson-s3-access-policy-${random_id.suffix.hex}"
  description = "Policy allowing access to our handson S3 bucket"
  
  policy = data.aws_iam_policy_document.s3_access_policy.json

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
  #         "${aws_s3_bucket.example.arn}"
  #         "${aws_s3_bucket.example.arn}/*"
  #       ]
  #     }
  #   ]
  # })
}

# IAMポリシードキュメントの定義
data "aws_iam_policy_document" "s3_access_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:Get*",
      "s3:List*",
      "s3:PutObject",
      "s3:AbortMultipartUpload"
    ]
    resources = [
      "${aws_s3_bucket.example.arn}",
      "${aws_s3_bucket.example.arn}/*"
    ]
  }
}

# IAMポリシーをユーザーにアタッチ
resource "aws_iam_user_policy_attachment" "s3_user_attach" {
  user       = aws_iam_user.s3_user.name
  policy_arn = aws_iam_policy.s3_access.arn
}

# アクセスキーの作成（注：本番環境では推奨されません）
resource "aws_iam_access_key" "s3_user_key" {
  user = aws_iam_user.s3_user.name
}
```

## 8. 出力値の定義

作成したリソースの重要な情報を出力するために、出力値を定義します。`main.tf`に以下の内容を追記してください：

```hcl
output "bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.example.bucket
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.example.arn
}

output "iam_user_name" {
  description = "The name of the IAM user"
  value       = aws_iam_user.s3_user.name
}

# IAMアクセスキーIDの出力
# CAUTION!!! Terraformの体験を優先するためアクセスキーを出力していますが、通常はやってはいけません。
# ハンズオン完了後、リソース削除を忘れないようにしましょう。
output "accesskey_id" {
  value = aws_iam_access_key.s3_user_key.id
}

# IAMアクセスキーシークレットの出力
# CAUTION!!! Terraformの体験を優先するためアクセスキーを出力していますが、通常はやってはいけません。
# ハンズオン完了後、リソース削除を忘れないようにしましょう。
output "accesskey_secret" {
  value     = aws_iam_access_key.s3_user_key.secret
  sensitive = true
}
```

### 8.1 出力値の構造

出力値は以下の構造を持ちます：

- **description**: 出力値の説明（省略可能）
- **value**: 出力する値
- **sensitive**: 機密情報かどうか（trueの場合、コンソールで値が隠されます）
- **depends_on**: 明示的な依存関係（省略可能）

### 8.2 出力値の用途

出力値は以下のような用途があります：

- リソースの重要な情報をコンソールに表示
- モジュールから値を返す
- リモート状態を通じて他のTerraformプロジェクトと値を共有
- 外部スクリプトやツールに値を提供

## 9. Terraformコマンドの実行

リソースを定義したら、次のTerraformコマンドを順に実行します。

### 9.1 初期化

プロジェクトを初期化します：

```bash
terraform init
```

このコマンドは以下のことを行います：

- `random`プロバイダーをダウンロード
- `.terraform`ディレクトリとプラグインを更新
- `.terraform.lock.hcl`ファイルを更新

### 9.2 コードフォーマット

コードを標準的なフォーマットに整形します：

```bash
terraform fmt
```

これにより、インデントやスペースなどが自動的に調整されます。チームで一貫したコードスタイルを維持するのに役立ちます。

### 9.3 検証

シンタックスと構造の検証を行います：

```bash
terraform validate
```

このコマンドは以下のチェックを行います：

- HCL構文が正しいか
- リソース属性が有効か
- 必須属性が欠けていないか
- 参照が有効か

検証に成功すると、以下のメッセージが表示されます：

```
Success! The configuration is valid.
```

### 9.4 実行計画の確認

実行計画を表示して、何が作成/変更/削除されるかを確認します：

```bash
terraform plan
```

出力例：
```
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # random_id.suffix will be created
  + resource "random_id" "suffix" {
      + b64_std     = (known after apply)
      + b64_url     = (known after apply)
      + byte_length = 8
      + dec         = (known after apply)
      + hex         = (known after apply)
      + id          = (known after apply)
      + keepers     = {
          + "name" = "seed値として自身の名前を記入してください"
        }
    }

  # aws_s3_bucket.example will be created
  + resource "aws_s3_bucket" "example" {
      + bucket                      = (known after apply)
      + bucket_domain_name          = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + id                          = (known after apply)
      + tags                        = {
          + "CreatedBy"   = "your-name"
          + "Environment" = "Training"
          + "Name"        = "Terraform Handson Bucket"
        }
      + tags_all                    = {
          + "CreatedBy"   = "your-name"
          + "Environment" = "Training"
          + "Name"        = "Terraform Handson Bucket"
        }
    }

  # ... 他のリソース ...

Plan: 5 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + accesskey_id     = (known after apply)
  + accesskey_secret = (sensitive value)
  + bucket_arn       = (known after apply)
  + bucket_name      = (known after apply)
  + iam_user_name    = (known after apply)
```

### 9.5 リソースの作成

計画を確認した後、リソースを作成します：

```bash
terraform apply
```

このコマンドを実行すると、実行計画が表示され確認を求められます。内容を確認した後、`yes`を入力して実行します。

```
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes
```

すべてのリソースが正常に作成されると、以下のようなメッセージが表示されます：

```
Apply complete! Resources: 5 added, 0 changed, 0 destroyed.

Outputs:

accesskey_id = "AKIAXXXXXXXXXXXXXXXX"
accesskey_secret = <sensitive>
bucket_arn = "arn:aws:s3:::terraform-handson-abcdef1234567890"
bucket_name = "terraform-handson-abcdef1234567890"
iam_user_name = "terraform-handson-s3-user-abcdef1234567890"
```

## 10. リソースの確認

AWSコンソールにログインして、以下のリソースが作成されたことを確認します：

1. **S3バケット**: S3コンソールで`terraform-handson-[ランダム文字列]`という名前のバケットを確認
2. **IAMユーザー**: IAMコンソールで`terraform-handson-s3-user-[ランダム文字列]`という名前のユーザーを確認
3. **IAMポリシー**: IAMコンソールで`terraform-handson-s3-access-policy-[ランダム文字列]`という名前のポリシーを確認

また、Terraformの出力値を確認します：

```bash
terraform output
```

出力例：
```
accesskey_id = "AKIAXXXXXXXXXXXXXXXX"
accesskey_secret = <sensitive>
bucket_arn = "arn:aws:s3:::terraform-handson-abcdef1234567890"
bucket_name = "terraform-handson-abcdef1234567890"
iam_user_name = "terraform-handson-s3-user-abcdef1234567890"
```

シークレットキーを確認するには：

```bash
terraform output -raw accesskey_secret
```

## 11. S3バケットの操作確認

作成したIAMユーザーのアクセスキーを使って、AWS CLIでS3バケットにアクセスできることを確認します。

### 11.1 AWS CLI プロファイルの設定

```bash
cat << EOS >> ~/.aws/credentials

[handson-sample]
aws_access_key_id = <accesskey_id>
aws_secret_access_key = <accesskey_secret>
EOS
```

```bash
cat << EOS >> ~/.aws/config

[profile handson-sample]
output = json
region = ap-northeast-1
EOS
```

### 11.2 S3操作の確認

バケットの一覧表示：
```bash
aws --profile handson-sample s3 ls
```

出力例：
```
2023-03-10 06:37:08 terraform-handson-abcdef1234567890
```

ファイルのアップロード：
```bash
echo "sample" > sample.txt
aws --profile handson-sample s3 cp sample.txt s3://terraform-handson-abcdef1234567890/
```

出力例：
```
upload: ./sample.txt to s3://terraform-handson-abcdef1234567890/sample.txt
```

バケット内のファイル一覧：
```bash
aws --profile handson-sample s3 ls terraform-handson-abcdef1234567890
```

出力例：
```
2023-03-10 06:43:53          7 sample.txt
```

## 12. ステートファイルの理解

Terraformは、作成したリソースの状態を`terraform.tfstate`というJSONファイルに保存します。

```bash
cat terraform.tfstate
```

このファイルには、作成されたすべてのリソースの詳細情報が記録されています：

- リソースの種類
- リソースの識別子
- リソースの属性（ARN、名前、ID、タグなど）
- 依存関係
- メタデータ

### 12.1 状態ファイルの重要性

状態ファイルは以下の役割を持ちます：

- リソースの現在の状態を追跡
- リソース間の依存関係を管理
- 再適用時の差分検出の基準
- リモート状態での共有と同期

### 12.2 状態ファイルのセキュリティ

状態ファイルにはシークレット（アクセスキーなど）が含まれる場合があるため、セキュリティ上の考慮が必要です：

- バージョン管理にコミットしない
- リモート状態を暗号化して保存
- アクセス制御を設定

次のステップでは、このステートファイルをリモートに保存する方法を学びます。
