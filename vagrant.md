vagrant 
=====

----
### disk resize(centos)

```
$ vagrant halt
$ cd ~/VirtualBox/VMs/****
$ VBoxManage clonehd box-disk1.vmdk box-disk1.vdi --format VDI
$ VBoxManage modifyhd box-disk1.vdi --resize 20480

$ cd ~/Vagrant/****
$ vagrant up

$ vagrant ssh
$ sudo fdisk -l
$ sudo /dev/sda
d
2
n
p
t
2
8e
p
:wq

$ exit

$ vagrant halt
$ vagrant up
$ vagrant ssh

$ sudo pvresize /dev/sda2
$ sudo pvscan
$ sudo lvscan
$ sudo lvresize -l +100%FREE /dev/centos/root
$ sudo lvscan
$ sudo xfs_growfs /dev/centos/root
$ df
```