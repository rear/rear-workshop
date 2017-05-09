#!/bin/bash -ex
cd /

if ! grep -q yum /etc/fstab ; then
  RPMDIR=/var/lib/yum/packages
  cat >/etc/yum.repos.d/workshop.repo <<EOF
[workshop]
name=Vagrant server
baseurl=file://$RPMDIR
enabled=1
gpgcheck=0
cost=500
metadata_expire=1
EOF

  echo "server:/var/lib/yum/plugins/local $RPMDIR  nfs ro 0 0" >>/etc/fstab
  mkdir -vp $RPMDIR
  mount -v $RPMDIR
fi

yum install -y epel-release \
  bareos-filedaemon bareos-bconsole bareos-client-conf \
  vim-enhanced nano \
  rsync fuse-sshfs

# check if eth1 is UP
# Why? See issue https://github.com/mitchellh/vagrant/issues/8115
# Will probably be fixed in vagrant 1.9.2
# Currently, when we start the vm (without provisioning) the eth1 is still DOWN
#ip addr show dev eth1 | grep -q DOWN && systemctl restart network.service
