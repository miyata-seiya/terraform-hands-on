# Step 1: プロバイダー定義とTerraform initの実行

このステップでは、Terraformプロジェクトを初期化し、AWSプロバイダーを設定します。Terraformプロジェクトの最初のステップは、必要なプロバイダーの設定と初期化です。

## 1. Terraformプロジェクトの構造

Terraformプロジェクトは、通常、複数の`.tf`ファイルで構成されます。各ファイルは特定の目的を持っていますが、Terraformはディレクトリ内のすべての`.tf`ファイルを一つの設定として扱います。

一般的なファイル構造:

- `main.tf`: 主要なリソース定義
- `variables.tf`: 入力変数の定義
- `outputs.tf`: 出力値の定義
- `providers.tf`: プロバイダー設定
- `terraform.tf`: Terraform自体の設定（バージョン制約など）
- `backend.tf`: 状態管理の設定

このステップでは、まず`main.tf`ファイルを作成し、基本的なプロバイダー設定を定義します。

## 2. ワーキングディレクトリの変更

まず、カレントディレクトリを作業用ディレクトリに変更します。

```bash
cd src/
```

## 3. プロバイダーの定義

`main.tf`ファイルを作成し、AWS プロバイダーを定義します。

```bash
touch main.tf
```

`main.tf`に以下の内容を記述してください：

```hcl
terraform {
  required_version = "v1.10.5"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.90.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region  = "ap-northeast-1"
  profile = "リソースデプロイ先AWSアカウントのProfileを指定してください。"
}
```

この設定により以下のことが定義されます：

- Terraformブロック
  - **required_version**: Terraformのバージョン要件（1.10.5）を指定
  - **required_providers**: 使用するプロバイダーとそのバージョンを指定
    - **source**: プロバイダーのソース（通常は`「組織名/プロバイダー名」`の形式）
    - **version**: プロバイダーのバージョン要件
- プロバイダーブロック
  - **region**: AWSリージョンを東京（ap-northeast-1）に設定
  - **profile**: AWS CLIのプロファイル名（`~/.aws/credentials`に定義されている）

### 3.3 プロバイダー設定オプション

AWSプロバイダーには、以下のような様々な設定オプションがあります：

```hcl
provider "aws" {
  region                   = "ap-northeast-1"
  profile                  = "my-profile"
  # または
  access_key               = "AKIAxxxxxxxxxEXAMPLE"
  secret_key               = "wJalrxxxxxxxxxxxxxxxxxxxxxEXAMPLEKEY"
  # その他のオプション
  max_retries              = 5
  allowed_account_ids      = ["123456789012"]
  forbidden_account_ids    = ["987654321098"]
  assume_role {
    role_arn               = "arn:aws:iam::123456789012:role/TerraformRole"
    session_name           = "terraform-session"
    external_id            = "terraform-external-id"
  }
  default_tags {
    tags = {
      ManagedBy            = "Terraform"
      Environment          = "Development"
    }
  }
}
```

### 3.4 参考: プロバイダー情報について

Terraform Registryにプロバイダーのドキュメントが公開されています。  
AWSプロバイダーの詳細については、以下のリンクを参照してください：

[Docs overview \| hashicorp/aws \| Terraform \| Terraform Registry](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

## 4. terraform init の実行

プロジェクトを初期化するために `terraform init` コマンドを実行します：

```bash
terraform init
```

### 4.1 initコマンドの動作

`terraform init`コマンドは以下の処理を行います：

1. **プロバイダーのダウンロード**: 必要なプロバイダープラグインをダウンロードし、`.terraform/providers`ディレクトリに保存します
2. **バックエンドの初期化**: 状態ファイルの保存先を設定します（デフォルトでは、ローカルの`terraform.tfstate`ファイル）
3. **モジュールのダウンロード**: 使用するモジュールをダウンロードし、`.terraform/modules`ディレクトリに保存します
4. **ロックファイルの作成**: プロバイダーとモジュールのバージョンを記録した`.terraform.lock.hcl`を作成または更新します

### 4.2 init成功時のメッセージ

成功すると次のようなメッセージが表示されます：

```
$ terraform init
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/aws versions matching "5.90.0"...
- Installing hashicorp/aws v5.90.0...
- Installed hashicorp/aws v5.90.0 (signed by HashiCorp)
Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

## 5. 初期化の確認

`.terraform` ディレクトリが作成されていることを確認しましょう：

```bash
ls -la
```

出力例：
```
total 24
drwxr-xr-x   5 user  group   160 Mar 10 10:00 .
drwxr-xr-x  10 user  group   320 Mar 10 09:55 ..
drwxr-xr-x   3 user  group    96 Mar 10 10:00 .terraform
-rw-r--r--   1 user  group  1720 Mar 10 10:00 .terraform.lock.hcl
-rw-r--r--   1 user  group   229 Mar 10 09:58 main.tf
```

`.terraform/providers` ディレクトリにダウンロードされたプロバイダーがあることを確認します：

```bash
find .terraform -type f | grep aws
```

出力例：

```
.terraform/providers/registry.terraform.io/hashicorp/aws/5.90.0/darwin_amd64/terraform-provider-aws_v5.90.0_x5
```

## 6. プロバイダーのバージョン確認

プロバイダーのバージョンを確認するには：

```bash
terraform version
```

出力例：
```
Terraform v1.10.5
on darwin_amd64
+ provider registry.terraform.io/hashicorp/aws v5.90.0
```

## 7. .terraform.lock.hcl ファイルの理解

`.terraform.lock.hcl`ファイルは、Terraformが使用するプロバイダーとモジュールのバージョンを記録するためのロックファイルです。これにより、チーム全体が同じバージョンのプロバイダーを使用できます。

```bash
cat .terraform.lock.hcl
```

出力例：

```hcl
# This file is maintained automatically by "terraform init".
# Manual edits may be lost in future updates.

provider "registry.terraform.io/hashicorp/aws" {
  version     = "5.90.0"
  constraints = "5.90.0"
  hashes = [
    "h1:...",
    "zh:..."
  ]
}
```

このファイルはバージョン管理システム（Git）にコミットすることで、チーム内での一貫性を確保できます。

## 8. ポイント

- `terraform init` はプロジェクトディレクトリで一度だけ実行する必要があります
- プロバイダーの追加や変更、バックエンド設定の変更時には再度 `init` を実行する必要があります
- `.terraform` ディレクトリはGitなどのバージョン管理から除外すべきです（`.gitignore` に追加）
- `.terraform.lock.hcl` ファイルはバージョン管理に含めることが推奨されます（チーム間で同じバージョンのプロバイダーを使用するため）

次のステップでは、実際にAWSリソース（S3バケット、IAMロール、ポリシー、ユーザー）を定義します。
