# Step 2.1: リソースIDの命名規則

このステップでは、リソースIDの命名についてベストプラクティスを紹介し、既存リソースの名前を変更する方法を学びます。  
リソースIDの命名は、Terraformコードの可読性、保守性、スケーラビリティに大きく影響します。

## 1. Terraformにおけるリソース識別子の理解

Terraformでは、各リソースは次の形式で識別されます：

```
resource "タイプ" "ID" { ... }
data "タイプ" "ID" { ... }
```

この「ID」はリソース識別子と呼ばれ、以下の用途があります：

- Terraformコード内でのリソース参照
- ステートファイル内での識別
- モジュール間での参照
- CIフローでのターゲット指定

例えば、`aws_s3_bucket.example`や`aws_iam_user.s3_user`などが挙げられます。

## 2. 命名の考え方とベストプラクティス

リソースIDの命名についていくつかの公式および業界のベストプラクティスがあります。

### 2.1 HashiCorp公式スタイルガイド

[Style Guide \- Configuration Language \| Terraform \| HashiCorp Developer](https://developer.hashicorp.com/terraform/language/style#resource-naming)によると：

- 複数の同様のリソースがある場合は、識別可能な特性に基づいた命名を使用する
- リソースタイプを繰り返さない（例: `aws_route_table.route_table`は避ける）
- スネークケース（小文字とアンダースコア）を使用する

### 2.2 Google Cloudのベストプラクティス

[一般的なスタイルと構造に関するベスト プラクティス  \|  Terraform  \|  Google Cloud](https://cloud.google.com/docs/terraform/best-practices/general-style-structure?hl=ja#naming-convention)によると：

- 命名規則にはスネークケースを使用する
- 単一リソースの場合、IDは「main」等を使用し簡略化する
- 複数のリソースがある場合は、関数または意図を示す修飾子を追加する

### 2.3 推奨される命名パターン

以下のようなパターンが広く採用されています：

1. **単一リソースパターン**:
   ```hcl
   resource "aws_s3_bucket" "this" { ... }
   resource "aws_iam_policy" "this" { ... }
   ```

2. **機能ベースのパターン**:
   ```hcl
   resource "aws_s3_bucket" "logs" { ... }
   resource "aws_s3_bucket" "data" { ... }
   ```

3. **環境ベースのパターン**:
   ```hcl
   resource "aws_s3_bucket" "dev" { ... }
   resource "aws_s3_bucket" "prod" { ... }
   ```

4. **複合パターン**:
   ```hcl
   resource "aws_s3_bucket" "logs_dev" { ... }
   resource "aws_s3_bucket" "logs_prod" { ... }
   ```

## 3. 既存リソースIDの確認

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

## 4. リソースIDの変更の必要性

現在のリソースIDにはいくつかの問題があります：

1. 一部のIDが説明的でない（`example`）
2. 他のIDはリソースタイプを繰り返している（`s3_user`）

ベストプラクティスに従って、これらのリソースIDを改善します。

## 5. リソースIDの変更方法

Terraformでリソースのプロパティを変更したり、新しいリソースを追加したりすることは簡単ですが、**リソースID自体を変更するとTerraformはそれを別のリソースとみなします**。  
これは、リソースIDがTerraformの状態ファイル内でリソースを識別するために使用されるからです。

リソースIDを変更するには、以下の2つの方法があります：

1. **コード変更後に再作成する**: コード内のリソースIDを変更し、`terraform apply`を実行する。これによりリソースが破棄されて再作成されます。
2. **状態の移動**: `terraform state mv`コマンドを使用して、状態ファイル内でリソースの参照を変更する（リソースそのものは再作成されない）。

今回は2番目の方法を使用します。

## 6. tfstateの更新

ベストプラクティスに習って重複の無いリソースはリソースIDを`this`に変更します。　　
`.tf`ファイルでリソースIDを変更した後、tfstateファイルも更新する必要があります。

`.tf`ファイルの修正後、現在の状態とコードの間に差があることを確認します：

```hcl
terraform plan
```

これを実行すると、リソースが再作成されるという警告が表示されるはずです。  
次に、各リソースの状態を移動します：

```sh
terraform state mv -state=terraform.tfstate random_id.suffix random_id.this
terraform state mv -state=terraform.tfstate aws_s3_bucket.example aws_s3_bucket.this
terraform state mv -state=terraform.tfstate aws_iam_user.s3_user aws_iam_user.this
terraform state mv -state=terraform.tfstate aws_iam_policy.s3_access aws_iam_policy.this
terraform state mv -state=terraform.tfstate aws_iam_user_policy_attachment.s3_user_attach aws_iam_user_policy_attachment.this
terraform state mv -state=terraform.tfstate aws_iam_access_key.s3_user_key aws_iam_access_key.this
terraform state mv -state=terraform.tfstate data.aws_iam_policy_document.s3_access_policy data.aws_iam_policy_document.this
```

### 6.1 `terraform state mv`コマンドの詳細

`terraform state mv`コマンドは、Terraformの状態ファイル内でリソースを移動するために使用されます。これにより、リソースを実際に破棄して再作成することなく、リソースIDを変更できます。

構文：
```
terraform state mv [options] SOURCE DESTINATION
```

- **SOURCE**: 移動元のリソースアドレス
- **DESTINATION**: 移動先のリソースアドレス
- **-state=PATH**: 使用する状態ファイルのパス
- **-state-out=PATH**: 出力先の状態ファイルのパス

### 6.2 実行結果

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

## 7. `.tf`ファイルの更新

状態ファイルを更新したら、`.tf`ファイルも更新して、新しいリソースIDを反映する必要があります。リソースIDの変更以外に、リソース間の参照も更新する必要があります。

例えば：

```hcl
# 変更前
resource "aws_s3_bucket" "example" {
  # ...
}

# 変更後
resource "aws_s3_bucket" "this" {
  # ...
}
```

そして、このリソースを参照しているすべての場所も更新します：

```hcl
# 変更前
resource "aws_iam_policy" "s3_access" {
  # ...
  policy = jsonencode({
    # ...
    Resource = "${aws_s3_bucket.example.arn}"
    # ...
  })
}

# 変更後
resource "aws_iam_policy" "this" {
  # ...
  policy = jsonencode({
    # ...
    Resource = "${aws_s3_bucket.this.arn}"
    # ...
  })
}
```

## 8. 変更後のリソースID確認

すべての変更が適用されたら、リソースIDが正しく更新されたことを確認します：

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

## 9. リソースID変更の利点

リソースIDを一貫したパターンに変更することで、以下のような利点があります：

1. **コードの一貫性**: すべてのリソースが同じ命名規則に従います
2. **可読性の向上**: リソースの役割が明確になります
3. **保守性の向上**: コードの変更が簡単になります
4. **スケーラビリティ**: 新しいリソースを追加する際のパターンが明確になります

## 10. さらなる改善の可能性

単一のリソースタイプが複数ある場合は、`for_each`または`count`を使用して、より簡潔で保守しやすいコードにすることを検討してください：

```hcl
# 変更前
resource "aws_s3_bucket" "logs" { ... }
resource "aws_s3_bucket" "data" { ... }
resource "aws_s3_bucket" "backup" { ... }

# 変更後
resource "aws_s3_bucket" "this" {
  for_each = {
    logs   = { ... },
    data   = { ... },
    backup = { ... }
  }
  
  bucket = "terraform-handson-${each.key}-${random_id.this.hex}"
  # ...
}
```

このようにすると、リソースIDは単一であっても、複数のリソースインスタンスを作成でき、コードの重複を減らすことができます。

次のステップでは、ファイル分割によってTerraformコードの構造をさらに改善します。
