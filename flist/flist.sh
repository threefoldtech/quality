#!/bin/bash
# This flist has :
#     ubuntu 16.04, js(development), most of test suite requirements library, zerotier

set -ex

# make output directory
mkdir -p /tmp/archives
rootdir="/tmp/xtremx"

mkdir -p ${rootdir}/proc
mkdir -p ${rootdir}/sys
mkdir -p ${rootdir}/dev
mkdir -p ${rootdir}/etc/apt
mkdir -p ${rootdir}/etc/initramfs-tools
mkdir -p ${rootdir}/etc/network/interfaces.d

apt-get update
apt-get install -y debootstrap # basic debian system
debootstrap xenial ${rootdir} http://ftp.belnet.be/ubuntu.com/ubuntu

cat > ${rootdir}/etc/apt/sources.list << EOF
deb http://archive.ubuntu.com/ubuntu/ xenial main universe multiverse restricted
deb http://download.zerotier.com/debian/xenial xenial main
EOF

cat >> ${rootdir}/etc/locale.gen << EOF
en_US.UTF-8 UTF-8
en_GB.UTF-8 UTF-8
EOF

cat > ${rootdir}/etc/initramfs-tools/modules << EOF
9p
9pnet
9pnet_virtio
9pnet_rdma
EOF

cat > ${rootdir}/etc/network/interfaces.d/ens4 << EOF
auto ens4
iface ens4 inet dhcp
EOF

echo "root    /    9p    rw,cache=loose,trans=virtio 0 0" > ${rootdir}/etc/fstab
echo "ubuntu_xTremX" > ${rootdir}/etc/hostname
echo "nameserver 8.8.8.8" > ${rootdir}/etc/resolv.conf

mount -o bind /proc ${rootdir}/proc

chroot ${rootdir} bash -c 'locale-gen'
chroot ${rootdir} bash -c 'apt-get update'
chroot ${rootdir} bash -c 'apt-get install -y --allow-unauthenticated --no-install-recommends openssh-server linux-generic wget ca-certificates curl acpid'
chroot ${rootdir} bash -c 'update-initramfs -u'
#chroot ${rootdir} bash -c 'curl -s https://install.zerotier.com/ | bash'

cat > ${rootdir}/boot/boot.yaml << EOF
kernel: /boot/vmlinuz-4.4.0-21-generic
initrd: /boot/initrd.img-4.4.0-21-generic
EOF

chroot ${rootdir} bash -c 'echo "root:root" | chpasswd'

umount ${rootdir}/proc

rm -rf ${rootdir}/var/apt/cache/archives

tar -czpf "/tmp/archives/testing_flist.tar.gz" --exclude mnt --exclude tmp --exclude dev --exclude sys --exclude proc -C ${rootdir} .
