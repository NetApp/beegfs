<a name="getting-started-guide-for-latest-netappeseriesbeegfsbeegfsclient-role"></a>
# Getting Started Guide for beegfs_client

The client role can be used to install the BeeGFS client on a node and, if requested, can mount one or more beeGFS file
systems (or the same file system multiple times). The role can also unmount one or more BeeGFS file systems if
requested. The following instructions will guide a user through creating the playbook, inventory, and host variables
files neccesary to configure clients for access to their BeeGFS storage cluster.

<a name="requirements"></a>
## Requirements
* Adhere to the requirements outlined in this collection's [README](../../README.md#requirements) prior to following
these instructions.
* To configure NTP on the client servers during deployment, you need to install the `geerlingguy.ntp` role to your
control node using the following command: `ansible-galaxy role install geerlingguy.ntp`
* The BeeGFS client [does not currently support SELinux](https://doc.beegfs.io/latest/trouble_shooting/general.html#access-denied-error-on-the-client-even-with-correct-permissions) so it must be disabled before running the role.
* The firewall ports used by the BeeGFS client for communication must not be blocked. The default TCP/UDP ports [can be
found here](https://doc.beegfs.io/latest/advanced_topics/network_tuning.html#firewalls-network-address-translation-nat),
and optionally overridden as part of mounting BeeGFS using this role (see beegfs_client_config below).
* When installing the BeeGFS client to Ubuntu, the ca-certificates package must be installed, or an error like the
following will occur when attempting to add the BeeGFS repository using apt: `Certificate verification failed: The
certificate is NOT trusted. The certificate chain uses expired certificate.  Could not handshake: Error in the
certificate verification. [IP: 178.254.21.65 443]`. If you still get this error with ca-certificates installed try
updating the package.

**IMPORTANT**: When using the BeeGFS client role to mount a BeeGFS filesystem backed by NetApp's shared-disk high
availability solution, `sysSessionChecksEnabled` must be set to false in the `beegfs_client_config` for each mount
point.This will prevent clients from reporting "remote I/O" errors if a storage service crashes and is restarted on
another node. In addition, to prevent silent data corruption, `sysSessionChecksEnabled: false` must only be set when the
underlying ext4/xfs filesystems used for BeeGFS management, metadata, and storage targets are mounted using the 'sync'
option. By default, the beegfs_ha* roles in this collection mount targets in 'sync' mode, but there are options
available to override this default behavior and deploy with the storage targets' 'sync' mode disabled. Read more about
this requirement [here](https://git.beegfs.com/pub/v7/-/blob/master/client_module/build/dist/etc/beegfs-client.conf#L312).

```
beegfs_client_mounts:
  - sysMgmtdHost: <BeeGFS Management Server IP or Hostname>
    mount_point: /mnt/beegfs
    beegfs_client_config:
      sysSessionChecksEnabled: false
```

<a name="user-guide"></a>
## User Guide

The following instructions build on the BeeGFS HA Role's [README](../beegfs_ha_building_block/README.md). Before you can
use this role to mount a BeeGFS filesystem to the client, you must first deploy a BeeGFS HA building block.

<a name="navigate-to-the-beegfsclient-directory"></a>
### 1. Navigate to the 'beegfs_client' Directory

From your Ansible control node, navigate to your project's `beegfs_client` subdirectory. 
For example:

```
cd ~/<project_name>/beegfs_client
```

If the `beegfs_client` directory does not exist, you can clone the playbooks files from NetApp's BeeGFS Collection by
following the instructions from the BeeGFS HA building block [README]](../beegfs_ha_building_block/README.md#1-clone-the-playbooks-directory).

<a name="create-or-update-client-host-variables"></a>
### 2. Create or Update Client Host Variables

In the `host_vars` directory, create a separate file for each BeeGFS client that you want to configure. Name the file
according to the client as `<hostname>.yml`. Example host variable files are provided by default to assist with creating
your environment. In the examples only the client's management IP address needs to be populated. Modify the host
variable files or create new ones according to your environment.

<a name="create-or-update-the-inventory-file"></a>
### 3. Create or Update the Inventory File

From the `beegfs_client` directory, update the `beegfs_client_inventory.yml` file to match your environment, or
alternatively, you can create a custom inventory file. Additional client variables can be found in the BeeGFS Client
Role [README](../../../roles/beegfs_client/README.md).

<a name="review-the-password-configuration-file"></a>
### 4. Update the Password Configuration File

Modify the `passwords.yml` file in the `beegfs_client/group_vars/all` directory. Supply credentials in the required
fields. It is not recommended to store these credentials in plain text. Use
[Ansible Vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html) to encrypt the passwords file.

<a name="create-or-update-the-playbook"></a>
### 5. Update the Playbook File

From the `beegfs_client` directory, located the `beegfs_client_playbook.yml` playbook file. Review the playbook and, if
needed, update it according to your desired deployment settings.

<a name="install-the-client-and-mount-beegfs"></a>
### 6. Install the Client and Mount BeeGFS

Once you have configured the host variables, inventory, credentials, and playbook to match your environment, you can run
the following command to install the client services and mount BeeGFS:

```
ansible-playbook -i beegfs_client_inventory.yml beegfs_client_playbook.yml
```

Note: If utilizing Ansible Vault, you must include the `--ask-vault-pass` parameter to the playbook command.

<a name="license"></a>
## License

BSD

<a name="maintainer-information"></a>
## Maintainer Information

- Christian Whiteside (@mcwhiteside)
- Vu Tran (@VuTran007)
