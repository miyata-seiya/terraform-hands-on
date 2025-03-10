# Step 4: モジュール化

このステップでは、作成したS3バケットとIAMリソースをモジュール化して再利用可能にします。モジュール化することで、コードの再利用性と保守性が向上します。
※Step3を実施済みである想定で進行します。Step4から開始する場合は`samples/step3`のファイルを`src/`にコピーし、`backend.tf`を修正のうえ開始してください。

## 1. ワーキングディレクトリの変更

これまでとは別の作業ディレクトリにカレントディレクトリを変更します。

```bash
cd ../src2/
```

## 2. ファイルのコピー

コピペすると長いのでサンプルファイルをコピーして使用します。

```sh
cp -r ../samples/step4/* .
```

## 2. モジュールの作成

まず、S3バケットとIAMリソースを含むモジュールを作成します。

### 2.1 変数定義（modules/s3_with_iam/variables.tf）

モジュール内で使用する変数を定義します。  
定義した変数の値はmoduleを利用する際に設定します。

### 2.2 S3リソース定義（modules/s3_with_iam/s3.tf）

Step3までのリソース定義と相違する点について注目してください。

```hcl
resource "aws_s3_bucket" "this" {
  bucket = "${var.bucket_name_prefix}-${var.environment}-${random_string.bucket_suffix.result}"

  tags = merge(
    {
      Name        = "${var.bucket_name_prefix}-${var.environment}"
      Environment = var.environment
      CreatedBy   = "your-name"
    },
    var.tags
  )
}
```

### 2.3 IAMリソース定義（modules/s3_with_iam/iam.tf）

同上。

### 2.4 出力値の定義（modules/s3_with_iam/outputs.tf）

今回は1つのモジュールしか使用しないためoutput定義は特に重要ではありませんが、module間で値の受け渡しをする際にはoutputによる値の出力が必要になります。

## 3. 環境設定ファイルの作成

モジュールを使用する環境設定ファイルを作成します。

### 3.1 バックエンド設定（environments/development/backend.tf）

backet、key、profileを指示の通り変更してください。

## 3.3 モジュール呼び出し（environments/development/main.tf）

moduleブロックでモジュールを呼び出し、その際に`modules/s3_with_iam/variables.tf`で定義した変数に値を設定します。  
※default値が設定されているため設定は必須ではない。  

`bucket_name_prefix`を任意の値に変更してください。

```hcl
module "s3_with_iam" {
  source = "../../modules/s3_with_iam"
  
  bucket_name_prefix = "terraform-handson"
  environment        = "dev"
  iam_user_name      = "s3-access-user"
  
  tags = {
    Project     = "Terraform Handson"
    Owner       = "Infrastructure Team"
    CostCenter  = "123456"
  }
}
```

参考: [Modules \- Configuration Language \| Terraform \| HashiCorp Developer](https://developer.hashicorp.com/terraform/language/modules/syntax)

### 3.4 出力値の定義（environments/development/outputs.tf）

割愛。

## 4. 環境の作成

開発環境ディレクトリに移動し、モジュールを使用してリソースをデプロイします：

```bash
cd environments/development
terraform init
terraform plan
terraform apply
```

応答が求められたら`yes`と入力して続行します。

## 5. モジュールの再利用

別の環境（例：ステージング）用に同じモジュールを再利用することができます：

```bash
cd ../../environments/staging
```

`providers.tf`, `backend.tf`, `outputs.tf`を開発環境からコピーし、`backend.tf`内のキーパスを変更します：

```hcl
backend "s3" {
  bucket = "existing-terraform-state-bucket"
  key    = "terraform-hands-on/<your-name>/staging/terraform.tfstate"
  region = "ap-northeast-1"
}
```

`main.tf`を作成して環境固有の値を設定します：

```hcl
module "s3_with_iam" {
  source = "../../modules/s3_with_iam"
  
  bucket_name_prefix = "terraform-handson"
  environment        = "staging"
  iam_user_name      = "s3-access-user"
  
  tags = {
    Project     = "Terraform Handson"
    Owner       = "Infrastructure Team"
    CostCenter  = "123456"
  }
}
```

そして、同様にデプロイを行います：  
※今回は割愛します。

```bash
terraform init
terraform plan
terraform apply
```

## 6. モジュール化の利点

モジュール化には以下のような利点があります：

1. **コードの再利用**: 同じコードを複数の場所で使い回せます
2. **抽象化**: 詳細な実装を隠蔽し、シンプルなインターフェースを提供します
3. **標準化**: チーム全体で一貫したリソース構成を維持できます
4. **メンテナンス性**: 一箇所を変更するだけで、それを使用するすべての場所に変更が適用されます
5. **テスト**: モジュール単位でテストを行うことができます

次のステップでは、Terraformの高度な機能について学びます。
