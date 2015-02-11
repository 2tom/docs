###add

	git add **/*.conf

###commit
     git commit
     git commit —amend     : commit直前の状態に戻す

###push
     git push <remote_name> <localbranch>
     git push <remote_name> <localbranch>:<remotebranch>
     git push —tags <remote_name>
     git push —delete <remote> tag_name
###clone
     git clone ssh://user@host:port/path/to/repo.git
     git clone https://host:port/path/to/repo.git
     git clone file:///path/to/repo.git/
###branch
     git branch
     git branch -r <remote_name>
     git branch -a
     git branch <branch_name>     :ローカルブランチ作成
     git branch -d <branch_name>
     git branch -r -d <remote_name>/<branch_name>
     git branch -m <old_branch> <new_branch>
###checkout
     git checkout <branch>
     git checkout -b <newbranch> <startpoint>
     git checkout <path>
###fetch
     git fetch <remote_name>
     git fetch —all
     git fetch -p
###pull
     git pull <remote_name> <branch>
     git pull origin master










