# Step 2: リソース定義とapplyの実行

このステップでは、ハンズオンで利用する各種リソースを定義します。

## 1. ワーキングディレクトリの変更

まず、カレントディレクトリを作業用ディレクトリに変更します。
Step1から続けて実施する場合はスキップしてください。

```bash
cd src/
```

## 2. S3バケットを定義

`main.tf`ファイルを作成し、S3バケットリソースを定義します。  
Step1から続けて実施している場合はすでに存在するはずです。

```bash
touch main.tf
```

`main.tf`に以下の内容を記述してください：

```hcl
# S3バケットのユニーク名を作成するためのランダム文字列を生成
resource "random_id" "suffix" {
  keepers = {
    "name" = "your-name"
  }
  byte_length = 8
}

# S3バケットの定義
resource "aws_s3_bucket" "example" {
  bucket = "terraform-handson-${random_id.suffix.result.hex}"

  tags = {
    Name        = "Terraform Handson Bucket"
    Environment = "Training"
    # 誰が作ったか分かりづらくなるので自身の名前を記入してください。
    CreatedBy   = "your-name"
  }
}
```

## 3. IAMリソースを定義

`main.tf`ファイルに追記する形で、IAMリソースを定義します。

`main.tf`に以下の内容を記述してください：

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

## 4. 出力値を定義

`main.tf`ファイルに追記する形で、出力値を定義します。

`main.tf`に以下の内容を記述してください：

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

## 5. プロバイダー設定の修正

`random_id`リソースを使用するので、`providers.tf`を更新して`random`プロバイダーを追加します：

```diff
terraform {
  required_version = "v1.10.5"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.90.0"
    }
+   random = {
+     source  = "hashicorp/random"
+     version = "3.6.3"
+   }
  }
}

provider "aws" {
  region = "ap-northeast-1"  # 東京リージョン
}
```

## 6. Terraformコマンドの実行

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

実行計画を確認します：

```bash
terraform plan
```

リソースを作成します：

```bash
terraform apply
```

`terraform apply`コマンドを実行すると、実行計画が表示され確認を求められます。内容を確認した後、`yes`を入力して実行します。

出力例：
```
Plan: 7 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + bucket_arn          = (known after apply)
  + bucket_name         = (known after apply)
  + iam_access_key_id   = (known after apply)
  + iam_access_key_secret = (sensitive value)
  + iam_user_name       = "terraform-handson-s3-user"

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes
```

## 7. リソースの確認

AWSコンソールにログインして、以下のリソースが作成されたことを確認します：

1. S3バケット（`terraform-handson-[ランダム文字列]`という名前）
2. IAMユーザー（`terraform-handson-s3-user-[ランダム文字列]`という名前）

また、Terraformの出力値を確認します：

```bash
terraform output
```

シークレットキーを確認するには：

```bash
terraform output -raw accesskey_secret
```

### 参考: 作成したS3バケットの操作検証

以下のコマンドで作成したIAMユーザーのアクセスキーを特定し、AWS CLIのprofileを追加する。

```sh
terraform output -raw accesskey_id
terraform output -raw accesskey_secret
```

※コンテナ側は`~/.aws`のファイルに対してread only属性を設定しているためローカル側で編集する必要があります。

```sh
cat << EOS >> ~/.aws/credentials

[handson-sample]
aws_access_key_id = <accesskey_id>
aws_secret_access_key = <accesskey_secret>
EOS
```

```sh
cat << EOS >> ~/.aws/config

[profile handson-sample]
output = json
region = ap-northeast-1
EOS
```

```sh
$ aws --profile handson-sample s3 ls
2025-03-10 06:37:08 terraform-handson-<ランダム文字列>
$ aws --profile handson-sample s3 ls terraform-handson-<ランダム文字列>
$ echo "sample" > sample.txt
$ aws --profile handson-sample s3 cp sample.txt s3://terraform-handson-<ランダム文字列>/
upload: ./sample.txt to s3://terraform-handson-<ランダム文字列>/sample.txt
$ aws --profile handson-sample s3 ls terraform-handson-<ランダム文字列>
2025-03-10 06:43:53          7 sample.txt
```

## 8. ステートファイルの確認

Terraformが作成したステートファイルを確認します：

```bash
cat terraform.tfstate
```

このファイルには、作成されたすべてのリソースの詳細が記録されています。このステートファイルはTerraformが既存のインフラと定義の差分を検出するために使用されます。

次のステップでは、このステートファイルをリモートに保存する方法を学びます。
