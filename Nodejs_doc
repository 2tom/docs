

## node.js 
==============


### セットアップ

#### vimインストール
```
$ sudo yum install -y git openssl-devel gcc-c++ make lua-devel.x86_64 ncurses-devel
$ sudo yum install mercurial
$ cd /usr/local/src
$ sudo hg clone -r 29e57603bf6f3a2e3c178a63d332ed4d2eccfa82 https://vim.googlecode.com/hg/ vim7.3.1314
$ cd vim7.3.1314
$ sudo ./configure --enable-multibyte --with-features=huge --disable-selinux --prefix=/usr/local   --enable-luainterp=yes --with-lua-prefix=/usr
$ sudo make && sudo make install
$ cd ~
$ git clone https://github.com/2tom/docs.git
$ mv docs/vimrc ~/.vimrc
$ vim
```

#### node.jsインストール
```
$ git clone git://github.com/creationix/nvm.git .nvm
$ cd .nvm
$ git checkout v0.24.0
$ cd ../
$ . .nvm/nvm.sh
$ nvm install v0.12.1
$ nvm use v0.12.1
```

```
$ npm install -g yo grunt-cli gulp bower
```

----

### 基本構文

#### 
```
setTimeout(function() {
  console.log('Timeout');
}, 1000);
console.log('Waiting');
```

```
var http = require('http');
http.createServer(function (req, res){
  res.writeHead(200,{'Content-Type':'text/plain'});
  res.end('Hello World\n');
}).listen(1337, '192.168.57.31');
console.log('Server running');
```

```
var http = require('http');
http.createServer(function (req, res){
  var num = parseInt(req.url.slice(1));
  if (isNaN(num)) {
    res.end();
    return;
  }
  res.writeHead(200,{'Content-Type':'text/plain'});
  res.end('fib('+num+') = ' + fib(num));
}).listen(1337, '192.168.57.31');
console.log('running');

function fib(n){
  if (n === 0 || n === 1) return n;
  return fib(n - 1) + fib(n - 2);
}
```

#### モジュール
```
"use strict";
var count = 0;
module.exports = {
  say:function(name){
    count++;
    console.log('Hello ' + name);
  },

  getCount:function(){
    return count;
  },

  resetCount:function(){
    count = 0;
  }
}
```

```
$ node
> var hello = require('./hello');
undefined
> hello
{ say: [Function], getCount: [Function], resetCount: [Function] }
> hello.say('a');
Hello a
undefined
> hello.say('a');
Hello a
undefined
> hello.getCount();
2
```

```
$ node
> require.resolve('./hello');
'/home/vagrant/hello.js'
> require.resolve('http');
'http'

```

----

### event driven
- node.js の http.createServer()は、APIに登録するコールバック関数はrequestイベント発生時に実行される
- javascriptで利用しているイベントはECMA-262では定義されておらず、W3CのDOM Class2 において定義されている


#### イベントの作成と利用
- node.jsでイベント自体を定義して、任意のタイミングで発生させ、そのイベントに応じた処理をする場合、処理の流れは以下のとおり


```
- イベントを発生するオブジェクトを作成する
- イベント発生時の処理関数（リスナ)を作成する
- イベントを定義する
- 任意のタイミングでイベントを発生させる
```

```
// オブジェクトの作成
var events = require('events');
var emitter = new events.EventEmitter();

// リスナの作成
var sampleListener = function(arg1){
  console.log(arg1);
}

// リスナをイベントに紐付け
emitter.on('occur', sampleListener);
  or

// イベント発生
emitter.emit('occur', 'occured');

//　一度限りのイベント
emitter.once('occur', ')
```


#### リスナ配列
- EventEmitterオブジェクトには複数のリスナを登録可能
- デフォルトは１０個以上のリスナ登録で警告（登録は実行できている）
- setMaxListeners()を利用すると数量変更可能(0 で無制限)
- emitter.listeners(event)で登録済みリスナを確認可能
- removeListener()でリスナ削除（全て消す場合はremoveAllListeners()）


#### シグナル
- process.on()でシグナルの受信が可能

```
process.on('SIGTERM', function(){
  //終了処理
});
```


### イベントループとprocess.nextTick()
- whileで実装されている

#### イベントループの仕組み
- setTimout()のコールバック実行
- process.nextTick()のコールバック実行
- I/Oイベント発生
- I/Oイベントのコールバック実行
- process.nextTick()のコールバック実行

```
var http = require('http');
var server = http.createServer(function(req, res){
  res.writeHead(200, {'Content-Type': 'text/plain'});
  res.end('Hello');
});
server.listen(1337);
while(true);　//このエントリにより、process.nextTick()で実行された
　　　　　　　　//初期化が完了せず、I/Oイベントであるrequestが飛んできても
　　　　　　　　// I/Oイベントが実施されない
```
 
#### 非同期イベントの作成
- events.EventEmiiterでイベントを発生させる場合、下記問題が発生する場合がある


```
var events = require('events');
var util = require('util');

function SyncEmitter(){
  this.emit('bar');
}

util.inherits(SyncEmitter, events.EventEmitter);
var foo = new SyncEmitter;

// new の時点でevent bar がemitされており、
// 下記リスナが実行されない。

foo.on('bar', function(){
  console.log('bar emitted');
});
```

- 上記のようなケースに対応する場合は、process.nextTick()を使って
リスナの登録処理後に非同期イベントが発生するようにする

```
var events = require('events');
var util = require('util');

function AsyncEmitter(){
  var self = this;
  process.nextTick(function(){
    self.emit('bar');
  });
}

util.inherits(AsyncEmitter, events.EventEmitter);

var foo = new AsyncEmitter();

//　ここで正常にリスナが呼ばれる
foo.on('bar', function(){
  console.log('bar event emitted');
});
```

#### 非同期コールバックの呼び出し
- コールバックの実行もprocess.nextTick()で非同期に呼び出すことが可能
- 下記ケースでは、コールバックを同期的に実行しようとしてエラーになります


```
var events = require('events');
var util = require('util');

function SyncCB(cb){
  if(cb)cb();
}

util.inherits(SyncCB, events.EventEmitter);

SyncCB.prototype.setbaz = function(arg){
  this.baz =arg;
}

//コールバック中にオブジェクトメソッドfoo.setbaz()を実行していますが、
//変数fooにオブジェクトが代入される前であるため、undefinedのエラーが発生
var foo = new SyncCB(function(){
  foo.setbaz('bar');
  console.log(foo.baz);
});
```
上記ケースの解決方法として、process.nextTick()を使って非同期にコールバックを実行する

```
var events = require('events');
var util = require('util');

function AsyncCB(cb){
  if(cb){
    process.nextTick(function() {
      cb();
    });
  }
}

util.inherits(AsyncCB, events.EventEmitter);

AsyncCB.prototype.setbaz = function(arg){
  this.baz = arg;
}

var foo = new AsyncCB(function(){
  foo.setbaz('bar');
  console.log(foo.baz);
});
```

----

### ストリーム、バッファ、ファイルシステム
- ストリームはNodeにおいて様々なオブジェクト内で、データの流れを扱う際に利用される抽象的なインタフェース
- ストリームにおいて、入出力データはバッファ単位でストリーム上を流れている（チャンク）
- ストリームはすべてのEventEmmiterのインスタンスとなっており、状態変更がイベントによって通知される

#### 入力ストリーム
- データ読み込みを司る

- 入力ストリームのイベント  

```
//data
- 読み込み開始でイベント発生
- リスナ関数にはBufferオブジェクトもしくは、ストリームオブジェクトがsetEncoding(encoding)メソッドでエンコード指定されていれば文字列が渡される
- setEncoding()にはutf8, ascii, base64を指定可能（デフォルトはutf8）
- dataイベントが発生しなくなるとendが生成

//end
- dataイベントが発生しなくなった際に生成される

//close
- ファイル記述子が閉じられた段階で生成される

//error
- 読み込み中にエラーが発生した場合に生成され、リスナに例外オブジェクトが渡される
- errorイベントリスナが登録されていない場合は uncaughtExceptionが発生
```

- メソッド

```
//destroy()
- データ読み込み処理を破棄する
- destory発行以降はイベントを生成せず、ファイル記述子は閉じられる

//pause()
- dataイベント発生を中断
- 主に入力データを出力ストリームに出力する際に利用

//resumre()
- dataイベントを再開
- 主に入力データを出力ストリームに出力する際に利用

//pipe(destination, [options])
- 出力ストリームに入力ストリームを接続
- destination = 出力ストリーム
- 入力ストリームの読み込みが完了した後、出力ストリームを閉じない場合false指定（デフォルトはtrue）

```

- プロパティ
- readableプロパティを確認することで読み込みの可否が判断できる

- sample

```
$ cat instream.js
var path = require('path');
fs = require('fs');

var filePath = path.join(__dirname, 'a.txt');

var readStream = fs.createReadStream(filePath);
readStream.setEncoding('utf8');

readStream.on('data', function(data){
  console.log(data);
});

readStream.on('end', function(){
  console.log('end');
});

readStream.on('error', function(err){
  console.log('error occured');
  console.log(err);
});
```




#### 出力ストリーム
- データ書き込みを司る
- 出力ストリームのイベント  

```
//drain
- dataイベントが発生しなくなるとendが生成

//error
- dataイベントが発生しなくなった際に生成される

//close
- ファイル記述子が閉じられた段階で生成される

//pipe
- 読み込み中にエラーが発生した場合に生成され、リスナに例外オブジェクトが渡される
- errorイベントリスナが登録されていない場合は uncaughtExceptionが発生
```

- メソッド

```
//write()
- データ書き込み
- write()にはBufferを渡せる
- write(string, [encoding],[fd])　という形で文字列を書き込み可能
- fdを使用するとUNIXストリームでのみのサポート
- write()は出力対象のデータがカーネルバッファにフラッシュされるとtrue, バッファがいっぱいの場合はfalse
- falseをうけた場合はdrainイベントを利用
- drainイベントはカーネルバッファに空きができると発生するため、
- write()->'drain'->write()という形でwriteを再開する形式が一般的

//end()
- 書き込みを終了
- Bufferと文字列を渡すことができる

//destroy()
- ファイル記述子をcloseする
- 出力キューに溜まっていたデータは送信されない

//destroySoon()
- 出力キューのデータが空になった時点でファイル記述子をcloseする
```

- プロパティ
- writeableプロパティを確認することで読み込みの可否が判断できる

- stream sample

```
var path = require('path'),
  fs = require('fs');

var outputFilePath = path.join(__dirname, 'write.txt');
var writeStream = fs.createWriteStream(outputFilePath);

var inputFilePath = path.join(__dirname, 'read.txt');
var readStream = fs.createReadStream(inputFilePath);

writeStream.on('pipe', function(){
  console.log('readableStream pipes writeStream');
})
writeStream.on('error', function(err){
  console.log('error occured');
  console.log(err);
});
writeStream.on('close', function(){
  console.log('writable stream closed');
});

readStream.pipe(writeStream);

readStream.on('data', function(data){
  console.log('>> data event occured');
});
readStream.on('end', function(){
  console.log('read end');
});
readStream.on('error', function(err){
  console.log('error occured');
  console.log(err);
});
```


### Buffer
- バイナリデータを扱う際に利用する
- v8ヒープ外部でメモリを確保する
- Bufferはバイナリファイルの読み書きに利用する

#### 使い方
- Bufferは文字列オブジェクトとして利用する
- デフォルトエンコーディングのUTF−8以外を利用する場合エンコーディングを指定して読み出す
- Bufferはグローバルクラスなのでコードの中でBufferクラスを利用することが可能
- Bufferオブジェクト作成時にサイズを引数に指定する
- オブジェクトを直接引数に指定する方法がある
- sample

```
$ cat buf.js
var size = 16;
var buf = new Buffer(size);
var arr = [1,2,3,4,5,6,7,8];
var arrayBuf = new Buffer(arr);
var str = "sample";
var stringBuf = new Buffer(str);

console.log(buf);
console.log(arrayBuf);
console.log(stringBuf);

$ node buf.js
<Buffer 00 a8 97 7a 02 00 00 00 00 63 72 65 61 74 65 50>
<Buffer 01 02 03 04 05 06 07 08>
<Buffer 73 61 6d 70 6c 65>
```

#### Buffer利用方法
- 書き込み

``` 
- buf.write(string, [offset], [length], [encoding])
 var a = 'test';
 buf.write(a, 0, a.length, 'utf-8');
```

- Bufferの文字列利用

```
var str = 'sample';
buf.write(str);
console.log(buf.toString('utf-8', 0,4));
```

- Bufferの配列

```
var a = 'buff';
buf.write(a);
console.log(buf[0]);
```
- copy(), concat(), slice() APIが存在する

### ファイル
- var fs = require('fs') でファイルシステムモジュールを使用可能

#### ファイル書き込み
- fs.writeFile(filename, data, [encoding], [callback])
- 絶対パス、相対パスが使える
- 相対パスはスクリプトファイルからのパスではなく、process.cwd()が返すパスからの相対になる
- 第１引数：ファイルパス
- 第２引数：書き込む内容(string or bufferの形式)
- 第３引数：ファイルの文字コード（デフォルトはnull）
- 第４引数：コールバック

#### ファイル読み込み
- fs.readFile(filename, [encoding], [callback])
- ファイルの内容を全て読み込む
- 絶対パス、相対パスが使える
- 相対パスはスクリプトファイルからのパスではなく、process.cwd()が返すパスからの相対になる
- 第１引数：ファイルパス
- 第２引数：ファイルの文字コード（デフォルトはnull）
- 第３引数：コールバック
```
var fs = require('fs');
fs.writeFile('target.txt', 'some data', 'utf8', function(err){
});
```



#### appieries auth

#### basic auth

#### rest api

#### dynamo db 

#### search and dlsite
