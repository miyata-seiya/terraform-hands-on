# Step 3: tfstateのリモート管理

このステップでは、Terraformの状態ファイル（tfstate）をAWS S3バケットに保存するように設定します。  
リモートバックエンドを使用することで、チーム開発が容易になり、状態ファイルのバックアップと履歴管理が可能になります。

## 1. Terraformの状態管理とは

Terraformは、管理するインフラの現在の状態を「状態ファイル」（terraform.tfstate）に記録します。この状態ファイルは、Terraformがリソースを作成、更新、削除する際の基準となる重要なファイルです。

### 1.1 状態ファイルの役割

状態ファイルは以下の重要な役割を持っています：

- **リソースの追跡**: Terraformが管理するリソースと、それらの現在の設定を記録
- **メタデータの保存**: リソース間の依存関係などのメタデータを保存
- **パフォーマンスの向上**: リモートAPIコールを最小化するためのキャッシュとして機能
- **チーム連携の基盤**: 複数の人が同じインフラを管理するための共有状態を提供

### 1.2 ローカル状態管理の問題点

デフォルトでは、Terraformは状態をローカルファイル（terraform.tfstate）に保存します。これには以下の問題があります：

- **共有の難しさ**: チームで作業する場合、状態ファイルの共有と同期が難しい
- **同時実行の問題**: 複数の人が同時に変更を適用すると、状態ファイルが競合する可能性がある
- **機密情報のリスク**: 状態ファイルには機密情報（パスワード、APIキーなど）が含まれる場合がある
- **バックアップの不足**: ローカルファイルの紛失やバックアップの不足によるリスク

これらの問題を解決するために、リモートバックエンドを使用します。

## 2. リモートバックエンドとは

リモートバックエンドは、Terraformの状態ファイルをリモートストレージに保存するための仕組みです。Terraformは様々なバックエンドをサポートしていますが、AWS環境では一般的にS3バケットが使用されます。

### 2.1 リモートバックエンドの利点

- **チーム協業**: 複数のチームメンバーが同じ状態ファイルを共有できる
- **状態のロック**: DynamoDBなどを使用して、同時実行による競合を防止できる
- **バージョン管理**: S3のバージョニング機能により、状態ファイルの履歴を保持できる
- **セキュリティ**: 暗号化機能により、機密情報を保護できる
- **信頼性**: クラウドストレージのデータ耐久性により、データの紛失リスクを低減

### 2.2 サポートされるバックエンドタイプ

Terraformは多くのバックエンドタイプをサポートしています：

- **[S3](https://developer.hashicorp.com/terraform/language/backend/s3)**: AWS S3バケットを使用（本ハンズオンで使用）
- **[GCS](https://developer.hashicorp.com/terraform/language/backends/gcs)**: Google Cloud Storage
- **[Azure Blob](https://developer.hashicorp.com/terraform/language/backends/azurerm)**: Microsoft Azure Blob Storage
- **[Consul](https://developer.hashicorp.com/terraform/language/backends/consul)**: HashiCorp Consul
- etc

## 3. ワーキングディレクトリの変更

まず、カレントディレクトリを作業用ディレクトリに変更します。
Step2.2から続けて実施する場合はスキップしてください。

```bash
cd src/
```

## 4. バックエンド設定ファイルの作成

AWS S3をバックエンドとして使用するための設定を行います。
`backend.tf`ファイルを作成します：

```bash
touch backend.tf
```

`backend.tf`に以下の内容を記述してください（※ハンズオンの中で実際のバケット名、key値を別途指示します）：

```hcl
terraform {
  backend "s3" {
    # 指定のバケット名に置き換えてください
    bucket = "existing-terraform-state-bucket"
    # 指定のkey値に置き換えてください
    key    = "terraform-hands-on/<your-name>/terraform.tfstate"
    region = "ap-northeast-1"
    # 指定のprofile名に置き換えてください
    # profile = "リモートステート用S3バケットを指定してください。"
    # 以下はオプションですが、本番環境では推奨されます
    # encrypt = true
    # dynamodb_table = "terraform-state-lock"
  }
}
```

## 5. 状態ファイルの移行

バックエンド設定を変更した後、tfstateファイルをリモートバックエンドに移行する必要があります。

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

## 6. リモート状態の確認

### 6.1 AWSコンソールでの確認

AWSコンソールでS3バケットを確認し、指定したキーパス（`terraform-hands-on/<your-name>/terraform.tfstate`）に状態ファイルがアップロードされていることを確認します：

1. AWSコンソールにログイン
2. S3サービスに移動
3. バケット名をクリック
4. 指定したキーパスで状態ファイルを検索

### 6.2 ローカルファイルの確認

また、ローカルの`terraform.tfstate`ファイルが削除されていることも確認できます：

```bash
ls -la
```

移行前のバックアップとして`terraform.tfstate.backup`ファイルが残っていることがあります。

## 7. リソースの変更確認

`terraform plan`を実行して、リモート状態ファイルが正しく読み込まれていることを確認します：

```bash
terraform plan
```

出力に「No changes. Infrastructure is up-to-date.」と表示されれば、リモート状態ファイルが正しく読み込まれています。　　
これは、ローカルコードと現在のリモート状態の間に違いがないことを示しています。

## 8. リモートバックエンドの利点（詳細）

リモートバックエンドを使用することで得られる主な利点を詳しく見ていきましょう：

### 8.1 チーム協業の改善

- **共有状態**: すべてのチームメンバーが同じ状態ファイルを参照
- **一貫性**: どのメンバーがapplyを実行しても同じ状態を参照
- **透明性**: インフラの現在の状態をチーム全体で可視化

### 8.2 状態ファイルのロックと競合防止

S3バックエンドはDynamoDBと組み合わせることで、状態ファイルのロック機能を提供します：

```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket"
    key            = "terraform.tfstate"
    region         = "ap-northeast-1"
    dynamodb_table = "terraform-locks"
  }
}
```

DynamoDBテーブルは以下の属性を持つ必要があります：

- テーブル名: 任意（例: terraform-locks）
- プライマリキー: LockID（文字列型）

これにより、以下のメリットがあります：

- 同時実行によるステート破損の防止
- ロックの自動解放（タイムアウト）
- ロック状態の可視化と管理

### 8.3 状態ファイルのバージョン管理

S3のバージョニング機能を有効にすることで、状態ファイルの履歴を保持できます：

- 以前のバージョンへのロールバック
- 変更の監査証跡
- 事故や誤操作からの復旧

### 8.4 セキュリティの強化

- **暗号化**: S3のサーバーサイド暗号化（SSE）またはKMSを使用
- **アクセス制御**: IAMポリシーによる細かなアクセス制御
- **監査**: AWS CloudTrailによるアクセス監査

次のステップでは、作成したリソースを削除し、Step 4でのモジュール化に備えます。
