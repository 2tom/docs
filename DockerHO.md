Docker HandsOn
===========

**BASIC**

-------
### Table of contents
[toc]

##<i class="icon-cog"></i> HandsOn
Docker のインストールから基本コマンドの実行等を記載しています。HandsOnの後に各設定値の説明等々がございますのでご参照ください。
本資料は 64bit 環境での手順となります。32bit環境の場合は適宜読み替えをお願いします。

-------
## 環境情報
本ドキュメント作成に使用した環境情報をまとめます。HandsOn実施に当たってはCentOSが稼動する環境であれば問題ありません。
| 項目 | バージョン |
| ---- | --------- -|
| ホストマシン | Lenovo X230 |
| ホストOS | MS Windows7 Professional |
| HV | VMware Player |
| ゲストOS | CentOS6.5 (minimal) |
| docker | 1.2.0(build fa7b24f/1.2.0)|



-------
## ゲストOSセットアップ 
HandsOn用に環境を用意します。

### 仮想マシン準備

- 事前準備
>- VMwarePlayerインストール
>- CentOS 6.5 minimal のISOイメージダウンロード(マシン環境に合わせて取得してください）

- マシン作成
> - 環境に合わせてセットアップを行ってください。
> - CentOSが稼動可能な環境であれば問題ありません。

- 環境情報 
> | 項目 | 内容 |
> | ---- | ---- |
> | Machine | IBM X230 |
> | VM | VMware player |
> | タイプ | Linux |
> | バージョン | Redhat 64bit |
> | CPU | x1 |
> | メモリサイズ | 2GB |
> | ハードドライブ | 仮想ディスクを作成する |
> | ハードドライブのファイルタイプ | QCOW2 |
> | ファイルの場所 | *デフォルト* |
> | ディスクサイズ | 20GB |

- マシン設定変更
> - ネットワークを選択
> - アダプター1 をNAT用
> - アダプター2 をホストオンリー用


### CentOSインストール
- minimalインストール


### OS初期設定
- SELINUX停止

```
# vi /etc/selinux/config
SELINUX=disabled
```

- sysctl 編集

```
# vi /etc/sysctl.conf
net.ipv4.ip_forward = 1
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1

# sysctl -p
# shutdown -r now
```

- ifcfg-eth0
```
# vi /etc/sysconfig/network-scripts/ifcfg-eth0
ONBOOT=yes
NM_CONTROLLED=no
BOOTPROTO=static
IPADDR=192.168.153.51
NETMASK=255.255.255.0
GATEWAY=192.168.153.2
DNS1=192.168.153
```

- ifcfg-eth1
```
# vi /etc/sysconfig/network-scripts/ifcfg-eth1
ONBOOT=yes
NM_CONTROLLED=no
BOOTPROTO=static
IPADDR=192.168.88.51
NETMASK=255.255.255.0
```

- Proxy設定（Proxy配下のNWの場合）
下記ファイルを配置

```
# vi /etc/profile.d/proxy.sh
↓下記内容を追記
#!/bin/sh
function setproxy(){
        proxy_uri="aaaa:8080"
        echo "PROXY_URI: ${proxy_uri}"
        echo -n "PROXY USER: "
        read proxy_id
        echo -n "PROXY PASSWORD: "
        read -s proxy_pw
        echo
        export http_proxy="http://\${proxy_id}:\${proxy_pw}@\${proxy_uri}"
        export https_proxy="http://\${proxy_id}:\${proxy_pw}@\${proxy_uri}"
        curl -I http://google.co.jp
}
```

```
# source /etc/profile.d/proxy.sh
# setproxy
PROXY_URI: aaa:8080
PROXY USER: [z付社員番号]
PROXY PASSWORD: [Knightのパスワード]
HTTP/1.1 301 Moved Permanently
〜省略〜
```

- OS/PKGアップデート

```
# yum -y install yum-plugin-fastestmirror
# yum -y update
# yum clean all
# shutdown -r now
```


-------
## Dockerセットアップ
Dockerのインストール及び、設定を行います。

### Dockerインストール

- EPELレポジトリ追加
```
# setproxy
PROXY_URI: aaaa:8080
PROXY USER: [z付社員番号]
PROXY PASSWORD: [Knightのパスワード\]
～省略～

# rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
# sed -i.org 's/enabled=1/enabled=0/' /etc/yum.repos.d/epel.repo
```

- Dockerインストール
```
# yum install -y --enablerepo=epel docker-io
# rpm -q docker-io
docker-io-1.2.0-3.el6.x86_64 
# docker -v
Docker version 1.2.0, build fa7b24f/1.2.0
```

> <i class="icon-pencil"></i>**Note:  追加されたパッケージは以下の通り**
> docker-io-1.2.0-3.el6.x86_64
> gpg-pubkey-0608b895-4bd22942
> libcgroup-0.40.rc1-15.el6_6.x86_64
> lua-alt-getopt-0.7.0-1.el6.noarch
> lua-filesystem-1.4.2-1.el6.x86_64
> lua-lxc-1.0.6-1.el6.x86_64
> lxc-1.0.6-1.el6.x86_64
> lxc-libs-1.0.6-1.el6.x86_64
> xz-4.999.9-0.5.beta.20091007git.el6.x86_64


### Docker起動
- サービス起動
```
# service docker start
# ps -ef | grep docker | grep -v grep 
root      1455     1  0 04:10 pts/0    00:00:00 /usr/bin/docker -d
```

- Docker情報の取得
下記よりセットアップ情報が確認できます。

```
# docker info
Containers: 0
Images: 0
Storage Driver: devicemapper
Pool Name: docker-253:0-523433-pool
Pool Blocksize: 64 Kb
Data file: /var/lib/docker/devicemapper/devicemapper/data
Metadata file: /var/lib/docker/devicemapper/devicemapper/metadata
  Data Space Used: 291.5 Mb
  Data Space Total: 102400.0 Mb
  Metadata Space Used: 0.7 Mb
  Metadata Space Total: 2048.0 Mb
Execution Driver: native-0.2
Kernel Version: 2.6.32-504.el6.x86_64
Operating System: <unknown>
```

### デバイス状態確認
- Devicemapper デバイスの確認
CentOS,RHELはDeviceMapperが利用されています
```
# dmsetup ls --tree
vg_handson01-lv_swap (253:1)
 mq (8:2)
vg_handson01-lv_root (253:0)
 mq (8:2)
docker-253:0-523433-pool (253:2)
 tq (7:0)
 mq (7:1)
```

- docker0  Bridgeの確認

```
# brctl show
bridge name     bridge id               STP enabled     interfaces
docker0         8000.000000000000       no
```

- docker0用 NAT設定
```
# iptables -L -t nat
Chain PREROUTING (policy ACCEPT)
target     prot opt source               destination
DOCKER     all  --  anywhere             anywhere            ADDRTYPE match dst-type LOCAL

Chain POSTROUTING (policy ACCEPT)
target     prot opt source               destination
MASQUERADE  all  --  172.17.0.0/16        anywhere
MASQUERADE  all  --  172.17.0.0/16        anywhere

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination
DOCKER     all  --  anywhere            !loopback/8          ADDRTYPE match dst-type LOCAL

Chain DOCKER (2 references)
target     prot opt source               destination'
```

-------
##  Docker イメージの登録

### 公式リポジトリより登録（From DockerHub)

- 公式リポジトリの検索
```
# docker search centos | head
NAME                                            DESCRIPTION                                     STARS     OFFICIAL   AUTOMATED
centos                                          The official build of CentOS.                   572       [OK]       
tianon/centos                                   CentOS 5 and 6, created using rinse instea...   28                   
ansible/centos7-ansible                         Ansible on Centos7                              14                   [OK]
saltstack/centos-6-minimal                                                                      7                    [OK]
blalor/centos                                   Bare-bones base CentOS 6.5 image                7                    [OK]
ariya/centos6-teamcity-server                   TeamCity Server 8.1 on CentOS 6                 6                    [OK]
```
<i class="icon-pencil"></i>**Note: 詳細は公式サイトを確認してください　https://registry.hub.docker.com/**


- イメージ取得
DockerHubよりイメージを取得します。
今回はCentOS公式リポジトリよりCentOS6(Latest)を取得します。
```
# docker pull centos:centos6
Pulling repository centos
70441cac1ed5: Download complete 
511136ea3c5a: Download complete 
5b12ef8fd570: Download complete 
```

- イメージ確認
取得したイメージがDockerリポジトリに登録されたことを確認します。
イメージファイルの依存関係をTree状で確認する際は"-t"オプションを付与します。
OS上では"var/lib/docker/graph/"の配下にイメージ情報が保存されます

```
# docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
centos              centos6             70441cac1ed5        16 hours ago        215.8 MB

# docker images -t
Warning: '-t' is deprecated, it will be removed soon. See usage.
└─511136ea3c5a Virtual Size: 0 B
  └─5b12ef8fd570 Virtual Size: 0 B
    └─70441cac1ed5 Virtual Size: 215.8 MB Tags: centos:centos6
```

- OS上のイメージファイル保存先

```
# find /var/lib/docker/graph
/var/lib/docker/graph
/var/lib/docker/graph/511136ea3c5a64f264b78b5433614aec563103b4d4702f3ba7d4d2698e22c158
/var/lib/docker/graph/511136ea3c5a64f264b78b5433614aec563103b4d4702f3ba7d4d2698e22c158/layersize
/var/lib/docker/graph/511136ea3c5a64f264b78b5433614aec563103b4d4702f3ba7d4d2698e22c158/json
/var/lib/docker/graph/70441cac1ed570d6c84b35382c9914c327e208f93a9d2e5227f6ee6c1111cb81
/var/lib/docker/graph/70441cac1ed570d6c84b35382c9914c327e208f93a9d2e5227f6ee6c1111cb81/layersize
/var/lib/docker/graph/70441cac1ed570d6c84b35382c9914c327e208f93a9d2e5227f6ee6c1111cb81/json
/var/lib/docker/graph/_tmp
/var/lib/docker/graph/5b12ef8fd57065237a6833039acc0e7f68e363c15d8abb5cacce7143a1f7de8a
/var/lib/docker/graph/5b12ef8fd57065237a6833039acc0e7f68e363c15d8abb5cacce7143a1f7de8a/layersize
/var/lib/docker/graph/5b12ef8fd57065237a6833039acc0e7f68e363c15d8abb5cacce7143a1f7de8a/json 
```


###  Docker用オリジナルイメージ登録
手動でDockerへImportするOSイメージを作成します。
なお、Packerでも作成可能ですので、興味があれば調べてください。

- febootstrap インストール

```
# yum -y install febootstrap xz
```

- OSイメージ作成

```
# febootstrap -i bash -i coreutils -i tar -i bzip2 -i gzip -i vim-minimal -i wget -i patch -i diffutils -i iproute -i yum centos centos65 "http://ftp.riken.jp/Linux/centos/6.5/os/x86_64/" -u "http://ftp.riken.jp/Linux/centos/6.5/updates/x86_64/"
```

- baseイメージの登録
```
# touch centos65/etc/resolv.conf
# touch centos65/sbin/init 
# tar --numeric-owner -Jcpf centos65.tar.xz -C centos65 .
# cat centos65.tar.xz | docker import - local/centos65
6cb2b7cbe999eed3580a931b8262b4942368f13fea76c7f8229972b7e70d83c6
# docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
local/centos65      latest              6cb2b7cbe999        22 seconds ago      260.1 MB
centos              centos6             70441cac1ed5        20 hours ago        215.8 MB
```

-------
##  Dockerコンテナ起動
### インタラクティブモード
インタラクティブモードでコンテナを起動した後基本的な一連の操作を行います。

- インタラクティブモードで起動
Dockerをインタラクティブモードで起動するためには"-i"オプションを用いてコンテナを起動します。
```
# docker ps -a
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES

# docker run -i -t centos:centos6 /bin/bash
[root@0edd781ffee1 /]# 
```

- コンテナのホスト名確認
ホスト名はコンテナIDになります
```
[root@0edd781ffee1 /]# hostname
0edd781ffee1
```

- コンテナのディスクを確認
Rootディスクは10GBです。ハードコーディングされているため、サイズを変更したい場合はソースコードを編集して、Buildしてください。

```
[root@0edd781ffee1 /]# df -h
Filesystem            Size  Used Avail Use% Mounted on
rootfs                9.9G  387M  9.0G   5% /
/dev/mapper/docker-8:1-393760-0edd781ffee187ff8d5ffc488cc399f2ffae8dc2d113bb2360b9569a32cdf215
                      9.9G  387M  9.0G   5% /
tmpfs                 295M     0  295M   0% /dev
shm                    64M     0   64M   0% /dev/shm
/dev/sda1             7.9G  1.5G  6.1G  20% /etc/resolv.conf
/dev/sda1             7.9G  1.5G  6.1G  20% /etc/hostname
/dev/sda1             7.9G  1.5G  6.1G  20% /etc/hosts
tmpfs                 295M     0  295M   0% /proc/kcore
```

- NIC確認
NICはeth0が作成され、docker0 ブリッジと同一セグメントのIPアドレスが付与されます。
```
[root@0edd781ffee1 /]# ifconfig
eth0      Link encap:Ethernet  HWaddr 0E:EB:27:95:32:88  
          inet addr:172.17.0.6  Bcast:0.0.0.0  Mask:255.255.0.0
          inet6 addr: fe80::ceb:27ff:fe95:3288/64 Scope:Link
          UP BROADCAST RUNNING  MTU:1500  Metric:1
          RX packets:6 errors:0 dropped:0 overruns:0 frame:0
          TX packets:7 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:468 (468.0 b)  TX bytes:558 (558.0 b)

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)
```

- コンテナ内部でオペレーション実施
```
[root@0edd781ffee1 ~]# touch /root/test
[root@0edd781ffee1 ~]# echo "aaaa" > /root/testfile
[root@0edd781ffee1 ~]# useradd tera
[root@0edd781ffee1 ~]# grep tera /etc/passwd
tera:x:500:500::/home/tera:/bin/bash
[root@0edd781ffee1 ~]# passwd tera
[root@0edd781ffee1 ~]# passwd tera
Changing password for user tera.
New password: 
BAD PASSWORD: it is too short
BAD PASSWORD: is too simple
Retype new password: 
passwd: all authentication tokens updated successfully.
```

- コンテナとのアクセスを中断
```
CTRL+pq 
#
```

- コンテナの状態確認
コンテナが稼働していることを確認
```
# docker ps -a
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
0edd781ffee1        centos:centos6      "/bin/bash"         5 minutes ago       Up 5 minutes                            sleepy_davinci 
```

- コンテナ内プロセス確認
基本的にはDockerは１コンテナ、１プロセス（コマンド）を推奨しているため、通常は対象プロセスが１つ見えます。

```
# docker top 0edd781ffee1
```

- コンテナの標準出力確認
```
# docker logs 0edd781ffee1
```

- コンテナ起動後からのファイルシステム差分確認
コンテナ起動時から、現在までの差分情報を確認することができます。
```
# docker diff 0edd781ffee1
C /home
A /home/tera
A /home/tera/.bash_profile
A /home/tera/.bashrc
A /home/tera/.bash_logout
C /var/spool/mail
A /var/spool/mail/tera
C /var/log/lastlog
C /etc
C /etc/shadow-
C /etc/gshadow
C /etc/group-
C /etc/shadow
C /etc/gshadow-
C /etc/passwd
C /etc/group
C /root
A /root/testfile
A /root/.bash_history
```

- 稼働中コンテナのファイル確認
コンテナ稼働中は"/var/lib/docker/devicemapper/mnt/[ContainerID]/"にrootfsはマウントされています。
これらはコンテナ停止時にマウントが解除されます。
```
# find /var/lib/docker | grep testfile
/var/lib/docker/devicemapper/mnt/0edd781ffee187ff8d5ffc488cc399f2ffae8dc2d113bb2360b9569a32cdf215/rootfs/root/testfile

# cat /var/lib/docker/devicemapper/mnt/0edd781ffee187ff8d5ffc488cc399f2ffae8dc2d113bb2360b9569a32cdf215/rootfs/root/testfile
aaaa
```

- コンテナのOS上での管理情報確認
execdriverはlibcontainerを制御しています。
"/var/lib/docker/execdriver/native/" 配下のcontainer.json、state.jsonによりNamespace, Cgroups, Bridge, vethに関する情報を確認できます。
```
# cat /var/lib/docker/execdriver/native/0edd781ffee187ff8d5ffc488cc399f2ffae8dc2d113bb2360b9569a32cdf215/state.json | python -mjson.tool
{
    "cgroup_paths": {
        "blkio": "/cgroup/blkio/docker/0edd781ffee187ff8d5ffc488cc399f2ffae8dc2d113bb2360b9569a32cdf215", 
        "cpu": "/cgroup/cpu/docker/0edd781ffee187ff8d5ffc488cc399f2ffae8dc2d113bb2360b9569a32cdf215", 
        "cpuacct": "/cgroup/cpuacct/docker/0edd781ffee187ff8d5ffc488cc399f2ffae8dc2d113bb2360b9569a32cdf215", 
        "cpuset": "/cgroup/cpuset/docker/0edd781ffee187ff8d5ffc488cc399f2ffae8dc2d113bb2360b9569a32cdf215", 
        "devices": "/cgroup/devices/docker/0edd781ffee187ff8d5ffc488cc399f2ffae8dc2d113bb2360b9569a32cdf215", 
        "freezer": "/cgroup/freezer/docker/0edd781ffee187ff8d5ffc488cc399f2ffae8dc2d113bb2360b9569a32cdf215", 
        "memory": "/cgroup/memory/docker/0edd781ffee187ff8d5ffc488cc399f2ffae8dc2d113bb2360b9569a32cdf215"
    }, 
    "init_pid": 9691, 
    "init_start_time": "1105627", 
    "network_state": {
        "veth_child": "veth355c", 
        "veth_host": "veth48e5"
    }
}

# cat /var/lib/docker/execdriver/native/0edd781ffee187ff8d5ffc488cc399f2ffae8dc2d113bb2360b9569a32cdf215/container.json | python -mjson.tool
{
    "capabilities": [
        "CHOWN", 
        "DAC_OVERRIDE", 
        "FSETID", 
        "FOWNER", 
        "MKNOD", 
        "NET_RAW", 
        "SETGID", 
        "SETUID", 
        "SETFCAP", 
        "SETPCAP", 
        "NET_BIND_SERVICE", 
        "SYS_CHROOT", 
        "KILL", 
        "AUDIT_WRITE"
    ], 
    "cgroups": {
        "allowed_devices": [
            {
                "cgroup_permissions": "m", 
                "major_number": -1, 
                "minor_number": -1, 
                "type": 99
            }, 
            {
                "cgroup_permissions": "m", 
                "major_number": -1, 
                "minor_number": -1, 
                "type": 98
            }, 
            {
                "cgroup_permissions": "rwm", 
                "major_number": 5, 
                "minor_number": 1, 
                "path": "/dev/console", 
                "type": 99
            }, 
            {
                "cgroup_permissions": "rwm", 
                "major_number": 4, 
                "path": "/dev/tty0", 
                "type": 99
            }, 
            {
                "cgroup_permissions": "rwm", 
                "major_number": 4, 
                "minor_number": 1, 
                "path": "/dev/tty1", 
                "type": 99
            }, 
            {
                "cgroup_permissions": "rwm", 
                "major_number": 136, 
                "minor_number": -1, 
                "type": 99
            }, 
            {
                "cgroup_permissions": "rwm", 
                "major_number": 5, 
                "minor_number": 2, 
                "type": 99
            }, 
            {
                "cgroup_permissions": "rwm", 
                "major_number": 10, 
                "minor_number": 200, 
                "type": 99
            }, 
            {
                "cgroup_permissions": "rwm", 
                "file_mode": 438, 
                "major_number": 1, 
                "minor_number": 3, 
                "path": "/dev/null", 
                "type": 99
            }, 
            {
                "cgroup_permissions": "rwm", 
                "file_mode": 438, 
                "major_number": 1, 
                "minor_number": 5, 
                "path": "/dev/zero", 
                "type": 99
            }, 
            {
                "cgroup_permissions": "rwm", 
                "file_mode": 438, 
                "major_number": 1, 
                "minor_number": 7, 
                "path": "/dev/full", 
                "type": 99
            }, 
            {
                "cgroup_permissions": "rwm", 
                "file_mode": 438, 
                "major_number": 5, 
                "path": "/dev/tty", 
                "type": 99
            }, 
            {
                "cgroup_permissions": "rwm", 
                "file_mode": 438, 
                "major_number": 1, 
                "minor_number": 9, 
                "path": "/dev/urandom", 
                "type": 99
            }, 
            {
                "cgroup_permissions": "rwm", 
                "file_mode": 438, 
                "major_number": 1, 
                "minor_number": 8, 
                "path": "/dev/random", 
                "type": 99
            }
        ], 
        "name": "0edd781ffee187ff8d5ffc488cc399f2ffae8dc2d113bb2360b9569a32cdf215", 
        "parent": "docker"
    }, 
    "environment": [
        "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin", 
        "HOSTNAME=0edd781ffee1", 
        "TERM=xterm"
    ], 
    "hostname": "0edd781ffee1", 
    "mount_config": {
        "device_nodes": [
            {
                "cgroup_permissions": "rwm", 
                "major_number": 10, 
                "minor_number": 229, 
                "path": "/dev/fuse", 
                "type": 99
            }, 
            {
                "cgroup_permissions": "rwm", 
                "file_mode": 438, 
                "major_number": 1, 
                "minor_number": 3, 
                "path": "/dev/null", 
                "type": 99
            }, 
            {
                "cgroup_permissions": "rwm", 
                "file_mode": 438, 
                "major_number": 1, 
                "minor_number": 5, 
                "path": "/dev/zero", 
                "type": 99
            }, 
            {
                "cgroup_permissions": "rwm", 
                "file_mode": 438, 
                "major_number": 1, 
                "minor_number": 7, 
                "path": "/dev/full", 
                "type": 99
            }, 
            {
                "cgroup_permissions": "rwm", 
                "file_mode": 438, 
                "major_number": 5, 
                "path": "/dev/tty", 
                "type": 99
            }, 
            {
                "cgroup_permissions": "rwm", 
                "file_mode": 438, 
                "major_number": 1, 
                "minor_number": 9, 
                "path": "/dev/urandom", 
                "type": 99
            }, 
            {
                "cgroup_permissions": "rwm", 
                "file_mode": 438, 
                "major_number": 1, 
                "minor_number": 8, 
                "path": "/dev/random", 
                "type": 99
            }
        ], 
        "mounts": [
            {
                "destination": "/etc/resolv.conf", 
                "private": true, 
                "source": "/var/lib/docker/containers/0edd781ffee187ff8d5ffc488cc399f2ffae8dc2d113bb2360b9569a32cdf215/resolv.conf", 
                "type": "bind", 
                "writable": true
            }, 
            {
                "destination": "/etc/hostname", 
                "private": true, 
                "source": "/var/lib/docker/containers/0edd781ffee187ff8d5ffc488cc399f2ffae8dc2d113bb2360b9569a32cdf215/hostname", 
                "type": "bind", 
                "writable": true
            }, 
            {
                "destination": "/etc/hosts", 
                "private": true, 
                "source": "/var/lib/docker/containers/0edd781ffee187ff8d5ffc488cc399f2ffae8dc2d113bb2360b9569a32cdf215/hosts", 
                "type": "bind", 
                "writable": true
            }
        ]
    }, 
    "namespaces": {
        "NEWIPC": true, 
        "NEWNET": true, 
        "NEWNS": true, 
        "NEWPID": true, 
        "NEWUTS": true
    }, 
    "networks": [
        {
            "address": "127.0.0.1/0", 
            "gateway": "localhost", 
            "mtu": 1500, 
            "type": "loopback"
        }, 
        {
            "address": "172.17.0.7/16", 
            "bridge": "docker0", 
            "gateway": "172.17.42.1", 
            "mtu": 1500, 
            "type": "veth", 
            "veth_prefix": "veth"
        }
    ], 
    "restrict_sys": true, 
    "tty": true
}

```

- コンテナの情報確認

```
IPアドレス確認
# docker inspect --format="{{.NetworkSettings.IPAddress}}" 0edd781ffee1
172.17.0.6

コンテナの詳細情報確認
# docker inspect 0edd781ffee1 
[{
    "Args": [],
    "Config": {
        "AttachStderr": true,
        "AttachStdin": true,
        "AttachStdout": true,
        "Cmd": [
            "/bin/bash"
        ],
        "CpuShares": 0,
        "Cpuset": "",
        "Domainname": "",
        "Entrypoint": null,
        "Env": [
            "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
        ],
        "ExposedPorts": null,
        "Hostname": "0edd781ffee1",
        "Image": "centos:centos6",
        "Memory": 0,
        "MemorySwap": 0,
        "NetworkDisabled": false,
        "OnBuild": null,
        "OpenStdin": true,
        "PortSpecs": null,
        "StdinOnce": true,
        "Tty": true,
        "User": "",
        "Volumes": null,
        "WorkingDir": ""
    },
    "Created": "2014-11-04T15:12:25.53049348Z",
    "Driver": "devicemapper",
    "ExecDriver": "native-0.2",
    "HostConfig": {
        "Binds": null,
        "CapAdd": null,
        "CapDrop": null,
        "ContainerIDFile": "",
        "Devices": [],
        "Dns": null,
        "DnsSearch": null,
        "Links": null,
        "LxcConf": [],
        "NetworkMode": "bridge",
        "PortBindings": {},
        "Privileged": false,
        "PublishAllPorts": false,
        "RestartPolicy": {
            "MaximumRetryCount": 0,
            "Name": ""
        },
        "VolumesFrom": null
    },
    "HostnamePath": "/var/lib/docker/containers/0edd781ffee187ff8d5ffc488cc399f2ffae8dc2d113bb2360b9569a32cdf215/hostname",
    "HostsPath": "/var/lib/docker/containers/0edd781ffee187ff8d5ffc488cc399f2ffae8dc2d113bb2360b9569a32cdf215/hosts",
    "Id": "0edd781ffee187ff8d5ffc488cc399f2ffae8dc2d113bb2360b9569a32cdf215",
    "Image": "70441cac1ed570d6c84b35382c9914c327e208f93a9d2e5227f6ee6c1111cb81",
    "MountLabel": "",
    "Name": "/sleepy_davinci",
    "NetworkSettings": {
        "Bridge": "docker0",
        "Gateway": "172.17.42.1",
        "IPAddress": "172.17.0.4",
        "IPPrefixLen": 16,
        "PortMapping": null,
        "Ports": {}
    },
    "Path": "/bin/bash",
    "ProcessLabel": "",
    "ResolvConfPath": "/var/lib/docker/containers/0edd781ffee187ff8d5ffc488cc399f2ffae8dc2d113bb2360b9569a32cdf215/resolv.conf",
    "State": {
        "ExitCode": 0,
        "FinishedAt": "0001-01-01T00:00:00Z",
        "Paused": false,
        "Pid": 8944,
        "Restarting": false,
        "Running": true,
        "StartedAt": "2014-11-04T15:12:25.626568987Z"
    },
    "Volumes": {},
    "VolumesRW": {}
}
]
```

- OS側におけるdocker0 , veth の確認

```
# brctl show
bridge name	bridge id		STP enabled	interfaces
docker0		8000.26335717ffda	no		veth03f9

# ifconfig veth03f9
veth03f9  Link encap:Ethernet  HWaddr 26:33:57:17:FF:DA  
          inet6 addr: fe80::2433:57ff:fe17:ffda/64 Scope:Link
          UP BROADCAST RUNNING  MTU:1500  Metric:1
          RX packets:7 errors:0 dropped:0 overruns:0 frame:0
          TX packets:6 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:558 (558.0 b)  TX bytes:468 (468.0 b)
```


- コンテナへアクセス

```
# docker attach 0edd781ffee1
[root@0edd781ffee1 /]# 
```



- コンテナ終了
実施中のCmd（現在は/bin/bash)終了でコンテナは停止します
```
[root@0edd781ffee1 /]# exit
exit

# docker ps -a
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                      PORTS               NAMES
0edd781ffee1        centos:centos6      "/bin/bash"         10 minutes ago      Exited (0) 16 seconds ago                       sleepy_davinci
```

- コンテナ再開
```
# docker start 0edd781ffee1
0edd781ffee1

# docker ps -a
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
0edd781ffee1        centos:centos6      "/bin/bash"         11 minutes ago      Up 6 seconds                            sleepy_davinci  
```

- コンテナ終了
```
# docker stop 0edd781ffee1
0edd781ffee1

# docker ps -a
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                       PORTS               NAMES
0edd781ffee1        centos:centos6      "/bin/bash"         13 minutes ago      Exited (-1) 12 seconds ago                       sleepy_davinci
```

- コンテナ削除
停止中のコンテナを削除します。稼働中のコンテナをいきなる削除する場合は"-f"オプションを付与するか、"docker stop"にて一旦停止してから削除してください。
```
# docker rm 0edd781ffee1
# docker ps -a
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
```



----

###  Dockerfile


----

###  Docker コンテナ起動
1. コンテナ起動
* 登録したイメージからコンテナ起動
> /# docker run -i -t local/centos:6.5 /bin/bash
> bash-4.1#

* コンテナからのdetach
> /* ctrl + p + q でdetach

2. コンテナ操作
* docker プロセス確認
> /# docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
21ed2e04c6cc        local/centos:6.5    /bin/bash           4 minutes ago       Up 4 minutes                            naughty_nobel

* コンテナログ（標準出力）確認
> \# docker logs -f 21ed2e04c6cc

* ブリッジインタフェースとvethの紐付き確認
> \# brctl show
bridge name     bridge id               STP enabled     interfaces
docker0         8000.fe3496dae706       no              veth9TQ44u

* コンテナ停止
> \# docker stop -t 10 21ed2e04c6cc
> \* コンテナ停止はコンテナ内のプロセスにSIGTERMが送出される。
> \* SIGTERM で停止しない場合は -t オプションで指定した秒数待機して
> \* SIGKILL が送出される。
>
> \# docker ps -a
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
21ed2e04c6cc        local/centos:6.5    /bin/bash           12 minutes ago      Exit -1                                 naughty_nobel

* コンテナ起動
> \# docker start 21ed2e04c6cc
>
> \# docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
21ed2e04c6cc        local/centos:6.5    /bin/bash           14 minutes ago      Up 2 seconds                            naughty_nobel

* コンテナへのアタッチ
> \# docker attach 64845b14bc1a
>
> bash-4.1# hostname
64845b14bc1a
>
> \* コンテナアクセス中に ctrl + d でコンテナ終了

* コンテナ　KILL
> \# docker kill 21ed2e04c6cc

* コンテナ状態の確認（go template http://golang.org）
> \# docker inspect -f "{{.State}}" 21ed2e04c6cc
map[Running:true Pid:4148 ExitCode:0 StartedAt:2014-05-15T08:51:16.304058045Z FinishedAt:0001-01-01T00:00:00Z Ghost:false]

* コンテナ状態の確認（JSON）
> \# docker inspect 21ed2e04c6cc
> /* コンテナの状態をJSON形式で取得可能
[{
    "ID": "21ed2e04c6cc7e213f7e484986bf4dea43680279f3de4d432a6f52abe869c3e8",
    "Created": "2014-05-15T08:51:13.836306943Z",
    "Path": "/bin/bash",
    "Args": [],
    "Config": {
        "Hostname": "21ed2e04c6cc",
        "Domainname": "",
        "User": "",
        "Memory": 0,
        "MemorySwap": 0,
        "CpuShares": 0,
        "AttachStdin": true,
        "AttachStdout": true,
        "AttachStderr": true,
        "PortSpecs": null,
        "ExposedPorts": {},
        "Tty": true,
        "OpenStdin": true,
        "StdinOnce": true,
        "Env": null,
        "Cmd": [
            "/bin/bash"
        ],
        "Dns": null,
        "Image": "local/centos:6.5",
        "Volumes": {},
        "VolumesFrom": "",
        "WorkingDir": "",
        "Entrypoint": null,
        "NetworkDisabled": false,
        "OnBuild": null
    },
    "State": {
        "Running": true,
        "Pid": 4148,
        "ExitCode": 0,
        "StartedAt": "2014-05-15T08:51:16.304058045Z",
        "FinishedAt": "0001-01-01T00:00:00Z",
        "Ghost": false
    },
    "Image": "e758f337483bf78f79bd55e8c8522f5b9852369c46ee975aea26a926a65a57ff",
    "NetworkSettings": {
        "IPAddress": "172.17.0.2",
        "IPPrefixLen": 16,
        "Gateway": "172.17.42.1",
        "Bridge": "docker0",
        "PortMapping": null,
        "Ports": {}
    },
    "ResolvConfPath": "/etc/resolv.conf",
    "HostnamePath": "/var/lib/docker/containers/21ed2e04c6cc7e213f7e484986bf4dea43680279f3de4d432a6f52abe869c3e8/hostname",
    "HostsPath": "/var/lib/docker/containers/21ed2e04c6cc7e213f7e484986bf4dea43680279f3de4d432a6f52abe869c3e8/hosts",
    "Name": "/agitated_hawking",
    "Driver": "devicemapper",
    "ExecDriver": "lxc-0.9.0",
    "Volumes": {},
    "VolumesRW": {},
    "HostConfig": {
        "Binds": null,
        "ContainerIDFile": "",
        "LxcConf": [],
        "Privileged": false,
        "PortBindings": {},
        "Links": null,
        "PublishAllPorts": false
    }
}]

* コンテナのコミット(イメージ登録）
> \# docker commit 21ed2e04c6cc 
> a75a7aea6b3a15eeca9bcdfb28cee349a7e2659d9933c74557c89aba48e07ea0
> 
> \# docker images
> /* --tree オプションを付与すると依存関係を確認できる
REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
<none>              <none>              a75a7aea6b3a        15 seconds ago      309.7 MB
local/centos        6.5                 e758f337483b        6 hours ago         309.7 MB
centos              centos6             0b443ba03958        4 weeks ago         297.6 MB
centos              latest              0b443ba03958        4 weeks ago         297.6 MB
centos              6.4                 539c0211cd76        13 months ago       300.6 MB

* コンテナの削除（rm)
> \# docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
21ed2e04c6cc        local/centos:6.5    /bin/bash           6 minutes ago       Up 6 minutes
> \# docker stop 21ed2e04c6cc
> \# docker rm 21ed2e04c6cc
21ed2e04c6cc
>
> \# docker ps -a
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES

* イメージの削除(rmi)
> \# docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
<none>              <none>              a75a7aea6b3a        2 minutes ago       309.7 MB
local/centos        6.5                 e758f337483b        6 hours ago         309.7 MB
centos              centos6             0b443ba03958        4 weeks ago         297.6 MB
centos              latest              0b443ba03958        4 weeks ago         297.6 MB
centos              6.4                 539c0211cd76        13 months ago       300.6 MB
>
> \# docker rmi a75a7aea6b3a
Deleted: a75a7aea6b3a15eeca9bcdfb28cee349a7e2659d9933c74557c89aba48e07ea0
>
> \# docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
local/centos        6.5                 e758f337483b        6 hours ago         309.7 MB
centos              centos6             0b443ba03958        4 weeks ago         297.6 MB
centos              latest              0b443ba03958        4 weeks ago         297.6 MB
centos              6.4                 539c0211cd76        13 months ago       300.6 MB

----
###  Dockerfilesからのビルド

1. Dockerfile の準備（サンプル）
* nginx にて hello world を返すコンテナを作成する
* ファイル構造
> ./nginx.conf
./default.conf
./src
./src/index.html
./Dockerfile

* nginx.conf
> daemon off;
user nginx;
worker_processes 1;
error_log /var/log/nginx/error.log;
pid /var/run/nginx.pid;
events {
 worker_connections 1024;
}
http {
     include       /etc/nginx/mime.types;
     default_type  application/octet-stream;
>
    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';
     access_log  /var/log/nginx/access.log  main;
     sendfile        on;
     \#tcp_nopush     on;
     keepalive_timeout  65;
     \#gzip  on;
     include /etc/nginx/conf.d/*.conf;
 }

* Dockerfile
>
FROM    local/centos:6.5
MAINTAINER      2040070
>
ENV     http_proxy 'http://*user_id*:*password*@*proxy_uri*'
ENV     https_proxy 'http://*user_id*:*password*@*proxy_uri*'
>
RUN     yum -y install yum-plugin-fastestmirror
RUN     yum -y update
RUN     rpm --import http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6
RUN     rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
RUN     sed -i -e "s/enabled=1/enabled=0/g" /etc/yum.repos.d/epel.repo
RUN     yum --enablerepo=epel -y install nginx
RUN     cp -p /etc/nginx/nginx.conf /etc/nginx/nginx.conf.org
RUN     cp -p /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.org
ADD     nginx.conf /etc/nginx/nginx.conf
ADD     default.conf /etc/nginx/conf.d/default.conf
ADD     src /var/www
>
EXPOSE 80
>
CMD     ["service","nginx","start"]

14. build
* buildの実行
> \# docker build -t tera/cent65:nginx .
Uploading context 7.168 kB
Uploading context
Step 0 : FROM local/centos:6.5
 ---> e758f337483b
Step 1 : MAINTAINER 2040070
 ---> Running in 15b2ee6ab3dc
 ---> 41d7effea14a
Step 2 : ENV http_proxy 'http://*user_id*:*password*@*proxy_uri*'
 ---> Running in a2c93759501b
 ---> 2eae4c4b18db
Step 3 : ENV https_proxy 'http://*user_id*:*password*@*proxy_uri*'
 ---> Running in 348dd6b1de89
 ---> 797647ef5ec2
Step 4 : RUN yum -y install yum-plugin-fastestmirror
 ---> Running in d249541704cc
Loaded plugins: fastestmirror
Setting up Install Process
Package yum-plugin-fastestmirror-1.1.30-17.el6_5.noarch already installed and latest version
Nothing to do
 ---> 777946a9c0f4
Step 5 : RUN yum -y update
 ---> Running in ab3efce63078
Loaded plugins: fastestmirror
Determining fastest mirrors
～省略～
Complete!
 ---> 680d8a5724a3
Step 6 : RUN rpm --import http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6
 ---> Running in f3d00bc655b7
 ---> 04af338790e1
Step 7 : RUN rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
 ---> Running in 41bf630a316f
Retrieving http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
 ---> 1be74f8c2ab6
Step 8 : RUN sed -i -e "s/enabled=1/enabled=0/g" /etc/yum.repos.d/epel.repo
 ---> Running in f12e97099246
 ---> 63752afa10b6
Step 9 : RUN yum --enablerepo=epel -y install nginx
 ---> Running in 73b04af63538
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
～省略～
Complete!
 ---> da52020d3106
Step 10 : RUN cp -p /etc/nginx/nginx.conf /etc/nginx/nginx.conf.org
 ---> Running in e19e1a37ad6f
 ---> d3dd82fd1a14
Step 11 : RUN cp -p /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.org
 ---> Running in 63c2408fface
 ---> 6a10f6823a2f
Step 12 : RUN echo "NETWORKING=yes" >  /etc/sysconfig/network
 ---> Running in 2addc4314fa2
 ---> df24261c8383
Step 13 : RUN echo "HOSTNAME=`hostname`" > /etc/sysconfig/network
 ---> Running in 49aa3cb5ab00
 ---> 2c6a1ca98661
Step 14 : ADD nginx.conf /etc/nginx/nginx.conf
 ---> e8ec3ba40eb8
Step 15 : ADD default.conf /etc/nginx/conf.d/default.conf
 ---> fb2238aee928
Step 16 : ADD src /var/www
 ---> 82244447b6dd
Step 17 : EXPOSE 80
 ---> Running in 9874d7a0721f
 ---> 174a84c219d2
Step 18 : CMD ["service","nginx","start"]
 ---> Running in 70d2d8c69c92
 ---> b6420e9e9425
Successfully built b6420e9e9425
Removing intermediate container d249541704cc
Removing intermediate container 2addc4314fa2
Removing intermediate container 6e96db8589f8
Removing intermediate container 6ee2a6cc9da1
Removing intermediate container 9874d7a0721f
Removing intermediate container 70d2d8c69c92
Removing intermediate container a2c93759501b
Removing intermediate container ab3efce63078
Removing intermediate container 41bf630a316f
Removing intermediate container 73b04af63538
Removing intermediate container 49aa3cb5ab00
Removing intermediate container 0217fb2b6211
Removing intermediate container 348dd6b1de89
Removing intermediate container 15b2ee6ab3dc
Removing intermediate container f3d00bc655b7
Removing intermediate container f12e97099246
Removing intermediate container e19e1a37ad6f
Removing intermediate container 63c2408fface

* 起動確認
> \# docker run -d -p 80:80 tera/cent65:nginx
aba2771420aa32f980a584f096bc750120034fb456d3daa62ac1042a01934789
> 
> \# docker ps
CONTAINER ID        IMAGE               COMMAND               CREATED             STATUS              PORTS                NAMES
aba2771420aa        tera/cent65:nginx   service nginx start   23 seconds ago      Up 20 seconds       0.0.0.0:80->80/tcp   sick_feynman
>
> \# curl -i http://localhost/index.html
HTTP/1.1 200 OK
Server: nginx/1.0.15
Date: Fri, 16 May 2014 04:08:29 GMT
Content-Type: text/html
Content-Length: 14
Last-Modified: Fri, 16 May 2014 00:58:41 GMT
Connection: keep-alive
Accept-Ranges: bytes
>
Hello, Nginx!


----

## <i class="icon-pencil"></i> Docker基本情報

### コンテナとネットワーク
1. ブリッジ機能
* デフォルトでdocker0をブリッジとして管理
* ブリッジはホストNWのroute で衝突しないものを選択
* デフォルトではNW:172.17.42.0/16, IP:172.17.42.1 が設定される
* Dockerは割り振られたrange内でコンテナごとにIPアドレスを割り振り管理している
* ホストはコンテナのインタフェースを*veth????* という名称を作成していく。

* コンテナ起動前状態
> \# brctl show
bridge name     bridge id               STP enabled     interfaces
docker0         8000.000000000000       no
>

* コンテナ起動後(ブリッジにコンテナのethが紐づく）
* 先ほどのインスタンスが起動している状態だと
>\# docker run -d -p 80:80 tera/cent65:nginx
>
> \# ctrl + p + q
>
\# docker ps
CONTAINER ID        IMAGE               COMMAND               CREATED             STATUS              PORTS                NAMES
aba2771420aa        tera/cent65:nginx   service nginx start   18 minutes ago      Up 18 minutes       0.0.0.0:80->80/tcp   sick_feynman
>
\# brctl show
bridge name     bridge id               STP enabled     interfaces
docker0         8000.fefa8c29380f       no              vethJb4fP7
>
\# ifconfig veth5bjfkJ
vethJb4fP7 Link encap:Ethernet  HWaddr FE:FA:8C:29:38:0F
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:10 errors:0 dropped:0 overruns:0 frame:0
          TX packets:12 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:833 (833.0 b)  TX bytes:910 (910.0 b)

2. Expose、ポートマッピング
* Docker は外部通信のためにポートマッピング機能を持っている
* 起動時に"-p" オプションでポートをexpose可能
* iptables にて管理される
> \# iptables -t nat -n -L
Chain PREROUTING (policy ACCEPT)
target     prot opt source               destination
DOCKER     all  --  0.0.0.0/0            0.0.0.0/0           ADDRTYPE match dst-type LOCAL
>
Chain POSTROUTING (policy ACCEPT)
target     prot opt source               destination
MASQUERADE  all  --  172.17.0.0/16       !172.17.0.0/16
>
Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination
DOCKER     all  --  0.0.0.0/0           !127.0.0.0/8         ADDRTYPE match dst-type LOCAL
>
Chain DOCKER (2 references)
target     prot opt source               destination
DNAT       tcp  --  0.0.0.0/0            0.0.0.0/0           tcp dpt:80 to:172.17.0.2:80

3. コンテナ間ネットワークとセキュリティ
* \--iccフラグでコンテナ間の通信の可否を制御可能
* \--icc=true デフォルト、コンテナ間の通信を許可
* iptables にて実現されている

4. LinkContainer
* 特定のコンテナのみの通信を許可する機能として　Link機能がある
* iptables にて実現されている
* \--link オプションを指定して接続したいコンテナを起動するとDB

5. Ambassador Pattern
* 異なるホストのコンテナ間を通信させる方法としてAmbassador Container が存在する
* コンテナ間の通信はAmbassador Container が行う
* イメージとしては以下の形
> client --> nginx-ambassador --> network --> nginx
* Ambassador Container は socat= socket proxy を行うプログラム
* 実際の接続先を環境変数から取得し、指定したホストIPアドレスへプロキシする機能を持つ

-------

### Dockerfile の記法
1. FROM
* 必須のエントリ
* BaseImageを設定する命令
* 複数記述可能でありその場合現れた順序で処理が実施される
* buildコマンドのオプションで指定したrepository名が設定されるのは最後に現れたFROMのイメージ
* tagを使用しない場合は自動でlatestが使用される
> FROM *image:tag*  or FROM *image*

2. MAINTAINER
* ImageのAuthorを設定する命令
* 必須ではない
> MAINTAINER *name*
3. RUN
* 任意のコマンドを実行し結果をイメージの上に新しいレイヤとしてコミットする
> RUN *command*
RUN *["executable", "param1", "param2"]*
> * 既知の問題として以下の2つがある
> * issue:783 ファイル削除時にPermissionの問題がある 
> * issue:2424 Localeが自動で設定されない

4. CMD
* コンテナで実行するメインコマンドを記述
* Dokerfile内で１つしか許容されない
* CMD命令はrunコマンドで上書き可能
> CMD *["executable", "param1", "param2"]*
CMD *command param1 param2*
CMD *["param1", "param2]*

5. EXPOSE
* コンテナが公開するポート番号
* Dockerはこの情報を元にコンテナ間のLINK、ポートマッピングを行う
* runコマンドからも設定可能
> EXPOSE *port*
EXPOSE *[port1, port2, ...]*

6. ENV
* 環境変数をセットする
* 環境変数は永続化される
* runコマンドで実行する際もこの変数は参照される
* inspectコマンドで参照可能
* runコマンドでも実行時環境変数の上書きが可能
> ENV *key* *value*

7. ADD
* ADD はホストのファイルをコンテナ内にコピーする
* srcはbuildするパスからの相対パスで記載
* destはコピー先のコンテナ内の絶対パスで指定
* ADDでコピーされたファイル、ディレクトリは mode 0755, uid/gid 0 でコンテナ内に作成される
> ADD *src* *dest*
> * *src* は親ディレクトリは参照できない
> * *src* がURLで *dest* が "/" で終わっていない場合にはダウンロードしたファイルが *dest* にコピーされる
> * *src* がURLで *dest* が"/" で終わっている場合はダウンロードしたファイルが *dest/filename* にコピーされる
> * *src* がディレクトリである場合はファイルシステムのメタデータもあわせてコピーされる
> * *src* がURLではなく tar archive(gzip, bzip2, xzも含む）である場合ディレクトリとして解凍される

8. ENTRYPOINT
* Dockerfileないで１つだけ許容される
* コンテナで事項するプログラムの設定を手助けする役割
* ENTRYPOINTを指定した場合コマンドは固定される
* runコマンドで実行する際のコマンド引数がENTRYPOINTの残りの引数として渡される
* コマンドライン引数をコンテナの外部から渡すことが可能となる
* CMDと併用した場合、デフォルト引数としてCMDで設定した値が利用される
> ENTPRYPOINT ["executable", "param1", "param2"]
> ENTRYPOINT *command* *param1* *param2*

9. VOLUME
* VOLUMEはホスト、他のコンテナにマウントするポイントを設定する
* ホスト、他のコンテナとファイル共有が可能
> VOLUME ["*/data*"]

10. USER
* 実行するusername もしくは UID をセットする
> USER *name*

11. WORKDIR
* WORKDIRは作業ディレクトリを設定する
* RUN, CMD, ENTRYPOINTすべてに影響する
* 相対パスを指定することが可能
> WORKDIR *path*

12. ONBUILD
* イメージがベースイメージとして利用される際に使用
* ONBUILD命令は自身のbuild時には利用されないが、子イメージがbuildされる際に実行される
* ONBUILDは子イメージを作成するDockerfileのFROM命令時に実行されるもの
> ONBUILD *instruction*

----

### <i class="icon-pencil"></i> Dockerfileの動的生成
* Dockerfileを python から実施させる場合

1. a.py ファイル作成
> base = """
FROM centos
"""
def main(argv):
    print(base)
    print('%s\n' % argv[1])
    print('CMD ["/bin/bash"]\n')
>
if \__name__ == '\__main__':
    import sys
    if len(sys.argv) > 1:
        main(sys.argv)
    else:
        print('need arg')

2. a.py 実行
> \# python a.py "ENV DOCKER FROM_PYTHON" | docker build -t frompy -
Uploading context 2.048 kB
Uploading context
Step 0 : FROM centos
 ---> 0b443ba03958
Step 1 : ENV DOCKER FROM_PYTHON
 ---> Running in 69bf3496142b
 ---> e9888c642179
Step 2 : CMD ["/bin/bash"]
 ---> Running in ff252d49019d
 ---> 835c3afb9024
Successfully built 835c3afb9024
Removing intermediate container 69bf3496142b
Removing intermediate container ff252d49019d
[root@cent01 work]# docker ps -a
CONTAINER ID        IMAGE               COMMAND               CREATED             STATUS              PORTS                NAMES
aba2771420aa        tera/cent65:nginx   service nginx start   2 hours ago         Up 34 minutes       0.0.0.0:80->80/tcp   sick_feynman

3. イメージ確認
> \# docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
frompy              latest              835c3afb9024        32 seconds ago      297.6 MB
tera/cent65         nginx               b6420e9e9425        3 hours ago         470.7 MB
local/centos        6.5                 e758f337483b        28 hours ago        309.7 MB
centos              centos6             0b443ba03958        4 weeks ago         297.6 MB
centos              latest              0b443ba03958        4 weeks ago         297.6 MB
centos              6.4                 539c0211cd76        13 months ago       300.6 MB

----

### Tips
* Dockerのイメージは /etc/default/docker に格納
    * DNSの設定を行う箇所になる

* コンテナ内のデータバックアップ
    * 下記は以下の意味合い
    * 現在のホストのディレクトリをコンテナの/backpにマウント
    * コンテナ内の/dataのデータをホスト側/backup/backup.tar にバックアップ
    * /backupはホストのディレクトリにマウントされているので干すと側にbackup.tar が作成される
    * \--rm オプションを付与する処理終了後 busybox コンテナは削除される
    * load する場合は tar コマンドを xvf に変えるのみ
> \# docker run --rm --volumes-from *container_id* -v $(pwd}:/backup busybox tar cvf /backup/backup.tar /data

* AUFSのリミットに達した場合
    * DockerのAUFS Layerの制限は127だが、足りない場合は export -> import することでまとめることが可能
    * save, load ではレイヤ数は減らないので注意
    * exportする際にはコンテナIDが必要
> \# container_id=\$(docker run -d *Repository:Tag* /bin/bash -c "")
\# docker export $container_id > tmp.tar
\# cat tmp.tar | docker import - <Repository:Tag>

* private-repository でイメージ共有、バックアップ
    * イメージ共有が可能
    * デフォルトで registry という名前で提供されている
    * registryコンテナを削除するとpush した内容も消えてしまう
    * ホストの/opt/registryをマウントしてpush したイメージを永続化している
    * デフォルトはコンテナ内の/tmp/registryへ保存される
> \# docker run -d -p 5000:5000 -v /opt/registry:/tmp/registry:rw registry

* イメージをリモートリポジトリにアップロードする
    * DockerIndexというリモートリポジトリにアップ可能
> \# docker login
\# docker push tera/teratera

* 実行メモリ容量の制限
    * \-m オプションを付与することで制限可能
    * Memory制限はデフォルトでサポートする環境が少ないのでGRUB、カーネルパラメータ等でcgoupの制限を解除してやる必要がある。
> \# docker run -m=128m -i -t centos /bin/bash
\# grep cgroup /proc/mounts
\# cat /sys/fs/cgroup/memory/docker/*container_id*/memory.limit_in_bytes

> Written with [StackEdit](https://stackedit.io/).


    あああ

　　　　ああああ
あああ



  [1]: https://www.docker.io/static/img/homepage-docker-logo.png
  [2]: http://docs.docker.io.s3-website-us-west-2.amazonaws.com/terms/images/docker-filesystems-multilayer.png
  [3]: https://docs.docker.com/article-img/architecture.svg
