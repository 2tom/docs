Kubernetes　まとめ
===========


--------

###Kubernetes登場の背景
近年、Linuxの界隈ではDockerというLinuxConatiner管理ソフトウェアが非常に注目を集めている。ただ、Dockerが実現するContainer技術自体はChroot, Jail, SolarisContainerなどUNIX界隈では古くから実現されており、Linuxでもnamespaceによるユーザ空間のパーティショニング、cgroupsによりリソース制御、さらにそれらを組み合わせたLinuxContainer(LXC)はDocker登場以前から存在していた。

昨今のDockerの注目度の高さはDockerがもつ下記の特徴が市場のニーズにマッチしていたためである。

- シンプルなコマンド、API経由の操作により容易にアプリケーションをコンテナへパッケージングする手法を実現
- 差分ディスクイメージによる再利用性の向上させるイメージ管理
- DockerfilesによるInfrastructure as Codeの実現
- ソーシャルなイメージ共有が可能なDockerHubの提供

上記の特徴をもつDockerは下記のように多種多様なクラウドサービス、OSでのサポートが開始されており、クラウド市場において既に中心になっているといって過言ではない。

####対応IaaS/PaaS
- AWS EC2
- Amazon Elastic Beanstalk
- Windows Azure
- Google Compute Engine
- RackSpace
- SoftLayer
- Google App Engine
- CloudFoundry
- OpenShift
- Deis(Docker + CoreOS PaaS)
- OpenStack
- CloudStack

####OperatingSystem
- RedHat7
- OracleLinux
- SUSE Linux
- Ubuntu
- Debian
- MacOSX
- WindowsServer

####専用OS
- RedHat Atomic
- CoreOS(Dockerだけではなく独自コンテナ[Rocket](https://github.com/coreos/rocket)のローンチ開始)


ただし、Dockerはあくまでシングルホスト上でのConatainer管理ソフトウェアであり、ContainerをProduction環境で利用するための、マルチホスト対応、死活監視、ライフサイクル管理、メトリクス取得、クラスタリングなどの運用観点は欠けていたため、Enterprise利用はまだまだ先になるだろうと思われていた。

--------

###Kubernetesとは
Dockerを利用したいが運用面の弱点克服には多大なる労力を要するDockerに対して、Googleがコンテナ管理ツールを2014/06に実施されたDockerConに合わせて発表した。それがKubernetesである。「Kubernetesは、Dockerコンテナによるクラスタ構築のためのスケジューリングサービス」である。Dockerがこれから本格的に普及し、大量にコンテナのクラスタを作り始めると、各VMへのコンテナの割り振りや管理がやっかいな問題となる。それを取りまとめようとのもくろみで開発されているジョブスケジューラである。

![kubernetes](https://qiita-image-store.s3.amazonaws.com/0/38290/67715810-bb24-a4f9-e8fb-c6928a68c35f.png)


既に下記のようなプロジェクトがForkされている。

#### 稼働中のForkProject
- CoreKube: RackSpaceが実施しているCoreOS+Kubernetes
- YARN: Hadoopをコンテナで実現していく
- OpenShift: PaaSであるOpenShiftは次バージョンでAtomic + KubernetesにてDockerコンテナのジョブスケジューラをコンテナ管理の中核に据えるアーキテクチャを採用
- mesoshere: kubernetes-mesos にてクラスタリング、リソース配置制御などを実施するプロジェクトを実施

...etc

#### Kubernetes Community
現在下記ベンダがコミュニティに参加している
- IBM
- HP
- redhat
- mesosphere
- Windows Azure
- CoreOS
- vmware

--------

### Kubernetes install

####作成環境
|項目|内容|
|---|---|
|マシン|IBM X230|
|OS|Windows7 Professional|
|HyperVisor|VirtualBox|
|VM vCPU|1vCPU|
|VM vRAM|2GB|
|VM Disk|32GB|
|VM NIC|NATNetworkx1,HostOnlyx1|
|VM OS|CentOS 7.0.1406|

####VM構成
|ホスト名|役割|enp0s3 IP|enp0s8 IP|
|---|---|---|---|
|cent70-01|Ansibleサーバ|10.0.2.51|192.168.56.51|
|k8s-master-01|Masterサーバ|10.0.2.61|192.168.56.61|
|k8s-minion-01|Minionサーバ|10.0.2.62|192.168.56.62|
|k8s-minion-02|Minionサーバ|10.0.2.63|192.168.56.63|

####インストール
**1. CentOSインストール(Minimal)**
~省略~

**2. インタフェース有効化**
```
# nmcli con mod enp0s3 connection.autoconnect yes
# nmcli con mod enp0s8 connection.autoconnect yes
```

**3. ipv6停止**
```
# vi /etc/sysctl.d/ipv6_disable.conf
↓下記を入力して保存
net.ipv6.conf.all.disable_ipv6=1
net.ipv6.conf.default.disable_ipv6=1
```

**4. SELINUX停止**
``` 
# vi /etc/selinux/config
↓下記に変更して保存
SELINUX=disabled
```

**5. OSリブート**
~省略~

**6.NIC設定**
```
# nmcli con mod enp0s3 ipv4.method manual ipv4.addresses “{IP}/24 10.0.2.2”

# nmcli con mod enp0s8 ipv4.method manual ipv4.addresses “{IP}/24”
```

**6.DNS設定**
```
# nmcli con mod enp0s3 ipv4.dns-search "intra.ctc-g.co.jp"
# nmcli con mod enp0s3 ipv4.dns "10.194.5.11, 10.194.5.12"
```
**7.Ansibleインストール**
-　対象ホスト:  centos7-01

```
# yum install  https://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-2.noarch.rpm
# sed -i -e "s/enabled=1/enabled=0/g" /etc/yum.repos.d/epel.repo
# yum --enablerepo=epel install ansible
```

```
# ssh-key-gen
以後全てEnterを入力
# ls -l ~/.ssh/id_rsa*
```

**8.SSH-KEY COPYインストール**
-　対象ホスト:  centos7-01
```
# cd
# ssh-copy-id -i .ssh/id_rsa.pub root@192.168.56.61
The authenticity of host '192.168.56.61 (192.168.56.61)' can't be established.
ECDSA key fingerprint is f1:98:7f:b1:36:39:32:a0:85:99:69:60:e0:19:60:3c.
Are you sure you want to continue connecting (yes/no)? yes ←入力
root@192.168.56.61's password: ←パスワード入力

# ssh-copy-id -i .ssh/id_rsa.pub root@192.168.56.62

# ssh-copy-id -i .ssh/id_rsa.pub root@192.168.56.63
```

**8.ANSIBLE 疎通確認**
-　対象ホスト:  centos7-01
- 作業用ディレクトリ作成
```
# mkdir ~/k8s-manual && cd ~/k8s-manual
# mkdir log
```

- ansible設定ファイルを作成
```
# vi ./ansible_hosts
↓下記を入力して保存
[k8s-master]
192.168.56.61
[k8s-minion]
192.168.56.62
192.168.56.63

# vi ansible.cfg
↓下記を入力して保存
[defaults]
hostfile = ansible_hosts
remote_user = root
ask_pass = False
log_path = ./log/ansible.log
forks = 3
```

- 疎通確認

```
# ansible -i ./ansible_hosts --module-name=setup all
192.168.56.63 | success >> {
    "ansible_facts": {
        "ansible_all_ipv4_addresses": [
            "10.0.2.63",
            "192.168.56.63"
        ],
        "ansible_all_ipv6_addresses": [
            "fe80::a00:27ff:fe32:2f",
            "fe80::a00:27ff:fe19:f0e4"
        ],
        "ansible_architecture": "x86_64",
        "ansible_bios_date": "12/01/2006",
        "ansible_bios_version": "VirtualBox",
        "ansible_cmdline": {
～省略～
```


- 
 
###KubernetesDesign

####Pod
Kubernetesではdocker ConainerをPodという単位でまとめている。Podは関係の密な複数のコンテナを配置する仮想的なサーバ。同じPodのコンテナは同じ基盤のサーバ（Minion）に配置される


<p><img src="https://github.com/GoogleCloudPlatform/kubernetes/raw/master/docs/architecture.png?raw=true" alt="kubernetesDesign" title="KubernetesDesign" width="960" height="480"/></p>

[引用:KubernetesDesign from GitHub](https://github.com/GoogleCloudPlatform/kubernetes/blob/master/DESIGN.md)
