Jenkins ユーザカンファレンス
========

### 基調講演
- 基調講演
- workflow周りの開発に力を入れている
- DotCI
- UI/UX変更
- Chef/Puppet tracback機能
- ファイルの指紋
- Dockerプラグイン

#### Workflow plugin


-------

### はてなにおける継続的デプロイメントの現状と Docker の導入

- 株式会社はてな 信岡 裕也

#### はてなのサービス開発
**Jenkinsの用途**

- テスト、静的ファイル作成等々で利用
- Mackerel
- ソフトウェア進化を継続するため
- テスト、ビルド、デプロイ
- 意識しなくてもテストを実行する自動化

**特にテスト**
- 開発時は各自のマシンで実施している
- Jenkinsで本番に近い環境でテスト実行
- 自動でテストを実行する。 
- Jenkinsの管理Chefで環境を構築
- 本番サーバもChefで構築

**基本方針**
Jenkinsの設定を複雑にしない

- Typescript -> JS -> minified JS
ビルドプロセスが必要

- LESS -> CSS
- ビルドプロセスが必要

- ビルドツール： gulp(node.js)
  - TS -> JS/LESS -> CSS
  - JSテスト
  - 静的ファイルにダイジェストハッシュ

- デプロイ：Capistrano 3
- バージョン管理：Git(中央はGithubEnterprise)
- チャット：Clack
- タスク管理：Trello
- 開発プロセス：２週間１スプリント
- リリースはほぼ毎週

- 開発中からPullReauestを出している

**Jenkinsの役割**

- Push のたびにライブラリ更新

**JenkinsのGithubPlugin**

- Server Hook
- Slack Integrations
- Slack NotificationPlugin

**Dockerの話**
- 開発サーバで複数アプリケーション起動
- 別ポートバングを使用
- ポート番号解決（NGINX）

**問題点**
- ライブラリ、ファイルシステム共有

**

DockerAPIを用いたポート番号解決を実施
gitclone
docker build
docker rm /docker runk

　　
　　
-------

### JenkinsとPuppet+ServerspecでインフラCI

- GMOペパボ株式会社 常松 伸哉 (@tnmt)


**継続的Webサービス改善ガイド**

**Puppet**

- すでにほぼ善ロールの構築に関してマニフェストかが完了
- 最初は大変
- 新規構築・機能追加における手間が大幅に軽減

**進め方**

- マニフェストのSyntaxエラーはないか？
- 仕様どおりにサービスは稼働しているか
- Nagiosの監視が通るか

**Serverspec活躍シーン**

- 既存マニフェストのリファクタリング
- Serverspecのテスト結果が変わらないように気をつけている

- Jenkins上には各ロールに合わせたジョブを用意している

- 定期的なテスト
- システム監視で見えない部分（recipeの変更とか・・）
- 複数台のテストをしているか？

-------
###「Infrastructure as a CodeにおけるJenkinsの役割」 〜環境構築も継続的インテグレーションを行う時代です〜



Provisioning ToolChain

**Bootstrapping**

- kickstart
- OS
- NIC/Rooting
- SELINUX 無効化
- useradd
- 鍵認証
- Chefが実行できればよい

**configuration**

- Chef, Puppetなどのミドルウェアセットアップ
- ChefSolo
- Jenkins knife solo
- Chefの成否がJenkinsから見えるようになった

**Orchestration**

- アプリケーションのプロビジョニング
- Jenkins + Serf　で実施
- Serf: イベンドを受けてそれぞれのやりたい子処理を実施
- Jenkins: Serf に発火するために実施

**Releasalizationレイヤ（造語）**

- Orchestratioの処理内容をテスト
- サーバを本番環境に投入（LB追加など）

**サーバ構築におけるJenkinsの役割**

- ソースコードのDeploy
- UnitTestによるCI
- サーバ構築の自動化管理

**Jenkinsでサーバ構築フローの制御も実施**

- Build Flow Plugin（Groovyベース）
- Build Graphで構築フローを視覚化
- Work Flow Plugin

**Serfの使い方**
Glusterfsクラスタ構築で利用している

**Orchestration**
- Serf query: 処理結果を取得できる
- Jenkinsがビルドフローをみることができる
- SerfTag:ChefのRoleを要約するために利用

SerfでConfigurationとOrchestrationを連携
- ChefでSerfをAgentとして起動
- Serfの起動をJenkinsで実行


**Releasalization**


**Jenkinsの役割**
- ChefのConfigurationに適応

cookbook作成
レシピ開発
ChefServerに登録
Insntance起動
Chef実行
GithubにPush

dockerでChefの開発方法（chef zeroで実施）

Serverspecの入ったイメージ
Chefリポジトリをマウント
Branch名＝Role名

GitHub　
pull req
Jenkins

**Jenkinsの冗長化**

Serfで冗長化
BuildFlow Tag

Jenkins
 Deploy, build, ci
Cobbler+

**野望**
AutoScaleをやりたい

Autoscale：ChefServerとの同時接続
Jenkins：ソースコード
















