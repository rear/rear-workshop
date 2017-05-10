#!/bin/bash -ex
cd /

yum -y install yum-plugin-local
yum -y install yum-utils rpm-build epel-release

sed -i -e 's/.*gpgcheck=.*/gpgcheck=0/; s/.*metadata_expire=.*/metadata_expire=1/; s/.*cost=.*/cost=500/' \
  /etc/yum.repos.d/_local.repo
RPMDIR=/var/lib/yum/plugins/local/

pushd /src
for d in *-* ; do
  pushd $d
  make clean
  make
  ls -l
  cp -v *.rpm $RPMDIR
  popd
done
popd

# Define bareos and rear repo defintions
yum-config-manager \
  --add http://download.bareos.org/bareos/release/latest/CentOS_7/bareos.repo \
  --add http://download.opensuse.org/repositories/Archiving:/Backup:/Rear/CentOS_7/Archiving:Backup:Rear.repo

# Snapshots
#  --add http://download.opensuse.org/repositories/Archiving:/Backup:/Rear:/Snapshot/CentOS_7/Archiving:Backup:Rear:Snapshot.repo

# Releases
#  --add http://download.opensuse.org/repositories/Archiving:/Backup:/Rear/CentOS_7/Archiving:Backup:Rear.repo

# fetch all the packages we need from the internet and put them into our local repo dir
packages=(
httpd createrepo wget curl
syslinux syslinux-extlinux genisoimage
net-tools xinetd tftp-server dhcp
samba samba-client cifs-utils
bind-utils mtools attr libusal
bareos bareos-database-postgresql postgresql-server
fuse-sshfs rsync
rpm-build
vim-enhanced nano
perl perl-Carp perl-Encode perl-Exporter perl-File-Path perl-File-Temp perl-Filter perl-Getopt-Long perl-HTTP-Tiny perl-PathTools perl-Pod-Escapes perl-Pod-Perldoc perl-Pod-Simple perl-Pod-Usage perl-Scalar-List-Utils perl-Socket perl-Storable perl-Text-ParseWords perl-Time-HiRes perl-Time-Local perl-constant perl-libs perl-macros perl-parent perl-podlators perl-threads perl-threads-shared
alpine lftp vsftpd
rear
)

yumdownloader --destdir $RPMDIR/ --resolve -y ${packages[@]}

# install web server to export local repo dir
# TODO use NFS instead
yum -y install \ # httpd wget curl \
  nano vim-enhanced \
  postgresql-server bareos bareos-database-postgresql bareos-server-conf \
  samba samba-client

# /export/nfs is used to store NFS backups
[[ ! -d /export/nfs ]] && mkdir -m 755 -p /export/nfs
# /export/archives is used to store sshfs or rsync backups
[[ ! -d /export/archives ]] && mkdir -m 755 -p /export/archives

cat > /etc/exports <<EOF
/export/nfs 192.168.0.0/16(rw,no_root_squash)
$RPMDIR 192.168.0.0/16(ro,no_root_squash)
EOF

# check if eth1 is UP
ip addr show dev eth1 | grep -q DOWN && systemctl restart network.service

# start the NFS service
systemctl start  nfs-idmapd rpcbind nfs-server
systemctl enable nfs-idmapd rpcbind nfs-server

echo "NFS exported file system on server:"
showmount -e

# install and configure postgres
echo "Installing and configuring postgresql"
# initialize the db
/bin/postgresql-setup initdb
# start postgres
systemctl enable postgresql.service
systemctl start postgresql.service

# install bareos RPMs
echo "Installing bareos server components"
# before doing the initialization of bareos tables make /etc/bareos readable for postgres user
chmod 755 /etc/bareos
chmod 644 /etc/bareos/*.conf

# configure bareos
echo "Configuring bareos Postgres tables"
su postgres -c /usr/lib/bareos/scripts/create_bareos_database
su postgres -c /usr/lib/bareos/scripts/make_bareos_tables
su postgres -c /usr/lib/bareos/scripts/grant_bareos_privileges

# start the bareos daemons
echo "Enabling and starting the Bareos daemons"
systemctl enable bareos-dir.service
systemctl enable bareos-sd.service
systemctl enable bareos-fd.service
systemctl start bareos-dir.service
systemctl start bareos-sd.service
systemctl start bareos-fd.service

# install samba server + basic config
yum install -y samba samba-client
systemctl start smb nmb
systemctl enable smb nmb
setsebool -P samba_enable_home_dirs on
restorecon -R /home/vagrant
# adding user vagrant into smb passwd file with passwd vagrant
printf "vagrant\nvagrant\n" | smbpasswd -s -a vagrant
# access share as "mount -t cifs  //server/homes /mnt -o username=vagrant"
# use "testparm -s" to view details of samba cinfig on system "server"

