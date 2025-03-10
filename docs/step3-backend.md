# Step 3: tfstateのリモート管理

このステップでは、Terraformの状態ファイル（tfstate）をS3バケットに保存するように設定します。  
これにより、チーム開発が容易になり、状態ファイルのバックアップと履歴管理が可能になります。

## 1. ワーキングディレクトリの変更

まず、カレントディレクトリを作業用ディレクトリに変更します。
Step2.2から続けて実施する場合はスキップしてください。

```bash
cd src/
```

## 2. バックエンド設定ファイルの作成

`backend.tf`ファイルを作成します：

```bash
touch backend.tf
```

`backend.tf`に以下の内容を記述してください：
※ハンズオンの中で実際のバケット名、key値を別途指示します。

```hcl
terraform {
  backend "s3" {
    # 指定のバケット名に置き換えてください
    bucket = "existing-terraform-state-bucket"
    # 指定のkey値に置き換えてください
    key    = "terraform-hands-on/<your-name>/terraform.tfstate"
    region = "ap-northeast-1"
    # 指定のprofile名に置き換えてください
    # profile = ""
    # 以下はオプションですが、本番環境では推奨されます
    # encrypt = true
    # dynamodb_table = "terraform-state-lock"
  }
}
```

**注意**: 
- `existing-terraform-state-bucket`は実際に存在するS3バケット名に置き換えてください
- バケットは事前に作成されている必要があります
- ここで指定するバケットは、作成したリソースとは別のものです

## 4. 状態ファイルの移行

修正したファイルを保存し、以下のコマンドを実行して初期化します：

```bash
terraform init
```

このコマンドを実行すると、Terraformは以前のローカル状態ファイルからリモートバックエンドへの移行確認を求めます：

```
Initializing the backend...
Do you want to copy existing state to the new backend?
  Pre-existing state was found while migrating the previous "local" backend to the
  newly configured "s3" backend. No existing state was found in the newly
  configured "s3" backend. Do you want to copy this state to the new "s3"
  backend? Enter "yes" to copy and "no" to start with an empty state.

  Enter a value: 
```

ここで`yes`と入力すると、ローカルの状態がS3バケットにコピーされます。

## 5. リモート状態の確認

AWSコンソールでS3バケットを確認し、指定したキーパス（`terraform-hands-on/<your-name>/terraform.tfstate`）に状態ファイルがアップロードされていることを確認します。

また、ローカルの`terraform.tfstate`ファイルが削除されていることも確認できます：

```bash
ls -la
```

代わりに`terraform.tfstate.backup`ファイルが残っていることがあります。

## 6. リソースを確認

`terraform plan`を実行して、リモート状態ファイルが正しく読み込まれていることを確認します：

```bash
terraform plan
```

出力に「No changes. Infrastructure is up-to-date.」と表示されれば、リモート状態ファイルが正しく読み込まれています。

## 7. リモートバックエンドの利点

リモートバックエンドを使用する主な利点は以下の通りです：

1. **チーム協業**: 複数のチームメンバーが同じ状態ファイルを共有できます
2. **バックアップ**: S3のバージョニング機能により、状態ファイルの履歴を保持できます
3. **状態ロック**: DynamoDBと組み合わせることで、同時実行によるコンフリクトを防止できます
4. **セキュリティ**: 暗号化機能により、機密情報を保護できます

## 8. 完全なリモートバックエンド設定の例（参考）

本番環境では、以下のような完全なバックエンド設定が推奨されます：

```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "path/to/my/key"
    region         = "ap-northeast-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
    role_arn       = "arn:aws:iam::ACCOUNT_ID:role/TerraformStateRole"
  }
}
```

この設定では：
- `encrypt = true`: S3にアップロードされるファイルをSSE-S3で暗号化
- `dynamodb_table`: 状態ロック用のDynamoDBテーブル名
- `role_arn`: 状態ファイルへのアクセスに使用するIAMロール

次のステップでは、作成したリソースをモジュール化する方法を学びます。
