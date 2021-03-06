
#### logmanagement
- loggregater 
- enable connect 3rd party service
```
$ cf cups <LOGSERVICE> -l syslog://<HOST>:<PORT>
$ cf bind-service <APP> <LOGSERVICE>
$ cf restage
```

#### Application Monitoring Tool
- NewRelic

#### autoscaling
- CF can allow applications to be automatically scaled
- AutoScaling
- Must be installed by administrator


#### Zero-Downtime Deployments
- Blue/Green Deployment
- BG Deployment was used when rolling upgrade
```
$ cf push blue -p app.war -n always-reliable -i 4
$ cf push green -p app.war -n temp-route -i 4

# duplicate route-> disconnect blue
$ cf map-route green cfapps.io -n always-reliable
$ cf unmap-route blue cfapps.io -n always-reliable

# temp route delete
$ cf unmap-route green cfapps.io -n temp-route

# delete app
$ cf delete blue
```

### Cloud Foundry Architecture
- CloudFoundry v1.5<~ はDIEGOになる
- Load-Balancer -> Router
 -
- BlobStore(NFS Store, droplet, buildpack...)
- CC DB(MetaData in cloud)
- CloudController
- AZ > DEA > Warden(Droplet)
- Service Broker*s(
- HealthManager
- UAA/Login Servers
- NATS
- BOSH(CPI --- IaaS)

UAA: User Authorization and Authentication
DEA: Droplet Execution Agent

#### LoadBalancer(HAProxy)
- ルータの前段に構える
- Floting IPを持つ
- Load-balancing
- SSL-Termination
- HAProxy or F5, NSX
- SPOF

#### Router
- 内部のHTTP通信を担っている(System & Service)
- supports websockets
- SPOF

#### Cloud Controller＊
- Command, Control のエンドポイント

#### BlobStore＊
- ApplicationPackage,Dropletsを格納している
- SPOF

#### CCDB
- Stores Information
 - App Name

#### AZ

#### DEA
- Linux VM
- manages application lifecycle
- DIEGOになるとDockerを管理するようになる
- NATS message bus を通じて状態を通知している

#### WardenContainer
- LightweightVM(LXC)
- Dropletsを動かしている

#### Service Broker
- サービスカタログ

#### HealthManager
- actual stateを管理
- expected stateかモニタリング
- CloudControllerに状態を伝える

#### Messaging(NATS)
- Single NATS/CloudFoundry

#### UAA/LoginServices
- OAuth2.0
- Token Server
- ID Server
- OAuth Scopesand SCIM
- Login Server
  - UAA DB
  - SAML Suppport(for SSO)
  - Active Directry Support with VMware SSO Appliance
- Access auditing

#### Cloud Foundry BOSH
- Tool chanin
- CloudProviderInterfaceによりIaaSを隠ぺい
- IaaS installer(v1.5-> openstack, aws)
- VMcreation and management
- HA(Restart DEA, CF Internal Processes)

#### Health Manager
- 


### Continuous Delivery adn Cloud Foundry
- SCM
- CI
- CD
 - CI + automated deployment


### DIEGO
- DIEGO = DEA in GO
- Metron Agent がすべてのログをとる
- Brain(MetricsServer) が性能をとっている（HealthManager)
- Converger: Scaleup,Scaleout
- Auctioneer: Dropletを稼働させるCellを選択（スケジューラ）
















