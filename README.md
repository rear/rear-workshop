# Relax-and-Recover (ReaR) Workshop

:author: Gratien Dhaese <gratien.dhaese@gmail.com>

The Relax-and-Recover (ReaR) workshop is guiding you into setting up rear, how to configure it, and with lots of real use cases, such as with Bareos, NFS, CIFS, RSYNC.

## Setting up your virtual machines

This document was only tested for the KVM and VirtualBox hypervisors, but it should work fine with other hypervisors.

I would really appreciate that you test your hypervisor of choice and contribute instructions back (at https://github.com/rear/rear-workshop/pulls).

A few words before going to the prerequisites - we use **vagrant** as digital assitant to setup up our virtual images (VMs) to play with rear. Why? Because, in order to speed up the workshop around rear we do install lots of software automatically in the client and server VMs.

Why use Vagrant to play with rear? Vagrant is a widely used amongst developers to create virtualized environments which can be used to setup test labs, to play around without the need to install from scratch a VM, and to screw it up completey without any impact on your host computer itself. Afterwards, the VMs can be deleted and/or rebuild. All of this is possible by a single command: *vagrant*

To give an example, when you have setup the _client_ and _server_ VMs by running *vagrant up* the _server_ VM contains a working Bareos backup environment, and the _client_ VM can simple make a full backup towards the _server_ VM without any additional steps or commands to execute. This is done in order to avoid any installation or configuration issues with Bareos. Especially, the workshop is around **the usage of rear** and not Bareos. We need to concentrate on the possibilities that rear offers. To avoid distractions of minor (or major) system administration tasks this is all done automatically via vagrant and its provisioning capabilities (via scripting). This might become food for another talk - how the hell did we achieve this?

## Prerequisites

Before we can start with the content of the workshop you need several things:

 - Host system can be Linux, Mac, Windows
 - A hypervisor like KVM, Oracle VirtualBox, VMware Player or VMware Fusion, Parallels Desktop
 - Install *vagrant* from your distribution or when not present from https://www.vagrantup.com/downloads.html
 - KVM with libvirt needs the *vagrant-libvirt* plugin:  _vagrant plugin install vagrant-libvirt_
 - Install *git* to download the workshop: _git clone https://github.com/rear/rear-workshop.git_
   or _git clone git@github.com:rear/rear-workshop.git_
 - Sufficient free disk space for 3 VMs (about 3G per virtual machine should do)
 - Optional, vncviewer to approach the recover VM

## Downloading the centos/7 box with vagrant

It is important to do these steps before going to the workshop so we do not waste time downloading the centos7 image. Furthermore, during the first time start up of vagrant with the centos7 vagrantfile all dependencies will be downloaded so that the _client_ and _server_ system are ready for the workshop. This takes quite some time (20 minutes or more).

At this point we assume you have a hypervisor and vagrant already installed. Also, the +git+ command is avaliable.
Start with downloading the workshop:

<pre>
$ git clone https://github.com/rear/rear-workshop.git
Cloning into 'rear-workshop'...
remote: Counting objects: 160, done.
remote: Total 160 (delta 0), reused 0 (delta 0), pack-reused 160
Receiving objects: 100% (160/160), 40.76 KiB | 0 bytes/s, done.
Resolving deltas: 100% (89/89), done.
Checking connectivity... done.
</pre>

Then, browse into:

<pre>
$ cd rear-workshop/centos7/
$ ls
nodeconfig-centos7.sh  provision-centos7.sh  Vagrantfile  Vagrantfile.libvirt.recover  Vagrantfile.virtualbox.recover
</pre>

And, let do vagrant its job:

<pre>
$ vagrant up
Bringing machine 'client' up with 'virtualbox' provider...
Bringing machine 'server' up with 'virtualbox' provider...
==> client: Box 'centos/7' could not be found. Attempting to find and install...
    client: Box Provider: virtualbox
    client: Box Version: >= 0
==> client: Loading metadata for box 'centos/7'
    client: URL: https://atlas.hashicorp.com/centos/7
==> client: Adding box 'centos/7' (v1607.01) for provider: virtualbox
    client: Downloading: https://atlas.hashicorp.com/centos/boxes/7/versions/1607.01/providers/virtualbox.box
    client: Progress: 1% (Rate: 606k/s, Estimated time remaining: 0:14:57)
==> client: Successfully added box 'centos/7' (v1607.01) for 'virtualbox'!
==> client: Importing base box 'centos/7'...
==> client: Matching MAC address for NAT networking...
==> client: Checking if box 'centos/7' is up to date...
==> client: Setting the name of the VM: centos7_client_1470826828474_34068
==> client: Clearing any previously set network interfaces...
==> client: Preparing network interfaces based on configuration...
    client: Adapter 1: nat
    client: Adapter 2: hostonly
==> client: Forwarding ports...
    client: 22 (guest) => 2222 (host) (adapter 1)
==> client: Booting VM...
==> client: Waiting for machine to boot. This may take a few minutes...
    client: SSH address: 127.0.0.1:2222
    client: SSH username: vagrant
    client: SSH auth method: private key

and so on....you will see lots of lines flying by (also for the server vm)

==> server: Complete!
==> server: Created symlink from /etc/systemd/system/multi-user.target.wants/smb.service to /usr/lib/systemd/system/smb.service.
==> server: Created symlink from /etc/systemd/system/multi-user.target.wants/nmb.service to /usr/lib/systemd/system/nmb.service.
==> server: Added user vagrant.
</pre>

## Login to the vagrant VMs

There are several possibilities to login onto these fresh created VMs:

 - vagrant ssh {client|server}
 - ssh vagrant@192.168.33.10  (password vagrant and this is the _client_)
 - ssh vagrant@192.168.33.15  (password vagrant and this is the _server_)
 - vncviewer 127.0.0.1:5991   (for the client interface)
 - vncviewer 127.0.0.1:5992   (for the server interface)
 - vncviewer 127.0.0.1:5993   (for the recover interface)
 - Or, via the VM console of your hypervisor

The passwords for the _vagrant_ and _root_ user are the same: *vagrant*

As _vagrant_ user you can easily become _root_ via *sudo su* (the rules are pre-configured).

Now, you are ready to attend the workshop without losing time to set it up from scratch.
The lab exercises are *not yet* uploaded as otherwise nobody would attend the workshop - makes sense, no?

## Halting the VMs

Is quite simple: *vagrant halt* (see also *vagrant -h* for more options)

## Cleaning up the VMs

When you are done with the labs you can simply destroy all the VMs by *vagrant destroy*

And, the vagrant box can be removed as *vagrant box remove centos/7*

# Encountered a problem with setting up the workshop

Oops, please open a new issue at https://github.com/rear/rear-workshop/issues

# Known Issues

## Windows 10 with cygwin may exit with rsync error

When you get to see an error like the following:

<pre>
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
</pre>

Then go check and follow the advise mentioned in issue https://github.com/mitchellh/vagrant/issues/6702 and restart as *vagrant up --provision*


## Author: Gratien D'haese

If you need to contact me for setting a workshop on your premises then see the possibilities at http://it3.be/rear-support/index.html

Be aware, this workshop uses *centos/7* as GNU/Linux Operating system. If you want to have it for another version or type of GNU/Linux then you have to pay for it (consultancy fee - see above link).

Last updated: 30 December 2016
