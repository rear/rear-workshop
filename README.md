# Relax-and-Recover (ReaR) Workshop

The Relax-and-Recover (ReaR) workshop is guiding you into setting up rear, how to configure it, and with lots of real use cases, such as with Bareos, NFS, CIFS, RSYNC.

## Setting up your virtual machines

This workshop uses the VirtualBox as hypervisor, we can add support for other hypervisors upon request. You can also contribute instructions about other hypervisors back (at https://github.com/rear/rear-workshop/pulls).

A few words before going to the prerequisites - we use **[vagrant](https://vagrantup.com)** as digital assistant to setup up our virtual images (VMs) to play with ReaR. Why? Because, in order to speed up the workshop around ReaR we do install lots of software automatically in the client and server VMs.

Why use Vagrant to play with ReaR? Vagrant is a widely used amongst developers to create virtualized environments which can be used to setup test labs, to play around without the need to install from scratch a VM, and to screw it up completey without any impact on your host computer itself. Afterwards, the VMs can be deleted and/or rebuild. All of this is possible by a single command, `vagrant`.

To give an example, when you have setup the _client_ and _server_ VMs by running `vagrant up`, the _server_ VM contains a working Bareos backup environment, and the _client_ VM can simple make a full backup towards the _server_ VM without any additional steps or commands to execute. This is done in order to avoid any installation or configuration issues with Bareos. Especially, the workshop is around **the usage of ReaR** and not Bareos. We need to concentrate on the possibilities that ReaR offers. To avoid distractions of minor (or major) system administration tasks this is all done automatically via vagrant and its provisioning capabilities (via scripting).

## Prerequisites

Before we can start with the content of the workshop you need several things:

 - Host system can be Linux, Mac, Windows
 - Your system supports and is configured to use CPU virtualization. This setting is typically configured through your system's BIOS
 - At least 15GB of free disk space so that you can download the base images and run a few virtual machine instances
 - At least 4GB of available memory
 - [Oracle VirtualBox](https://www.virtualbox.org/) ≥ 5.0
 - [vagrant](https://www.vagrantup.com/downloads.html) ≥ 1.9.4
 - Download these [workshop files](https://github.com/rear/rear-workshop/archive/master.zip)

## Operating System

As ReaR supports practically all Linux OS, the workshop could be held with the OS of choice of the participants. However, the automation provided here is for CentOS 7 only (in `centos7/`).

As part of a custom workshop we can of course use your OS of choice instead.

## Downloading the OS boxes with vagrant

It is important to do the following steps before going to the workshop so we do not spend so much time downloading the OS images. Furthermore, during the first time start up of vagrant with the Vagrantfile all dependencies will be downloaded so that the _client_ and _server_ system are ready for the workshop. This takes quite some time (up to 20 minutes, download size ca. 1 GB).

<details>
<summary>Download `https://github.com/rear/rear-workshop/archive/master.zip` and unzip it somewhere.</summary>

```
$ wget https://github.com/rear/rear-workshop/archive/master.zip
--2017-05-09 16:12:13--  https://github.com/rear/rear-workshop/archive/master.zip
Resolving github.com (github.com)... 192.30.253.112, 192.30.253.113
Connecting to github.com (github.com)|192.30.253.112|:443... connected.
HTTP request sent, awaiting response... 302 Found
Location: https://codeload.github.com/rear/rear-workshop/zip/master [following]
--2017-05-09 16:12:15--  https://codeload.github.com/rear/rear-workshop/zip/master
Resolving codeload.github.com (codeload.github.com)... 192.30.253.120, 192.30.253.121
Connecting to codeload.github.com (codeload.github.com)|192.30.253.120|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 45070 (44K) [application/zip]
Saving to: ‘master.zip’

master.zip                                 100%[======================================================================================>]  44,01K   190KB/s    in 0,2s    

2017-05-09 16:12:16 (190 KB/s) - ‘master.zip’ saved [45070/45070]

$ unzip master.zip
Archive:  master.zip
0aa2e086f03bb85976df7fcc96db2d810a9a58e4
   creating: rear-workshop-master/
 extracting: rear-workshop-master/.gitignore  
  inflating: rear-workshop-master/LICENSE  
  inflating: rear-workshop-master/README.md  
   creating: rear-workshop-master/centos7/
  inflating: rear-workshop-master/centos7/Vagrantfile  
  inflating: rear-workshop-master/centos7/Vagrantfile.libvirt.recover  
  inflating: rear-workshop-master/centos7/provision-centos7-client.sh  
  inflating: rear-workshop-master/centos7/provision-centos7-server.sh  
  inflating: rear-workshop-master/centos7/provision-centos7.sh  
   creating: rear-workshop-master/insecure_keys/
  inflating: rear-workshop-master/insecure_keys/vagrant.private  
  inflating: rear-workshop-master/insecure_keys/vagrant.public  
   creating: rear-workshop-master/src/
   creating: rear-workshop-master/src/bareos-client-conf/
 extracting: rear-workshop-master/src/bareos-client-conf/Makefile  
  inflating: rear-workshop-master/src/bareos-client-conf/bareos-client-conf.spec  
  inflating: rear-workshop-master/src/bareos-client-conf/bareos-fd.conf  
  inflating: rear-workshop-master/src/bareos-client-conf/bconsole.conf.install  
   creating: rear-workshop-master/src/bareos-server-conf/
 extracting: rear-workshop-master/src/bareos-server-conf/Makefile  
  inflating: rear-workshop-master/src/bareos-server-conf/bareos-dir.conf  
   creating: rear-workshop-master/src/bareos-server-conf/bareos-dir.d/
  inflating: rear-workshop-master/src/bareos-server-conf/bareos-dir.d/client.conf  
  inflating: rear-workshop-master/src/bareos-server-conf/bareos-fd.conf  
  inflating: rear-workshop-master/src/bareos-server-conf/bareos-sd.conf  
  inflating: rear-workshop-master/src/bareos-server-conf/bareos-server-conf.spec  
  inflating: rear-workshop-master/src/bareos-server-conf/bconsole.conf.install  
  inflating: rear-workshop-master/src/common.Makefile  
   creating: rear-workshop-master/src/rear-workshop/
  inflating: rear-workshop-master/src/rear-workshop/.cifs  
 extracting: rear-workshop-master/src/rear-workshop/Makefile  
  inflating: rear-workshop-master/src/rear-workshop/README  
  inflating: rear-workshop-master/src/rear-workshop/local-with-bareos.conf  
  inflating: rear-workshop-master/src/rear-workshop/local-with-cifs.conf  
  inflating: rear-workshop-master/src/rear-workshop/local-with-dir-excludes.conf  
  inflating: rear-workshop-master/src/rear-workshop/local-with-nfs.conf  
  inflating: rear-workshop-master/src/rear-workshop/local-with-rsync.conf  
  inflating: rear-workshop-master/src/rear-workshop/local-with-sshfs.conf  
  inflating: rear-workshop-master/src/rear-workshop/rear-workshop.spec  
```
</details>

<p/>
Change into the working directory:

```
$ cd rear-workshop-master/centos7
```

And let Vagrant to its job:

```
$ vagrant up
```

## Login to the vagrant VMs

There are several possibilities to login onto these freshly created VMs:

 - vagrant ssh {client|server}
 - ssh vagrant@192.168.33.10  (password vagrant and this is the _client_)
 - ssh vagrant@192.168.33.15  (password vagrant and this is the _server_)
 - Or, start VirtualBox and use the console

The passwords for the _vagrant_ and _root_ user are the same: *vagrant*

As _vagrant_ user you can easily become _root_ via *sudo su* (the rules are pre-configured).

Now, you are ready to attend the workshop without losing time to set it up from scratch.

## Halting the VMs

Is quite simple: `vagrant halt` (see also `vagrant -h` for more options). Bring them backup with `vagrant up --no-provision`

## Cleaning up the VMs

When you are done with the labs you can simply destroy all the VMs by `vagrant destroy`

And, the vagrant box can be removed as `vagrant box remove centos/7 ; vagrant box remove bento/centos-7.3`

# Encountered a problem with setting up the workshop

Oops, please open a new issue at https://github.com/rear/rear-workshop/issues

# Known Issues

## `vagrant` fails with Ruby gem error

Observed especially with vagrant 1.9.4, see https://github.com/mitchellh/vagrant/issues/8519 for background info, the fix is

```
vagrant plugin install vagrant-share --plugin-version 1.1.8
```

## `vagrant up client` fails with network error

<details><summary>
Observed when **recover** VM is still running. Click for details.
</summary>

```
$ vagrant up client
Bringing machine 'client' up with 'virtualbox' provider...
==> client: Importing base box 'centos/7'...
==> client: Matching MAC address for NAT networking...
==> client: Checking if box 'centos/7' is up to date...
==> client: Setting the name of the VM: centos7_client_1494411878038_54569
==> client: Fixed port collision for 22 => 2222. Now on port 2200.
==> client: Clearing any previously set network interfaces...
==> client: Preparing network interfaces based on configuration...
    client: Adapter 1: nat
    client: Adapter 2: hostonly
==> client: Forwarding ports...
    client: 22 (guest) => 2200 (host) (adapter 1)
==> client: Booting VM...
==> client: Waiting for machine to boot. This may take a few minutes...
    client: SSH address: 127.0.0.1:2200
    client: SSH username: vagrant
    client: SSH auth method: private key
==> client: Machine booted and ready!
==> client: Checking for guest additions in VM...
    client: No guest additions were detected on the base box for this VM! Guest
    client: additions are required for forwarded ports, shared folders, host only
    client: networking, and more. If SSH fails on this machine, please install
    client: the guest additions and repackage the box to continue.
    client:
    client: This is not an error message; everything may continue to work properly,
    client: in which case you may ignore this message.
==> client: Setting hostname...
==> client: Configuring and enabling network interfaces...
The following SSH command responded with a non-zero exit status.
Vagrant assumes that this means the command failed!

# Down the interface before munging the config file. This might
# fail if the interface is not actually set up yet so ignore
# errors.
/sbin/ifdown 'eth1'
# Move new config into place
mv -f '/tmp/vagrant-network-entry-eth1-1494411902-0' '/etc/sysconfig/network-scripts/ifcfg-eth1'
# attempt to force network manager to reload configurations
nmcli c reload || true

# Restart network
service network restart


Stdout from the command:

Restarting network (via systemctl):  [FAILED]


Stderr from the command:

usage: ifdown <configuration>
Job for network.service failed because the control process exited with error code. See "systemctl status network.service" and "journalctl -xe" for details.

```
</details>

To solve simply kill the recover VM with `vagrant destroy recover -f`

## Windows 10 with cygwin may exit with rsync error

When you get to see an error like the following:

```
=> client: Rsyncing folder: /home/grati/rear-workshop/centos7/ => /vagrant
There was an error when attempting to rsync a synced folder.
Please inspect the error message below for more info.

Host path: /home/grati/rear-workshop/centos7/
Guest path: /vagrant
Command: rsync --verbose --archive --delete -z --copy-links --chmod=ugo=rwX --no-perms --no-owner --no-group --rsync-path sudo rsync -e ssh -p 2222 -o ControlMaster=auto -o ControlPath=C:/cygwin64/tmp/ssh.977 -o ControlPersist=10m -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o UserKnownHostsFile=/dev/null -i 'C:/cygwin64/home/grati/rear-workshop/insecure_keys/vagrant.private' --exclude .vagrant/ /home/grati/rear-workshop/centos7/ vagrant@127.0.0.1:/vagrant
Error: Warning: Permanently added '[127.0.0.1]:2222' (ECDSA) to the list of known hosts.
mm_receive_fd: no message header
process_mux_new_session: failed to receive fd 0 from slave
mux_client_request_session: read from master failed: Connection reset by peer
Failed to connect to new control master
rsync: connection unexpectedly closed (0 bytes received so far) [sender]
rsync error: error in rsync protocol data stream (code 12) at io.c(226) [sender=3.1.2]
```

Then go check and follow the advise mentioned in issue https://github.com/mitchellh/vagrant/issues/6702 and restart as *vagrant up --provision*


## Authors: Gratien D'haese & Schlomo Schapiro

If you need to contact us for setting a workshop on your premises then see the possibilities at http://relax-and-recover.org/support/

Be aware, this workshop uses *centos/7* as GNU/Linux Operating system. If you want to have it for another version or type of GNU/Linux then that can be part of the consulting engagement.