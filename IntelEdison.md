Intel Edisonセットアップ
=====


### Hardware
- Intel Edison + Minibreak board
- USB2.0ケーブル(A-microBタイプ)50cm
- 

### 事前準備

#### 各種ドライバをインストールする

**Mac**

- [FTDI USB Driver(Mac)](http://www.ftdichip.com/Drivers/VCP.htm)
- [Intel XDK IoT Edition](https://software.intel.com/en-us/iot)

**Win**

- Intel Edison Driver(win)
- FTDI Driver(win)


### 組み立てと起動
- Edison と breakboardを接続する（カチッと音がする）
- 手でネジ留めする
- 
- EFTDI端子がある方がUSBシリアル、もう一つが電源となる

**USBケーブルが2本存在する場合**

- USBケーブルを2本接続し、PCと接続する
- breakboardのLEDが点滅することを確認
- 下記のとおり"/dev/cu.usebserial***"というdeviceが作成されていることを確認

```
$ ls -l /dev/cu.usbserial*
crw-rw-rw-  1 root  wheel   17,  13  4  4 15:22 /dev/cu.usbserial-AJ0360DW
```

- cuコマンドでコンソール接続、"rootユーザ(パスワードはなし)"でログインする

```
$ sudo cu -s 115200 -l /dev/cu.usbserial-AJ0360DW
Password:
Connected.
(Enterを2度押す)

Poky (Yocto Project Reference Distro) 1.6 edison ttyMFD2

edison login: root
root@edison:~# 
```

- コンソールから抜ける場合は以下のとおり"~."を入力してしばし待つと切断される

```
root@edison:~# exit

Poky (Yocto Project Reference Distro) 1.6 edison ttyMFD2

edison login: ~.
Disconnected.
```

**USBケーブルが1本の場合**

- [HoRNDIS](http://joshuawise.com/horndis): USB tethering driver for Mac OS X(SSHアクセス用)の最新版をダウンロード

- "HoRNDIS-rel*.pkg"をダブルクリックしてインストール
- 給電用のポートにUSBケーブルを1本接続しPCと接続する
- breakboardのLEDが点滅することを確認

- システム環境設定->ネットワーク環境のdeviceに"Multifunction Composite Gadget(169.254.174.176)"というdeviceが追加される
- IPを"192.168.2.2/255.255.255.0"に変更する
- ターミナルを起動して、192.168.2.15(EdisonのデフォルトIP)へPINGを実施

```
$ ping 192.168.2.15
PING 192.168.2.15 (192.168.2.15): 56 data bytes
64 bytes from 192.168.2.15: icmp_seq=0 ttl=64 time=1.916 ms
64 bytes from 192.168.2.15: icmp_seq=1 ttl=64 time=0.945 ms
CTRL+C
```

- sshでログインする

```
$ ssh root@192.168.2.15
root@edison:~# ifconfig
```

### ファームウェアの確認と最新化
以後のオペレーションは sshログイン　想定で記載しています

#### ファームウェアのバージョン確認
- edisonにログイン
- edisonのバージョン確認

```
# cat /etc/version
edison-weekly_build_56_2014-08-20_15-54-05
```

- kernelのバージョンを確認

```
# uname -a
Linux edison 3.10.17-poky-edison+ #1 SMP PREEMPT Wed Aug 20 16:09:18 CEST 2014 i686 GNU/Linux
```


#### マスストレージのフォーマットをFAT32に変更する
ファームウェアの更新を行うにはEdisonのマスストレージにファイルを書き込む必要があるが、Edisonのマスストレージは、初期状態ではFAT16であり、マックでは書き込みができない。そのため、EdisonのマスストレージをFAT32でフォーマットしなおす必要がある。

- Macのディスクユーティリティー起動
- Edisonというdeviceを選択
- 情報を確認し、フォーマットが MS-DOS(FAT16)であることを確認
- 消去タブを選択
- フォーマット MS-DOM(FAT), 名前 EDISON として右下の"消去"を実施
- パーティション削除の許可により削除実行
- 検証を行う
- 情報タブを選択し、フォーマットがMS-DOS(FAT32)になったことを確認


#### Yocto Linux イメージのダウンロード
- [Intel Edison Support & Downloads Page](http://www.intel.com/support/edison/sb/CS-035180.htm?_ga=1.86494616.126673810.1428127765) より最新のOSイメージ（Yocto complete image, ZIPファイル）をダウンロードする


#### イメージを解凍して、EDISONに展開
- ZIPファイルを解凍し、中身のフォルダを全て上記のEDISONへコピーする

```
$ mkdir edison-image
$ unzip edison-image-ww05-15.zip -d edison-image
$ cd edison-image ; pwd
$ ls
(ファイルができていることを確認)
$ ls -ld /Volumes/EDISON/
$ mv * /Volumes/EDISON/
```

#### Edisonのファームウェア更新
- edisonにログイン
- 不要ファイルの削除

```
# ls -l /var/log/journal/*
# rm -rf /var/log/journal/*
```

- Edisonリブート

```
# reboot ota
```

- Mac側のUSBネットワークのIPアドレスが初期状態に戻っているので"ネットワーク設定から修正する"
- システム環境設定->ネットワーク環境のdeviceで表示される"Edison"のIPを"192.168.2.2/255.255.255.0"に変更する

- ファームウェアを更新した後通常と同様の手順でアクセスすると下記のようにエラーとなる。

```
$ ssh root@192.168.2.15
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
IT IS POSSIBLE THAT SOMEONE IS DOING SOMETHING NASTY!
Someone could be eavesdropping on you right now (man-in-the-middle attack)!
It is also possible that a host key has just been changed.
The fingerprint for the RSA key sent by the remote host is
95:e0:e6:7e:a1:41:ff:c9:47:86:86:63:32:1e:a0:78.
Please contact your system administrator.
Add correct host key in /Users/tera/.ssh/known_hosts to get rid of this message.
Offending RSA key in /Users/tera/.ssh/known_hosts:15
RSA host key for 192.168.2.15 has changed and you have requested strict checking.
Host key verification failed.
```
- 192.168.2.15のキーを削除

```
$ ssh-keygen -R 192.168.2.15
# Host 192.168.2.15 found: line 15 type RSA
/Users/tera/.ssh/known_hosts updated.
Original contents retained as /Users/tera/.ssh/known_hosts.old
```

- sshログイン

```
$ ssh root@192.168.2.15
```

- Edisonのバージョン確認

```
# cat /etc/version
weekly-120
```

- kernelのバージョンを確認

```
# uname -a
Linux edison 3.10.17-poky-edison+ #1 SMP PREEMPT Wed Aug 20 16:09:18 CEST 2014 i686 GNU/Linux
```

- ログアウトして,マスストレージ内部のファイルを全て削除


```
$ rm -rf /Volumes/EDISON/*
```


### 初期設定
- edisonにログインする

```
$ ssh root@192.168.2.15
```


#### ノード名、パスワード、Wi-Fiの設定を行う
```
# configure_edison --setup
```

- パスワード変更画面


```
Configure Edison: Device Password

Enter a new password (leave empty to abort)
This will be used to connect to the access point and login to the device.
Password: 	**********
Please enter the password again: 	**********

```

- device name設定画面


```
Configure Edison: Device Name

Give this Edison a unique name.
This will be used for the access point SSID and mDNS address.
Make it at least five characters long (leave empty to skip): edison01
Is edison01 correct? [Y or N]: Y

Do you want to set up wifi? [Y or N]:Y
(ssidのスキャン開始)
```

```
Configure Edison: WiFi Connection

Scanning: 1 seconds left

0 :	Rescan for networks
1 :	Exit WiFi Setup
2 :	Manually input a hidden SSID
3 :	Airport
4 :	aterm-dc86a2-gw
5 :	106F3F277800_G
6 :	106F3F277800_G-1
7 :	Tera WiFi 5GHz
8 :	Tera WiFi


Enter 0 to rescan for networks.
Enter 1 to exit.
Enter 2 to input a hidden network SSID.
Enter a number between 3 to 8 to choose one of the listed network SSIDs: 7

192.168.179.10
```

#### repository設定、Upgrate


```
# echo "src intel-iotdk http://iotdk.intel.com/repos/1.1/intelgalactic" > /etc/opkg/intel-iotdk.conf

# echo "src mraa-upm http://iotdk.intel.com/repos/1.1/intelgalactic" > /etc/opkg/mraa-upm.conf

# opkg update
# opkg upgrade
```

#### ntpdateインストール
opkgパッケージにはntpがないためソースよりコンパイルして利用する
```
# curl http://www.eecis.udel.edu/~ntp/ntp_spool/ntp4/ntp-4.2/ntp-4.2.8p2.tar.gz -o ntpdate.tar.gz
# tar zxvf ntpdate.tar.gz
# cd ntp-4.2.8p2
# ./configure -prefix=/usr -sysconfdir=/etc -enable-linuxcaps -with-binsubdir=sbin -with-lineeditlibs=readline
# make
# make install
# cd ../
# rm -rf ntp*

# ntpdate -v ntp.nict.jp
# ntpdate -q ntp.nict.jp
# ntpdate -bv ntp.nict.jp
# export TZ=JST-9
```

#### nvmインストール

```
# git clone git://github.com/creationix/nvm.git .nvm
# cd .nvm
# git tag
# git checkout v0.25.3
# cd ../




 
