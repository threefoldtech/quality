#!/bin/bash
# This flist has : 
#     ubuntu 16.04, js(development), most of test suite requirements library, zerotier

set -ex

# make output directory
ARCHIVE=/tmp/archives
FLIST=/tmp/flist
mkdir -p $ARCHIVE

# install system deps
apt-get update
apt-get install -y curl locales git wget netcat tar sudo tmux ssh libffi-dev python3-dev libssl-dev libpython3-dev libssh-dev libsnappy-dev build-essential libvirt-dev libsqlite3-dev linux-image-4.4.0-21-generic systemd-sysv systemd

echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "export LC_ALL=en_US.UTF-8" >> /root/.bashrc
echo "export LANG=en_US.UTF-8" >> /root/.bashrc
echo "export LANGUAGE=en_US.UTF-8" >> /root/.bashrc
echo " export HOME=/root" >> /root/.bashrc

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
curl https://raw.githubusercontent.com/threefoldtech/jumpscale_core/$JUMPSCALEBRANCH/install.sh?$RANDOM | bash 

# Testing packages
pip3 install nose nose-progressive nose-testconfig sphinx sphinx-rtd-theme parameterized rednose

# Install zerotier
#(curl -s https://install.zerotier.com/ | sudo bash) || true
#service zerotier-one start

# change root password
usermod --password xTremX root

# create bootable
echo "kernel: /boot/vmlinuz-4.4.0-21-generic" > /boot/boot.yaml
echo "initrd: /boot/initrd.img-4.4.0-21-generic" >> /boot/boot.yaml

tar -cpzf "/tmp/archives/testing_flist.tar.gz" --exclude tmp --exclude dev --exclude sys --exclude proc  /
