Kubernetesを触ってみた
===========


--------

###Kubernetes登場の背景
近年、Linuxの界隈ではDockerというLinuxConatiner管理ソフトウェアが非常に注目を集めている。ただ、Dockerが実現するContainer技術自体はChroot, Jail, SolarisContainerなどUNIX界隈では古くから実現されており、Linuxでもnamespaceによるユーザ空間のパーティショニング、cgroupsによりリソース制御、さらにそれらを組み合わせたLinuxContainer(LXC)はDocker登場以前から存在していた。

昨今のDockerの注目度の高さはDockerがもつ下記の特徴が市場のニーズにマッチしていたためである。

- シンプルなコマンド、API経由の操作によりアプリケーションを容易にコンテナにパッケージングする手法を実現
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


###Kubernetesとは
Dockerを利用したいが運用面の弱点克服には多大なる労力を要するDockerに対して、Googleがコンテナ管理ツールを2014/06に実施されたDockerConに合わせて発表した。それがKubernetesである。「Kubernetesは、Dockerコンテナによるクラスタ構築のためのスケジューリングサービス」である。Dockerがこれから本格的に普及し、大量にコンテナのクラスタを作り始めると、各VMへのコンテナの割り振りや管理がやっかいな問題となる。それを取りまとめようとのもくろみで開発されているジョブスケジューラである。

![kubernetes](https://qiita-image-store.s3.amazonaws.com/0/38290/67715810-bb24-a4f9-e8fb-c6928a68c35f.png)


既に下記のようなプロジェクトがForkされており、KubernetesがこれからPaaSの中核技術になっていくと思われる。

- CoreKube: RackSpaceが実施しているCoreOS+Kubernetes
- YARN: Hadoopをコンテナで実現していく
- OpenShift: PaaSであるOpenShiftは次バージョンでAtomic + KubernetesにてDockerコンテナのジョブスケジューラをコンテナ管理の中核に据えるアーキテクチャを採用
- mesoshere: kubernetes-mesos にてクラスタリング、リソース配置制御などを実施するプロジェクトを実施

...etc

### Kubernetes Community
現在下記ベンダがコミュニティに参加している
- IBM
- HP
- redhat
- mesosphere
- Windows Azure
- CoreOS
- vmware
- 

###KubernetesDesign

####Pod
Kubernetesではdocker ConainerをPodという単位でまとめている。Podは関係の密な複数のコンテナを配置する仮想的なサーバ。同じPodのコンテナは同じ基盤のサーバ（Minion）に配置される


<p><img src="https://github.com/GoogleCloudPlatform/kubernetes/raw/master/docs/architecture.png?raw=true" alt="kubernetesDesign" title="KubernetesDesign" width="960" height="480"/></p>

[引用:KubernetesDesign from GitHub](https://github.com/GoogleCloudPlatform/kubernetes/blob/master/DESIGN.md)