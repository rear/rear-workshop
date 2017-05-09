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

exit 0

# Our VMs uses NetworkManager for dhcp of eth0 and eth1 uses a fixed IP address, however, vagrant 1.9.1
# has a bug that eth1 does not get activated (should get fixed in next release of vagrant)
# As work-around we will do the following in the mean-time:
cat > /usr/lib/systemd/system/restart-network.service <<EOF
[Unit]
Description=Restart the network (due to bug in vagrant 1.9.1)

[Service]
Type=oneshot
ExecStart=/bin/sh -c "ip addr show dev eth1 | grep -q DOWN && systemctl restart network.service || :"

[Install]
WantedBy=multi-user.target
EOF
systemctl enable restart-network.service
systemctl start restart-network.service

# Prepare /srv/http/packages/workshop (download area for RPMs)
RPMDIR=/srv/http/packages/workshop
if [[ ! -d $RPMDIR ]] ; then
    mkdir -m 755 -p $RPMDIR
    echo "Created RPM directory $RPMDIR"
fi

# Install software that is required to bootstrap the rest of the workshop
# do an update of the base system first
echo "Running yum update..."
#yum --disableplugin=fastestmirror update -y

# httpd,createrepo,wget
# epel-release will install Epel repository
echo "Installing base RPMs via yum"
yum --disableplugin=fastestmirror install -y httpd createrepo wget epel-release

if [[ -d /src ]] ; then
  pushd /src
  for d in * ; do
    pushd d
    make
    mv *.rpm $RPMDIR
    popd
  done
  popd
fi

if [[ ! -f $RPMDIR/workshop.repo ]] ; then
  echo "Create the yum repo for workshop"
  cat > $RPMDIR/workshop.repo <<EOF
  [workshop]
  name=Rear workshop
  baseurl=http://server/packages/workshop
  enabled=1
  gpgcheck=0
EOF
fi



# Configure /etc/httpd/conf.d/packages.conf
if [[ ! -f /etc/httpd/conf.d/packages.conf ]] ; then
    cat >/etc/httpd/conf.d/packages.conf <<EOF
Alias /packages /srv/http/packages

<Directory /srv/http/packages>
  Options Indexes FollowSymlinks
  AllowOverride All
  # See http://stackoverflow.com/questions/18392741/apache2-ah01630-client-denied-by-server-configuration
  #Order allow,deny
  #Allow from all
  Require all granted
</Directory>
# prevent hitting VirtualBox/sendfile bug
EnableSendfile Off
EOF
fi

# SElinux settings when Enforce is on (default setting)
echo "Current mode of SELinux is \"$(getenforce)\""
echo "Give httpd rights to read from /srv/http/packages"
chcon -R -t httpd_sys_content_t /srv/http/packages/


# Restart httpd so it knows about $RPMDIR location (/etc/httpd/conf.d/packages.conf)
#service httpd restart
systemctl restart  httpd.service
systemctl enable   httpd.service

# Define bareos and rear repo defintions
yum-config-manager \
  --add http://download.bareos.org/bareos/release/latest/CentOS_7/bareos.repo \
  --add http://download.opensuse.org/repositories/Archiving:/Backup:/Rear/CentOS_7/Archiving:Backup:Rear.repo

#  --add http://download.opensuse.org/repositories/home:/gdha/CentOS_7/home:gdha.repo \
# enable this to use ReaR Snapshot instead of Releases
#  --add http://download.opensuse.org/repositories/Archiving:/Backup:/Rear:/Snapshot/CentOS_7/Archiving:Backup:Rear:Snapshot.repo \

packages=(
syslinux syslinux-extlinux cifs-utils genisoimage
net-tools xinetd tftp-server dhcp
samba samba-client
bind-utils mtools attr libusal
bareos bareos-database-postgresql postgresql-server
sshfs
rpm-build
vim-enhanced nano
rear
)
# Download RPMs for workshop
echo "Downloading workshop packages into $RPMDIR"
yum --disableplugin=fastestmirror install -y --downloadonly --downloaddir=$RPMDIR ${packages[@]}

# create the 'workshop repo' files from the downloaded packages
echo "Run the createrepo command"
createrepo $RPMDIR

yum-config-manager --add http://server/packages/workshop/workshop.repo



# Disable firewall and switch SELinux to permissive mode.
#chkconfig iptables off
#chkconfig ip6tables off
# firewallD is by default not running with this box


# disable external repos to avoid internet usage during workshop
yum-config-manager --disable \* | grep -E '(\[|enable)'
yum-config-manager --enable workshop | grep -E '(\[|enable)'
echo "Disabled all yum repos except the workshop.repo"

