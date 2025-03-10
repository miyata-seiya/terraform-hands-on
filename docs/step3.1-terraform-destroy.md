# Step 3.1: リソースの削除

Step4では新規にリソースを作成するため、ここまでに作成したリソースを削除します。

## 1. ワーキングディレクトリの変更

まず、カレントディレクトリを作業用ディレクトリに変更します。
Step3から続けて実施する場合はスキップしてください。

```bash
cd src/
```

## 2. バケット内のファイル削除

作成したS3バケットの中身を削除してください。  
Step2を実施していた場合、`sample.txt`が存在するはずです。  

## 3. リソースの削除

以下のコマンドを実行してリソースを削除します：

```bash
terraform destroy
```

このコマンドを実行すると、Terraformは削除対象リソースを列挙します：

```
Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: 
```

ここで`yes`と入力すると、削除が実行されます。
