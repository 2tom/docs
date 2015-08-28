
Server-Side 開発資料 (draft)
===============================

## はじめに
本資料はServer−Sideで利用する規約、APIを規定した資料である。
全体の環境を説明する資料は別途用意する。

----

## バージョン
0.9

----


## Coding規約
[Node.js Codingガイド](http://popkirby.github.io/contents/nodeguide/style.html)を採用する。

----


## 開発機能
### 機能概要

### 認証機構を利用
- サービスを提供するユーザ Credential(ID,PASSWORD)はmBaaSのユーザ管理機能を利用する
- mBaaSのAPIコール回数の上限は10,000回/月となっているため、コール回数を削減するためにmBaaSが発行するTokenに有効期限を設けて運用する。
- Tokenの有効期限が切れた場合、不正なTokenであった場合は再ログインを実施してもらう
- Tokenの有効期限が切れる処理を発生させるため、下記実装を行う。


|client|seq|APIServer|seq|appiaries|
|---|---|---|---|---|
|req|-(id/pw)->|/login|||
||||-(id/pw)->|/v1/tkn/DS_ID/APP_ID/|
|||| <--- ||
|||JWT Create||
|| <--- |||
|Req with JWT| ---> |/v0.9/{resources}|||


### システム環境

### ドメイン



--- 
## プログラミング環境
### node.jsインストール

```
$ sudo yum -y update
$ sudo yum -y install git
$ sudo mkdir /opt/node/
$ sudo mkdir 777 /opt/node

$ git clone git://github.com/creationix/nvm.git /opt/node/.nvm
$ cd .nvm
$ git checkout v0.25.3
$ cd ../
$ . .nvm/nvm.sh
$ nvm install v0.12.4
$ nvm use v0.12.4

$ sudo vi /etc/profile.d/setnvm.sh
# 下記を追加
function setnvm(){
  NVM_HOME=/opt/node/.nvm
  if [ -e "${NVM_HOME}" ]; then
    source ${NVM_HOME}/nvm.sh
    nvm use stable
  fi
  cd /opt/node; pwd
}
```

### express4 Generatorインストール
- express4よりGeneratorとスケルトン作成が分離された
- 本環境ではexpress4以上を用いるためgeneratorをインストールする

```
$ npm install -g express-generator
```

### ドキュメント作成ツール
#### TBD

### テストツールインストール
- mocha,chaiをインストールする
- mochaはコマンドラインを実行するので、グローバルインストールとする
- chaiは後述のパッケージインストールとする

```
$ npm install -g mocha
```

### プロセス監視ツールインストール
```
$ npm install -g pm2
```

### アプリケーションインストール
- Git経由

```
$ git config --global user.email <EMAIL ADDRESS>
$ git config --global user.name <NAME>
$ git config --global http.sslVerify false
```


```
$ cd /opt/node ; pwd
$ git clone https://ec2-52-68-136-135.ap-northeast-1.compute.amazonaws.com/gitbucket/git/kpet/node-api.git
$ cd node-api
```

```
$ npm install -g pm2
```

#### 設定ファイル作成
- AWS accessKey, secretAccessKeyを確認し、Configへ埋め込む


```
$ mkdir config
$ vi config/default.yaml
mbaas:
  host: "api-datastore.appiaries.com"
  token: "***********"
  dsId: "_sandbox"
  aplId: "trialP0"
aws_s3:
  apiVers: "2006-03-01"
  accessKey: "***********"
  secretKey: "***********"
  region: "us-east-1"
  bucket: "pet-dev-bucket-tokyo"
  basedir: "pet-dev-device-upload-data"
aws_dynamo:
  accessKey: "***********"
  secretKey: "***********"
  region: "ap-northeast-1"
  profileTable: "Kpet-Profile"
  activityTable: "Kpet-Activity"
  recordTable: "Kpet-Record"
upload_user:
  id: "z1930374"
  pass: "z1930285"
jwt:
  duration: 1440
  secret: "**********"
```

#### プロセス起動

```
$ pwd
/opt/node/node-api
$ pm2 start process.json
$ pm2 show 
$ pm2 log
$ pm2 stop
```


----

### 自己認証局、サーバ証明書
#### CA認証局作成

- 認証局のフォルダ作成

```
$ sudo cp -p /etc/pki/tls/openssl.cnf /etc/pki/tls/openssl.cnf.org
$ sudo vi /etc/pki/tls/openssl.cnf
dir = /home/ec2-user/apps/kpetCA

$ mkdir /home/ec2-user/apps/kpetCA
$ cd /home/ec2-user/apps/kpetCA

$ mkdir certs
$ mkdir private
$ mkdir crl
$ mkdir newcerts
```

- シリアル初期化

```
$ echo "01" > serial
```

- 証明書データベース初期化

```
$ touch index.txt
```

- CA証明書、秘密鍵作成（期間は５年）

```
$ openssl req -new -x509 -newkey rsa:2048 -out cacert.pem -keyout private/cakey.pem -days 1825

Generating a 2048 bit RSA private key
.......+++
....................+++
writing new private key to 'private/cakey.pem'
Enter PEM pass phrase:
Verifying - Enter PEM pass phrase:
Verify failure
Enter PEM pass phrase:
Verifying - Enter PEM pass phrase:

-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.

-----
Country Name (2 letter code) [XX]:JP
State or Province Name (full name) []:Tokyo
Locality Name (eg, city) [Default City]:Chiyoda
Organization Name (eg, company) [Default Company Ltd]:CTC
Organizational Unit Name (eg, section) []:
Common Name (eg, your name or your server's hostname) []:ap-northeast-1.compute.amazonaws.com
Email Address []:
```

- Android取り込み用にDER形式(.cer拡張子で保存)へ変更

```
$ openssl x509 -inform PEM -outform DER -in cacert.pem -out kpetCAcert.cer
```

#### サーバ証明書
 - 鍵ペアとCSR作成
 
 ```
$ mkdir /home/ec2-user/apps/kpetSVAuth
$ cd /home/ec2-user/apps/kpetSVAuth
 
$ openssl req -new -keyout server.key -out server.csr

Generating a 2048 bit RSA private key
......+++
..........+++
writing new private key to 'server.key'
Enter PEM pass phrase:
Verifying - Enter PEM pass phrase:

-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.

-----
Country Name (2 letter code) [XX]:JP
State or Province Name (full name) []:Tokyo
Locality Name (eg, city) [Default City]:Chiyoda
Organization Name (eg, company) [Default Company Ltd]:CTC
Organizational Unit Name (eg, section) []:
Common Name (eg, your name or your server's hostname) []:*.ap-northeast-1.compute.amazonaws.com
Email Address []:

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:
```

- 自己認証CA局で署名

```
$ cd /home/ec2-user/apps
$ openssl ca -out kpetSVAuth/server.cer -infiles kpetSVAuth/server.csr
Using configuration from /etc/pki/tls/openssl.cnf
Enter pass phrase for /home/ec2-user/apps/kpetCA/private/cakey.pem:
Check that the request matches the signature
Signature ok
Certificate Details:
        Serial Number: 1 (0x1)
        Validity
            Not Before: Apr 16 12:29:37 2015 GMT
            Not After : Apr 15 12:29:37 2016 GMT
        Subject:
            countryName               = JP
            stateOrProvinceName       = Tokyo
            organizationName          = CTC
            commonName                = *.ap-northeast-1.compute.amazonaws.com
        X509v3 extensions:
            X509v3 Basic Constraints:
                CA:FALSE
            Netscape Comment:
                OpenSSL Generated Certificate
            X509v3 Subject Key Identifier:
                C7:53:C1:80:A5:0D:07:BE:CC:0E:BD:38:19:A4:0E:9E:0B:29:94:25
            X509v3 Authority Key Identifier:
                keyid:C3:05:87:CA:23:DA:C7:D2:B7:FF:A9:60:0E:0E:9A:90:B4:85:29:E8

Certificate is to be certified until Apr 15 12:29:37 2016 GMT (365 days)
Sign the certificate? [y/n]:y


1 out of 1 certificate requests certified, commit? [y/n]y
Write out database with 1 new entries
Data Base Updated
```

- サーバ証明書の秘密鍵からパスワード削除

```
$ openssl rsa -in kpetSVAuth/server.key -out kpetSVAuth/server.key
Enter pass phrase for server.key:
writing RSA key
```


```
$ cd ../
$ vi bin/www

+var fs = require('fs');
+var https = require('https');
+var options = {
+ key: fs.readFileSync('./keys/server.key'),
+ cert: fs.readFileSync('./keys/server.crt'),
+ ca: fs.readFileSync('./keys/ca.crt')
+ }
```

-------
## GitBucket
- リバースプロキシとしてnginxを用いる
- SSLの終端はnginxとする
- ストレージはS3とする




### S3 Bucket作成

|name|value|
|---|---|
|s3 bucket|pet-dev-data-001|
|region|tokyo|
|user|dev-user-01(S3,Dynamo,FullAccess)|


### EC2 instance
|name|valune|
|---|---|
|name|tls_dev_vcs01|
|type|t2.micro|
|VPC|vpc-93f520f6|
|subnet|subnet-6db0691a|
|secgroup|for_tls_dev_vcs01|


### EC2 S3マウント設定

- 初期設定

```
$ sudo yum update
$ sudo yum -y install gcc-c++ fuse fuse-devel libcurl-devel libxml2-devel openssl-devel automake
$ sudo yum -y install git
```

- s3fsソース取得、コンパイル、インストール

```
$ git clone https://github.com/s3fs-fuse/s3fs-fuse.git
$ cd s3fs-fuse; pwd
$ git checkout v1.78
$ ./autogen.sh
$ ./configure --prefix=/usr
$ make
$ sudo make install
```

- マウント

```
$ mkdir s3-dev
$ sudo vi /etc/passwd-s3fs
AccessKey:SecretAccessKey

$ sudo chmod 640 /etc/passwd-s3fs
$ sudo /usr/bin/s3fs pet-dev-data-001 /home/ec2-user/s3-dev -o rw,allow_other,uid=500,gid=500,default_acl=public-read

$ umount /home/ec2-user/s3-dev
$ sudo echo "/usr/bin/s3fs#pet-dev-data-001 /home/ec2-user/s3-dev fuse rw,allow_other,uid=500,gid=500,default_acl=public-read 0 0" >> /etc/fstab
$ sudo mount -a

```

### Nginx

- サーバ証明書作成

```
$ mkdir -p ./ssl ; cd ./ssl
$ openssl genrsa  -out server.key 2048 -sha256
$ openssl req -new -sha256 -key server.key -out server.csr
```


|Name|Value|
|---|---|
|Country|JP|
|State|Tokyo|
|Locality|Chiyoda|
|Organization|CTC|
|OrganaizationUnit||
|CommonName|*.ap-northeast-1.compute.amazonaws.com|
|Email||

```
$ openssl x509 -req -days 3650 -signkey server.key < server.csr > server.crt  
```

- nginxセットアップ
Dockerfile参照


### GitBucketインストール
- 下記Dockerfileにてプロセス起動
- gitコマンドで証明書verifyを中止

```
$ git config --global http.sslVerify false
$ export GIT_SSL_NO_VERIFY=true
```
