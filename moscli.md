

```
$ keystone tenant-create --name teraproj --description 'sample project'
$ keystone user-create --name tera --tenant teraproj --pass nova --email tera@domain.tld
$ keystone user-role-add --user tera --role admin --tenant teraproj
$ keystone user-role-remove --user tera --role _member_ --tenant teraproj
$ keystone user-role-add --user demo --role _member_ --tenant teraproj


$ nova quota-show --tenant fa08ab5f7f6e478cad8d83e02fa97ce9
$ cinder quota-show fa08ab5f7f6e478cad8d83e02fa97ce9
$ nova quota-update --instances 2 --cores 4 fa08ab5f7f6e478cad8d83e02fa97ce9
$ cinder quota-update --gigabytes 3 fa08ab5f7f6e478cad8d83e02fa97ce9

$ neutron net-create --tenant-id fa08ab5f7f6e478cad8d83e02fa97ce9 teranet
$ neutron subnet-create --tenant-id fa08ab5f7f6e478cad8d83e02fa97ce9 --name terasubnet --gateway 10.2.0.225 --allocation-pool start=10.2.0.240,end=10.2.0.245 teranet 10.2.0.224/27
$ neutron 
$ neutron router-create --tenant-id fa08ab5f7f6e478cad8d83e02fa97ce9 trouter
$ neutron router-list
$ neutron net-list
$ neutron router-gateway-set 4f7a5dce-eeda-40af-81e7-cb98ffbfff75 6ab4b856-9cbb-45cd-acb4-ca456664d4cc
$ neutron router-list
$ neutron subnet-list
$ neutron router-interface-add 4f7a5dce-eeda-40af-81e7-cb98ffbfff75 subnet=terasubnet
$ neutron router-port-list trouter

$ nova secgroup-create custom
$ nova secgroup-list-rules custom
$ nova secgroup-add-rule custom icmp -1 -1 0.0.0.0/0
$ nova secgroup-add-rule custom tcp 22 22 0.0.0.0/0
$ nova secgroup-add-rule custom tcp 80 80 0.0.0.0/0

$ nova boot --image cirros-0.3.2-x86_64-uec --flavor m1.tiny tera
$ nova add-secgroup tera custom
$ nova show tera
$ glance image-list
$ glance image-create --name ubuntu --container-format bare --disk-format qcow2 --location http://127.0.0.1:8090/ubuntu1204.img

$ nova list
$ ceilometer alarm-threshold-create --name cpu_high --description 'Instance running hot' -m cpu_util --statistic avg --period 600 --evaluation-periods 3 --comparison-operator gt --threshold 80 --alarm-action 'log://' -q resource_id=bb10b8b7-01d9-4f1c-ba82-c5cb28b3ffd5

$ nova net-list
$ nova boot --image cirros-0.3.2-x86_64-uec --flavor m1.tiny --nic net-id=23bd8516-388c-45d8-9a78-79b629c3db17 --security-groups default,custom demo

$ neutron subnet-list
$ neutron lb-pool-create --name tpool --lb-method ROUND_ROBIN --protocol HTTP --subnet-id ff34f086-9f91-471b-b7b4-75df0c2d2192
$ neutron lb-member-create --address 10.2.0.242 --protocol-port 80 tpool
$ neutron lb-member-create --address 10.2.0.240 --protocol-port 80 tpool
$ neutron 
(neutron) lb-healthmonitor-create --delay 3 --type HTTP --max-retries 3 --timeout 3
CTRL + C
$ neutron lb-healthmonitor-associate  e9fb8f89-1302-47cf-816f-21a1459f9f02 tpool
$ neutron lb-vip-create --name tvip --protocol-port 80 --protocol HTTP --subnet-id ff34f086-9f91-471b-b7b4-75df0c2d2192 tpool

$ nova floating-ip-create
$ neutron floatingip-show 20a07975-9bba-494a-9b84-8b62a2d7c782
$ neutron lb-vip-list 
$ neutron lb-vip-show 87a559b9-8fa8-42f6-ae76-b600ea2d6fd7
$ neutron floatingip-associate 20a07975-9bba-494a-9b84-8b62a2d7c782 27e1e91d-041d-418c-967c-dce65d54ff39

$ ip route add
$ nohup sh -c \"while true; do echo -e 'HTTP/1.0 200 OK\r\n\r\ndemo' \ | sudo nc -l -p 80 ; done" &
$ cinder create --display-name vol1 1
$ nova volume-attach demo 45ec70c2-1ee6-444c-b48a-27734f9ed632 /dev/vdb

$ swift post workshop
$ swift upload --object-name test.jpg workshop /home/stack/files/test.jpg
$ swift upload --object-name test.mov \ --segment-size 10485760 workshop /home/stack/files/test.mov

$ cd ~/devstack/
$ ./rejoin-stack.sh

戻る：ctrl+a+p
進む：ctrl+a+n

ctrl+c->ヒストリ->プロセス起動 

元のスクリーンに戻る：ctrl+a, ctrl+d
screen切り替え:rejoin-stack.sh
```

