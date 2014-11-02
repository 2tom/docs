python programming
===================
---

### pip
- パッケージ確認

```
$ pip freeze
```
---

### virtualenv
- 仮想環境作成

```
$ virtualenv --distribute [dir]
$ sudo chown -R tera [dir]
```

- 仮想環境有効化

```
$ source [dir]/bin/activate
()$ cd [dir]
```

- 仮想環境から抜ける

```
()$ deactivate
``` 

---
### Code Check
#### pep8
- CodingStyleCheckを実施してくれる

```
()$ pip install pep8
```

- pep8 に適合したコードに自動修復

```
()$ pip install autopep8
()$ autopep8 -i [file]
```

- autopep8 をカレントディレクトリ配下に実行

```
$() pep8 . | cut -d: -f1 | sort | uniq | xargs autopep8 -i
```


#### pyflakes
- Syntax Check 実施してくれる、pychecker, pylint なども有名

```
()$ pip install pyflakes
```
- pyflakes をカレントディレクトリ配下に実行

```
()$ find . -name \*.py | xargs pyflakes 
```

---
### Code Check
### django
```
()# pip install django
()# django-manage.py startproject [proj]
()# 
```