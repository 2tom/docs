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
### test
#### unittest, nose
- unit testを実行するためのツール "unittest"はデフォルトでバンドル
- nose は3rd-partyツール。unittestよりも容易にテストが記載でき、プラグインも豊富

```
()$ pip install nose
()$ nosetests
```

#### coverage
- 実行されたステートメント情報を収集
- nose のプラグインを使うとテスト中にどのコードが実行されたか、確認できる

```
()$ pip install coverage
```



#### mock
- テスト対象が依存しているオブジェクトをmockに入れ替えるライブラリ

```
()$ pip install mock
```

#### WebTest
- Webアプリケーションの機能テスト用のライブラリ
- WSGIアプリケーションに擬似的なリクエストを実行して結果を取得



```
()$ pip install webtest
```


---
参考URL
http://achiku.github.io/2014/04/04/road-to-django-best-practice.html

http://daigo3.github.io/fullstackpython.github.com/django.html

http://django-mongodb-engine.readthedocs.org/en/latest/topics/setup.html#

http://nwpct1.hatenablog.com/entry/how-to-write-unittest-on-django


http://www.revsys.com/blog/2014/nov/21/recommended-django-project-layout/


---
### Web Framework
### django
- MVCに対応したPythonのWebFramework


```
()# pip install django
()# django-manage.py startproject [proj]
()# cd [proj]
()# python manage.py startapp [app]
```

---
### mongodb
- django の MONGODB ORM

```
()# pip install django-