# Step 2.1: リソースIDの命名規則

このステップでは、リソースIDの命名についてベストプラクティスを紹介します。

## 1. 命名の考え方

* [Style Guide \- Configuration Language \| Terraform \| HashiCorp Developer](https://developer.hashicorp.com/terraform/language/style#resource-naming)
* [一般的なスタイルと構造に関するベスト プラクティス  \|  Terraform  \|  Google Cloud](https://cloud.google.com/docs/terraform/best-practices/general-style-structure?hl=ja#naming-convention)

## 2. 既存リソースIDの確認

下記コマンドで定義済みリソースを確認します。  
`<resource_type>.<resource_id>`の形式でリソースが列挙されます。

```sh
$ terraform state list
data.aws_caller_identity.this
data.aws_iam_policy_document.s3_access_policy
aws_iam_access_key.s3_user_key
aws_iam_policy.s3_access
aws_iam_user.s3_user
aws_iam_user_policy_attachment.s3_user_attach
aws_s3_bucket.example
random_id.suffix
```

## 3. リソースIDの変更

ベストプラクティスに習って重複の無いリソースはリソースIDを`this`に変更します。

[一般的なスタイルと構造に関するベスト プラクティス  \|  Terraform  \|  Google Cloud](https://cloud.google.com/docs/terraform/best-practices/general-style-structure?hl=ja#naming-convention)

## 4. tfstateの更新

tfstateの内容とmain.tfとの内容に差が出てしまっているのでこれを修正します。

```hcl
terraform plan
```

```sh
terraform state mv -state=terraform.tfstate random_id.suffix random_id.this
terraform state mv -state=terraform.tfstate aws_s3_bucket.example aws_s3_bucket.this
terraform state mv -state=terraform.tfstate aws_iam_user.s3_user aws_iam_user.this
terraform state mv -state=terraform.tfstate aws_iam_policy.s3_access aws_iam_policy.this
terraform state mv -state=terraform.tfstate aws_iam_user_policy_attachment.s3_user_attach aws_iam_user_policy_attachment.this
terraform state mv -state=terraform.tfstate aws_iam_access_key.s3_user_key aws_iam_access_key.this
terraform state mv -state=terraform.tfstate data.aws_iam_policy_document.s3_access_policy data.aws_iam_policy_document.this
```

result

```sh
$ terraform state mv -state=terraform.tfstate random_id.suffix random_id.this
Move "random_id.suffix" to "random_id.this"
Successfully moved 1 object(s).
$ terraform state mv -state=terraform.tfstate aws_s3_bucket.example aws_s3_bucket.this
Move "aws_s3_bucket.example" to "aws_s3_bucket.this"
Successfully moved 1 object(s).
$ terraform state mv -state=terraform.tfstate aws_iam_user.s3_user aws_iam_user.this
Move "aws_iam_user.s3_user" to "aws_iam_user.this"
Successfully moved 1 object(s).
$ terraform state mv -state=terraform.tfstate aws_iam_policy.s3_access aws_iam_policy.this
Move "aws_iam_policy.s3_access" to "aws_iam_policy.this"
Successfully moved 1 object(s).
$ terraform state mv -state=terraform.tfstate aws_iam_user_policy_attachment.s3_user_attach aws_iam_user_policy_attachment.this
Move "aws_iam_user_policy_attachment.s3_user_attach" to "aws_iam_user_policy_attachment.this"
Successfully moved 1 object(s).
$ terraform state mv -state=terraform.tfstate aws_iam_access_key.s3_user_key aws_iam_access_key.this
Move "aws_iam_access_key.s3_user_key" to "aws_iam_access_key.this"
Successfully moved 1 object(s).
$ terraform state mv -state=terraform.tfstate data.aws_iam_policy_document.s3_access_policy data.aws_iam_policy_document.this
Move "data.aws_iam_policy_document.s3_access_policy" to "data.aws_iam_policy_document.this"
Successfully moved 1 object(s).
```

## 5. 変更後のリソースID確認

```sh
$ terraform state list
data.aws_caller_identity.this
data.aws_iam_policy_document.this
aws_iam_access_key.this
aws_iam_policy.this
aws_iam_user.this
aws_iam_user_policy_attachment.this
aws_s3_bucket.this
random_id.this
```
