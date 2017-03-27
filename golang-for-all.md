みんなのGo
==================

## 環境作成

1. pkgインストール
```
$ brew update
$ brew install go
```

2. GOROOTにPATHを通す
```
$ vi ~/.bash_profile
export PATH=$PATH:/usr/local/opt/go/libexec/bin
```

3. GOPATHの設定
- GOPATHとは、Go言語開発を行うワークスペース
- 必ず定義が必要
- '$HOME/go', '$HOME/dev' などにしている人が多い

```
$ vi ~/.bash_profile
export GOPATH=$HOME/WORK/go
export PATH=$PATH:$GOPATH/bin
```

## REPLパッケージインストール
- goreはREPLツール
- gore -autoimport で起動
- gocode, pp, godocを入れると、補完、出力ハイライト、APIドキュメント参照が可能になる

```
$ go get github.com/motemen/gore
$ go get github.com/nsf/gocode
$ go get github.com/k0kubun/pp
$ go get golang.org/x/tools/cmd/godoc
```

## GOPATH管理のためghqを導入

