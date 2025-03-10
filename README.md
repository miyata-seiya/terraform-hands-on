# Terraformハンズオン

Terraformに触ってみようと言う趣旨で軽いハンズオンを行います。

## 想定読者・対象者

* 主にAWSを業務で利用している。
* AWSを利用する際はCloudFormationを利用しており、IaCの概念は多少なりとも理解がある。
* Terraformと言う言葉は聞いたことがあり、どんなツールかも知っているが使ったことはない。

## ハンズオンでやること

* Terraformを使ってみると言う最初のハードルをみんなで超える。
* IaCの概念が多少わかっていればツールが変わったくらいで難しいことはそんなにないと理解する。

## ハンズオンでやらないこと

Terraformに関する詳しい説明。

## 注意事項

社内環境に依存した部分は別途説明します。

## 初回環境構築手順

1. 任意のディレクトリにgit cloneを行う。
1. cloneしたrepositoryをVS Codeで開く。
1. 開いた際に「フォルダーに開発コンテナーの構成ファイルが含まれています。 コンテナーで開発するフォルダーをもう一度開きます ([詳細情報](https://aka.ms/vscode-remote/docker))。」と表示されるので、「コンテナーで再度開く」を押下しコンテナで開き直す。
   * サジェストが出ない、見逃した場合は`⌘ + P`でコマンドパレットを開き `>Dev Containers: Reopen in Container` を入力して実行コマンドを選択する。
