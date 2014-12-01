# OpenShift Seminor for partner


-------


## Day1 Lecture


### Broker
- 複数のnodeホストを管理する。
- broker is responsible for state, DNS, and authentication
- システムの状態はmongodbに管理されているため、複数Broker構成でもmongodbは同一（クラスタ構成）である必要がある。

### NODE
- GEARが稼働するホスト、実態はSELINUXで分割された空間にGEARがデプロイされる


#### GEARS
- SELINUX Policies でnodeインスタンスを論理的に分割
- 分割された領域にGEARがデプロイされる。
- 同じdistrictのgearは管理者権限でnodeを移動できる

### CARTRIDGES
- Java, PHP, Python, Ruby, MySQL, POSTGRESや
- CUSTOMも可能

### WORKFLOW

### SCALING
- Vertical, Horizontal

### Communication
- Client->Broker->ActiveMQ->Node
- RESTAPI で操作可能
- 
### HTTP FLOW
- User -> Proxy -> Gear

-----
##Day2
### Chapter13 on Learning OpenShift_ebook.pdf
### Lab23
### Chapter5
- www.github.com/gshipleg/mlbparks
- mongodb へデータ登録後は下記手順で実施するイメージ
### Chapter7




```
$ rhc app create mlbparks jbosseap-6
$ rhc cartridge add mongodb-2.4 -a mlbparks
$ rhc app ssh mlbparks

\> cd /tmp
\> wget https://raw.github.com/gshipley/mlbparks/master/mlbparks.json

\> mongoimport --jsonArray -d $OPENSHIFT_APP_NAME -c teams --type json --file /tmp/mlbparks.json -h $OPENSHIFT_MONGODB_DB_HOST --port $OPENSHIFT_MONGODB_DB_PORT -u $OPENSHIFT_MONGODB_DB_USERNAME -p $OPENSHIFT_MONGODB_DB_PASSWORD
connected to: 127.12.242.2:27017
Wed Nov 12 21:27:11.759 check 9 30
Wed Nov 12 21:27:11.761 imported 30 objects

\> mongo --quiet $OPENSHIFT_MONGODB_DB_HOST:$OPENSHIFT_MONGODB_DB_PORT/$OPENSHIFT_APP_NAME -u $OPENSHIFT_MONGODB_DB_USERNAME -p $OPENSHIFT_MONGODB_DB_PASSWORD --eval "db.teams.count()"
30

\> mongo $OPENSHIFT_MONGODB_DB_HOST:$OPENSHIFT_MONGODB_DB_PORT/$OPENSHIFT_APP_NAME --eval 'db.teams.ensureIndex( { coordinates : "2d" } );'
MongoDB shell version: 2.4.9
connecting to: 127.12.242.2:27017/mlbparks
[object Object]

\> exit

$ cd /home/vagant/ose
$ rhc git-clone mlbparks
Initialized empty Git repository in /home/vagrant/ose/mlbparks/.git/
Your application Git repository has been cloned to '/home/vagrant/ose/mlbparks'

$ cd mlbparks
$ ls
$ vi pom.xml
$ git diff                     
diff --git a/pom.xml b/pom.xml
index ed7d563..055200d 100755
--- a/pom.xml
+++ b/pom.xml
@@ -60,6 +60,11 @@ jboss-eap-*-maven-repository/org/jboss/spec/jboss-javaee-6.0
                        <type>pom</type>
                        <scope>provided</scope>
                </dependency>
+               <dependency>
+                       <groupId>org.mongodb</groupId>
+                       <artifactId>mongo-java-driver</artifactId>
+                       <version>2.9.1</version>
+               </dependency>
        </dependencies>
        <profiles>
                <profile>

$ git commit -am "added MongoDB dependency"
$ git push
Counting objects: 5, done.
Compressing objects: 100% (3/3), done.
Writing objects: 100% (3/3), 395 bytes, done.
Total 3 (delta 2), reused 0 (delta 0)
remote: Stopping MongoDB cartridge
remote: Stopping jbosseap cartridge
remote: Sending SIGTERM to jboss:5142 ...
remote: Building git ref 'master', commit b4caef0
remote: Building jbosseap cartridge
remote: Found pom.xml... attempting to build with 'mvn -e clean package -Popenshift -DskipTests'
remote: Apache Maven 3.0.3 (r1075437; 2011-06-20 13:22:37-0400)
remote: Maven home: /etc/alternatives/maven-3.0
remote: Java version: 1.7.0_71, vendor: Oracle Corporation
remote: Java home: /usr/lib/jvm/java-1.7.0-openjdk-1.7.0.71.x86_64/jre
remote: Default locale: en_US, platform encoding: ANSI_X3.4-1968
remote: OS name: "linux", version: "2.6.32-504.el6.x86_64", arch: "amd64", family: "unix"
remote: [INFO] Scanning for projects...
remote: [INFO]                                                                         
remote: [INFO] ------------------------------------------------------------------------
remote: [INFO] Building mlbparks 1.0
remote: [INFO] ------------------------------------------------------------------------

---- 省略 ----


remote: [INFO] Packaging webapp
remote: [INFO] Assembling webapp [mlbparks] in [/var/lib/openshift/5464144da0a3b4d7f20000ab/app-root/runtime/repo/target/mlbparks]
remote: [INFO] Processing war project
remote: [INFO] Copying webapp resources [/var/lib/openshift/5464144da0a3b4d7f20000ab/app-root/runtime/repo/src/main/webapp]
remote: [INFO] Webapp assembled in [41 msecs]
remote: [INFO] Building war: /var/lib/openshift/5464144da0a3b4d7f20000ab/app-root/runtime/repo/deployments/ROOT.war
remote: [INFO] WEB-INF/web.xml already added, skipping
remote: [INFO] ------------------------------------------------------------------------
remote: [INFO] BUILD SUCCESS
remote: [INFO] ------------------------------------------------------------------------
remote: [INFO] Total time: 1:39.090s
remote: [INFO] Finished at: Wed Nov 12 21:47:38 EST 2014
remote: [INFO] Final Memory: 15M/141M
remote: [INFO] ------------------------------------------------------------------------
remote: Preparing build for deployment
remote: Deployment id is c44cad02
remote: Activating deployment
remote: Starting MongoDB cartridge
remote: Deploying jbosseap cartridge
remote: Starting jbosseap cartridge
remote: Found 127.12.242.1:8080 listening port
remote: Found 127.12.242.1:9999 listening port
remote: /var/lib/openshift/5464144da0a3b4d7f20000ab/jbosseap/standalone/deployments /var/lib/openshift/5464144da0a3b4d7f20000ab/jbosseap
remote: /var/lib/openshift/5464144da0a3b4d7f20000ab/jbosseap
remote: Artifacts deployed: ./ROOT.war
remote: -------------------------
remote: Git Post-Receive Result: success
remote: Activation status: success
remote: Deployment completed with status: success
To ssh://5464144da0a3b4d7f20000ab@mlbparks-ose.user30.onopenshift.com/~/git/mlbparks.git/
   fab95b4..b4caef0  master -> master

$ cd ../../
$ pwd
/home/vagrant

$ mkdir sample_src
$ cd sample_src ; pwd
$ git clone https://github.com/gshipley/mlbparks.git
Initialized empty Git repository in /home/vagrant/mlbparks/.git/
remote: Counting objects: 79, done.
remote: Total 79 (delta 0), reused 0 (delta 0)
Unpacking objects: 100% (79/79), done.

$ cd /home/vagrant/sample_src/mlbparks/src/main/java
$ find ./
./
./.gitkeep
./org
./org/openshift
./org/openshift/mlbparks
./org/openshift/mlbparks/mongo
./org/openshift/mlbparks/mongo/DBConnection.java
./org/openshift/mlbparks/rest
./org/openshift/mlbparks/rest/MLBParkResource.java
./org/openshift/mlbparks/rest/JaxrsConfig.java
./org/openshift/mlbparks/domain
./org/openshift/mlbparks/domain/MLBPark.java

$ find /home/vagrant/ose/mlbparks/src/main/java/
/home/vagrant/ose/mlbparks/src/main/java/
/home/vagrant/ose/mlbparks/src/main/java/.gitkeep

$ cd /home/vagrant/ose/mlbparks/src/main/java/ ; pwd
$ mkdir -p org/openshift/mlbparks/mongo
$ cp /home/vagrant/sample_src/mlbparks/src/main/java/org/openshift/mlbparks/mongo/DBConnection.java ./org/openshift/mlbparks/mongo/

$ git add .
$ git commit -am "Adding database connection class"

$ cd ../webapp/WEB-INF/ 
$ vi beans.xml
   <?xml version="1.0"?>   <beans xmlns="http://java.sun.com/xml/ns/javaee" xmlns:xsi="http://   www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://java.   sun.com/xml/ns/javaee http://jboss.org/schema/cdi/beans_1_0.xsd"/>

$ git add .
$ git commit -am "Adding beans.xml for CDI"

$ cd ../../java/org/openshift/mlbparks/  
$ mkdir domain
$ cd domain
$ cp /home/vagrant/sample_src/mlbparks/src/main/java/org/openshift/mlbparks/domain/MLBPark.java  ./

$ git add .
$ git commit -am "Adding MLBParks model object"

$ cd ../
$ mkdir rest
$ cd rest
$ cp /home/vagrant/sample_src/mlbparks/src/main/java/org/openshift/mlbparks/rest/* ./
$ git add .
$ git commit -am "Adding REST web services"
$ git push
```

-----
## Lab1

### 1.1 Assumuptions
- ３台のRHELサーバを用いる
- SSH, Git, yumなどのコマンドを理解している必要がある

### 1.2 What you can expect to learn form this training
- OpenShiftEnterprise 2.2 が構築できるようになる
- CLI, AdminConsole経由で操作できるようになる

### 1.3 Overview of OpenShift Enterprise PaaS
```
Platform as a Service is changing the way developers approach developing software. Developers typically use a local sandbox with their preferred application server and only deploy locally on that instance. Developers typically start JBoss locally using the startup.sh command and drop their .war or .ear file in the deployment directory and they are done. Developers have a hard time understanding why deploying to the production infrastructure is such a time-consuming process.

System administrators understand the complexity of not only deploying the code, but procuring, provisioning, and maintaining a production level system. They need to stay up to date on the latest security patches and errata, ensure the firewall is properly configured, maintain a consistent and reliable backup and restore plan, monitor the application and servers for CPU load, disk IO, HTTP requests, etc.

OpenShift Enterprise provides developers and IT organizations an auto-scaling cloud application platform for quickly deploying new applications on secure and scalable resources with minimal configuration and management headaches. This means increased developer productivity and a faster pace with which IT can support innovation.

This manual will walk you through the process of installing and configuring an OpenShift Enterprise 2.2 environment as part of this training class that you are attending.
```

### 1.4 Overview of IaaS
- EC2, VMware, RHEV, Rackspace, CloudStack , RHELサーバ上で稼働する
- EC2でLabは実施する。

### 1.5 Electronic version of this document

- Document URL
```
http://training.runcloudrun.com
```

- Userinfo

|content|description|
|--|--|
|id|user30|
|broker|54.65.75.189|
|node1|54.65.75.172|
|node2|54.65.76.53|


-----
## Lab2
### AWS SecretKey Import
“http://training.runcloudrun.com/”のLinkよりダウンロード

### Login


```
$ ssh -i aws-tokyo.cer ec2-user@[IP]
```

-----
## **Lab 3: Installing OpenShift Enterprise with *oo-install***


During this lab you will stand up your OpenShift Enterprise (OSE) environment.  Our environment will be modeled after one of the world's most popular public PaaS offerings.  Some configuration choices have been made in order to save money (AWS bill concerns), but we have stayed as true to a production configuration as possible.  We will deploy the following:

- (1) Broker
- (2) OSE nodes

As you can see, this will consume 3 AWS EC2 nodes.  

###**Puppet or openshift.sh?**

Many OSE customers have been leveraging puppet to deploy a highly available OSE.  In this lab we will leverage the new oo-install command in OSE 2.2. OSE 2.2 was to be released to the general public this month (Nov, 2014).  oo-install cannot make the assumption that the customer knows or wants puppet and so it drives automation via the openshift.sh installation script.  oo-install will interrogate the user with questions, generate a YAML file based on the responses, and feed that file to openshift.sh as proper variables.  This offers a cleaner and more reproducible installation.

This does not mean we are not also investing in puppet.  Shortly after the release of OSE 2.2 we will also have completed the porting of the Origin puppet modules to work with OSE 2.2.  Customers will eventually have a choice between puppet or oo-install.

### **What Has Already Been Done to the Environment** 

**Packaging:**

As I mentioned, this is OSE 2.2.  OSE 2.2 requires RHEL 6.6. Check out the yum repository configuration on your boxes.


    $ yum repolist

  
    jb-eap-6-for-rhel-6-server-rpms           JBoss Enterprise Application server
    jb-ews-2-for-rhel-6-server-rpms           JBoss Enterprise Web Server
    rhel-6-server-ose-2.2-infra-rpms          Red Hat OpenShift Enterprise
    rhel-6-server-ose-2.2-jbossamq-rpms       Red Hat OpenShift Enterprise
    rhel-6-server-ose-2.2-jbosseap-rpms       Red Hat OpenShift Enterprise
    rhel-6-server-ose-2.2-jbossfuse-rpms      Red Hat OpenShift Enterprise
    rhel-6-server-ose-2.2-node-rpms           Red Hat OpenShift Enterprise
    rhel-6-server-ose-2.2-rhc-rpms            Red Hat OpenShift Enterprise
    rhel-6-server-rpms                        Red Hat Enterprise Linux 6
    rhel-server-rhscl-6-rpms                  Red Hat Software Collections
    rhui-REGION-client-config-server-6        Red Hat Update Infrastructure
    rhui-REGION-rhel-server-releases          Red Hat Enterprise Linux 
    rhui-REGION-rhel-server-releases-optional Red Hat Enterprise Linux
    rhui-REGION-rhel-server-rh-common         Red Hat Enterprise Linux
    rhui-REGION-rhel-server-rhscl             Red Hat Enterprise Linux

Some of you might have RHUI channels enabled instead for the RHEL access.  Your EC2 image has already been registered with RHN through subscription-manager and the needed channels subscribed to via /etc/yum.repos.d/.  SSL keys for the connection to the development mirrors have been configured in /var/lib/yum.

oo-install requires that the following packages additionally be installed before you start:

**Note:** For this training class, the packages listed below have already been installed.


    $ yum -y install ruby unzip curl ruby193-ruby yum-plugin-priorities

**CPU/MEM/NET**

We will be using an AWS m1.small instance.  That does not mean we recommend the m1.small for production use by customers.  m3.mediums or higher would be better suited for production.  We have also already configured the AWS security groups to allow for the required port access.  

**Password-less Access**

oo-install will be executed from your broker nodes and then SSH into the other EC2 instances and configure OpenShift.  In order to allow that to occur, the OSE 2.2 oo-install requires that an SSH private/public key exchange be used in place of a normal password challenge.  This has already been set up for you in the images provided.  

The oo-install program will default to using the root user.  You can use any user.  Should you wish to use another user, you need to ensure that full access has been granted via sudo and that sudo has been configured to be password-less as well.  For the purpose of this class, please use the root user when asked during the oo-install.  We have modified /etc/ssh/sshd_config to allow for root login access.  


### Download and Run oo-install

Now that we have done our pre-work, we can actually issue the oo-install command.  In this environment, due to the fact we are on AWS and are using a development build of the product the check list you should run through is:


- **Machine Roles:** Do I know what my boxes are and what role I'm going to ask them to play (broker, msgserver, mongo, node)?
- **Password-less SSH:** Do I have a password-less SSH login to the instances from the broker where I will be issuing the oo-install command?
- **Power User:** Do I know what username I will be giving to oo-install to execute the commands on the instances? It needs to have full command access through sudo or be root. For the classroom environment, just use root.
- **Yum Channels:** Does `yum repolist` show the correct repo setup?  Do I have the five prereq packages installed?
- **IP Addresses:** Have I decided on a virtual hostname for brokers?  Do I know which broker's IP address I plan to give the broker virtual hostname?

oo-install is not shipped with the product, but instead maintained out of cycle and distributed on openshift.com.  First we need to download and execute the *oo-install* script.  To do this, issue the following command as the **ec2-user** or **root** user on the **broker** host:

    $ sudo su -
	# sh <(curl -s https://install.openshift.com/ose-2.2)

The curl command will download the installer and create a .openshift directory in the home directory of the user who issued the command.  It will then execute the installation program.  The first question that is asked is as follows:

    Checking for necessary tools...
    ...looks good.
    Downloading oo-install package...
    Extracting oo-install to temporary directory...
    Starting oo-install...
    OpenShift Installer (Build 20141003-2025)
    ----------------------------------------------------------------------
    
    Welcome to OpenShift.
    
    This installer will guide you through a basic system deployment, based
    on one of the scenarios below.
    
    Select from the following installation scenarios.
    You can also type '?' for Help or 'q' to Quit:
    1. Install OpenShift Enterprise
    2. Add a Node to OpenShift Enterprise
    Type a selection and press <return>: 1
    
    It looks like you are running oo-install for the first time on a new
    system. The installer will guide you through the process of defining
    your OpenShift deployment.


We are selecting "1" so we can install OpenShift Enterprise for the first time.  As you can see, oo-install can be used to add additional nodes to the environment as well.

The next thing we need to do is install a DNS server for usage during this class.  For the purposes of this class, we are going to be using BIND, which we will install on the broker host provided to you by the instructor.  The oo-install program will display the following information:

    It looks like you are running oo-install for the first time on a new
    system. The installer will guide you through the process of defining
    your OpenShift deployment.

    ----------------------------------------------------------------------
    DNS Configuration
    ----------------------------------------------------------------------

    First off, we will configure some DNS information for this system.

    Do you want me to install a new DNS server for OpenShift-hosted
    applications, or do you want this system to use an existing DNS
    server? (Answer 'yes' to have me install a DNS server.) (y/n/q/?)

Answer *y* to have BIND installed on the broker host.

The next thing we need to do is set the hostname of the environment that we will be using.  For this class we will be using userX.onopenshift.com, where X is a user number provided to you.

    All of your hosted applications will have a DNS name of the form:

    <app_name>-<owner_namespace>.<all_applications_domain>

    What domain name should be used for all of the hosted apps in your
    OpenShift system? |example.com|

Type in *userX.onopenshift.com* domain and press the enter key.

    Do you want to register DNS entries for your OpenShift hosts with the
    same OpenShift DNS service that will be managing DNS records for the
    hosted applications? (y/n/q)

Answer *y* as we do want to add DNS records for hosted applications.

    What domain do you want to use for the OpenShift hosts?
    |hosts.userX.onopenshift.com|

Select the default domain of hosts.userX.onopenshift.com by pressing the enter key.

We then need to specify the hostname for the host we are describing:

    You have indicated that you want the installer to deploy DNS. Please configure a host to use as the nameserver.

    Hostname (the FQDN that other OpenShift hosts will use to connect to
    the host that you are describing):

Enter in broker.hosts.userX.onopenshift.com and press the enter key.

We then need to provide the IP address of the broker.hosts.userX.onopenshift.com host that we are defining.  It is important to use the 54.x.x.x address that has been provided to you by the instructor.

    Hostname / IP address for SSH access to broker.hosts.userX.onopenshift.com from
    the host where you are running oo-install. You can say 'localhost' if
    you are running oo-install from the system that you are describing:
    |broker.hosts.userX.onopenshift.com|

Input the 54.x.x.x address provided to you by the instructor.

Once you enter in the IP address of the host, you will then need to provide the username that will be used to install the product.  For this class, you can use the default of *root*:

    Username for SSH access to 54.65.64.139: |root|

Use the default of *root*.

You should see the following output indicating that *oo-install* was able to authenticate with the provided username using a password-less login via SSH keys.  You will then need to specify the IP address of the host:

Validating root@54.65.64.139... looks good.

    Detected IP address 172.31.29.241 at interface eth0 for this host.
    Do you want Nodes to use this IP information to reach this host?
    (y/n/q/?)

Answer *n* and then press the enter key.

    Specify the IP address that other hosts will use to connect to this
    host (Detected 172.31.29.241): |54.65.64.139|

Once you enter in *n*, you will be asked to provide the IP address that you would like to use.  Use the 54.x.x.x one provided by pressing the enter key.

You will then be asked to specify the network interface that should be used to send packets across the network:

    Specify the network interface that other hosts will use to connect to
    this host (Detected 'eth0'): |eth0|

Use the default of *eth0* by pressing the enter key.

You will then be presented with the following information:

    Normally, the BIND DNS server that is installed on this host will be
    reachable from other OpenShift components using the host's configured
    IP address (54.65.64.139).

    If that will work in your deployment, press <enter> to accept the
    default value. Otherwise, provide an alternate IP address that will
    enable other OpenShift components to reach the BIND DNS service on
    this host: |54.65.64.139|

Use the default 54.x.x.x IP address by pressing the enter key.

### Broker Configuration

Now that we have our DNS server installed on our host, we can also assign the *broker* role to the host so that the host will act as both the DNS server and the OpenShift Enterprise Broker.

    ----------------------------------------------------------------------
    Broker Configuration
    ----------------------------------------------------------------------

    Okay. I'm going to need you to tell me about the host where you want
    to install the Broker.

    Do you want to assign the Broker role to broker.hosts.userX.onopenshift.com?
    (y/n/q/?)

Enter in *y* and press the enter key.

You will then be asked if you want to configure an additional broker:

    Do you want to configure an additional Broker? (y/n/q)

Enter in *n* and press enter.

### Node Configuration

At this point in the installation we have configured a DNS server, MongoDB server, and a Broker host.  We now need to configure a host for a node that our applications will be deployed on.


    ----------------------------------------------------------------------
    Node Configuration
    ----------------------------------------------------------------------

    Okay. I'm going to need you to tell me about the host where you want
    to install the Node.

    Do you want to assign the Node role to broker.hosts.userX.onopenshift.com?
    (y/n/q/?)

OpenShift allows you to assign the *node* role to the same machine as the broker.  Doing this would mean that your applications will be deployed on the same host as the broker.  This is a bad architecture and should never be used in a production environment.  However, it may be suitable for a proof of concept where only a single machine is available.

For this class, we are going to install a multi-node configuration.  For that reason, answer *n* and press the enter key.

Once you say not to add the node role to the broker host, you will be asked to provide information about the host that you will be using for your node:

    Okay, please provide information about this Node host.

    Hostname (the FQDN that other OpenShift hosts will use to connect to
    the host that you are describing):

Enter in *node1.hosts.userX.onopenshift.com* and press the enter key.

You will then be asked to provide the IP address of the node1 host.

    Hostname / IP address for SSH access to node1.hosts.userX.onopenshift.com from
    the host where you are running oo-install. You can say 'localhost' if
    you are running oo-install from the system that you are describing:
    |node1.hosts.userX.onopenshift.com|


Enter in the *54.x.x.x* IP address of your node1 host and press the enter key.


    Username for SSH access to 54.65.70.239: |root|

Use the default username that is provided (*root*) and press the enter key.

    Validating root@54.65.70.239... looks good.

    Detected IP address 172.31.29.240 at interface eth0 for this host.
    Do you want to use this as the public IP information for this Node?
    (y/n/q/?)

We then need to provide the IP address of the node host.  By default, the installation program will ask you to use the 172.x.x.x address.  This is **not** what we want to use.  Enter in *n* and press the enter key.

    Specify the public IP address for this Node (Detected 172.31.29.240):
    |54.65.70.239|

Use the provided public 54.x.x.x IP address and press the enter key.


You will then be asked to specify the network interface that should be used to send packets across the network:

    Specify the network interface that other hosts will use to connect to
    this host (Detected 'eth0'): |eth0|

Use the default of *eth0* by pressing the enter key.

You will then see the following output:

    That's everything we need to know right now for this Node.

    Currently you have described the following host system(s):
    * broker.hosts.userX.onopenshift.com (Broker, NameServer)
    * node1.hosts.userX.onopenshift.com (Node)

    Do you want to configure an additional Node? (y/n/q)


At this time, we need to install our 2nd node.  Enter in *y* and press enter and then following the on-screen instructions to add your node2 just as you did node1.

You will then be asked if you want to manually provide username/password combinations for the required services such as ActiveMQ etc.  

    Do you want to manually specify usernames and passwords for the
    various supporting service accounts? Answer 'N' to have the values
    generated for you (y/n/q)

Enter in *n* and press the enter key.

You will then see an overview of the installation:

    Here are the details of your current deployment.

    Note: ActiveMQ and MongoDB will be installed on all Broker instances.
    For more flexibility, rerun the installer in advanced mode (-a).

    DNS Settings
      * Installer will deploy DNS
      * Application Domain: userX.onopenshift.com
      * Register OpenShift hosts with DNS? Yes
      * Component Domain: hosts.userX.onopenshift.com

    Global Gear Settings
    +-------------------------+-------+
    | Valid Gear Sizes        | small |
    | User Default Gear Sizes | small |
    | Default Gear Size       | small |
    +-------------------------+-------+

    Account Settings
    +----------------------------+------------------------------------------------------------------+
    | OpenShift Console User     | demo                                                             |
    | OpenShift Console Password | j8AFZ4yoQrulFhQdILD6Xg                                           |
    | Broker Session Secret      | advO54MMmtw6r0oehHyRQ                                            |
    | Console Session Secret     | g1lSvmvaBop8JRdnYlCdOQ                                           |
    | Broker Auth Salt           | a0YA15nc1E53IfoLLwl1Kw                                           |
    | Broker Auth Private Key    | -----BEGIN RSA PRIVATE KEY-----                                  |
    |                            | MIIEowIBAAKCAQEA9CLW0CxxY824ALMY9jfq+aPGI2QMg5s7xTt11SyEb+XpUnjX |
    |                            | 42Kt+W04ghtQk/8Fmu/LreCQlEgS/hKEP0O0C8LvDkaZ0E2gUUjSKdkGZNiRsvq6 |
    |                            | PbXadZ0BSsnOEe8uA3J6AuPYI4KZw4B6oEdysKx2M1plYm5xdJczFPkUNs8rLTEB |
    |                            | IZMgFErzaywvju2cOrI32t/SySZstfXYHwCi8IdwM6bAcwoiQ9vCQz8kaIWdyenc |
    |                            | UGRaCMLdAph7LLyTUB13qO1jsgxcYPYQdmxDdCbxm5eLm0IWZkTZCH20CXMHF+VK |
    |                            | /M+ElHefccQgMBura6HC1pUOoEhpk55uNvT0TQIDAQABAoIBAQC1lFQBcYzElnWM |
    |                            | z6h5OQ3jrxPnrrpACG1kPN1fOEUolO/9DzRDQ1nycnHdE0PTT5JzsnbjVGs0XocB |
    |                            | wfPqughn1wzGqWwtqg7bZjYqOeiviQSVAjcTPvbFE4mqfn5uiF7I4ZQuIhjYEIMd |
    |                            | DaonG/0JurwPZeSSWWK5PNwZdUi7mdafERDaxvn43eDsOUUTDMnKoOTSNGCd+yWB |
    |                            | rxkHJfXP/TxfFPNMDKkYJTjEX3LHUYd1vSHe+Ak97vSBCMIbkY24XGbFjdudR0yu |
    |                            | Zb/qoxy9inzDOK4eQqzn8n+7O9McgjX0nauQlh2s/LsTToqNBLSdHIuHUiONLphX |
    |                            | PVbnWf4BAoGBAP/mzq1PmFkudTBs99+iLQLaYnQVu+sL9vwcQnhjs8wwjOxTsrG/ |
    |                            | uGTGzfrkdYxhtpN1D3JeTDZgscZyvl8my6Tz8+DVJLhbEr5tNEUMOefjffHWQg/U |
    |                            | dzulCCgQ4Mx3JC3/Cxle0TmRUGiSolCKW6yXRmbEaT99ey3N/7yYokg9AoGBAPQ6 |
    |                            | 354q19ZRerRx0by42n9JprKRyoYKbpIadCsjNamNVX9mBIPVj+VgvohsOzVBOsY6 |
    |                            | cYDdVCLebwWWdnlxWviky8X1VHLQAZbynB2YUFFk15UFjAMypE9KtvU2UsGLucOs |
    |                            | 5Ujx46oTsdKqJGKkCABVIMlqtbsOXvS8OHrjxQ1RAoGABJ+G3Fqzxeiw9U8Cq2ei |
    |                            | qIqJfM9ntbdhnuxjxwkGFopKAXsBn3R3QFrXHdFCzmZ1hfR3cvmBJvpYO92W0uFA |
    |                            | jJpbrZQsNahvjkEq0JSH90iE3fmg9+g+vzUcEJ09cnQ0kyAocyzjWsblTP5ZMFtP |
    |                            | jK6u9uxVenAp6YnvNNkNFYECgYAigDaat16qLfRxjSqdyFdFZ/gefa3oZYzdItOK |
    |                            | TH0GKKsNRjIZFZAwTQxdZTyv9zkAS71BAQMjsdxpI6o02aiKO21114RIe83drwQS |
    |                            | wjOGbAJwUMpIoVzIvrs9xKDIKp7hX4k8Vr9chU+3fMWLEbT3pw7spSBq/kq3s+ce |
    |                            | pRJvIQKBgFEVxC98gDAIQn2Tmsoqu5BMleGqnN2U1RH9DCZ1q8+sK6M8LBzyhS5V |
    |                            | 5ydPyNnPYsBCt0luvTEyLqPjdCbUdff23/wl3ItD9oCcEdpcb4OWHU+phwf9wO36 |
    |                            | PY4z4aBQehzVv96VnFtvRFrSrBE6C+/gFTCASvwiDsBvvcGm4r3H             |
    |                            | -----END RSA PRIVATE KEY-----                                    |
    | MCollective User           | mcollective                                                      |
    | MCollective Password       | 5agqqDiRInHpkulFta5C3w                                           |
    | MongoDB Admin User         | admin                                                            |
    | MongoDB Admin Password     | z6sys4iOzddWMe0GXesmQ                                            |
    | MongoDB Broker User        | openshift                                                        |
    | MongoDB Broker Password    | 7JmWlau3VzY3eDlotxLvA                                            |
    +----------------------------+------------------------------------------------------------------+

    Node Districts
    +----------+-----------+-------------------------+
    | District | Gear Size | Nodes                   |
    +----------+-----------+-------------------------+
    | Default  | small     | node1.hosts.userX.onopenshift.com |
    +----------+-----------+-------------------------+

    Role Assignments
    +------------+--------------------------+
    | Broker     | broker.hosts.userX.onopenshift.com |
    | NameServer | broker.hosts.userX.onopenshift.com |
    | Node       | node1.hosts.userX.onopenshift.com  |
    +------------+--------------------------+

    Host Information
    +--------------------------+------------+
    | Hostname                 | Roles      |
    +--------------------------+------------+
    | broker.hosts.userX.onopenshift.com | Broker     |
    |                          | NameServer |
    | node1.hosts.userX.onopenshift.com  | Node       |
    +--------------------------+------------+

    Choose an action:
    1. Change the deployment configuration
    2. View the full host configuration details
    3. Proceed with deployment
    Type a selection and press <return>:

If everything looks correct, select *3* to proceed with the deployment.

oo-install also gives the user the ability to specify additional Red Hat Subscription information.  This has been preconfigured for you in this class.

    Do you want to make any changes to the subscription info in the
    configuration file? (y/n/q/?)

Enter in *n* and press the enter key.

    Do you want to set any temporary subscription settings for this
    installation only? (y/n/q/?)

Enter in *n* and press the enter key.


OpenShift Enterprise 2.2 will now be installed on your system.


-----
## Lab4
**Server used:**

* broker host

**Tools used:**

* *cat*
* *ping*
* *oo-diagnositcs*
* *oo-mco* 
* *mongo*
* *shutdown*

##**Rebooting the hosts**

Congratulations! You have just installed OpenShift Enterprise 2.2.  However, before proceeding any further in the lab manual, we need to verify that the installation was successful.  There are a couple of utilities that we can use to help with this task.  

##**Verifying the installation**

###**Verifying DNS**
Now that our broker and node hosts have been restarted, we can verify that some of the core services have started upon system boot.  The first one to test is the named service, provided by *BIND*.  In order to test that *BIND* was started successfully, enter in the following command:

	$ sudo service named status

You should see information similar to the following:

	version: 9.8.2rc1-RedHat-9.8.2-0.17.rc1.el6_4.6
	CPUs found: 2
	worker threads: 2
	number of zones: 8
	debug level: 0
	xfers running: 0
	xfers deferred: 0
	soa queries in progress: 0
	query logging is OFF
	recursive clients: 0/0/1000
	tcp clients: 0/100
	server is up and running
	named (pid  1106) is running...

If *BIND* is up and running, we can be assured that there are no syntax errors in our zone file.

The next aspect of DNS that we can verify is the actual database for our DNS records.  There should be two database files that contain the domain information for our hosts.  Let's verify that the DNS information for our *hosts.userX.onopenshift.com* has been set up correctly with the following command:

	$ sudo cat /var/named/dynamic/hosts.userX.onopenshift.com.db

The output should look similar to the following.

**Note:** The IP addresses for your hosts will be different from the information in the following sample.

	$ORIGIN .
	$TTL 1	; 1 seconds (for testing only)
	hosts.user1.onopenshift.com		IN SOA	broker.hosts.example.com. hostmaster.hosts.example.com. (
					2011112904 ; serial
					60         ; refresh (1 minute)
					15         ; retry (15 seconds)
					1800       ; expire (30 minutes)
					10         ; minimum (10 seconds)
					)
				NS	broker.hosts.user1.onopenshift.com.
				MX	10 mail.hosts.user1.onopenshift.com.
	$ORIGIN hosts.user1.onopenshift.com.
	broker			A	54.187.248.254
	node1			A	54.187.249.104

Verify that you have entries for both the broker and the node host listed in the output of the *cat* command.

###**Verifying DNS resolution**

One of the most common problems that students encounter is improper host name resolution for OpenShift Enterprise.  If this error occurs, the broker will not be able to contact the node hosts and vice versa.  Both the broker and node host should be using your *broker.hosts.userX.onopenshift.com* host for DNS resolution.  To verify this, view the */etc/resolv.conf* file on both the broker and node host to verify it is pointed to the correct *BIND* server.

	$ cat /etc/resolv.conf

If everything with DNS is set up correctly, you should be able to ping *node1.hosts.userX.onopenshift.com* from the broker and receive a response as shown below:

	$ ping node1.hosts.user1.onopenshift.com
	
	PING node1.hosts.user1.onopenshift.com (54.187.249.104) 56(84) bytes of data.
	64 bytes from node1.osop-local (54.187.249.104): icmp_seq=1 ttl=64 time=0.502 ms

###**Verifying MCollective**	

To verify that MCollective is able to communicate between the broker and the node hosts, use the *oo-mco ping* command.

**Note:** Execute the following on the broker host.

	$ sudo oo-mco ping

If MCollective is working correctly, you should see the following output (the time values will vary):

	node1.hosts.user1.onopenshift.com                  time=114.73 ms
	
	
	---- ping statistics ----
	1 replies max: 114.73 min: 114.73 avg: 114.73


###**Using the *oo-diagnostics* utility**	

OpenShift Enterprise ships with a diagnostics utility that can check the health and state of your installation.  The utility may take a few minutes to run as it inspects your hosts.  In order to run this tool, enter the following command:

**Note:** Execute the following on the broker host

	$ sudo oo-diagnostics -v

You may see an error regarding the verification of the security certificate because we did not acquire properly signed certificates for the hosts you are installing and configuring in this training session.  You can ignore this error for this training session.

**Lab 4 Complete!**

-----
## Lab 5 
skipped

-----
## Lab 6: Adding cartridges**

**Server used:**

* node host
* broker host

**Tools used:**

* *oo-admin-broker-cache*
* *oo-admin-console-cache*
* *oo-admin-ctl-cartridge*
* *service*
* *sudo*
* *yum*

By default, OpenShift Enterprise caches certain values for faster retrieval. Clearing this cache allows the retrieval of updated settings.

For example, the first time MCollective retrieves the list of cartridges available on your nodes, the list is cached so that subsequent requests for this information are processed more quickly. If you install a new cartridge, it is unavailable to users until the cache is cleared and MCollective retrieves a new list of cartridges.

This lab will focus on installing cartridges to allow OpenShift Enterprise to create JBoss gears.

### **Listing available cartridges for your subscription**

For a complete list of all cartridges that you are entitled to install, you can perform a search using the *yum* command that will output all OpenShift Enterprise cartridges.

**Note:  Run the following command on the node host.**

	$ sudo yum search origin-cartridge

During this lab, you should see the following cartridges available to install:

	openshift-origin-cartridge-cron.noarch : Embedded cron support for OpenShift
	openshift-origin-cartridge-diy.noarch : DIY cartridge
	openshift-origin-cartridge-haproxy.noarch : Provides HA Proxy
	openshift-origin-cartridge-jbosseap.noarch : Provides JBossEAP6.0 support
	openshift-origin-cartridge-jbossews.noarch : Provides JBossEWS2.0 support
	openshift-origin-cartridge-jenkins.noarch : Provides jenkins-1.x support
	openshift-origin-cartridge-jenkins-client.noarch : Embedded jenkins client support for OpenShift
	openshift-origin-cartridge-mysql.noarch : Provides embedded mysql support
	openshift-origin-cartridge-nodejs.noarch : Provides Node.js support
	openshift-origin-cartridge-perl.noarch : Perl cartridge
	openshift-origin-cartridge-php.noarch : Php cartridge
	openshift-origin-cartridge-postgresql.noarch : Provides embedded PostgreSQL support
	openshift-origin-cartridge-python.noarch : Python cartridge
	openshift-origin-cartridge-ruby.noarch : Ruby cartridge

### **Installing JBoss support**

In order to enable consumers of the PaaS to create JBoss gears, we will need to install all of the necessary cartridges for the application server and supporting build systems.  This step is slightly complicated by the fact that the JBoss cartridge depends on packages that are shipped in specific channels that must be enabled.  Fortunately, the *openshift.sh* script can perform the steps necessary to enable these channels and then install the cartridges you specify.

Perform the following command to install the required cartridges:

**Note:  Execute the following on the node host.**

	$ wget https://raw.githubusercontent.com/openshift/openshift-extras/enterprise-2.2/enterprise/install-scripts/generic/openshift.sh

	$ sudo sh openshift.sh actions=configure_repos,install_cartridges cartridges=jbosseap,jbossews,jenkins install_method=rhsm

The above command will allow users to create JBoss EAP and JBoss EWS gears.  We also installed support for the Jenkins continuous integration environment and do-it-yourself cartridge, which we will cover in later labs.

**Note:** Depending on your connection and speed of your node host, this installation make take several minutes.

### **Restart MCollective Server on node host**

After installing new cartridges, you need to restart the MCollective.  To do this, run the following command:

	$ sudo service ruby193-mcollective restart

### **Importing the updated cartridge list into the broker**

At this point, you will notice that if you try to create a JBoss based application via the management console, the application type is not available.  This is because the broker host creates a cache of available cartridges to increase performance.  After adding a new cartridge, you need to instruct the broker to reload the list of cartridges that are available on the node host.

In order for the broker to import the updated list of cartridges from the node, enter the following command:

**Note:** Execute the following on the broker host.

	$ sudo oo-admin-ctl-cartridge -c import-node --activate --obsolete

You should see output similar to the following:

	Updating 1 cartridges ...
	54606c883a0fb2073e000001 # A jbosseap-6 (active)

### **Clearing the broker application cache**

In addition to loading the updated list of cartridges into the broker, we need to flush caches that may contain stale data.

Caching is performed in multiple components:

* Each node maintains a database of facts about itself, including a list of installed cartridges.
* Using MCollective, a broker queries a node's facts database for the list of cartridges and caches the node's response.
* Using the broker's REST API, the management console queries the broker for the list of cartridges and caches the broker's response.

The cartridge lists are updated automatically at the following intervals:

* The node's database is refreshed every minute.
* The broker's cache is refreshed every six hours.
* The console's cache is refreshed every five minutes.

In order to clear the cache for both the broker and management console at the same time, enter in the following command:

**Note:** Execute the following on the broker host.

	$ sudo oo-admin-broker-cache --clear
	$ sudo oo-admin-console-cache --clear

You should see the following confirmation messages:

	Clearing broker cache.
	Clearing console cache.

If you reload the management console in your web browser, you should now see the updated list of cartridges available.

### **Testing new cartridges**

Given the steps in Lab 5 of this training, you should be able to access the management console from a web browser using your local machine.  Open up your preferred browser and enter the following URL:

	http://broker.hosts.userX.onopenshift.com

Remember to replace X with your user number.

You will be prompted to authenticate and then be presented with an application creation screen.  After the cache has been cleared, and assuming you have added the new cartridges correctly, you should see a screen similar to the following:

**Note:** The demo user's password was displayed in the output for *openshift.sh* that you copied to a local text file.

```
DNS Settings
  * Installer will deploy DNS
  * Application Domain: user30.onopenshift.com
  * Register OpenShift hosts with DNS? Yes
  * Component Domain: hosts.user30.onopenshift.com

Global Gear Settings
+-------------------------+-------+
| Valid Gear Sizes        | small |
| User Default Gear Sizes | small |
| Default Gear Size       | small |
+-------------------------+-------+

Account Settings
+----------------------------+------------------------------------------------------------------+
| OpenShift Console User     | demo                                                             |
| OpenShift Console Password | 1HT7vMtc5LJLsDRfy5lGsQ                                           |
| Broker Session Secret      | oU8pS5YaS9qNqlXhIY2YA                                            |
| Console Session Secret     | fSO1ZleWrzG1d8UjeBmKQ                                            |
| Broker Auth Salt           | 1puvkU8FXN2L8bhaOuVbvg                                           |
| Broker Auth Private Key    | -----BEGIN RSA PRIVATE KEY-----                                  |
|                            | MIIEpAIBAAKCAQEAvxXqqFOJAxnkidnUPQlmtXbSp14bN4CUvtEhV/GaH2xRLIDp |
|                            | jORdEV13uWCFtPTKes40vp87RZDO1Lndpo8dYUpkyErWK4W0EkiZxAPwEo5pDdE+ |
|                            | tfPwcf4K8shBfk18FrzKws0MWfz2jX3z3sAosuFSzkIDdQU/2n7rWvC39pO7t1se |
|                            | dPYCYCYgULsl2KGjHP9bcXLGnT1OrVGrVVCIi8YEx9SFiC5WyO+dwcXpGHJKpcmu |
|                            | HSiPdIthn/nNXnAsHT6HsL2N/guGrKFH0vsqdJlsstkbh/UWC561CUjK8Tn6MqGy |
|                            | DQND3jrI2FeHDpcA2XCjzlDcZw4KdTMKNYuWHQIDAQABAoIBAH6KfQNLjohHNVk0 |
|                            | r6BcAXBaZ9X+M/flZpuW0oXysSXuDTNzizaKZDeDti1FBkZ3dT8uHy+9Mvs2kkG9 |
|                            | dFNAoywyn9sj9ACOYllZSrrMAMfJFzjXQLgt+yUCHy33/6csmOhVzdCDCZLuOjgp |
|                            | GL6CcnFDVhrRDIkKGOcQ9bsbfjgDJlttwBaqKK6AS4vkWcfT1KClLmyK/Mdr8As5 |
|                            | KGcBzQlJx0K8FNoZd7qcdCxKGT60rhfy7ddL98XZQ2qggYUO0CsqQrTJvDQ37B2G |
|                            | 5XrBsZs1y8BVCljUIM48owpWpwo/zJkb34/RET5vhr1IFvz5HHsy98c3ArP056qy |
|                            | U7oxieECgYEA+UjYxT8LUCrDsGzv4Uhn8nuZ9UWedOg7SNz+VCFjv9wM8eLgIszZ |
|                            | +dLjO5Sv9LSco1/H2sWht2NwKk2QTCyt5qb7Bu608mTbz9XGFv7kOLTU0b8tWT+t |
|                            | Ypu9TuErDJgY65Q6E4MCh8psEsPP83FXROAZPlpyLERr0wNGdhYagtMCgYEAxDu1 |
|                            | q1cr9lhwrRG1nzBN6GGiFu5JYxsGspPSflJNNtq4FGC2JVmES9rLsdOgL4NSZIVg |
|                            | N2qgqW71gTJlF3VU20Zya9vd8XJ3lLyZ9TgWfnAFr1k3hEnkvG+o2/JDfI+7y+Nk |
|                            | aA+veBS/J9MJyvv04lAsG0I7+CDLrJ4UyvoVjU8CgYAQb5YjQynaykcGvdf/EYgQ |
|                            | +8dF3aY57QnjnvaB04XBI6AS3rOKd9kzWI0043PKfZIKT4lcykUEU2EU2PJXo2Z/ |
|                            | 26iXZ2u0w6Oei2i5IWsotfuGLMWvqbwj0ULlDYGKHgkelzJREQU8sML5ZcGzOljX |
|                            | qLLhYpM+ifBWBFRD+ucakwKBgQClOx2yQzlaOYfOwr2qZ9MB28vPAR+8GlKeZUf1 |
|                            | Y7lueeZMCk70zhZOhNHFT0tvFmV3DLNClj7ny+1etx9WDE7CP+Qym7SbDGZSUChW |
|                            | yb5vAkZXKolLk6jNXjvRz4Exzhk0CalO0f5O3zFCCDoTt+mv8g/hd/jk6kB1fbpG |
|                            | WyNwkwKBgQDpeTjpo5i/801GY80Pm1ej1nJ7vlQszoID/p6ohB/1ZsOmcKBENUa4 |
|                            | s9zW903MRxmzsNQFqw5fIxN2hVxV34cWw50nwdCLw2oLSz0uW28SbUylKQUPcrST |
|                            | yO2oQfB3h99lojugQahwYlvHNqPopqY3j7TomLAZ2Azt2Je1gHXyqQ==         |
|                            | -----END RSA PRIVATE KEY-----                                    |
| MCollective User           | mcollective                                                      |
| MCollective Password       | 2NFwZkznYAyOIke939dw                                             |
| MongoDB Admin User         | admin                                                            |
| MongoDB Admin Password     | nXkVZSUvNXGAnoiPucTw8g                                           |
| MongoDB Broker User        | openshift                                                        |
| MongoDB Broker Password    | xZQXeIlEZVcTzSksD0V9Tw                                           |
+----------------------------+------------------------------------------------------------------+

Node Districts
+----------+-----------+-----------------------------------------------------------------------+
| District | Gear Size | Nodes                                                                 |
+----------+-----------+-----------------------------------------------------------------------+
| Default  | small     | node1.hosts.user30.onopenshift.com,node2.hosts.user30.onopenshift.com |
+----------+-----------+-----------------------------------------------------------------------+

Role Assignments
+------------+-------------------------------------+
| Broker     | broker.hosts.user30.onopenshift.com |
| NameServer | broker.hosts.user30.onopenshift.com |
| Nodes      | node1.hosts.user30.onopenshift.com  |
|            | node2.hosts.user30.onopenshift.com  |
+------------+-------------------------------------+

Host Information
+-------------------------------------+------------+
| Hostname                            | Roles      |
+-------------------------------------+------------+
| broker.hosts.user30.onopenshift.com | Broker     |
|                                     | NameServer |
| node1.hosts.user30.onopenshift.com  | Node       |
| node2.hosts.user30.onopenshift.com  | Node       |
+-------------------------------------+------------+

```
![](http://training-onpaas.rhcloud.com/ose2/addCartridgeWebConsole.png)

If you do not see the new cartridges appear when you reload the management console, check that the new cartridges are available by viewing the contents of the */usr/libexec/openshift/cartridges* directory:

	$ cd /usr/libexec/openshift/cartridges
	$ ls

**Lab 6 Complete!**


-----
## **Lab 7: Managing resources**

**Server used:**

* node host
* broker host

**Tools used:**

* text editor
* *oo-admin-ctl-user*

### **Setting default gear quotas and sizes**

A user's default gear size and quota are specified in the */etc/openshift/broker.conf* configuration file located on the broker host.

The *VALID_GEAR_SIZES* setting is not applied to users but specifies the gear sizes that the current OpenShift Enterprise PaaS installation supports.

The *DEFAULT_MAX_GEARS* settings specifies the number of gears to assign to all users upon user creation.  This is the total number of gears that a user can create by default.

The *DEFAULT_GEAR_SIZE* setting is the size of gear that a newly created user has access to.

The *DEFAULT_MAX_DOMAINS* setting specifies the number of domains that one user can create.

Take a look at the  */etc/openshift/broker.conf* configuration file to determine the current settings for your installation:

**Note:** Execute the following on the broker host.

	$ sudo cat /etc/openshift/broker.conf

By default, OpenShift Enterprise sets the default gear size to small and the number of gears a user can create to 100 and the maximum number of domains to 10.

When changing the */etc/openshift/broker.conf* configuration file, keep in mind that the existing settings are cached until you restart the *openshift-broker* service.

### **Setting the number of gears a specific user can create**

There are often times when you want to increase or decrease the number of gears a particular user can consume without modifying the setting for all existing users.  OpenShift Enterprise provides a command that will allow the administrator to configure settings for an individual user.  To see all of the available options that can be performed on a specific user, enter the following command:

	$ sudo oo-admin-ctl-user

To see how many gears our *demo* user has consumed as well as how many gears the *demo* user has access to create, you can provide the following switches to the *oo-admin-ctl-user* command:

	$ sudo oo-admin-ctl-user -l demo

Given the current state of our configuration for this training class, you should see the following output:

	User demo:
	                            plan:
	                   plan quantity: 1
	            plan expiration date:
	                consumed domains: 0
	                     max domains: 10
	                  consumed gears: 0
	                       max gears: 100
	    max tracked storage per gear: 0
	  max untracked storage per gear: 0
	                       max teams: 0
	viewing all global teams allowed: false
	                      gear sizes: small
	            sub accounts allowed: false
	private SSL certificates allowed: false
	              inherit gear sizes: false
	                      HA allowed: false

In order to change the number of gears that our *demo* user has permission to create, you can pass the `--setmaxgears` switch to the command.  For instance, if we only want to allow the *demo* user to be able to create 25 gears, we would use the following command:

	$ sudo oo-admin-ctl-user -l demo --setmaxgears 25

After entering the above command, you should see the following output:

	Setting max_gears to 25... Done.

	User demo:
	                            plan:
	                   plan quantity: 1
	            plan expiration date:
	                consumed domains: 0
	                     max domains: 10
	                  consumed gears: 0
	                       max gears: 25
	    max tracked storage per gear: 0
	  max untracked storage per gear: 0
	                       max teams: 0
	viewing all global teams allowed: false
	                      gear sizes: small
	            sub accounts allowed: false
	private SSL certificates allowed: false
	              inherit gear sizes: false
	                      HA allowed: false


### **Creating new gear types**

In order to add new gear types to your OpenShift Enterprise 2.1 installation, you will need to do two things:

* Create and define the new gear profile on the node host.
* Update the list of valid gear sizes on the broker host.

Each node can only have one gear size associated with it.  That being said, in a multi-node setup you would edit the */etc/openshift/broker.conf* file on each broker host to specify the gear name and then modify the */etc/openshift/resource_limits.conf* file on each node that you would like to that you would like to host that gear size to match the name and sizing you would like.

### **Setting the type of gears a specific user can create**

**Note:** The below information is for informational purposes only.  During this lab, we are only working with one node host and can therefore not add additional gear sizes.

In a production environment, a customer will typically have different gear sizes that are available for developers to consume.  For this lab, we will only create small gears.  However, to add the ability to create medium size gears for the *demo* user, you could pass the `--addgearsize` switch to the *oo-admin-ctl-user* command.

	$ sudo oo-admin-ctl-user -l demo --addgearsize medium

After entering the above command, you would see the following output:

	Adding gear size medium for user demo... Done.
	User demo:
	  consumed gears: 0
	  max gears: 25
	  gear sizes: small, medium


**Note**: That above command will not work in our environment since we only have one gear size.

In order to remove the ability for a user to create a specific gear size, you can use the `--removegearsize` switch:

	$ sudo oo-admin-ctl-user -l demo --removegearsize medium

**Lab 7 Complete!**



-----
## **Lab 8: Managing districts**

- Districts は Gearのプロファイル
- Node単位でdistrictsを適用可能
- Production では　small, midium, large 毎にdistrictsを設けて管理すると思う。


**Server used:**

* node host
* broker host

**Tools used:**

* text editor
* *oo-admin-ctl-district*

Districts define a set of node hosts within which gears can be easily moved to load-balance the resource usage of those nodes. As of OpenShift Enterprise 2.1, districts are required for any OpenShift Enterprise installation.

Districts allow a gear to maintain the same UUID (and related IP addresses, MCS levels, and ports) across any node within the district, so that applications continue to function normally when moved between nodes in the same district. All nodes within a district have the same profile, meaning that all the gears on those nodes are the same size (for example, small or medium). There is a hard limit of 6000 gears per district.

This means, for example, that developers who hard-code environment settings into their applications instead of using environment variables will not experience problems due to gear migrations between nodes. The application continues to function normally because exactly the same environment is reserved for the gear on every node in the district. This saves developers and administrators time and effort.

### **Enabling districts**

To use districts, the broker's MCollective plug-in must be configured to enable districts.  Edit the */etc/openshift/plugins.d/openshift-origin-msg-broker-mcollective.conf* configuration file and confirm the following parameters are set:

**Note: Confirm the following on the broker host.**

	DISTRICTS_ENABLED=true
	NODE_PROFILE_ENABLED=true

While you are viewing this file, you may notice the *DISTRICTS_REQUIRE_FOR_APP_CREATE=true* setting.  Enabling this option prevents users from creating a new application if there are no districts defined or if all districts are at maximum capacity.

OpenShift Enterprise provides a command-line tool to display information about a district.  Simply enter the following command to view the JSON information that is stored in the MongoDB database:

	$ sudo oo-admin-ctl-district

Once you enter the above command, you should a more human readable version of the document:

	{"_id"=>"5379f15e3a0fb20d01000001",
	 "active_servers_size"=>1,
	 "available_capacity"=>6000,
	 "available_uids"=>"<6000 uids hidden>",
	 "created_at"=>2014-05-19 11:56:14 UTC,
	 "gear_size"=>"small",
	 "max_capacity"=>6000,
	 "max_uid"=>6999,
	 "name"=>"Default",
	 "servers"=>
	  [{"_id"=>"5379f2d63a0fb208d8000001",
	    "active"=>true,
	    "name"=>"node1.hosts.user1.onopenshift.com",
	    "unresponsive"=>false}],
	 "updated_at"=>2014-05-19 11:56:14 UTC,
	 "uuid"=>"5379f15e3a0fb20d01000001"}


**Note:**If your node is not listed in the *servers* section, you can run the following command to add it:

	$ sudo oo-admin-ctl-district -p small -n Default -c add-node --available


### **Managing district capacity**

Districts and node hosts have a configured capacity for the number of gears allowed. For a node host, the default value configured in */etc/openshift/resource_limits.conf* is the following:

* Maximum number of active gears per node : 100

Use the *max_active_gears* parameter in the */etc/openshift/resource_limits.conf* file to specify the maximum number of active gears allowed per node. By default, this value is set to 100, but most administrators will need to modify this value over time. Stopped or idled gears do not count toward this limit; a node can have any number of inactive gears, constrained only by storage. However, starting inactive gears after the *max_active_gears* limit has been reached may exceed the limit, which cannot be prevented or corrected. Reaching the limit exempts the node from future gear placement by the broker.

##**Viewing district capacity statistics**

In order view usage information for your installation, you can use the *oo-stats* command.  Let's view the current state of our district by entering in the following command:

	$ sudo oo-stats

You should see information similar to the following:

	------------------------
	Profile 'small' summary:
	------------------------
	            District count : 1
	         District capacity : 6,000
	       Dist avail capacity : 6,000
	           Dist avail uids : 6,000
	     Lowest dist usage pct : 0.0
	    Highest dist usage pct : 0.0
	        Avg dist usage pct : 0.0
	               Nodes count : 1
	              Nodes active : 1
	         Gears total count : 0
	        Gears active count : 0
	    Available active gears : 100
	 Effective available gears : 100
	
	Districts:
	          Name Nodes DistAvailCap GearsActv EffAvailGears LoActvUsgPct AvgActvUsgPct
	-------------- ----- ------------ --------- ------------- ------------ -------------
	Default     1        6,000         0           100          0.0           0.0
	
	
	------------------------
	Summary for all systems:
	------------------------
	 Districts : 1
	     Nodes : 1
	  Profiles : 1

	 
**Lab 8 Complete!**



-----
## Lab 9 Skipped



-----
## **Lab 10: Zones and Regions**

- MongoDBに




**Server used:**

* node host
* broker host

**Tools used:**

* text editor

Regions and zones provide a way for brokers to manage several distinct geographies by controlling application deployments across a selected group of nodes. A group of nodes can form a zone, and several zones can belong to a single region. These groups can represent physical geographies--such as different countries or data centers--or can be used to provide network-level separation between node environments.

The current implementation of regions requires the use of districts. Nodes in districts can be tagged with a region and zone, while districts themselves can span several regions or a single region. Any single application is restricted to one region at a time, while gears within an application gear group are distributed across available zones in the current region. The broker attempts to distribute new gears evenly across the available zones; if the default gear placement algorithm is not desired, a custom gear-placement plug-in can be implemented.

For example, an administrator could use the regions and zones feature to create a region for a geography they have a datacenters in.  Inside of this region, the administrator could create zones for the location of each specific datacenter.  As an example, the following image depicts two regions with multiple zones across both the United States and EMEA:

<img src="http://training.runcloudrun.com/ose2/zones.png" alt="写真" width="1170" height="612">

### **Creating a Region with a Zone**

To learn how to implement these features, let's create a region with a zone as shown with the following command:

**Note:** Perform these command on the **broker host.**

	$ sudo oo-admin-ctl-region -c create -r emea

You should see the following confirmation displayed on the screen:

	Successfully created region: emea
	
	{"_id"=>"53765c773a0fb2abc9000001",
	 "name"=>"emea",
	 "updated_at"=>2014-05-16 18:44:07 UTC,
	 "created_at"=>2014-05-16 18:44:07 UTC}

Now that we have a region created, we can create and add a zone to the *emea* region:

	$ sudo oo-admin-ctl-region -c add-zone -r emea -z east

You should see the following confirmation displayed on the screen:

	Success!

	{"_id"=>"53765c773a0fb2abc9000001",
	 "created_at"=>2014-05-16 18:44:07 UTC,
	 "name"=>"emea",
	 "updated_at"=>2014-05-16 18:44:07 UTC,
	 "zones"=>
	  [{"_id"=>"53765ca73a0fb2974b000001",
	    "name"=>"east",
	    "updated_at"=>2014-05-16 18:44:55 UTC,
	    "created_at"=>2014-05-16 18:44:55 UTC}]}

We have just created an east zone inside of the *emea* region.  To verify this, you can list all of the regions with the following command:

	$ sudo oo-admin-ctl-region -c list -r emea

You should see the following confirmation displayed on the screen:

	{"_id"=>"53765c773a0fb2abc9000001",
	 "created_at"=>2014-05-16 18:44:07 UTC,
	 "name"=>"emea",
	 "updated_at"=>2014-05-16 18:44:07 UTC,
	 "zones"=>
	  [{"_id"=>"53765ca73a0fb2974b000001",
	    "name"=>"east",
	    "updated_at"=>2014-05-16 18:44:55 UTC,
	    "created_at"=>2014-05-16 18:44:55 UTC}]}


##**Adding a node to a region and a zone**

Now that we have both a region and a zone created, the next step is to allocate nodes to zone that we would like them to reside in.  Since our node has already been added to a district, we simply want to tag it with the region and the zone that we created previously in this lab.  For example, if our district is called *Default*, and our node hostname is *node1.hosts.userX.onopenshift.com*, and we want to add the node to the *emea* region in the *east* zone, we would enter in the following command:

	$ sudo oo-admin-ctl-district -c set-region -n Default -i node1.hosts.userX.onopenshift.com -r emea -z east

Once you enter in the above command, you will see the following information indicating that the addition of the node to the region and zone was a success:

	Success for node 'node1.hosts.user1.onopenshift.com'!
	
	{"_id"=>"53739dc63a0fb2ba34000001",
	 "active_servers_size"=>2,
	 "available_capacity"=>5991,
	 "available_uids"=>"<5991 uids hidden>",
	 "created_at"=>2014-05-14 16:45:58 UTC,
	 "gear_size"=>"small",
	 "max_capacity"=>6000,
	 "max_uid"=>6999,
	 "name"=>"Default",
	 "servers"=>
	  [{"_id"=>"53739dcc3a0fb2ba34000002",
	    "active"=>true,
	    "name"=>"node1.hosts.user1.onopenshift.com",
	    "region_id"=>"53765c773a0fb2abc9000001",
	    "region_name"=>"emea",
	    "unresponsive"=>false,
	    "zone_id"=>"53765ca73a0fb2974b000001",
	    "zone_name"=>"east"},
	   {"_id"=>"5373d76e3a0fb26c02000001",
	    "active"=>true,
	    "name"=>"node2.hosts.user1.onopenshift.com",
	    "unresponsive"=>false}],
	 "updated_at"=>2014-05-14 16:45:58 UTC,
	 "uuid"=>"53739dc63a0fb2ba34000001"}

To add *node2.hosts.userX.onopenshift.com* to the west zone, we would perform the following commands:

	$ sudo oo-admin-ctl-region -c add-zone -r emea -z west
	$ sudo oo-admin-ctl-district -c set-region -n Default -i node2.hosts.userX.onopenshift.com -r emea -z west

Given the above commands, you should see the following confirmation message:

	Success for node 'node2.hosts.user1.onopenshift.com'!
	
	{"_id"=>"53739dc63a0fb2ba34000001",
	 "active_servers_size"=>2,
	 "available_capacity"=>5991,
	 "available_uids"=>"<5991 uids hidden>",
	 "created_at"=>2014-05-14 16:45:58 UTC,
	 "gear_size"=>"small",
	 "max_capacity"=>6000,
	 "max_uid"=>6999,
	 "name"=>"Default",
	 "servers"=>
	  [{"_id"=>"53739dcc3a0fb2ba34000002",
	    "active"=>true,
	    "name"=>"node1.hosts.user1.onopenshift.com",
	    "region_id"=>"53765c773a0fb2abc9000001",
	    "region_name"=>"emea",
	    "unresponsive"=>false,
	    "zone_id"=>"53765ca73a0fb2974b000001",
	    "zone_name"=>"east"},
	   {"_id"=>"5373d76e3a0fb26c02000001",
	    "active"=>true,
	    "name"=>"node2.hosts.user1.onopenshift.com",
	    "region_id"=>"53765c773a0fb2abc9000001",
	    "region_name"=>"emea",
	    "unresponsive"=>false,
	    "zone_id"=>"53765f573a0fb2d22b000001",
	    "zone_name"=>"west"}],
	 "updated_at"=>2014-05-14 16:45:58 UTC,
	 "uuid"=>"53739dc63a0fb2ba34000001"}

##**Additional region and zone commands**

List all available regions with the following command:

	$ sudo oo-admin-ctl-region -c list -r region_name

Remove region and zone tags from a node with the following command:

	$ sudo oo-admin-ctl-district -c unset-region -n district_name -i server_identity

Remove zones from a region with the following command:

	$ sudo oo-admin-ctl-region -c remove-zone -r region_name -z zone_name

Destroy empty regions with the following command:

	$ sudo oo-admin-ctl-region -c destroy -r region_name

##**Requiring new applications to use zones**

In the */etc/openshift/plugins.d/openshift-origin-msg-broker-mcollective.conf* file on the **broker host**, set the *ZONES_REQUIRE_FOR_APP_CREATE* parameter to *true* to require that new applications only use nodes tagged with a zone. When true, gear placement will fail if there are no zones available with the correct gear profile.  Edit the above file and ensure that this configuration item is set to true:

	ZONES_REQUIRE_FOR_APP_CREATE=true

Once the above configuration item has been added, you will need to restart the *openshift-broker* service with the following command on the **broker host**:

	$ sudo service openshift-broker restart

### **Understanding the gear placement algorithm**

The following steps describe the default algorithm for selecting a node on which to place a new gear for an application:

1. Find all the districts.
2. Find the nodes that have the least active_capacity.
3. Filter nodes based on given criteria to ensure gears within scalable applications are spread across multiple nodes.
4. Filter non-districted nodes when districts are required.
5. When regions and zones are present:
	1. Filter nodes without zones when zones are required.
	2. If the application already has gears on a node tagged with a region, exclude nodes that do not belong to the current region.
    3. Verify whether the minimum required number of zones for application gear groups is met.
    4. Filter zones to ensure that gears within the application gear group do not exist solely in a single zone.
    5. Choose zones that are least consumed to evenly distribute gears among zones.
    6. When zone nodes available, exclude nodes without zones.
6. When districted nodes are available, exclude nodes without districts.
7. Among remaining nodes, choose the ones with plenty of available capacity that are in districts with available UIDs.
8. Randomly choose one of the nodes with the lower levels of active_capacity.

Customers are also free to extend or to implement their own gear placement algorithm.  For example, a customer may want to develop an algorithm that will determine a developers physical location and create gears for that developer only within the closest region.

**Lab 10 Complete!**


-----
##**Lab 11: Log Management**

**Server used:**

* node host
* broker host

**Tools used:**

* text editor


### **Default node log file locations**

By default, node components write log messages locally to their configured log file destination. The following table provides the default locations of important log files for node components, summarizes the information they contain, and identifies the configuration setting that changes their default location:

![](http://training.runcloudrun.com/ose2/nodelog.png)

### **Enabling syslog for node components**

You can configure node hosts to send node platform and Apache logs to *syslog* instead of writing to their default log file locations. After enabling *syslog* logging, messages from the various node components are grouped and sent to the configured *syslog* service. This method of aggregating log messages gives you the option to further configure your *syslog* service to send logs directly to a remote logging server or monitoring solution without the messages being written locally to disk.

Configure Apache to send log messages to *syslog* by adding the following option in the */etc/sysconfig/httpd* file on the node host:

	OPTIONS="-DOpenShiftFrontendSyslogEnabled"

After adding the option information, restart the *httpd* service with the following command:

	$ sudo service httpd restart

To enable *syslog* for node platform, we need to perform a few more steps.  Configure the node platform to send log messages to *syslog* by editing the */etc/openshift/node.conf* file. Add the following line and any or all of the described optional settings that follow:

	PLATFORM_LOG_CLASS=SyslogLogger

Restart the *ruby193-mcollective* service for the node platform changes to take effect:

	$ sudo service ruby193-mcollective restart

When *syslog* support is enabled for the node platform, the *local0* *syslog* facility is used to log messages. By default, the */etc/rsyslog.conf* file does not log platform debug messages. If you are using *rsyslog* as your *syslog* implementation, add the following line to the */etc/rsyslog.conf* file to enable platform debug message logging. If desired, replace */var/log/messages* with your chosen logging destination:

	local0.*;*.info;mail.none;authpriv.none;cron.none /var/log/messages

Then restart the *rsyslog* service:

	$ sudo service rsyslog restart

### **Enabling application and gear context in Apache logs**

Further context, such as application names and gear UUIDs, can be included in log messages from node components, which adds visibility by associating entries with specific applications or gears. This can also improve the ability to correlate log entries using reference IDs from the broker.
竅
Configure Apache to include application names and gear UUIDs in its log messages by editing the */etc/sysconfig/httpd* file and adding the following line:

	OPTIONS="-DOpenShiftAnnotateFrontendAccessLog"

**NOTE:** All Apache options must be on the same line.  If you added the option previously in this lab, you will need to format the line in the following fashion:

	OPTIONS="-Option1 -Option2"

Restart the *httpd* service for the Apache changes to take effect for new applications:

	$ sudo service httpd restart

Update the gear front-end Apache configuration files for the Apache changes to take effect for existing applications. Red Hat recommends backing up your application prior to a rebuild to prevent loss of data:

	$ sudo oo-frontend-plugin-modify --save
	$ sudo oo-frontend-plugin-modify --rebuild

### **Enabling application and gear context in node platform logs**

Configure the node platform to include application and gear context in its log messages by editing the */etc/openshift/node.conf* file and adding the following line:

	PLATFORM_LOG_CONTEXT_ENABLED=1

Add the following line to specify which attributes are included. Set any or all of the following options in a comma-delimited list:

	PLATFORM_LOG_CONTEXT_ATTRS=request_id,container_uuid,app_uuid

This produces key-value pairs for the specified attributes. If no context attribute configuration is present, all context attributes are printed.

Restart the *ruby193-mcollective* service for the node platform changes to take effect:

	$ sudo service ruby193-mcollective restart


**Lab 11 Complete!**

-----
## **Lab 12: Introducing Watchman**

**Server used:**

* localhost
* broker host
* node host

**Tools used:**

* *rhc*

### **Overview of Watchman**

Watchman is a daemon Red Hat has been using on our public PaaS at *www.openshift.com* for a while. This daemon has the built in intelligence to protect you from the most common issues we have found while running a PaaS for a massive number of users and a very high application count. Companies should not have to hire more people just because they have more applications; Watchman will help fill the gap. Watchman has a fully extensible plug-in interface, but does come out-of-the-box with the following logic that you can choose to leverage or turn off:

* It will search the *cgroup* event flow through *syslog* to determine when a gear is destroyed. If the pattern does not match a clean gear removal, we will restart the gear.
* It will watch over the application server logs for "out of memory" type messages and will restart the gear if needed.
* Watchman compares the state the user believes the gear to be in to the actual status of the gear and fixes the dependency.
* It searches out processes and makes sure they belong to the correct *cgroup*. It kills processes associated to a stopped gear that have been abandoned or restarts a gear that has no running processes at all.
* Watchman monitors the rate of usage on CPU cycles and will throttle a gear's CPU consumption if the rate of change is too aggressive.

### **Enable Watchman**

The *watchman* service runs on the node host.  To enable it, all you need to do is to turn the daemon using the *chkconfig* tool.  SSH to your node host(s) where you want to enable *watchman* and enter in the following command:

	$ sudo chkconfig openshift-watchman on

### **Configure Watchman Behavior**

The *watchman* service relies on variables that are configured in the */etc/sysconfig/watchman* file to specify the behavior of the daemon.  The following variables are available:

* *RETRY_DELAY*
This variable sets the number of seconds to wait before attempting to restart the gear.
* *RETRY_PERIOD*
This variable sets the number of seconds to wait before resetting the *GEAR_RETRIES* entry.
* *GEAR_RETRIES*
This variable sets the number of gear restarts attempted before a *RETRY_PERIOD*.
* *STATE_CHANGE_DELAY*
This variable sets the number of seconds the gear remains broken before *watchman* attempts to fix the issue.

Open the */etc/sysconfig/watchman* file on your node host(s) and enter in the following information:

	# Number of restarts to attempt before waiting RETRY_PERIOD
	GEAR_RETRIES=3
	
	# Number of seconds to wait before accepting another gear restart
	RETRY_DELAY=300
	
	# Number of seconds to wait before resetting retries
	RETRY_PERIOD=28800
	
	# Number of seconds a gear must remain inconsistent with its state before
	#   Watchman attempts to reset state
	STATE_CHANGE_DELAY=900
	
	# Wait at least this number of seconds since last check before checking gear state on the Node.
	# Use this to reduce Watchman's GearStatePlugin's impact on the system.
	STATE_CHECK_PERIOD=0

Once you have added the above contents on the node(s), restart the *watchman* service with the following command:

	$ sudo service openshift-watchman restart

You should see the following confirmation:

	Stopping Watchman
	Starting Watchman


### **Configure Watchman Plugins**

*Watchman* plug-ins are used to expand the events and conditions on which the *watchman* service takes action. These plug-ins are located in the */etc/openshift/watchman/plugins.d* directory, and are outlined below:

* *SyslogPlugin*
This plug-in searches the */var/log/messages* file for any messages logged by *cgroups* when a gear is destroyed. The gear is restarted if needed.
* *JBossPlugin*
This plug-in searches JBoss cartridge *server.log* files for out-of-memory exceptions. The gear is restarted if needed.
* *GearStatePlugin*
This plug-in compares the last state change commanded by the user against the current status of the gear in order to find the best use for resources. For example, this plug-in kills any processes running on a stopped gear, and restarts a started gear if it has no running processes.
* *ThrottlerPlugin*
This plug-in uses *cgroups* to monitor CPU usage and restricts usage if needed.
* *MetricsPlugin*
This plug-in gathers and publishes gear-level metrics such as *cgroups* data for all gears on a node host at a configurable interval.

### **Enabling Watchman Metrics**

The metrics configuration is located in the */etc/openshift/node.conf* file in addition to the plug-in being located in the */etc/openshift/watchman/plugins.d* directory.  In order to enable metrics gathering, open up the *node.conf* file and uncomment the following lines:

**Note:** You should perform this on each node host where you want to collect and publish metrics

	$ sudo vi /etc/openshift/node.conf
	
	WATCHMAN_METRICS_ENABLED=true
	WATCHMAN_METRICS_INTERVAL=30
	METRICS_METADATA="appName:OPENSHIFT_APP_NAME,gearUuid:OPENSHIFT_GEAR_UUID"
	CGROUPS_METRICS_KEYS="cpu.stat,cpuacct.stat,memory.usage_in_bytes"
	MAX_CGROUPS_METRICS_MESSAGE_LENGTH=1024
	METRICS_PER_GEAR_TIMEOUT=3
	METRICS_PER_SCRIPT_TIMEOUT=1
	METRICS_MAX_LINE_LENGTH=2000

Once you have made the changes, restart the daemon on each node host:

	$ sudo service openshift-watchman restart

### **Viewing the published information**

To view the information that *watchman* is collecting, you can look at the *syslog* log data by viewing the */var/log/messages* file:

	# tail -n 50 /var/log/messages

You should see entries similar to the following:

	May 16 12:35:23 node2 watchman[27636]: type=metric appName=test4 gearUuid=5373d79c3a0fb200fa000015 quota.blocks.used=920 quota.blocks.limit=1048576 quota.files.used=211 quota.files.limit=80000
	May 16 12:35:23 node2 watchman[27636]: type=metric appName=binarydeploy gearUuid=537430f53a0fb200fa000065 quota.blocks.used=14560 quota.blocks.limit=1048576 quota.files.used=401 quota.files.limit=80000

	
**Lab 12 Complete!**






