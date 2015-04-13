
KPET Server-Side 開発資料
===============================

## はじめに
本資料はKPET（仮）のServer−Sideで利用する規約、APIを規定した資料である。
全体の環境を説明する資料は別途用意する。

----

## バージョン
0.9

----


## Coding規約
[Node.js Codingガイド](http://popkirby.github.io/contents/nodeguide/style.html)を採用する。

----



## 開発機能
### 導入パッケージ説明
** express **

express-generatorでデフォルトで導入されたパッケージ

```   
"body-parser": "~1.12.0",
"cookie-parser": "~1.3.4",
"debug": "~2.1.1",
"express": "~4.12.2",
"jade": "~1.9.2",
"morgan": "~1.5.1",
"serve-favicon": "~2.2.0",
```

** config **

Credential, Token, AccessKey等を設定ファイルに落とすためのパッケージ
設定ファイルは可読性、フォーマットのシンプルさを採用するために、yamlを採用
./config/default.yml がデフォルトコンフィグファイルとなる

```
"config": "~1.12.0",
"js-yaml": "*",
```

** aws s3, dynamodb **

AWSのS3, Dynamoなどを触るために導入したパッケージ

```
"aws-sdk": "~2.1.21",
"dynode": "~0.6.1",
"connect": "~1.0.6",
"connect-dynamodb": "~1.0.6",
```
   

** auth **

```
"basic-auth": "~1.0.0"
```



### 共通仕様
### APIバージョン
トライアル期間完了までAPIバージョンは全て“0.9”とします

### URL
APIバージョン情報は全ての開発者が意識できるようにURIに含める方式とする。

{ROOT_URL}/v0.9/{resource}


### システム構成図
- mBaaS(ユーザ認証)
- 

### BaaS認証機構を利用
- サービスを提供するユーザ Credential(ID,PASSWORD)はmBaaSのユーザ管理機能を利用する
- mBaaSのAPIコール回数の上限は10,000回/月となっているため、コール回数を削減するためにmBaaSが発行するTokenに有効期限を設けて運用する。
- 
- Tokenの有効期限が切れた場合、不正なTokenであった場合はもう一度ログイン用インタフェースへリダイレクトして再取得が必要となる。
- Tokenの有効期限が切れる処理を発生させるため、下記実装を行う。

Client --(Credential)--> 



### upload.js

#### 機能概要

```
- 本アプリケーションはBLEセンサーdeviceよりAndroid端末が取得したデータを受信するAPIである
- 実装する機能は以下の３つ
- http サーバ(basic認証)
- http ヘッダよりX-DEVICE-ID を取得
- 認証が通るアクセスをS3へ格納
```

#### API仕様
**プロトコル**
```
HTTPS (CLIENTサイド)
```


**































### システム環境
### AWS上に下記環境を構築
- gitbucket+S3
- node.js
- jenkins+S3

### ドメイン
Production: 
Development: 

### 
## プログラミング環境
### node.jsインストール
```
$ git clone git://github.com/creationix/nvm.git .nvm
$ cd .nvm
$ git checkout v0.24.0
$ cd ../
$ . .nvm/nvm.sh
$ nvm install v0.12.1
$ nvm use v0.12.1

$ vi ~/.bashrc
下記追加
NVM_HOME=${HOME}/.nvm
if [ -e "${NVM_HOME}" ]; then
	source ${NVM_HOME}/nvm.sh
	nvm use v0.12.1
fi
```

### expressインストール

```
$ npm install -g express-generator
```

#### Path作成
- 初回



```
$ express node-api
$ cd node-api
```

- Git経由

```
$ git clone ****
$ cd ****
$ git tag
$ git checkout <tag>
```


#### パッケージインストール

```
$ vi package.json
{
  "name": "node-api",
  "version": "0.0.0",
  "private": true,
  "scripts": {
    "start": "node ./bin/www"
  },
  "dependencies": {
    "body-parser": "~1.12.0",
    "cookie-parser": "~1.3.4",
    "debug": "~2.1.1",
    "express": "~4.12.2",
    "jade": "~1.9.2",
    "morgan": "~1.5.1",
    "serve-favicon": "~2.2.0",
    "config": "~1.12.0",
    "js-yaml": "~3.2.7",
    "aws-sdk": "~2.1.21",
    "dynode": "~0.6.1",
    "connect": "~1.0.6",
    "connect-dynamodb": "~1.0.6",
    "basic-auth-connect": "~1.0.0",
    "promise": "~6.1.0"
  }
}

$ npm install
```


#### 設定ファイル作成
```
$ mkdir config
$ vi config/default.yaml
{
  "baas": {
    "hostname": "api-datastore.appiaries.com",
    "apiVers": "v1",
    "aplToken": "app4066dcb7ee310208cbc390790a",
    "dsId": "_sandbox",
    "aplId": "tera_test01",
  },
  "aws_s3": {
  },
  "aws_dynamo": {
  }
}
```




