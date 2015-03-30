

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

----

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


----

### ファイルシステム
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

fs.writeFile('./target.txt', 'some data', 'utf-8', function(err){
  if(err) throw err;
  fs.readFile('./target.txt', 'utf-8', function(err, data){
    if(err) throw err;
    console.log(data);
  });
});

- fs.readFile()をfs.writeFile()のコールバックで呼ぶようにしているのは、ファイル書き込み完了後に読み込みが実施されるようにするため
- エラーがある場合には例がをスローしている
```

----

### ストリーム
- メモリを大量に消費させないようにするために利用する

#### 入力ストリーム
- fs.createReadStream(path, [options])

- プロパティ

```
- flag: ファイルオープンモードの文字列を指定する
- encoding: エンコーディング形式を指定（デフォルトはBuffer形式）
- mode: ファイルのオープンモード, r, r+, w+, a, a+
- bufferSize: 読み込みバッファサイズ（デフォルトは1024*64）
- start: 読み込み開始位置を表す。（デフォルトは0、先頭からよむ）
- end: 読み込み終了位置
```


- イベント

```
- data: ストリームから新たなデータが読み込まれた時のイベント、リスナは読み込まれたデータを受け取る１つの引数が渡される
- end: ストリームからすべてのデータ読み込みが完了したことを示す。このイベント以降にdataイベントは発生しない
- error: ストリーム読み込みちゅうのエラーを示すイベント。このイベントにリスナが登録されていない場合、イベントループから例外がスローされる
- close: ストリームが閉じた時のイベント。HTTPリクエストなどでは発生しないが、ファイル読み込みなどでは発生する。 
```

```
$ cat readStream.js
var fs = require('fs');

var rs = fs.createReadStream('./target.txt', {encoding: 'utf-8', bufferSize: 1});

rs.on('data', function(chunk){
  console.log(chunk);
});

rs.on('end', function(){
  console.log('<EOF>');
});
```

#### 出力ストリーム
- fs.createWriteStream(path, [options])
- プロパティ

```
- flags: ファイルオープンモード
- encoding: 文字エンコーディングを指定
- mode: ファイルオープンモードによっては、ファイルが存在しない場合ファイルが新規作成される

```
var fs = require('fs');

var stdin = process.stdin;
var file = process.argv[2];
var output = fs.createWriteStream(file, {flags: 'a+'});
stdin.resume();
stdin.pipe(output);
```

----

### ファイル記述子
- ファイルの読み書きを何度も行ったり、特定の箇所を書き換えるなどの処理を行う場合、ストリームや、ファイルの全てを読み書きする方法は不適切
- このような場合はファイル記述子を利用した高度な入出力を行う
- fs.open()でファイルオープン
- fs.open(path, flags, [mode], [callback])
- modeはデフォルト値が0666
- fs.close()でファイルclose
- fs.close(fd, [callback])
- open(),close()共にcallbackは省略可能
- openのコールバック関数は右記形式で記載する"function(err, fd)"
- closeのコールバック関数は右記形式で記載する"fucntion(err)"


#### ファイル記述子を使った入力
- fs.read(fd, buffer, offset, length, position, [callback])
- fd: オープンされているファイル記述子
- buffer: 読み込んだ内容を格納するバッファ
- offset,length: offsetで指定した位置からlengthでした長さまでbufferに格納される
- positionは読み込みを開始する位置
- callbackは読み込み完了後に呼び出されるコールバック関数。関数の形式は"function(err, byteRead, buffer)"

#### ファイル記述子を使った出力
- fs.write(fd, buffer, offset, length, postion, [callback])
- オプションの意味はfs.read()と同じ
- コールバック関数の形式はfunction(err, written, buffer)

----

### ファイルやディレクトリの操作
- fs.rename(path1, path2, [callback]), mvに相当
- fs.mkdir(path, [mode], [callback]), mkdirに相当デフォルトは0666
- fs.rmdir(path, [callback]), rm -rに相当
- fs.readdir(path, [callback]), lsコマンドに相当
- callbackは fuction(err, files)


----
### ソケット(TCP/UDP)
- Nodeは第1級プロトコルはHTTPとしているが、その実装の根幹はソケット通信モジュール
- TCPには"net", UDPには"dgram"を用いる
- net/dgramモジュールは内部的に作成したTCP/UDPオブジェクトを経由してUNIX/Windowsのシステムコールを抽象化したイベントライブラリ"libuv"を利用している
- libuvではシステムコールを呼び出し、通信イベントを管理する機能(UNIX:libev, Windows:IOCP)と組み合わせて通信イベント発生時にnetモジュールに通知するコールバックを実行させている
- net.ServerはTCPサーバを扱うクラスで、events.EventEmitterクラスを継承している
- net.createServer()メソッドを使うとnet.Serverオブジェクトを生成可能
- net.SocketはTCPのSocket接続を行うクラスで、events.EventEmitter, stream.Streamクラスを継承している
- net.connect() / net.createConnection()メソッドからnet.Socketオブジェクトを生成可能
 
```
var net = require('net');
var dgram = require('dgram');
```

#### TCPサーバ
** TCPサーバを生成 **

- net.createServer([options], [connectionListener])
- optionsにはソケットの挙動を指定可能
- allowHalfOpenプロパティ(デフォルトはfalse)を与えることが可能
- connectionListnerは接続を受け付けた時に実行されるリスナ関数

```
var net = require('net');
var server = net.createServer();
```

** TCPサーバをリッスン **

- server.listen(port, [host], [callback])
- IPアドレス省略時は "0.0.0.0"が利用される
- callbackには"listening"イベントで実行するコールバック関数を指定

```
// listeningイベントリスナを一緒に記述
server.listen(8000, '127.0.0.1', function(){
});

// listeningイベントリスナを別々に記述
server.listen(8000, '127.0.0.1');
server.on('listening', function(){
});
```

** TCPクライアントから接続を受ける **

- TCPクライアントがサーバとTCP接続を確立するとserverオブジェクトは connectionイベントを生成する。その際net.Socketオブジェクトを引数としてコールバック関数を呼び出す

```
server.on('connection', function(socket){
//connectionイベントの処理
});

// serverオブジェクト生成とonnectionイベントへのリスナ登録を一緒に行う場合
var server = net.createServer(function(socket)){
});
```

** TCPクライアントからデータを受信する **

- TCP接続後クライアントから送信されたデータをサーバで受け取るとsocketオブジェクトはdataイベントを発生させる
- dataイベントに登録されたリスナ関数は受信データ"chunk"を引数にして実行される
- “chunk”は何も指定されていない場合はbuffer型でリスナに渡される
- "chunk"はsocket.setEncoding()によって受信データエンコードが指定されている場合は指定された文字列型になる

```
server.on('connection', function(socket){
 socket.on('data', function(chunk){
   //dataイベント発生後クライアントから送信されたデータ処理を記載
 });
});
```
** TCPクライアントにデータを送信する **

- TCPサーバからクライアントへデータを送信する場合 socket.write()メソッドを利用する
- OSへ書き込むデータの待ちがなければ、socket.write()はtrueを返却し、直ちにsocketオブジェクトでdrainイベントが発生する

```
socket.on('connection', function(socket){
 var return = socket.write('hello');
 socket.on('drain', function{
 });
});
```

** TCPクライアントへのデータ送信が滞る **

- TCPサーバからクライアントへのデータ送信が滞りデータ送信が待ち状態になった場合、送信データはサーバ上のバッファに滞り、socket.write()の戻り値はfalseになる
- この際、サーバ上に溜まっている送信バッファサイズはsocket.buffreSizeで取得できる

```
server.on('connection', function(socket){
  var return = socket.write('hello');
  if (return === true){
    console.log(socket.bufferSize);
  };
});
```

** TCPクライアントへのデータ送信滞留が解消する **
- 滞留が解消するとdrainイベントが生成される

```
server.on('connection', function(socket){
  var ret = socket.write('hello');
  if (ret === false){
    console.log(socket.bufferSize);
  }
  socket.on('drain', function(){
    console.log(socket.bufferSize);
  });
})

** TCPクライアントから接続終了を受け付ける **
- TCPクライアントからFINを受信するとsocketは読み込み不可となり、endイベントが生成される
- net.createServer()オプションで"allowHalfOpen: true"を指定している場合、この処理は実施されない

```
// defaultの場合
var server = net.createServer(function(socket){
  console.log("new connection:", server.connections);
  
  socket.on('end', function(){
    console.log("end connection:", server.connections);
  });
});
server.listen(8000);
```

```
//allowHalfOpen: true の場合
var server = net.createServer({allowHalfOpen: true}, function(socket){
  console.log("net connection:", server.connections);
  socket.on('end', function() {
    console.log("end connection", server.connections);
  });
});
server.listen(8000);
```

** TCPクライアントとの接続を終了する **
- TCPサーバがsocketを終了する場合、socket.end()メソッドが使われる
- socketは書き込み不可となり、内部でsocket.destroy()が実施されハンドルが削除される
- server.connectionsが減り、closeイベントが発生する

```
var server = net.createServer(function(socket){
  socket.end();
  socket.on('close', function(){
    console.log("socket.end");
  });
});
server.listen(8000);
```

** TCPサーバを終了する **
- server.close()


#### TCPクライアント
- TCPクライアントは socketオブジェクトに対するメソッド操作と、イベントリスナの登録によって実現する
- socketオブジェクト作成によりTCPHandShake：net.connect(port, [connect], [connectListener])
- net.connect() = net.createConnection（）は同じ機能を担う
- connectイベント発生後はTCPサーバでのsocket操作と同じメソッド・イベントによりデータ書き込み・受信・終了といったイベント操作が可能になる

** TCPサーバを生成 **
```
var net = require('net');
var socket = net.connect(1338, 'localhost', function(){
  console.log('TCP Client Connected');
  socket.end();
});

var net = require('net');
var socket = new net.socket();
socket.connect(1338, 'localhost');
socket.on('connect', function(){
  console.log('TCP Client connected');
  socket.end();
});


----
### HTTP/HTTPS

```
var http = require('http');
var https = require('https');
```

#### http.Serverクラス
- evnets.EventEmitter, net.Serverを継承
- request, connectなどHTTPリクエストに関連したクラスが追加
- 実態はHTTP処理に特化したリスナを持つnet.Server

#### http.ServerRequest, http.ClientResponse(IncomingMessage)
- http.ServerRequest, http.ClientResponseはどちらも、http.IncomingMessageクラスから生成される同じオブジェクト
- events.EventEmitter, stream.Streamを継承
- stream制御を行う pause(), requme(), setEnconding()メソッドを持っている

|property|ServerRequest|ClientResponse|
|----|---|---|
|method|⭕️|❌|
|url|⭕️|❌|
|headers|⭕️|⭕️|
|trailers|⭕️|⭕️|
|httpVersion|⭕️|⭕️|
|connection|⭕️|❌|
|statusCode|❌|⭕️|
|setEncoding()|⭕️|⭕️|
|pause|⭕️|⭕️|
|resume()|⭕️|⭕️|

#### http.ServerResponse, http.ClientRequest(OutgoingMessage)
- http.ServerResponse, http.ClientRequestはどちらもhttp.OutgoingMessageクラスを継承している
- http.ClientRequestクラスはhttp.Agentクラスと密接に関連している
- socket, responseのイベントはHTTP接続時に発生するイベントであり、
- connect, upgrade, continueイベントはHTTPのリクエストやヘッダをサーバとやりとりする際に発生するイベント

#### http.Serverのエコーサーバ
- httpモジュールを読み込む
- http.Serverオブジェクトを生成する
- http.Serverのrequestイベントにリスナを登録する
- リクエストイベントリスナ内でhttp.ServerRequestオブジェクトのデータイベントを受け取り終了時に標準出力する
- http.Serverのconnectionイベントにリスナを登録する
- connectionイベントリスナ内でsocketオブジェクトのデータイベントを受け取り、終了時に標準出力する
- http.ServerでtcpポートをLISTENする
- http.Serverでerror, clientErrorイベントのリスナを登録し、エラーメッセージを標準出力する

```
var http = require('http');
var server = http.Server();
var port = 8000;

server.on('request', function(req, res) {
  var data = '';
  req.on('data', function(chunk) {
    data += chunk;
  });
  req.on('end', function() {
    res.writeHead(200, {'Content-Type': 'text/plain'});
    res.end('Body Echo:' + data + '\n');
  });
});

server.on('connection', function(socket) {
  console.log('=== raw socket data ===');
  socket.on('data', function(chunk){
    console.log(chunk.toString());
  });
  socket.on('end', function(){
  console.log('=======================');
  });
});

server.on('clientError', function(e) {
  console.log('Client Error: ', e.message);
});

server.on('error', function(e) {
  console.log('Server Error: ', e.message);
});

server.listen(port, function() {
  console.log('listening on ' + port);
});
```

```
var http = require('http');
var port = 8000;
var obj = {};
var server = http.createServer(function(req, res) {
  var remoteAddress = req.connection.remoteAddress;
  var header = {'Connection': 'close',
                'Content-Length': 0};
  var key = req.url;

  switch(req.method) {
    case 'POST':
      if (obj[key]) {
        res.writeHead(403, header);
        res.end();
    } else {
      var data = '';
      req.on('data', function(chunk) {
        data += chunk;
      });
      req.on('end', function() {
        try {
          obj[key] = JSON.parse(data);
          res.writeHead(200, header);
          console.log('POST', key, obj[key], ' from ' + remoteAddress);
        } catch (e) {
          res.writeHead(400, e.message, header);
        }
        res.end();
      });
    }
    break;

    case 'GET':
      if (obj[key]) {
        var json= JSON.stringify(obj[key]);
        res.writeHead(200, {
          'Content-Length': Buffer.byteLength(json),
          'Content-Type': 'application/json',
          'Connection': 'close'
        });
        res.write(json);
        console.log('GET', key, ' from ' + remoteAddress);
      } else {
        res.writeHeat(404, header);
      }
      res.end();
      break;

    case 'PUT':
      if (obj[key]) {
        var data = '';
        req.on('data', function(chunk) {
          data += chunk;
        });
        req.on('end', function() {
          try {
            obj[key] = JSON.parse(data);
            res.writeHead(200, header);
            console.log('PUT', key, obj[key], ' from ' + remoteAddress);
          } catch(e) {
            res.writeHead(400, e.message, header);
          }
          res.end();
        });
      } else {
        res.writeHead(400, header);
        res.end();
      }
      break;

      case 'DELETE':
        if (obj[key]) {
          delete obj[key];
          res.writeHead(200, header);
          console.log('DELETE', key, ' from ' + remoteAddress);
        } else {
          res.writeHead(404, header);
        }
        res.end();
        break;
  }
});

server.on('error', function(e) {
  console.log('Server Error', e.message);
});


server.on('clientError', function(e) {
  console.log('Client Error', e.message);
});

server.listen(port, function() {
  console.log('listening on ' + port);
});
```



#### appieries auth

#### basic auth

#### rest api

#### dynamo db 

#### search and dlsite
