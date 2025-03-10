# Step 1: プロバイダー定義とTerraform initの実行

このステップでは、Terraformプロジェクトを初期化し、AWSプロバイダーを設定します。

## 1. ワーキングディレクトリの変更

まず、カレントディレクトリを作業用ディレクトリに変更します。

```bash
cd src/
```

## 2. プロバイダーの定義

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
  region = "ap-northeast-1"
}
```

この設定により：

- Terraformのバージョン要件（1.10.5以上）を指定
- AWS プロバイダーのバージョン要件（5.90.0）を指定
- AWS リージョンを東京（ap-northeast-1）に設定

### 参考: プロバイダー情報について

Terraform Registryにプロバイダーのドキュメントが公開されています。

[Docs overview \| hashicorp/aws \| Terraform \| Terraform Registry](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

## 3. terraform init の実行

プロジェクトを初期化するために `terraform init` コマンドを実行します：

```bash
terraform init
```

このコマンドは以下の処理を行います：
- 必要なプロバイダーをダウンロード
- `.terraform` ディレクトリを作成
- バックエンドを初期化

成功すると次のようなメッセージが表示されます：

```sh
vscode ➜ /workspaces/terraform-hands-on/src (step0-introduction) $ terraform init
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

`.terraform/providers` ディレクトリにダウンロードされたプロバイダーがあります：

```bash
find .terraform -type f | grep aws
```

## 6. プロバイダーのバージョン確認

プロバイダーのバージョンを確認するには：

```bash
terraform version
```

これにより、Terraformのバージョンとインストールされたプロバイダーのバージョンが表示されます。

## ポイント

- `terraform init` はプロジェクトディレクトリで一度だけ実行する必要があります
- プロバイダーの追加や変更、バックエンド設定の変更時には再度 `init` を実行する必要があります
- `.terraform` ディレクトリはGitなどのバージョン管理から除外すべきです（`.gitignore` に追加）
- `.terraform.lock.hcl` ファイルはバージョン管理に含めることが推奨されます（チーム間で同じバージョンのプロバイダーを使用するため）

次のステップでは、実際にAWSリソース（S3バケット、IAMロール、ポリシー、ユーザー）を定義します。
