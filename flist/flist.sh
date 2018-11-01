#!/bin/bash
# This flist has : 
#     ubuntu 16.04, js(development), most of test suite requirements library, zerotier

set -ex

# make output directory
mkdir -p /tmp/archives

mkdir -p /tmp/xTremX/proc
mkdir -p /tmp/xTremX/sys
mkdir -p /tmp/xTremX/dev
mkdir -p /tmp/xTremX/etc/apt
mkdir -p /tmp/xTremX/etc/initramfs-tools
mkdir -p /tmp/xTremX/etc/network/interfaces.d

mount -o bind /proc /tmp/xTremX/proc
mount -o bind /sys /tmp/xTremX/sys
mount -o bind /dev /tmp/xTremX/dev

apt-get install -y debootstrap #basic debian system
debootstrap xenial /tmp/xTremX http://ftp.belnet.be/ubuntu.com/ubuntu

printf "deb http://archive.ubuntu.com/ubuntu/ xenial main universe multiverse restricted\n" >> /tmp/xTremX/etc/apt/sources.list
printf "deb http://download.zerotier.com/debian/xenial xenial main\n" >> /tmp/xTremX/etc/apt/sources.list

printf "en_US.UTF-8 UTF-8\n" >> /tmp/xTremX/etc/locale.gen
printf "en_GB.UTF-8 UTF-8\n" >> /tmp/xTremX/etc/locale.gen

printf "9p\n9pnet\n9pnet_virtio\n9pnet_rdma\n" > /tmp/xTremX/etc/initramfs-tools/modules
printf 'root    /    9p    rw,cache=loose,trans=virtio 0 0\n' > /tmp/xTremX/etc/fstab
printf 'auto ens4\niface ens4 inet dhcp\n' >> /tmp/xTremX/etc/network/interfaces.d/ens4
printf 'ubuntu_xTremX\n' > /tmp/xTremX/etc/hostname
printf 'nameserver 8.8.8.8\n' > /tmp/xTremX/etc/resolv.conf

chroot /tmp/xTremX bash -c 'locale-gen'
chroot /tmp/xTremX bash -c 'apt-get update'
chroot /tmp/xTremX bash -c 'apt-get install -y --allow-unauthenticated --no-install-recommends openssh-server linux-generic wget ca-certificates curl acpid'
chroot /tmp/xTremX bash -c 'update-initramfs -u'
#chroot /tmp/xTremX bash -c 'curl -s https://install.zerotier.com/ | bash'

printf "kernel: /boot/vmlinuz-4.4.0-21-generic\n" > /tmp/xTremX/boot/boot.yaml
printf "initrd: /boot/initrd.img-4.4.0-21-generic\n" >> /tmp/xTremX/boot/boot.yaml

chroot /tmp/xTremX bash -c 'printf "root:root" | chpasswd'

umount /tmp/xTremX/proc
umount /tmp/xTremX/sys
umount /tmp/xTremX/dev

rm -rf /tmp/xTremX/var/apt/cache/archives

tar -czpf "/tmp/archives/testing_flist.tar.gz" /tmp/xTremX 

