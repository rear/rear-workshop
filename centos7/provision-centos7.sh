#!/bin/bash -x
cd /
echo "Provisioning centos 7"

# set up hostname (client) - is done via the Vagrantfile

# set up the timezone
timedatectl set-timezone Europe/Brussels
# check the timezone:
date


# Add IP addresses to /etc/hosts
IPclient="192.168.33.10"
grep -q "^$IPclient" /etc/hosts
if [[ $? -eq 1 ]] ;then
   echo "Add IP addresses of client and server to /etc/hosts file"
   echo "# Private IP addresses are in the 192.168.33.0 network" >> /etc/hosts
   echo "192.168.33.10   client.box client vagrant-client" >> /etc/hosts
   echo "192.168.33.15   server.box server vagrant-server" >> /etc/hosts
   echo "192.168.33.1    vagrant-host vagrant-host-private" >> /etc/hosts
   echo "# Oracle VirtualBox Public IP addresses are using network 10.0.2.0" >> /etc/hosts
   echo "# With Oracle VirtualBox the public interface eth0 uses IP address 10.0.2.15" >> /etc/hosts
   echo "10.0.2.2   	 vagrant-host-public" >> /etc/hosts
fi

# SSH setup
# Add Vagrant ssh key for root and vagrant accouts.
sed -i 's/.*UseDNS.*/UseDNS no/' /etc/ssh/sshd_config
sed -i 's/.*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
cat >>/etc/ssh/ssh_config <<EOF
Host *
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
EOF

systemctl restart sshd

# setup SSH keys for user root
[ -d ~root/.ssh ] || mkdir -m 700 ~root/.ssh
cat >> ~root/.ssh/authorized_keys << EOF
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key
EOF
chmod 600 ~root/.ssh/authorized_keys
# add vagrant insecure key to root user for communication between VMs
cat >>~root/.ssh/id_rsa << EOF
-----BEGIN RSA PRIVATE KEY-----
MIIEogIBAAKCAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzI
w+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoP
kcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2
hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NO
Td0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcW
yLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQIBIwKCAQEA4iqWPJXtzZA68mKd
ELs4jJsdyky+ewdZeNds5tjcnHU5zUYE25K+ffJED9qUWICcLZDc81TGWjHyAqD1
Bw7XpgUwFgeUJwUlzQurAv+/ySnxiwuaGJfhFM1CaQHzfXphgVml+fZUvnJUTvzf
TK2Lg6EdbUE9TarUlBf/xPfuEhMSlIE5keb/Zz3/LUlRg8yDqz5w+QWVJ4utnKnK
iqwZN0mwpwU7YSyJhlT4YV1F3n4YjLswM5wJs2oqm0jssQu/BT0tyEXNDYBLEF4A
sClaWuSJ2kjq7KhrrYXzagqhnSei9ODYFShJu8UWVec3Ihb5ZXlzO6vdNQ1J9Xsf
4m+2ywKBgQD6qFxx/Rv9CNN96l/4rb14HKirC2o/orApiHmHDsURs5rUKDx0f9iP
cXN7S1uePXuJRK/5hsubaOCx3Owd2u9gD6Oq0CsMkE4CUSiJcYrMANtx54cGH7Rk
EjFZxK8xAv1ldELEyxrFqkbE4BKd8QOt414qjvTGyAK+OLD3M2QdCQKBgQDtx8pN
CAxR7yhHbIWT1AH66+XWN8bXq7l3RO/ukeaci98JfkbkxURZhtxV/HHuvUhnPLdX
3TwygPBYZFNo4pzVEhzWoTtnEtrFueKxyc3+LjZpuo+mBlQ6ORtfgkr9gBVphXZG
YEzkCD3lVdl8L4cw9BVpKrJCs1c5taGjDgdInQKBgHm/fVvv96bJxc9x1tffXAcj
3OVdUN0UgXNCSaf/3A/phbeBQe9xS+3mpc4r6qvx+iy69mNBeNZ0xOitIjpjBo2+
dBEjSBwLk5q5tJqHmy/jKMJL4n9ROlx93XS+njxgibTvU6Fp9w+NOFD/HvxB3Tcz
6+jJF85D5BNAG3DBMKBjAoGBAOAxZvgsKN+JuENXsST7F89Tck2iTcQIT8g5rwWC
P9Vt74yboe2kDT531w8+egz7nAmRBKNM751U/95P9t88EDacDI/Z2OwnuFQHCPDF
llYOUI+SpLJ6/vURRbHSnnn8a/XG+nzedGH5JGqEJNQsz+xT2axM0/W/CRknmGaJ
kda/AoGANWrLCz708y7VYgAtW2Uf1DPOIYMdvo6fxIB5i9ZfISgcJ/bbCUkFrhoH
+vq/5CIWxCPp0f85R4qxxQ5ihxJ0YDQT9Jpx4TMss4PSavPaBH3RXow5Ohe+bYoQ
NE5OgEXk2wVfZczCZpigBKbKZHNYcelXtTt/nP3rsCuGcM4h53s=
-----END RSA PRIVATE KEY-----
EOF
chmod 600 ~root/.ssh/id_rsa


# Networking setup..
#-------------------
# Disable IPv6
sysctl -w net.ipv6.conf.all.disable_ipv6=1
sysctl -w net.ipv6.conf.default.disable_ipv6=1
cat >/etc/sysctl.d/noipv6.conf <<EOF
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
EOF

# Fix slow DNS
# Add 'single-request-reopen' so it is included when /etc/resolv.conf is generated
# https://access.redhat.com/site/solutions/58625 (subscription required)
echo 'RES_OPTIONS="single-request-reopen"' >>/etc/sysconfig/network
systemctl restart network
echo 'Slow DNS fix applied (single-request-reopen)'

# TODO
# # Don't fix ethX names to hw address.
# rm -f /etc/udev/rules.d/*persistent-net.rules
# rm -f /etc/udev/rules.d/*-net.rules
# rm -fr /var/lib/dhclient/*



# Disacle kdump service - fails anyway due to lack of swap
systemctl stop kdump.service
systemctl disable kdump.service

# add the domain name to the /etc/idmapd.conf file (for NFSv4)
sed -i -e 's,^#Domain =.*,Domain = box,' /etc/idmapd.conf

if [[ "$(virt-what)" == *virtualbox* ]] ; then
  echo "Removing serial console support as it breaks autorelabel on VirtualBox"
  sed -i -e 's/ console=[^ ]\+\?//g; s/quiet/vga=791 quiet/' /etc/default/grub
  grub2-mkconfig -o /boot/grub2/grub.cfg
fi

# Delta RPM costs too much CPU, we have enough Internet bandwidth
echo "deltarpm=0" >> /etc/yum.conf
exit 0