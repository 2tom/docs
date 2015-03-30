Mirantis OpenStack 研修
==========

----
#Day1

## Tips
- OpenStack はアパッチと似たFoundation運営をしている
- License Apache2.0
- python2.7
- OpenStackはAWS2.0を目指したもの
- NASA:Nova
- RackSpace:Swift

- MirantsはCactusよりSIしている
- Essexリリースの際、OpenStackFoundationが設立された

- RedHatはGrizzlyより参加
- Essexでプロジェクトが分割され様々ベンダが各分野で積極的に関与するようになった。

- Mirantisが始めた Murano はPaaSを目指したものだが、Heatが存在するためまだ

## OpenStackProject 
### Level
- stackforge:(OpenStack外のプロジェクト)
- Incubation:(斜体)
- Integration:

### Integrated Programs
|target|Project|
|----|----|
|Compute|Nova|
|Networking|Neutron|
|ObjectSotre|Swift|
|Block Storage|Cinder|
|Image|Glance|
|Identity|Keystone|
|Dashboard|Horizon|
|Metering|Ceilometer|
|Orchestration|Heat|
|DataProcessing|Sahara|
|DatabaseService|Trove|

### Incubation Programs
|target|Project|
|----|----|
|QueService|Zaqar|
|BareMetal|Ironic|
|Key managment|Barbican|
|DNS Service|Desinate|


### Havana
- NFVでOpenStackを利用する

### OpenStackArchitecture
- OpenStackはDatabaseに全ての情報を保持している
- cloudstack/vmware はInternalAPIと、PublicAPIが分離されているが、OpenStackはInternal/Publicが同じAPIを提供している


### Tips
- Nova -> MQ
- Cinder -> MQ
- Ceilometerは頻繁にMQにアクセスするので、MQの性能が問題になる。


### Dashboard(Horizon)
- APIを提供していない
- おおよその処理を実装しているがOpenStackの全ての操作を網羅しているわけではない

### Identity(Keystone)

```
role          ->
project/tenant->  user
Domain        ->  
```

```
OpenStack
 |
 +- Domain
      |
      +-Project/Tenant
            
```

#### Auth


## Compute(Nova)

### DB
- NovaのDBはMySQL
- 一番利用しているのはGalera
- Multi-Master-Replicationはあまり使っていない。

### Message Queue
- MirantisではRabbitMQを一部カスタマイズして使っている。
- ZeroMQ（性能がよくなかった）
- RPCCALLの使い分け
 - rpc.cast: result受信を待たない
 - rpc.call: result受信を待つ
- HA構成とする必要がある

### Nova Scheduler

|Scheduler|Description|Behavior|
|---|---|---|
|Chance|---|Random|
|Filter|動作可能なComputeを探して起動する|

- Filterには様々な規則を作成可能
- HyperThredingを有効にしてOvercommitする場合、Core数を1.3として計算すべき！
- CustomFiterも作成可能
```
Filter:デプロイ可能なnodeを全nodeから探す。CPU,Memory,Disk,Networkの状態などを判断する

Weight:Filterの結果動作可能なnodeから集中させるか、分散させるか、選択して対応する
```

### NovaConductor
- Nova ComputeがVMの状態をrpc.callでnova-Conductorで情報を提供し、Nova-ConductorがDBの情報を更新している
- Nova Computeが直接DBを操作することはない。
- Nova ConductorがDBを更新している


----
## Networking(Neutron)

- NovaNetworkは分散アーキテクチャだったが、HavanaのNeutronは分散アーキテクチャではなかったため、
- NeutronはNovaNetworkがデフォルト

### Architecture
|Name|説明|
|---|---|
|Neutron Plugin|SDN Controller|
|Neutron L2Agent|Local vSwitches|
|Neutron L3 Agent|Optionalであり、PluginでL3を実装しているなら不要となる。|
|Neutron DHCP Agent -> DHCPサーバではなく、Staticな情報を仮想マシンにNetwork情報を提供するための仕組み（HAが必要）|
|Other Network Services|FWaas, VPNaaS, LBaaS等々、|
|Neutron Metadata Agent|使う使わないは、環境依存。|


---
## Cinder
### 特徴
- Multi-back-endなので、Tierの形式でVolume提供が可能になっている。
- Ceph, Swift, Clerversafe
- iscsiであればマイグレーションが可能
- Ceph:LVD-iscsi

### OpenStackStorageの種類
- Ephemeral storage:
 - VMのローカルディスク
 - VMがTerminateするまで永続化

- BlockStorage: Cinder
 - ユーザが削除するまで永続化
 - VMからblock deviceとしてアクセス
 
- Object storage:
 - ユーザが削除するまで永続化

### Resources

- Volume
	- 読み書き可能なブロックデバイス
	- VMの2ndストレージ
	- １つのインスタンスで利用する
- Snapshot
	- hot backup
	- Volumeのread-only point in time copy
- Backup
	- cold backup
	- アーカイブバックアップ

- DRを行う場合は、snapshotをSwiftにいれて 
 
- Manila: FileShare as a Service(Incubate), NetAppとMirantis社のプロジェクト

### Architecture

### BackupDriver
- Swift
- Ceph
- IBM Tivoli Storage Manager(TSM)

---
## Glance
- hard drive
- iso
- other storage media

- パーティションなどの情報を含んでいる

- 仮想マシンのISO
- Create VM(qemu-img create)
- cloud-init(Linux)
- cloudbase-init(Windows)
- virtIO dirvers(Windows only)

- virtIO:JunoからSCSIもサポート

### Glance
- Glanceはクラウド内のImage情報を管理する
- 様々なバックエンドストレージに対応している
- 同時に複数のLocationを保持することが可能

### Architecture
- GlanceAPI(+StoreAdapter)
	- Cinder
	- FileSystem
	- GridFS
	- Sheepdog
	- Swift
	- S3
	- Ceph(RBD)
- GlanceRegistry
- GlanceDB

### Notes
- バックエンドの機能を100%提供していない
- Swiftで開発・テストされている

### Capabilities
- CRUD images
- Search images via below filters
	- name
	- container format
	- disk format
	- size_min, size_max
	- status
- Cache images 
	- SQLite or FS support(xattrs)
	- queues images for prefetching
	- prefetches images
	- prune images(イメージ廃棄の予約的な感じ)
	- cleans invalid cache entries
	
Disk Formats
- raw は性能が必要な時に使う

Image Containers
- bare
- ovf

----
## Mirantis
### ベンダ独自の対応
下記要件を対応
- tier変更
- デフォルト値からのチューニング
- AD連携
- DRをやりたいなどの

### インストーラ
- FUEL
- TripleO(OpenStack on OpenStackインストール)
- Juju(devstack)

### TripleO
- HPが製作した、OpenStackによりOpenStackをインストールさせるプロジェクト
- Ironic: Baremetal
- OpenStack: TripleO でインストール完了

### FUEL
- Cobbler（将来的にはIronic)でBaremetal
- FuelではH/Wのボンディングから、Pluginの選択までできるようになっている


----
## VM boot Process
### HorizonからVM作成を開始
- VMにパラメータ追加
	- VM Name
	- Image(OStype)
	- Flavor
	- Network(Neutron経由)
		- Optional(SSH Keys, PersistetVol,comments.etc)
- Createを選択
- HorizonがHTTP POSTでバックエンドへリクエスト

### Keystoneで認証
- HorizonがKeystoneへHTTPリクエスト
- username, passwordなどを送信
- keystoneはtemporary tokenを返却
	- Keystoneがキャッシュしていた場合
	- NovaAPIのtokenがExpireしていた場合
- APIリクエストをNovaへ送信
- NovaAPIはでKeystoneへToken認証を実施

### NovaAPIでAPIリクエストを処理
- NovaDBにParseしたリクエスト情報を格納
- DBにVMの初期化の状態を登録
- MQに次のアクションを格納
- NovaAPIがrpc_castでSchedulerにMQの情報を取得させる
- SchedulerにVM情報がPublishされる
- NovaSchedulerはFilterで利用可能なホストを選択
	- Filterの種類は多数存在
	- CPU、Ram, DiskなどのHW情報
	- 極力同じHostにのせるか？別のホストにするか？
	- AZで選択
	- Group選択
	- IoOps
	- Instance数
	- イメージ名
	- カスタムイメージも作成可能
- Weightingで利用するホストを選択
- SchedulerがNovaDBからfilter, compute node,などの情報を取得
- SchedulerがVMのProvisioningのメッセージをMQにPublish
- Nova Computeが rpc_callでNovaConductorにDBの情報をQueue経由で取得

### NovaComputeからNeutronへ依頼
- Nova ComputeがNeutronAPIへVM用のNWプロビジョニング情報に従って命令を発行する
- NeutronのPluginとAgentがIP,GateWay,DNS Name, L2設定などなどをVM用に実施する
- MACアドレス確保
- IPアドレスを確保
- IPとMACとVM情報をDBに格納
- L2設定を実施(NeutronPlugin, OVS Bridge)
- L3設定を実施(DHCP/Gateway)

### NovaComputeからCinderへ依頼
- Nova ComputeがCinderAPIへVM用のNWプロビジョニング情報に従って命令を発行する
- CinderAPIよりNovaComputeにボリューム情報を提供(/dev/vdx)

### NovaComputeでGlance
- NovaComputeがGlanceAPIにVMイメージを要求(ImageID)
- もしImageIDがあれば取得用 HTTP URIをNovaComputeへ返却
- NovaComputeがURIより直接イメージをダウンロードする。(ex. Swift/Ceph)
- GlanceServerはCache機能によりイメージを

### NovaComputeがVM起動
- NovaComputeがVMを起動するためHypervisorのコマンドを実行
- NovaComputeがVMが起動したことをQueueへ情報を格納
- NovaConductorがVMの状態をDBに格納
- NovaAPIをPollingしているHorizonがDBよりVMの状態を取得して返却

----
#Day2


## Tips
- Projectに含まれるおおよそのコンポーネント
	- Process(daemon)
	- database
	- queue
	- plugin
	- oslo

- Tokenを取得してAPIは通信している送信する情報は以下のとおり
	- credential情報
		- tenant/project
			- policy.json(APIのconfiguration)
		- username
		- password 

- Tokenを使わない場合はPKIで実施する
	
- VMware/OpenStack比較

|項目|VMware|OpenStack|
|---|---|---|
|メンタリティ|１台ずつ厳密に管理したい(ペット)|機能が問題なく稼働していればよい(家畜)|
|ステート|ステートフルアプリでも動作可能|ステートレスアプリを推奨|
|LiveMigration|vCenter機能で提供|機能は存在するが、厳密にCloudWatch/Zabbixなどとの連携が重要|


- 複数のハイパーバイザーを管理したい場合はAZでKVMZone,ESXZoneなどを規定する方法
- CERN: NovaNetworkを使っている


----

## OpenStack Networking DeepDive

### NovaNetworkの変遷

- Single-Host Networking(routingは単一ホストで提供)
	- Cactus/Diabloの時
	- routingを単一Hostで提供

- Multi-Host Networking
	- routing/NAT機能を全ホストに分散した
	- L3サービスのSPOF解消
	- スケーラビリティの獲得
	- 各nodeがL3NWに接続する必要がでてきた
	- ComputeのNW処理負荷が上がってきた

- Network Managers
	- LinuxBridgesの作成
	- IP提供(DHCP/NWConfig)
	- VLAN設定
	- TrafficFilterling

- FlatManager
	- Debianでしか利用できなかった
	- 大きなIPPoolをChunkで分割

- FlatDHCPManager
	- dnsmasq でIP管理を始めた
	- Debian以外のホストでも利用できる状態になった

- DHCPServer(dnsmasq)
	- MacAddressに応じてstatic leaseを行った
	- この状態では全てのテナントが通信できる状態なので、

- VlanManager
	- dnsmasq+vlanを用いてテナントを分離した
	- dhcpサーバ数が増加(tenant毎)
	- 802.1q を利用した
	- NW機器にVlantagの設定が必要になった

### VLAN Managerでのroutingは資料参照


### Floating IP
- Fixed IPs:
	- インスタンス起動時に提供
	- Private IP
	- instance間の通信、外部NWとの通信で利用
	- 外部NWからアクセスはできない
	
- Floating IPs:
	- ユーザがinstanceに付与する
	- 外部NWからアクセス可能

- 外部からのアクセスに対しては　iptablesの DNAT rule でfloating IP -> fixed IP のNATを行っている
- 内部からのインターネットアクセスに対しては、eth0(物理NIC)をGatewayとしたSNATにより実施している

-----

## Neutron
### Why Neutron
- NW管理をクラウド管理したい
- Enterpriseで利用されるようなNWトポロジに対応したい
- Pluginを用いたマルチベンダ対応環境を使いたい
- VLANはDynamicProvisioningできないので自動化できない
- 複数のネットワークカプセル化に対応できない
- 論理NWトポロジに向かいたかった
- OpenvSwitch

### Neutron Logical Network Model
- L2 Network
	- VLANなどのL2ネットワーク
- Subnet(IP pools and DHCP)
	- v4,v6のIPアドレスと関連する状態を保持 	
- Port
	- deviceを１つバインドする  
- Router
	- local networkのroutingを制御
	- NAT変換を行う

### Features

|feature|NovaNetwork|Notes|Neutron|
|---|---|---|---|
|
|

### Components

** Controller(NetworkNode) **

- Neutron Server(NeutronAPI)
	- pluginをもつ 
	- SDN Controllerなどと連携
	
- Neutron L3 Agent
	- plugin依存  
	
- Neutron DHCP Agents
	- Queueと通信している
	- Network
	 
- Other Network Services
	- FWaaS, VPNaaS, LBaaS...etc
	- Driver経由で実施(HAProxyでも、F5などのH/Wでも可能)
	
- Neutron Metadata Agent
	- Neutronサーバに導入されている。
	- Cloud-Init(Linux), CloudBase-Init(Win)の情報や、ホスト名などが入っている

- DB
- Queue

** Compute Node **

- Neutron L2 Agent
	- local の vSwitchを管理している
	- 各ComputeNodeで稼働する

### Architecture

- L2,L3,L4, LBaaS,+L7レイヤまでサポート予定
- Plugin経由で様々なH/W対応

### Neutron Plugins
- http://stackalystics.com/report/driverlog
- 実際のテストの内容を参照できる
- Neutron は Niciraのプロジェクトだった
- ml2はCiscoのプロジェクト(multi-layer2の略)


### Neutron Linux Bridge

#### Plugin
- AZ,HostAggregateを使って同じ仮想マシンに集中させると、bridge数、ethが節約できるためスケールさせることができる

#### Linux Bridge Network Node
- IPアドレスはNetworkNode上のDHCPAgentが割り当てる
- NameSpace(netns)で

### Open vSwitch

#### Linux OpenvSwitch Plugin
- FLAT
- VLAN
- Tunnel(GRE,VXLAN,IPSec,GRE, VXLAN over IPSec)
- STP, VM instance毎のQoS Control
- OpelFlow support
- Remote Configuration(C,python)
- Kernel/user-spaceで利用可能(Hyper-V対応)

#### FLAT mode
- br-eth0 デバイスで untagged

#### VLAN mode
- 802.1q Trunkで通信する
- LovalVLANtagをglobalVLANtagへ変更する, segmentation vlanid　

#### TunnelMode
- GRE tunnel IDs
- Local Vlan tag を GRE tunnel tag へ変更する

#### VLAN vs GRE Scalability
|Type|Bits|Max Number of Tenant Networks|
|---|---|---|
|VLAN ID|12-bit|4096|
|VXLAN ID|24-bit|xxxxx|
|GRE tunnel ID|32-bit|4294967296|

- GRE tunnelを使えばよいが、、使う場合はNIC Off-Loadingを行わないと性能がでなかった
- 理由はMTUサイズによるパケット分割
- ただし、NIC OffLoadingを使用する場合、同一H/W+NICを利用してファームウェアバージョン管理が必要など、制約が増えてきて、クラウド向きではなくなってきた。
- VXLAN(24bit)を利用すれば問題ないが、VXLANをOVSで利用する場合マルチキャストで問題があるため、利用が難しいと言われている。(Kiloなら問題解決？)
- NiCira は　GRE + STT　で対応しようとしたが、FireWallを通過できないという問題がある
- JunoまではL3-Agentの冗長化を行う場合HAで対応が必要だった。
- もしくは、複数のパブリックIPを利用可能ならL3−Agentを冗長化できたが、
- SDNコントローラはL3Agentの冗長化、HAなどを提供できていたので、Neutron+SDNが必要だった(NovaNetworkという選択も存在した)


### ML2 Plugin-in

#### Layer
- 同一のPluginで複数のベンダの機構を利用することができるようになった
- OpenvSwitch+LinuxBridgeを利用する場合はML2−Pluginを利用する必要がある

```
- Neutron
    |
    +->ML2
    	|
    	+->Mechanism(Vendor)
```
- TypeManager
	- VLAN
	- VXLAN
	- GRE 
	
- Mechanism Manager
	- Hyper-V
	- CiscoNexus
	- OVS, LinuxBridege
 

#### ML2 Motivation
- ML2によりOVS関連の機能が分離されたため、自社製品にのみ対応すればよくなったので、開発が効率化された

#### Multi-Segment Networks


- GENEVE
	- STT(NSX):ジャンボフレームで通常のTCP
	- DPDK:intelが作成した。DataPlaneDeplymentKit(OVS-DPDK)。もうやめた
	- GRE:
	- VXLAN:


- Neutronの問題
	- L3Agentが可用性、スケーラビリティの面で問題があった。


### Neutron Agents
#### Routing/NAT & IPAM
- IPAM(IP address Management service)をDHCP＆NeutronDBでインスタンスに提供
- Routing,NAT(DNAT,SNAT)

#### Tenant Connection Needs L3
- DHCPマネジメントを提供

#### L3-Agent
- 論理Routerを作成
- 様々なサブネットを接続、GWとしても機能
- L3 Connectivityを提供（NAT）

|**|Nova-Network|Neutron|
|---|---|---|
|


NovaNetworkと同等の機能を提供するためNeutronでは下記機能を実装
- Schedulerにより複数のDHCPAgentを利用したスケールアウトができる
- JunoリリースでDVR and VRRPがリリースされた。おそらくKiloで性能面も担保されると思われる。
 
#### Neutron Agent Scheduling
- DHCP, L3Agnetを異なるnodeで提供するため
- HAなどで利用する

#### Network Service Driver
- DHCP
	- dnsmasq
- L3 Routing and NAT
	- iptables, routing table
- Access Control Lists
	- Neutron Security Service
- LBaaS
	- HAProxy
	- Radware vDirect
	- LVS
- FWaaS
	- iptables  
	- vArmor
-VPN as a Service
	- OpenSwan IPSec VPN
	
### LBaaS

#### Features
- HAProxyが標準
- 他のベンダもサポートしている
- アルゴリズム
	- Round-Robin
	- Least-Connection
	- Source-IP
- ヘルスモニタ
	- ICMP
	- TCP
	- HTTP
	- HTTPS

#### Architecture
- 資料参照

### Neutron Network Topology
- 資料参照

----
## OpenvSwitch 
### ComputeNode
- 資料を参照
### Network Node
- 資料を参照

----
### Metadata Service
- AWS互換サービス
- 169.254.169.254を使っている
- OverLapping IP Poolが使えない(NameSpaceが使えない)
- 

 	 

---
### LBaaS HandsOn

#### Topology Setup

- nova インスタンス起動

```
$ nova boot server1 --image --flavor
```

- subnetID確認

```
$ neutron subnet-list
```

- lb-pool を subnet に作成

```
$ neutron lb-pool-create --name <> --lb-method <> --protocol HTTP --subnet-id <subnet-id>
```

- subnetに属するinstanceのIPを確認

```
$ nova list
```

- pool に member追加


```
$ neutorn lb-member-create mypool --address <IP> --protocol-port 80
```

- healthmonitor を作成


```
$ neutron lb-healthmonitor-create --delay 3 --type HTTP --max-retries 3 --timeout 3
```

- healthmonitor と poolを関連づけ


```
$ neutron lb-healthmonitor-associate <healthmonitor ID> mypool
```

- VIPとpoolを関連づけ


```
$ neutron lb-vip-create --name myvip --protocol-port 80 --protocol HTTP --subnet-id <subnet ID> mypool
```


#### Configure Instances as Web Server

- SSH/HTTP通信の許可


```
$ neutron security-group-rule-create default --port-range-min 22 --port-range-max 22 --protocol tcp --remote-ip-prefix 172.24.4.0/24
$ neutron security-group-rule-create default --port-range-min 80 --port-range-max 80 --protocol tcp --remote-ip-prefix 172.24.4.0/24
```

##### Navigating Linux Networking

```
$ ifconfig
$ route -n
$ sudo iptables -nL -t nat
```


```
$ sudo ip netns list
$ sudo ip netns exec qrouter-**** ifconfig
$ sudo ip netns exec qrouter-**** 
```


------
## Swift

### CAP Theorem
- Consistency
- Availability
- Patition tolerance

Swift Availability and Partition


### Swift Capabiliteies
- 完全分散
- ３つ以上のデータ冗長性
- buil-in audit of drives
- RAID必要なし
- REST API
- Multi-tenancy

```
User
 |
 + - Proxy
      |
      +- Account:
      |     |
      +- Container:
      |     |
      +- Object:
            |
            +-- Auditors
            |
            +-- Updaters
            |
            +-- Replicators
```

### Detailed Architecture

- Ring
	- AccountRing
	- ContainerRing
	- ObjectRing

- Account/Containerが参照するDBは(SQLite)を用いているがファイルの数が増えてくると

### Swift Proxy Servers
- REST APIを公開している
- errorを処理する
- Objectはキャッシュしない
- consist hasing ringを使ってデータを返却可能なストレージnodeを決定する

### RING
- Clusterにおけるデータの場所を決定するMapping
- zone,device,partigin,replicaの情報を保持している
- クラスタの全nodeにコピーする

### Device Data in the Ring
|key|value|
|---|---|
|id|全デバイスのIndex|
|zone|どのzoneに属するか|
|weight|他のデバイスから見た重みづけ|
|IP|IPアドレス|
|port|port番号|
|device|/dev/sdaのようなディスク名|
|meta|General−use fieled|

### Preparing The Ring
- ringのパーティション数
	- md5 hashのビット数
	- 2の乗数で計算
	- ring sizeと最大のクラスタサイズのバランスを探す
- replica数
- zone数を確認
	- 最小は５を推奨

### RingBuilder
- Create rings:
- Add devices:
- Verify consistency of ring file:
- Rebalance rings: 

### ObjectServer
- ローカルストレージを利用してblob storage
- xattrsに対応したファイルシステムを利用する必要あり(XFS)
- objectのversioningに対応
- objectのexpirationに対応

### Account and Container Servers
- ContainerServer
	- オブジェクトのリストを保持
	- nested Containerは作成できない
- AccountServer:
	- containerのリストを保持
	- 使用状況の集計を行っている
- SQLiteDBを利用している 

### Replication
- corruptを検知したらreplicaを試みる
- Tombstone cleanup(expireデータを削除する)

### Object Replication
- Replicator:
	- hashファイルより計算
	- 異なるzoneにreplicaリクエストを発行
	- push bsed mechanism

### Account/Container Replication
- Replicator:
	- low-cost hash comparison
	- hashが異なる場合は壊れている行を探す
	- データベースが利用できない場合は、完全なデータベースをコピーしてくる
	- (DB ReplicatorによるAccout/Containerのレプリカは同期的) 

### Large Object Support
	- Upload時のセグメントサイズを決定
	- Upload時に

### Auditors
- ローカルオブジェクトを巡回して完全性を確認
- quarantinedとして破壊されたオブジェクトmarkする。

### Updaters（accounts and containers）
- containerリストに含まれる、accout/objectの情報をアップデート
- account,container毎のオブジェクト数を記録する

### Authentication
- Keytstone
- Swift認証機構(temp/swauth)

### swift-recon

### Swift ACLS
- Refferer
	- HTTP Reffererの情報を確認している
- Accounts/Users
- ACLはchain可能 

### Swift Notes
- ProxyサーバはCPU、Network I/Oネック
- Account/Container/Objectサーバは Disk, Network I/Oネック
- Do not use RAID on servers


### RequestFlow
#### ユーザがファイルアップロード
- ProxyへデータをPOSTする
- ProxynodeがHashに従い格納先を決定する
- replica数の設定に従いファイルをアップロードする(一貫性はBASE)
- ストレージの過半数に書き込みが成功したら、ユーザへレスポンス変更
- レプリケータはRingからデータを読み取り、パーティションを比較して、一貫性が取れていない場合


----
# Day3

## Tips
### OpenStack Network
- net
- subnet
- router
- port
- floating ip

- Network起動
- mac address を付与
- network node上の dhcp agent(dnsmasq)よりIP付与
- dhcp agentはNameSapce

- monasuca(Sensuを使ったMonitoring as a Service)

----

## Ceilometer
### Billing Process
- Metering *** <- Ceilometerが提供する
- Rating
- Billing

### Ceilometerの目的
- Metering
- Multi-publisher
	- Capacity Planning, Monitoring, Debuggingなど
- Alarming
	- monitoring + event trigger -> Action

### KeyFeatures
- OpenStackをpollingしている
- CeilometerAPI経由でデータ取得可能
- 閾値＋trigger
- リソースの利用状況を確認
- RESTAPI

### Architecture
- RabbitMQよりデータを取得するため、全コンポーネントは共通のRabbitMQを取得する必要がでてきた
- 詳細は資料参照

### Component
- Ceilometer API
- Ceilometer Database
- Ceilometer Messages Queue
- Metring and Multi-publisher related
	- Agent
		- Compute Agent
		- Central Agent
		- Notification Agent(icehouse)
	- Ceilometer Collector
	- Alarming related
		- Ceilometer Evaluator
		- Ceilometer Notifier

### Ceilometer API Server
- REST API via HTTP

### Ceilometer Database
- 複数のDBドライバーをもつが、１度に１つのDBを選択する
	- SQLAlchemy, MySQL, PostgresSQL
	- NoSQL: MongoDB, HBase
- MongoDB が最も利用されている
- 自動的にデータを取得している
	- time_to_live=-1 のため、永遠にデータ保持される
	- MongoDB 2.2以上をサポート
	- CollectorによってPurgeされる
	
### Ceilometer Message Queue
- 全てのOpenStackコンポーネントと同一のRabbitMQを使う必要がある
- Agentは測定情報をpublishしている
- Collectorは測定情報を受信して、DBに格納する
- 他のOpenStack Serviceはnotification messageをpublishしている

### Ceilometer Compute Agent
- それぞれのCompute Nodeで稼働している
- Nova APIをPollingをしている
- KeyStoneと接続する(PKIを使えるのであれば代替可能)
- ハイパーバイザより実際の利用状況をpollingして取得している
	- Current CPU time and usage, memory consumption
	- Disk write and reads
	- incoming and outgoing network traffic(bytes and number of packets)
- 対応ハイパーバイザ
	- libvirt
	- HyperV
	- VMware vSphereAPI(icehouse)
- RPCでCeilometer metering message que に送信している(UDPへ変更も可能)

### Central Agent
- Active/Passive HAのみ対応
- OpenStack APIをpollingしている
	- Nova API: floating IPの有無
	- Glance API: imageサイズとイメージの有無
	- Swift API: コンテナ数、オブジェクトのトータルサイズ、コンテナ毎のオブジェクトサイズ
- OpenStack APIをpollingするため、Keystoneと接続する必要がある
- Kwapi をpollingして電力消費量を取得できる	
- SDNコントローラをpollingできる
- RPCでCeilometer metering message queueに送信している(UDPへ変更も可能)

### Notification Agent
- スケールアップのために Ceilometer Collectorより分割された
- HA構成でデプロイ可能(スケールアップ？)
- OpenStackサービスのnotification message queueを確認している
- notificationから情報を抽出して、Metering情報を格納する

### Metering Data from Notification
- From Nova:
	- インスタンスの状態、スケジュール、flavor, deleted
	- memory, vCPU, epehemeralDisk
	- CPU
- From Cinder:
	- Volumeとサイズ
- From Glance:
	- image, アップロード数、更新回数、削除回数
	- イメージダウンロードサイズ
- From Neutron
	- network, subnet, port, router, floating ip 作成数、更新リクエスト数
	- Network traffic bandwidthとIPアドレスグループを確認
- From Heat:
	- stackの作成、更新、サスペンド、resume、削除リクエスト数
- From OpenStackAPI:
	- APIの呼び出し数

- Ceilometer用にコンバートしたnotification数を保存している
- YAML形式に変換ルールを記載する
- DB, File, dispacherに格納可能

### Ceilometer Collector
- HA構成が可能。スケールアウト可能
- Ceilometer message queueを参照している
	- Compute Agent
	- Central Agent
	- Notification Agent
	- message signatureをvalidate
- UDP socketも作成可能
- DB, File, dispacherに格納可能

### Ceilometer Alarm Evaluator
- HA構成が可能。スケールアウト可能
- Ceilometer APIを定期的にpollingしている
- KeyStoneとの接続が必要
- alarm state changeを評価している
	- Threshold-oriented alarms
	- meta alarm 
- alarmをトリガとしてCeilometer Notifier Message queueにメッセージを送信する

### Ceilometer Alarm Notifier
- HA構成、スケールアウト可能
- alarm evaluatorのalarm messageが格納されるnotifier message queueをListenしている
- アラームによってアクションを起こせる
	- HTTP(s) callback
		- 特定のURLをcallできる
		request
	- log

### Ceilometer Basic Terminology
- Meters
- Sample
- statics
- event

### Meter Attribute

- 資料参照

### Meter Type
- Cumulative
- Delta
- Gauge

### Sample Attribute


### Publishing Pipeline
- YAML で定義可能



----
## Heat
- OpenStackインフラデプロイのテンプレートエンジン

### Capability
- Deployment機能をstack(deployment)を呼ぶ
	- OpenStack resources:server, network, volumes,,,,etcを記述
	- RelationShips resources:
	- templateと呼ばれるテキストフォーマットで記述
- インフラを管理する
	- templateを変更し適用すると自動的にインフラ構成を変更できる
	- stackを削除するとインフラ構成を削除できる
- Configuration management toolsと統合できる
	- VM作成と一緒にpuppetと連携
	- cloud-initに値を渡せる
- Ceilometerと連携するとAutoScaleが実現できる

### Templating Language
- 対応しているフォーマット
	- AWS CloudFormation(CFN)
	- TOSCA(Topology and Orchestration Specification for Cloud Applications)
	- OASIS(Cloud Application Management for Platforms)
	- Heat Domain Specific Language(DSL)
	- Others
- Heatは HeatDSL, AWS CFN のフォーマットをNATIVEサポート


### HeatAPI
- heat-api: OpenStack Native reST API
- heat-api-cfn: AWS Query API
- どちらもQueueを利用している

### HeatEnginge
- オーケストレーションを行う

### Heat CloudWatch API
- AWSのCloudWatchを参照して作った
- デフォルトはCeilometerに置き換わる
- Auto-Scalingにつかわれた

### Heat Orchestration Template
- templateからstackを生成する
- orchestrationの情報を
- structure, abstractionはAWS CloudFormationと同じ
- YAML or JSON　で記述

### HOT Definitions
- Parameters
- Resources
	- Heatを使うリソース
	- Type, Properties, dependencyを記述
- Outputs

#### Parameters
```
Parameters:   <param name>:
	type: <string | number | json | comma_delimited_list | boolean>
	label: <human-readable name of the parameter>
	description: <description of the parameter>
	default: <default value for parameter>
	hidden: <true | false>
	constraints:
		<parameter constraints>

parameters:
	key_name:
		type: string
		description: Name of key-pair to be used for compute instance 	image_id: 
		type: string
		description: Image to be used for compute instance 
	instance_type:
		type: string
		description: Type of instance (flavor) to be used
```

#### Constrains

```
constraints:
 - length: { min: 6, max: 8 }
 description: User name must be between 6 and 8 characters
 - range: { min: 0, max: 10 }
 description: Number of floating-ips to allocate
 - allowed_values: [ m1.medium, m1.large, m1.xlarge ]
 description: Value must be one of m1.medium, m1.large or m1.xlarge.
 - allowed_pattern: "[A-Z]+[a-zA-Z0-9]*”
 description: User name must start with an uppercase character
```

#### Resources

```
parameters:
server_name:
  type: string
  description: Name of the server
default:
  str_replace:
    template: my_stack_name
  params:
    stack_name: { get_param: "OS::stack_name" }
key_name:
  type: string 
  description: Name of key-pair to be used for instance
image_id: 
  type: string 
  description: Image to be used for compute instance 
instance_type: 
  type: string 
  description: Type of instance (flavor) to be used
```

```
resources: 
  my_instance: 
    type: OS::Nova::Server 
    properties: 
      name: { get_param: server_name }
      key_name: { get_param: key_name } 
      image: { get_param: image_id } 
      flavor: { get_param: instance_type }
      user_data: |
         #!/bin/bash
         sudo apt-get update
```


### Auto-Scaling

#### Heat Auto Sacling Principles

- Heat + Ceilometer Alarming = Alarming
- Up/Down Scaling

#### Heat Auto Scaling Resources

|name|description|
|---|---|
|OS::Heat::AutoScalingGroup|An autoscaling group that can scale arbitrary resources|
|OS::Heat::ScalingPolicy|A resource to manage scaling of OS::Heat::AutoScalingGroup|
|OS::Ceilometer::Alarm|The resource for defining a ceilometer alarm|
|OS::stack_id|Heat “stack” indentifier used as glue to tie an OS::Ceilometer::Alarm to an OS::Heat::AutoScalingGroup|


--
## For Excersise 14

- project 

```
$ keystone tenant-create --name prac01 --description 'Comprehensive Practice project 01'
$ keystone tenant-list
```

- user

```
$ keystone user-create --name john01 --email 'john01@domain.tld' --pass nova --tenant prac01
$ keystone user-role-add --user john01 --role admin --tenant prac01
$ keystone user-role-list --user john01 --tenant prac01
$ keystone user-role-remove --user john01 --tenant prac01 --role _member_
```

- quota

```
$ nova quota-show --tenant fa08ab5f7f6e478cad8d83e02fa97ce9
$ cinder quota-show fa08ab5f7f6e478cad8d83e02fa97ce9

$ nova quota-update --instances 2 --cores 4 fa08ab5f7f6e478cad8d83e02fa97ce9
$ cinder quota-update --gigabytes 3 fa08ab5f7f6e478cad8d83e02fa97ce9
```

- net

```
$ neutron net-create --tenant-id 925fd528e0454a31aee5ff3d9d82792d prac01
```


- subnet

```
$ neutron subnet-create --name prac01subnet --gateway 10.2.0.225 --allocation-pool start=10.2.0.240,end=10.2.0.245 --tenant-id 925fd528e0454a31aee5ff3d9d82792d prac01 '10.2.0.224/27'
```

- security group

```
$ nova secgroup-create custom
$ nova secgroup-list-rules custom
$ nova secgroup-add-rule custom icmp -1 -1 0.0.0.0/0
$ nova secgroup-add-rule custom tcp 22 22 0.0.0.0/0
$ nova secgroup-add-rule custom tcp 80 80 0.0.0.0/0
```

- nova boot

```
$ nova boot --image cirros-0.3.2-x86_64-uec --flavor m1.tiny john01
$ nova show john01
$ nova add-secgroup john01 custom
```
- image 登録

```
$ glance image-create --name ubuntu --container-format bare --disk-format qcow2 < images/ubuntu1204.img
```

- telemetry

```
$ ceilometer alarm-threshold-create --name cpu_high --description 'Instance running hot' -m cpu_util --statistic avg --period 600 --evaluation-periods 3 --comparison-operator gt --threshold 80 --alarm-action 'log://' -q resource_id=40ec0b1d-8478-4244-ab33-c388da21c135
```

- nova boot(demo)

```
$ nova boot --image cirros-0.3.2-x86_64-uec --flavor m1.tiny demo01
```

- neutron(lb)

```
$ neutron subnet-list
$ neutron lb-pool-create --name prac01pool --lb-method ROUND_ROBIN --protocol HTTP --subnet-id 602805df-69af-48c1-b319-2bd4e0fdf296

$ nova list
$ neutron lb-member-create prac01pool --address 10.2.0.240 --protocol-port 80
$ neutron lb-member-create prac01pool --address 10.2.0.242 --protocol-port 80

$ neutron 
(neutron) lb-healthmonitor-create --delay 3 --type HTTP --max-retries 3 --timeout 3
CTRL + C
$ 
$ neutron lb-healthmonitor-associate fec30d95-347b-495a-a82e-419018332ba8 prac01pool
$ 
$ neutron lb-vip-create --name prac01vip --protocol-port 80 --protocol HTTP --subnet-id 602805df-69af-48c1-b319-2bd4e0fdf296 prac01pool
```

- neutron(router)

```
$ neutron router-create prac01router
$ neutron router-gateway-set 65791e44-3720-4b5a-a942-2e79bfe2a815 a6e7c067-925c-444a-b38f-57064f54819e
$ neutron router-list
$ neutron subnet-list
$ neutron router-interface-add 65791e44-3720-4b5a-a942-2e79bfe2a815 602805df-69af-48c1-b319-2bd4e0fdf296
```

- floating-ip

```
$ neutron floatingip-create public
$ neutron floatingip-show 59defabb-c210-47fc-a45e-7acf2cabb3f8
$ neutron router-port-list prac01router
$ neutron floatingip-associate 59defabb-c210-47fc-a45e-7acf2cabb3f8 ba68e53d-44d1-4679-a317-d9aae6f8180c
```

- 

ロードバランサのVIPのポート番号を
FloatingIPに紐付ける

FloatingIPからロードバランサのポート番号を選択する



