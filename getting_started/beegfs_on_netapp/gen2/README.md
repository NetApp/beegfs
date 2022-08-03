BeeGFS on NetApp Verified Architecture: Gen2 Sample Deployment
==================================================================================

This directory contains a complete example of the Ansible inventory assembled in the deployment guide for the second
generation [BeeGFS on NetApp Verified Architecture (NVA)](https://docs.netapp.com/us-en/beegfs/index.html). It is meant
as a companion reference for anyone following the deployment guide who wants to see the final inventory all in one
place. It can also serve as a starting point for anyone going through the steps to deploy a BeeGFS file system following
the gen2 building block design, even if the quantity and configuration profile for each building block differs.

Quick Start
-----------

This section describes the minimum updates needed to this Ansible inventory if you wanted to deploy a BeeGFS file system
that matches the NVA exactly. This requires you to use the Lenovo SR665 as your file nodes and NetApp EF600 as your
block nodes and deploy the following building blocks:

* One base building block running BeeGFS management, metadata, and storage services. 
* One building block running BeeGFS metadata and storage services.
* One building block running only BeeGFS storage services.

IMPORTANT: When updating the Ansible inventory the following variables can optionally be omitted and specified when you
run the playbook using --extra-vars: `--extra-vars "ansible_become_password=<PASSWORD>
eseries_system_password=<PASSWORD>`. This is generally recommended over storing passwords in plaintext, especially for
production systems. To avoid commands containing passwords from showing up in the bash history you can first run
`HISTCONTROL=ignoreboth` then add a leading space character to the command (example: ` ansible-playbook ...`).

Alternatively you can use [ansible-vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html) to securely
store your passwords.

### Step 1: Update the inventory for your environment: 

On the system you want to use as your [Ansible control
node](https://docs.netapp.com/us-en/beegfs/beegfs-deploy-setting-up-an-ansible-control-node.html):

* In a new empty directory download this example inventory. This can be done with the following one-liner: `git clone -b
release-3.0.1 --single-branch https://github.com/netappeseries/beegfs.git && cp -r
beegfs/getting_started/beegfs_on_netapp/gen2/* . && rm -rf beegfs`

* Update `inventory.yml`, `client_inventory.yml` and rename the files in `host_vars/` with appropriate hostnames for
  your environment. They are currently named so: 
  * All block nodes start with: ictad22a
  * All file nodes start with: ictad22h
  * All clients start with: ictad21h

* In all of the inventory files for clients and file nodes (starting with ictad21hXX or ictad22hXX) under `host_vars/`
  update `<MANAGEMENT_IP>` or remove `ansible_host` entirely if the hostnames are resolvable from your Ansible control
  node.
  * Note: If you remove `ansible_host`, also update `beegfs_ha_cluster_node_ips` in each of the inventory files for the
    file nodes to replace `<MANAGEMENT_IP>` with the hostname.

* In `group_vars/eseries_storage_systems.yml`:
  * Reference the note to download the desired E-Series firmware, NVSRAM, and drive firmware to a new `packages/`
    directory. 
  * Fill in all text in angled (<>) brackets.

* In `group_vars/ha_cluster.yml`: 
  * Fill in all text in angled brackets, including selecting/configuring a fencing agent referencing the comments in the
    file.
  * Download the packages listed for OpenSM from Mellanox's website to `packages/`:
```
  curl -o packages/opensm-libs-5.9.0.MLNX20210617.c9f2ade-0.1.54103.x86_64.rpm https://linux.mellanox.com/public/repo/mlnx_ofed/5.4-1.0.3.0/rhel8.4/x86_64/opensm-libs-5.9.0.MLNX20210617.c9f2ade-0.1.54103.x86_64.rpm
  curl -o packages/opensm-5.9.0.MLNX20210617.c9f2ade-0.1.54103.x86_64.rpm https://linux.mellanox.com/public/repo/mlnx_ofed/5.4-1.0.3.0/rhel8.4/x86_64/opensm-5.9.0.MLNX20210617.c9f2ade-0.1.54103.x86_64.rpm
```
* In `client_inventory.yml` fill in all text in angled brackets. Review the comments and uncomment or change any
  variables depending on the desired configuration.

* At this point it is strongly recommended you store your inventory in Git to track changes over time, and avoid losing
  the inventory if the Ansible control node crashes.

### Step 2: Setup passwordless SSH from the Ansible control node to all file nodes and clients

* If needed on your Ansible control node run `ssh-keygen`. 

* On your Ansible control node for each file node and client in your inventory run `ssh-copy-id
  <USER>@<HOSTNAME_OR_IP>`.
  * IMPORTANT: Do not setup passwordless SSH to your block nodes.

### Step 3: Execute the playbook to deploy the BeeGFS file system: 

* With the current working directory set to the Ansible inventory run: `ansible-playbook -i inventory.yml playbook.yml`

  * If you choose to specify passwords using extra-vars run: `ansible-playbook -i inventory.yml playbook.yml
  --extra-vars "ansible_become_password=<PASSWORD> eseries_system_password=<PASSWORD>`

### Step 4: Execute the playbook to configure the BeeGFS clients: 

* With the current working directory set to the Ansible inventory run: `ansible-playbook -i client_inventory.yml
  client_playbook.yml`

  * If you choose to specify passwords using extra-vars run: `ansible-playbook -i client_inventory.yml
  client_playbook.yml --extra-vars "ansible_become_password=<PASSWORD>`

* After deploying, it is strongly recommended you run `beegfs-fsck --checkfs` from one of the clients to ensure that all
  nodes are reachable and there are no issues reported.
