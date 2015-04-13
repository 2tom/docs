IntelEdison IoT
========


### IntelEdisonを Intel IoT Analytics サイトへ登録

#### iotkit-agent起動

```
# systemctl enable iotkit-agent
ln -s '/lib/systemd/system/iotkit-agent.service' '/etc/systemd/system/multi-user.target.wants/iotkit-agent.service'

# systemctl start iotkit-agent
```

#### iotkit-agentの動作確認

```
# iotkit-admin test
2015-04-05T13:41:08.270Z - info: Trying to connect to host ...
2015-04-05T13:41:10.615Z - info: Connected to dashboard.us.enableiot.com
2015-04-05T13:41:10.620Z - info: Environment: prod
2015-04-05T13:41:10.621Z - info: Build: 0.12.6

# iotkit-admin device-id
2015-04-05T13:41:25.406Z - info: Device ID: 06-12-c7-da-24-79
```



#### Intel IoT Analyticsアカウント登録

- [Intel Iot Analytics](https://dashboard.us.enableiot.com/ui/dashboard#/board)にアクセス、アカウントを作成
- Accountの"Activation Code"を取得(xxxxxx)

#### マシンの登録

```
# iotkit-admin activate xxxxxxxx
2015-04-05T13:42:45.087Z - info: Activating ...
2015-04-05T13:42:47.694Z - info: Saving device token...
2015-04-05T13:42:47.707Z - info: Updating metadata...
2015-04-05T13:42:47.715Z - info: Metadata updated.
```

#### mraa programing (MPU9250+mraa)

```
var mraa = require('mraa');

// mraaのバージョン表示
console.log('MRAA Version: ' + mraa.getVersion());

//MPU9250のI2Cバスadress（AD0=Lの場合、0x68, AD0=Hの場合 0x69）
var bus = 0x68;

// whoamiレジスタの内部アドレス
var whoami = 0x75;

// Henry BoardへのI2Cポート番号を指定
x = new mraa.I2c(6);

// MPU9250のポートを開く
x.address(bus);

// 受信用バッファ指定
var buff = new Buffer(7);

//whoamiレジスタのアドレス指定
buf = x.readReg(whoami);

//0x71, 113 で正常応答
console.log(buf.toString(16));
```