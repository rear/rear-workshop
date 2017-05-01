#!/bin/bash -x

echo "Provisioning centos/7"

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


# Prepare /srv/http/packages/workshop (download area for RPMs)
RPMDIR=/srv/http/packages/workshop
if [[ ! -d $RPMDIR ]] ; then
    mkdir -m 755 -p $RPMDIR
    echo "Created RPM directory $RPMDIR"
fi

# Install software that is required to bootstrap the rest of the workshop
# do an update of the base system first
echo "Running yum update..."
yum --disableplugin=fastestmirror update -y

# httpd,createrepo,wget
# epel-release will install Epel repository
echo "Installing base RPMs via yum"
yum --disableplugin=fastestmirror install -y httpd createrepo wget epel-release

# Define bareos and rear repo defintions
yum-config-manager \
  --add http://download.bareos.org/bareos/release/latest/CentOS_7/bareos.repo \
  --add http://download.opensuse.org/repositories/Archiving:/Backup:/Rear/CentOS_7/Archiving:Backup:Rear.repo \
  --add http://download.opensuse.org/repositories/home:/gdha/CentOS_7/home:gdha.repo \
# enable this to use ReaR Snapshot instead of Releases
#  --add http://download.opensuse.org/repositories/Archiving:/Backup:/Rear:/Snapshot/CentOS_7/Archiving:Backup:Rear:Snapshot.repo \

packages=(
syslinux syslinux-extlinux cifs-utils genisoimage
net-tools xinetd tftp-server dhcp
samba samba-client
bind-utils mtools attr libusal
bareos bareos-database-postgresql bareos-client-conf bareos-server-conf postgresql-server
sshfs
vim-enhanced nano
rear rear-workshop
)
# Download RPMs for workshop
echo "Downloading workshop packages into $RPMDIR"
yum --disableplugin=fastestmirror install -y --downloadonly --downloaddir=$RPMDIR ${packages[@]}

# create the 'workshop repo' files from the downloaded packages
echo "Run the createrepo command"
createrepo $RPMDIR

if [[ ! -f /etc/yum.repos.d/workshop.repo ]] ; then
   echo "Create the yum repo for workshop"
   cat > /etc/yum.repos.d/workshop.repo <<EOF
[workshop]
name=Rear workshop
baseurl=http://localhost/packages/workshop
enabled=1
gpgcheck=0

EOF
fi

echo "Adding user vagrant and some security related stuff"
# Users, groups, passwords and sudoers.
echo 'vagrant' | passwd --stdin root
grep 'vagrant' /etc/passwd > /dev/null
if [ $? -ne 0 ]; then
	echo '* Creating user vagrant.'
	useradd vagrant
	echo 'vagrant' | passwd --stdin vagrant
fi
grep '^admin:' /etc/group > /dev/null || groupadd admin
usermod -G admin vagrant

echo 'Defaults    env_keep += "SSH_AUTH_SOCK"' >> /etc/sudoers
echo '%admin ALL=NOPASSWD: ALL' >> /etc/sudoers
sed -i 's/Defaults\s*requiretty/Defaults !requiretty/' /etc/sudoers


# SSH setup
# Add Vagrant ssh key for root and vagrant accouts.
sed -i 's/.*UseDNS.*/UseDNS no/' /etc/ssh/sshd_config
sed -i 's/.*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config

# setup SSH keys for user root
[ -d ~root/.ssh ] || mkdir  -m 700 ~root/.ssh
cat >> ~root/.ssh/authorized_keys << EOF
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key
EOF
chmod 600 ~root/.ssh/authorized_keys
# use ssh-keygen to generate a new pair of SSH keys for root to exchange between client/server systems?
echo "Generate a new keypair for root"
ssh-keygen -t rsa -P '' -f ~root/.ssh/id_rsa

# setup SSH insecure key for user vagrant
[ -d ~vagrant/.ssh ] || mkdir -m 700 ~vagrant/.ssh
cat >> ~vagrant/.ssh/authorized_keys << EOF
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key
EOF
chmod 600 ~vagrant/.ssh/authorized_keys


# Disable firewall and switch SELinux to permissive mode.
#chkconfig iptables off
#chkconfig ip6tables off
# firewallD is by default not running with this box

# Networking setup..
#-------------------
# Fix slow DNS
# Add 'single-request-reopen' so it is included when /etc/resolv.conf is generated
# https://access.redhat.com/site/solutions/58625 (subscription required)
echo 'RES_OPTIONS="single-request-reopen"' >>/etc/sysconfig/network
service network restart
echo 'Slow DNS fix applied (single-request-reopen)'

# Don't fix ethX names to hw address.
rm -f /etc/udev/rules.d/*persistent-net.rules
rm -f /etc/udev/rules.d/*-net.rules
rm -fr /var/lib/dhclient/*

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
EOF
fi

# SElinux settings when Enforce is on (default setting)
echo "Current mode of SELinux is \"$(getenforce)\""
echo "Give httpd rights to read from /srv/http/packages"
chcon -R -t httpd_sys_content_t /srv/http/packages/
# However, SELinux and Oracle VirtualBox are not close friends and give restore issues when enabled
# Therefore, for the sake of the workshop we disable it
echo "Force SELinux in Permissive mode"
setenforce Permissive

# Restart httpd so it knows about $RPMDIR location (/etc/httpd/conf.d/packages.conf)
#service httpd restart
/bin/systemctl restart  httpd.service
/bin/systemctl enable   httpd.service

# Disacle kdump service - fails anyway due to lack of swap
/bin/systemctl stop kdump.service
/bin/systemctl disable kdump.service

# add the domain name to the /etc/idmapd.conf file (for NFSv4)
sed -i -e 's,^#Domain =.*,Domain = box,' /etc/idmapd.conf

# disable external repos to avoid internet usage during workshop
yum-config-manager --disable \* | grep -E '(\[|enable)'
yum-config-manager --enable workshop | grep -E '(\[|enable)'
echo "Disabled all yum repos except the workshop.repo"

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
