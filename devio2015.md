Intel Edison HandsOn
=======

1. Edison にUSBケーブルで接続
2. シリアル接続でログイン
```
$ screen /dev/cu.usbserial-A103KKK0 115200 -L
root/Password1

C-a,C-¥
y
```

3. IntelXDKの起動
4. IntelXDKにdeviceを認識させるためプロジェクトをオープン

```
"OPEN AN INTEL XDK PROJECT"
-> SampleCode1/A0.xdk

>プロジェクトにdeviceを紐づける

* configure_edison --setup
* Seed Studio Grobve Starter Kit V3
```

## AWS 
### Cognito
- APIKeyをアプリに埋め込まない。
- Keyの管理はCognitoに実施させる

Cognito
us-east-1:28396ee0-f2dc-4a0c-8c2c-009cc1f38ef5

IAM
arn:aws:iam::867707021209:role/Cognito_iothandsonUnauth_DefaultRole

http://ec2-52-68-53-22.ap-northeast-1.compute.amazonaws.com:9000



