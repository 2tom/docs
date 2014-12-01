Golang 1st Step
=========

<p><img src="https://go.googlecode.com/hg/doc/gopher/bumper.png" alt="gopher" title="gopher" width="480" height="270"/></p>


---------

##はじめに
Goは2009年にGoogleより発表されたオープンソースのプログラミング言語です。本資料は初心者でも、Golangプログラミング環境構築から、並行処理の実装のノウハウまで解説するものです。


###言語の特徴
GoはCやC++などが使用されるシステムプログラミング領域でより効率よくプログラミングすることを目的として開発されました。従って他の言語が持つような機能の多くを削減し、シンプルな言語仕様となっています。これらはコンパイルの高速化や予期せぬミスを減らすことに役立っています。


###最小限の構文
高速なコンパイルを実現している
- **繰り返し構文はfor文しかなく**、while、do-whileなどの構文は存在しない
- 条件分岐でも**ifの波括弧は省略できず**、**３項演算子も存在しない**
- マクロのようなプリプロセスが必要な構文もサポートされない


###危険の回避
- ポインタ演算の排除による不要なメモリリークの危険回避
- 暗黙の型変換の禁止による意図せぬエラー回避
- 使用しないパッケージのロードによるバイナリの巨大化を防ぐためのコンパイル時のPKGチェック（コンパイルエラーとしている）


###例外の排除




###特徴的な機能
- クロスコンパイルのサポート
- ゴルーチンという軽量スレッド、チャネル機能によるゴルーチン間のデータ授受をサポート



###インストール

- バイナリダウンロード

```
[DLページ](http://golang.org/dl/) より環境に応じたファイルをダウンロード
インストーラを用いてインストール
```

- 環境変数設定
```
$ vi ~/.bash_profile
↓下記を入力
export GOROOT=/usr/local/go
PATH=$PATH:$GOROOT/bin

$ source ~/.bash_profile
```


- version確認

```
$ go version
go version go1.3.3 darwin/amd64
```


- hello world


```
$ vi hello.go
package main
import (
	"fmt"
)

func main(){
	fmt.Println("hello world")
}	
```

```
$ go run hello.go
hello world
```

```
$ go build hello.go
$ ls
hello hello.go

$ ./hello
```

###format
Goのコーディング規約にそったフォーマットに変換するコマンドが用意されている。エディタ保存時、コミット時には必ず実行するようにしてください。
```
$ go fmt hello.go
```

###ドキュメント
- ドキュメント確認コマンド
```
$ godoc fmt
```

- ブラウザベースでドキュメント確認する方法
```
$ godoc -http=":3000"
```

###プロジェクト構成とパッケージ
- goenvインストール


```
**前提条件**
- Goがインストールされていること
- GOROOTが設定されていること
```

- 環境準備
 - GOENVTARGET作成、GOENVTARGETはgoenvコマンドのインストール先

```
$ mkdir ~/Goproj
$ vi ~/.bash_profile
↓下記を追記
export GOENVTARGET=$HOME/GoProj/.goenvtarget
export PATH=$GOENVTARGET:$PATH

$ source ~/.bash_profile
$ mkdir -p $GOENVTARGET
```

- インストール

```
$ curl -L https://bitbucket.org/ymotongpoo/goenv/raw/master/shellscripts/fast-install.sh | bash
```

- 環境作成

```
$ goenv test
$ source test/activate
（go:test）$
```

- 環境解除

```
(go:test) $ deactivate
```

- Appendix(Vimでgoの自動補完有効)

```
()$ go get -u github.com/nsf/gocode
()$ mkdir -p "$HOME/.vim/autoload"
()$ mkdir -p "$HOME/.vim/ftplugin/go"
()$ cp "${0%/*}/autoload/gocomplete.vim" "$HOME/.vim/autoload"
()$ cp "${0%/*}/ftplugin/go/gocomplete.vim" "$HOME/.vim/ftplugin/go"
```

```
()$ vi $HOME/.vimrc
↓を追記
filetype plugin on

()$ 
```


------
##基本文法

###mainパッケージ
Goコードはパッケージの宣言から始まる。プログラムをコンパイルして実行するとmainパッケージの main()関数が実行される

```
package main

func main(){
}
```

###インポート
- プログラム内の他のパッケージを取り込むために使用

```
import "fmt"
```

```
import (
	"fmt"
	"strings"
	"github.com/wdpress/gosample"
)
```

- インポートにもオプションを指定



|項目|内容|
|---|---|
|任意の一文字|f "fmt"などと記載するとパッケージを呼び出す際は“f.Println”という略称で呼び出し可能となる|
|アンダーバー(_)|使用しないパッケージを指定|
|ドット(.)|使用時にパッケージ名が省略可能となる|


###組み込み型
|型|説明|
|---|---|
|uint8|8ビット符号なし整数|
|uint16|16ビット符号なし整数|
|uint32|32ビット符号なし整数|
|uint64|64ビット符号なし整数|
|int8|8ビット符号あり整数|
|int16|16ビット符号あり整数|
|int32|32ビット符号あり整数|
|int64|64ビット符号あり整数|
|float32|32ビット浮動小数|
|float64|64ビット浮動小数|
|complex32|32ビット複素数|
|complex64|64ビット複素数|
|byte|uinit8のエイリアス|
|rune|Unicodeのポイント|
|uint|32 or 64 ビットの符号なし整数|
|int|32 or 64 ビットの符号あり整数|
|uintptr|ポインタ値用符号なし整数|
|error|エラーを表すインタフェース|


###変数

- 変数の宣言は"var <変数名＞ <型> = <値>"のように宣言する


```
var message string = "aaaa"

func main() {
	fmt.Println(message)
}
```

- 一度に宣言

```
var foo, bar, buz string = "FOO", "BAR", "BUZ"
```


```
var (
a string = aaa
b        = bbb
c        = ccc
)
```

###関数内部での変数宣言と初期化
変数宣言と初期化を関数内部で行う場合は "var" と　型宣言を省略して":="という記号を用いることができる

```
func main(){
	message := "hello world"
	fmt.Println(message)
}
```

###定数
- 定数の宣言は"const <変数名＞ <型> = <値>"のように宣言する

```
const message string = "hello"
```

###ゼロ値
変数を宣言し、明示的に値を初期化しなかった場合、変数にはゼロ値と呼ばれる初期値が設定される

|型|ゼロ値|
|---|---|
|整数型|0|
|浮動小数点型|0.0|
|bool|false|
|string|""|
|配列|各要素がゼロ|
|構造体|各フィールドがゼロ値の構造体|
|その他の型|nil値(値がない、null状態のことを示す)|

###if文
if文の条件部に丸括弧は必要ありません。

```
func main() {
	a, b := 10, 20
	if a > b {
		fmt.Println("a")
	} else if a < b {
		fmt.Println("b")
	} else {
		fmt.Println("")
	}
}
```


###for文
- C, Javaとは異なり必要な条件部の丸括弧は不要

```
func main(){
	for i := 0; i < 10; i++ {
		fmt.Println(i)
	} 
}
```


- while文もforで表現

```
func main() {
	n := 0
	for n < 10 {
		fmt.Println(n)
		n++
	}
```

- 無限ループ

```
for {
	doSomething()
}
```


- break, continueを用いてループを制御可能

```
func main() {
	n :=0
	for {
		n++
		if n > 10 {
			break
		}
		if n % 2 == 0 {
			continue
		}
	}
}
```	


###switch
- Goのswitch文は非常に柔軟でいろいろな用途で利用できる

```
func main() {
	n := 10
	switch n {
		case 15:
			fmt.Println("FizzBuzz")
		case 5, 10:
			fmt.Println("BUzz")
		case 3, 6, 9:
			fmt.Println("Fizz")
		default:
			fmt.Println(n)
	}
}
```

- GoのSwitch文はC、Javaとは異なり、caseが１つ実行されると次のcaseに実行がうつることはなくSwitch文が終了します。処理を次のcaseに移したい場合は"fallthurough"と記載する必要があります

```
func main() {
	n := 10
	switch n {
		case 3:
			n = n - 1
			fallthrough
		case 2:
			n = n + 1
			fallthrough
		default:
			fallthrough
	}
}
```

- 式での分岐も可能です

```
func main() {

	n := 10
	switch {
		case n % 15 == 0:
			fmt.Println(n)
		case n % 5 == 0:
			fmt.Println(n)
	}
}
```

###fallthrough
C,Javaといった言語のswitch文はbreakにより処理を中断する必要があったが、Goのswitch文ではcaseが１つの処理で終了しますが、次のcase文に処理を進めたい場合は"fallthrough"を記載します。

```
func main() {
	n := 3
	switch n {
	case 3:
		n = n - 1
		fallthrough
	case 2:
		n = n - 1
		fallthrough
	case 1:
		n = n - 1
		fmt.Println(n)
	}
}
```

###式での分岐
Goのswitch文はcaseに式も指定可能

```
func main(){
	n := 10
	switch {
	case n%15 == 0:
		fmt.Println("Fizz")
	case n%5 == 0:
		fmt.Println("Buzz")
	}
}
```

###関数
func から初めて定義をします。

- 戻り値を持たない関数

```
func hello() {
	fmt.Println("hello")
}

func main() {
	hello()
}
```

- 引数がある場合

```
func sum(i, j int) {
	fmt.Println( i + j )
}

func main() {
	sum(1,2)
}

```

- 戻り値がある場合
- 下記では(int)と単一の型を戻り値としているが、戻り値は(int, int)のように記載して複数返すことが可能

```
func sum (i, j int) (int) {
	return i + j
}

func main() {
	n := sum(1,2)
	fmt.Println(n)
}
```

- エラーを返す関数
Goでは関数が複数の値を返せることを利用して、内部で発生したエラーを戻り値で表現すうる。関数の処理に成功した場合は“nil”にして、異常があった場合はエラーに値が入るようになります。

```
func main(){
	file, err := os.Open("a.go")
	if err != nil {
		//エラー処理を実施
		//returnなどで、他の処理に抜ける
	}	
}
```

- 名前付き戻り値
戻り値にあらかじめ名前をつけることができます

```
func div(i,j int) (result int, err error){ }
```

- 関数リテラル

無名の関数を作ることができます

```
func main () {
	func(i, j int){
		fmtp.Println(i + j)
	}(2,4)
}
```

 - 関数を変数に代入したり関数の引数に渡すことができる

```
var sum func(i, j int) = func(i, j int){
	fmt.Println(i + j)
}
```

###配列
Goの配列は固定長です。可変長配列は後述のスライスが該当します。

```
var arr [4]string

arr[0] = "a"
arr[1] = "b"
arr[2] = "c"
```

宣言と同時に初期化することも可能。[...]を用いると暗黙的に配列の長さを指定可能

```
arr := [4]string{"a","b","c","d"}
arr := [...]string{"a","b","c"}
```


###スライス
スライスは可変長配列として扱うことができる。

- 宣言

長さを指定せずに定義をする

```
var s []string
```

- append()
スライスの末尾に値を追加する

```
var s []string
s = append(s, "a")
s = append(s, "b")

fmt.Println(s) // a, b
```

- range
配列やスライスに格納された値を先頭から順番に処理する場合に使用

```
func main() {
	var arr [4]string
	arr[0] = "a"
	arr[1] = "b"
	arr[2] = "c"
	arr[3] = "d"

	for i, s := range arr {
		fmt.Println(i, s)
	}
}
```

- 値の切り出し

```
func main() {
	s := []int{0, 1, 2, 3, 4, 5}
	fmt.Println(s[2:4])      //2,3
	fmt.Println(s[0:len(s)]) //0,1,2,3,4,5
	fmt.Println(s[:3])       //0,1,2,3
	fmt.Println(s[3:])       //3,4,5
	fmt.Println(s[:])        //0,1,2,3,4,5
}
```

- 可変長引数

関数において引数を“_”のようい指定すると任意の数の引数をその型のスライスとしてうけとることができる。

```
func sum(nums ...int) (result int) {
	for _, n := range nums {
		result += n
	}
	return
}

func main() {
	fmt.Println(sum(1, 2, 3))
}

```

###マップ

- 宣言と初期化

intをキーにstringを格納するマップの宣言

```
var month map[int]string = map [int]string{}

month[1] = "Januaruy"
month[2] = "February"

fmt.Println(month)
```

宣言と同時に初期化した場合

```
func main() {
	month := map[int]string{
		1: "January",
		2: "February",
	}
	fmt.Println(month)
}
```

- マップの操作

マップから値を取り出す場合


```
func main() {
	month := map[int]string{
		1: "January",
		2: "February",
	}

	n := month[1]
	fmt.Println(n)
}
```

マップのキーの存在を調べる場合

```
func main() {
	month := map[int]string{
		1: "January",
		2: "February",
	}

	_, ok := month[2]
	if ok {
		fmt.Println(true) // "true"が表示される
		fmt.Println(month)
	} else {
		fmt.Println(false)
	}

	delete(month, 1)     // "monthのキー１のデータ削除"
	fmt.Println(month)
}
```

for文でkey,valueの値にアクセス、なお取り出される順番は保障されない

```
func main() {
	month := map[int]string{
		1: "January",
		2: "February",
	}
	
	for key, value := range month {
		fmt.Printf("%d %s\n", key, value)
	}
}
```


###ポインタ
ポインタ型変数は型の前に"*"をつけ、アドレスは変数の前に"&"をつけて取得する

```
func callByValue(i int) {
	i = 20
}

func callByRef(i *int) {
	*i = 20
}

func main() {
	var i int = 10
	callByValue(i) //値を渡す
	fmt.Println(i) //10
	callByRef(&i)  //アドレスを渡す
	fmt.Println(i) //20
}
```

###defer
ファイル操作などを行う場合、使用後のファイルは必ず閉じる必要がある。しかし、閉じる前に関数を抜ける、パニックなどで処理が中断するといったケースがあるので、そのような場合は"defer"を用いる。

```
package main

import (
	"fmt"
	"os"
)

func main() {
	file, err := os.Open("./b.go")
	if err != nil {
		fmt.Println(err)
	}
	defer file.Close() //main終了時に必ず呼ばれる
}
```

###パニック
配列や、スライスの範囲外へアクセスした場合や、ゼロ除算を行った場合などはエラーを返すことができないため、パニックという方法でエラーが発生する。このパニックで発生したエラーは"recover()"という組み込み関数で取得、エラー処理を実施してから関数を抜けることが可能

- recover()

```
package main

import (
	"fmt"
	"log"
)

func main() {
	defer func() {
		err := recover()   // エラー処理
		if err != nil {
			fmt.Println("defer func")
			log.Fatal(err)
		}
	}()
	a := []int{1, 2, 3}
	fmt.Println(a[10])
}
```

- panic()

```
package main

import (
	"errors"
	"fmt"
)

func main() {
	a := []int{1, 2, 3}
	fmt.Println(a[1])
	panic(errors.New("index out of range"))
}
```


------
##型システム

###type
下記のようなケースでは引数があっているため格納した値と意味が異なっても動作してしまう

```
package main

import (
	"fmt"
)

func ProcessTask(id, priority int) {
	fmt.Println(id, priority)
}

func main() {
	id := 3
	priority := 5
	ProcessTask(priority, id)
	ProcessTask(id, priority)
}
```

そこで、既存の型を拡張した独自の型を生成する

```
package main

import (
	"fmt"
)

type ID int
type Priority int

func ProcessTask(id ID, priority Priority) {
	fmt.Println(id, priority)
}

func main() {
	var id ID = 3
	var priority Priority = 5
	ProcessTask(id, priority)
	//	ProcessTask(priority, id) // これが有効なエントリだと、コンパイルエラー
}
```

###構造体
下記のとおりに宣言できる
フィールドの可視性は名前で決まり、大文字で始まる場合はパブリック、小文字で始まる場合はパッケージ内に閉じたスコープとなる

```
package main

import (
	"fmt"
)

type Task struct {
	ID     int
	Detail string
	done   bool
}

func main() {
	var task Task = Task{
		ID:     1,
		Detail: "buy the milk",
		done:   true,
	}
	fmt.Println(task.ID)
	fmt.Println(task.Detail)
	fmt.Println(task.done)
}
```

構造体には定義した順でパラメータを渡すことでフィールド名を省略可能

```
var task Task = Task {
	1, "buy the milk", tue
}
```

構造体に明示的に値を渡さなかった場合は初期値がはいる

```
package main

import (
	"fmt"
)

type Task struct {
	ID     int
	Detail string
	done   bool
}

func main() {
	task := Task{}
	fmt.Println(task.ID)
	fmt.Println(task.Detail)
	fmt.Println(task.done)
}
```

###ポインタ型
構造体をポインタとして呼び出しできます

```
var task Task = Task{} //Task型
var task *Task = &Task{} // ポインタ型
```

###new
構造体の初期化を行う場合new()を用いることが可能

```
package main

import (
	"fmt"
)

type Task struct {
	ID     int
	Detail string
	done   bool
}

func main() {
	task := Task{}
	fmt.Println(task.ID)
	fmt.Println(task.Detail)
	fmt.Println(task.done)
}
```

###コンストラクタ
Goにはコンストラクタ機能は存在しませんが、代わりにNewで始まる関数を定義して、内部で構造体
を定義するのが通例

```
package main

import (
	"fmt"
)

type Task struct {
	ID     int
	Detail string
	done   bool
}

func NewTask(id int, detail string) *Task {
	task := &Task{
		ID:     id,
		Detail: detail,
		done:   false,
	}
	return task
}

func main() {
	task := NewTask(1, "buy the milk")
	fmt.Printf("%+v\n", task)
}
```

###メソッド
型にはメソッドを定義できます。メソッドはそのメソッドを実行した対象の型をレシーバーとして受け取り、メソッドの内部で使用できます。

```
package main

import (
	"fmt"
)

//Task構造体を定義
type Task struct {
	ID     int
	Detail string
	done   bool
}

//Taskのコンストラクタ
//“task = &Task"によりTaskのアドレスをtaskに格納して、Taskポインタ(*Task)を返却している
func NewTask(id int, detail string) *Task {　
	task := &Task{
		ID:     id,
		Detail: detail,
		done:   false,
	}
	return task
}

// Taskを引数とし、String() を返却する関数
func (task Task) String() string {
	str := fmt.Sprintf("%d) %s", task.ID, task.Detail)
	return str
}

// Taskのポインタに、trueという値を埋め込むメソッド
func (task *Task) Finish() {
	task.done = true
}

func main() {
	task := NewTask(1, "buy the milk")
	task.Finish()
	fmt.Printf("%+v\n", task)
}

```


------
##インタフェース

###インターフェースの宣言

インタフェースの名前は実装すべき関数名が単純な場合は"er"をつける慣習がある

```
type Stringer interface {
	String() string
}
```	


###インタフェースの実装
GoではJavaのImplements構文のように、インタフェースを実装していることを明示的に宣言する構文がなく、型がインタフェースに定義されたメソッドを実装していれば、インタフェースを満たしているとみなす。


```
func Print(stringer Stringer) {
	fmt.Println(stringer.String())
}

Print(task)
```


###代表的なインタフェース
Goであらかじめ実装されている代表的なインタフェースを示します。

|インタフェース名|定義|説明|
|---|---|---|
|io.Reader|Read(p []byte)(n int, err error)|リソースからデータの読み出しを行う|
|io.Writer|Write(p []byte)(n int, err error)|リソースからデータの書き出しを行う|
|io.Closer|Close() error |リソースのクローズ処理を行う|
|http.Handler|ServeHTTP(ResponseWriter, *Request)|HTTPリクエストに対するレスポンスを行う|
|json.Marshaler|MarshalJSON()([]byte, error)|構造体やスライスなどをJSONに変換する|
|json.Unmarshaler|UnmarshalJSON([]byte)error|JSONを構造体やスライスなどに変換する|


###interface{}
下記のようなインタフェースは実装すべきメソッドを指定していない。つまり、すべての型はこのインタフェースを実装していることになる。これを利用すると、どんな型も受け取ることができる関数を定義できる

```

type Any Interface {
}

func Do(e Any){
}

Do("a")
```

```
func Do(e interface{}){
	//do something
}

Do("a")　//どのような型でもわたすことができる
```

fmt.Println()などのいわゆるプリント関数は下記のように定義されているため、型を気にせずに複数の値を渡すことができる

```
func Println(a ...interface{}) (n int, err error)
```


------
##型の埋め込み
Goでは継承はサポートされていない代わりに他の型を埋め込む（Embbed)という方式で構造体やインタフェースの振る舞いを拡張できる


###構造体の埋め込み


```
type User struct{
	FirstName string
	LastName  string
}

func (u *User) Fullname() string {
	fullname := fmt.Sprintf("%s %s", u.FirstName, u.LastName)
	return fullname
}

func NewUser(firstName, lastName string) *User {
	return &User{
		FirstName: firstName,
		LastName:  lastName,
}

type Task struct {
	ID		int
	Detail	string
	done bool
	*User //Userを埋め込む
}

func NewTask(id int, detail, firstName, lastName string) *Task {
	task := &Task {
		ID:		id,
		Detail: detail,
		done:	false,
		User:	NewUser(firstName, lastName),
		}
		return task
}

func main() {
	task := NewTask(1, "buy the milk", "Jack", "Daniel")
	fmt.Println(task.FirstName)
	fmt.Println(task.LastName)
	fmt.Println(task.FullName())
	fmt.Println(task.User)
}

```	






