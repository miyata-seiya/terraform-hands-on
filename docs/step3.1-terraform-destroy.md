# Step 3.1: リソースの削除

このステップでは、Step 4のモジュール化に進む前に、ここまでに作成したリソースを削除します。　　
Terraformでは`terraform destroy`コマンドを使用して、管理されているすべてのリソースを削除します。

## 1. ワーキングディレクトリの変更

まず、カレントディレクトリを作業用ディレクトリに変更します。
Step3から続けて実施する場合はスキップしてください。

```bash
cd src/
```

## 2. バケット内のファイル削除

S3バケットを削除する前に、そのバケット内のすべてのオブジェクト（ファイル）を削除する必要があります。Terraformは空でないS3バケットを自動的に削除できません。

Step2で`sample.txt`ファイルをアップロードした場合、以下のコマンドでバケット内のファイルをリストアップできます：

```bash
aws --profile handson-sample s3 ls s3://terraform-handson-${bucket_suffix}/
```

バケット内のすべてのファイルを削除するには：

```bash
aws --profile handson-sample s3 rm s3://terraform-handson-${bucket_suffix}/ --recursive
```

または、AWSコンソールからバケットの中身を確認して削除することもできます。

## 3. Terraform destroyの実行

すべてのリソースを削除するには、以下のコマンドを実行します：

```bash
terraform destroy
```

### 3.1 destroy実行計画の確認

`terraform destroy`コマンドを実行すると、まず削除されるリソースの一覧が表示されます：

```
Terraform will perform the following actions:

  # aws_iam_access_key.this will be destroyed
  - resource "aws_iam_access_key" "this" {
      - create_date          = "2023-03-10T06:37:08Z" -> null
      - id                   = "AKIAXXXXXXXXXXXXXXXX" -> null
      - secret               = (sensitive value) -> null
      - status               = "Active" -> null
      - user                 = "terraform-handson-s3-user-abcd1234" -> null
    }

  # aws_iam_policy.this will be destroyed
  - resource "aws_iam_policy" "this" {
      - arn         = "arn:aws:iam::123456789012:policy/terraform-handson-s3-access-policy-abcd1234" -> null
      - description = "Policy allowing access to our handson S3 bucket" -> null
      - id          = "arn:aws:iam::123456789012:policy/terraform-handson-s3-access-policy-abcd1234" -> null
      - name        = "terraform-handson-s3-access-policy-abcd1234" -> null
      - path        = "/" -> null
      - policy      = jsonencode(
            {
              Statement = [
                  {
                      Action   = [
                        "s3:Get*",
                        "s3:List*",
                        "s3:PutObject",
                        "s3:AbortMultipartUpload"
                      ]
                      Effect   = "Allow"
                      Resource = [
                        "arn:aws:s3:::terraform-handson-abcd1234",
                        "arn:aws:s3:::terraform-handson-abcd1234/*"
                      ]
                  }
              ]
              Version   = "2012-10-17"
          }
        ) -> null
    }

  # ... 他のリソース ...

Plan: 0 to add, 0 to change, 8 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: 
```

ここで`yes`と入力すると、削除が実行されます。

### 3.2 destroy処理の実行

確認入力後、Terraformは以下のような順序でリソースを削除します：

1. 依存関係があるリソースから先に削除（例: IAMポリシーアタッチメント）
2. 独立したリソース（例: S3バケット、IAMユーザー）
3. その他のリソース（例: ランダムID）

削除が完了すると、以下のようなメッセージが表示されます：

```
Destroy complete! Resources: 8 destroyed.
```

### 3.3 destroy時の依存関係

Terraformは、リソース間の依存関係を考慮して、正しい順序でリソースを削除します。これは、リソースの作成時と逆の順序になります。

例えば、以下のような依存関係がある場合：

1. S3バケット
2. S3バケットを参照するIAMポリシー
3. IAMポリシーがアタッチされたIAMユーザー

削除順序は以下のようになります：

1. IAMポリシーアタッチメント
2. IAMポリシー
3. IAMユーザー
4. S3バケット

これにより、依存関係エラー（例: 使用中のポリシーを削除しようとするなど）を防ぎます。

## 4. 削除の確認

リソースが正常に削除されたことを確認するために、以下の方法があります：

### 4.1 Terraform状態の確認

```bash
terraform state list
```

このコマンドを実行すると、Terraformの状態ファイルに残っているリソースがあればリストアップされますが、正常に削除された場合は何も表示されません（またはエラーが発生します）。

### 4.2 AWSコンソールでの確認

AWSコンソールにログインして、以下のリソースが削除されていることを確認します：

1. S3バケット（`terraform-handson-[ランダム文字列]`）
2. IAMユーザー（`terraform-handson-s3-user-[ランダム文字列]`）
3. IAMポリシー（`terraform-handson-s3-access-policy-[ランダム文字列]`）

## 5. 状態ファイルの管理

リソースを削除した後も、状態ファイルはS3バケットに残ります。これは、Terraformが内部的に使用するメタデータファイルであり、すべてのリソースが削除されても存在し続けます。  
ハンズオンが完全に終了したら、状態ファイル自体も削除して構いません。

次のステップでは、Terraformのモジュール化について学びます。  
モジュール化により、コードの再利用性と保守性が向上します。
