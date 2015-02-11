git Tips.
=============

- ローカル->リモート

```
$ mkdir -p <dir> ; cd <dir>
$ git init .
~~ 作業~~
$ git add .
$ git status
$ git commit -m "init" 
$ git remote add origin https://github.com/<user>/<dir>.git
$ git config branch.master.remote origin
$ git config branch.master.merge refs/heads/master
```

``` 
$ git commit -m "test"
$ git tag
show
v0.01
$ git tag -a v0.02 -m "tag added"
$ git push --tags
$ git tag -d <tag>
$ git push origin --tags
```

- clone->local->remote

```
$ git clone https://github.com/2tom/ocp-dockerfiles.git
$ git branch aaa/bbb
$ git checkout aaa/bbb
~作業~
$ git commit -a -m "test"
$ git branch master
$ git merge aaa/bbb
$ git branch -d aaa/bbb
$ git tag -a v0.03 -m "tag added"
$ git push origin --tags
```
