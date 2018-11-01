#!/bin/bash
# This flist has : 
#     ubuntu 16.04, js(development), most of test suite requirements library, zerotier

set -ex

# make output directory
ARCHIVE=/tmp/archives
FLIST=/tmp/flist
mkdir -p $ARCHIVE

echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "export LC_ALL=en_US.UTF-8" >> /root/.bashrc
echo "export LANG=en_US.UTF-8" >> /root/.bashrc
echo "export LANGUAGE=en_US.UTF-8" >> /root/.bashrc
echo " export HOME=/root" >> /root/.bashrc

# test
mkdir -p /etc/initramfs-tools
mkdir -p /etc/network/interfaces.d

echo "deb http://archive.ubuntu.com/ubuntu/ xenial main universe multiverse restricted" >> /etc/apt/sources.list
echo "deb http://download.zerotier.com/debian/xenial xenial main" >> /etc/apt/sources.list

echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "en_GB.UTF-8 UTF-8" >> /etc/locale.gen

echo '9p' >> /etc/initramfs-tools/modules
echo '9pnet' >> /etc/initramfs-tools/modules
echo '9pnet_virtio' >> /etc/initramfs-tools/modules
echo '9pnet_rdma' >> /etc/initramfs-tools/modules
echo "root	/	9p	rw,cache=loose,trans=virtio	0 0" >> /fstab
echo 'auto ens4' >> /etc/network/interfaces.d/ens4
echo 'iface ens4 inet dhcp' >> /etc/network/interfaces.d/ens4
echo 'ubuntu' >> /etc/hostname
echo 'nameserver 8.8.8.8' > /etc/resolv.conf

echo "kernel: /boot/vmlinuz-4.4.0-21-generic" > /boot/boot.yaml
echo "initrd: /boot/initrd.img-4.4.0-21-generic" >> /boot/boot.yaml

# install system deps
apt-get update
apt-get install -y curl locales git wget netcat tar sudo tmux ssh libffi-dev python3-dev libssl-dev libpython3-dev libssh-dev libsnappy-dev build-essential libvirt-dev libsqlite3-dev openssh-server
DEBIAN_FRONTEND=noninteractive apt-get install -y linux-image-4.4.0-21-generic systemd-sysv systemd

#ssh generate
ssh-keygen -f ~/.ssh/id_rsa -P ''
eval `ssh-agent -s`
ssh-add ~/.ssh/id_rsa

# Insall jumpscale
locale-gen en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export JUMPSCALEBRANCH="development"
export JSFULL=1
curl -s https://raw.githubusercontent.com/threefoldtech/jumpscale_core/$JUMPSCALEBRANCH/install.sh?$RANDOM | bash


# Testing packages
pip3 install nose nose-progressive nose-testconfig sphinx sphinx-rtd-theme parameterized rednose

#Install zerotier
#(curl -s https://install.zerotier.com/ | bash) || true

# change root password
usermod --password root root

# start ssh 
/etc/init.d/ssh start
wget https://github.com/0xislamtaha.keys -O /root/.ssh/authorized_keys
rm -rf /.dockerenv

tar -cpzf "/tmp/archives/testing_flist.tar.gz" --exclude tmp --exclude dev --exclude sys --exclude proc  /

