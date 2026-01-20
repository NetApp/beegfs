Getting Started Guide for `beegfs_remote_sync`
=========

This guide will help you deploy and configure BeeGFS client nodes with remote sync capabilities using Ansible.

You'll use three main tools:

- **beegfs-client:** Mount and access BeeGFS file systems from your nodes.
- **beegfs-sync:** Synchronize files/directories between BeeGFS and other storage.
- **beegfs-remote:** Perform remote file operations (copy, move, manage) on BeeGFS storage.

You'll create the necessary Ansible playbooks, inventory, and host variable files to automate deployment and configuration.


Requirements
=========

Before you begin, ensure the following:

- **General:**
  - Review this collection's [README requirements](../../README.md#requirements).
  - Supported OS: Linux (Ubuntu, RHEL/CentOS, etc.).
  - Ansible 2.9+ (recommended).

- **BeeGFS:**
  - BeeGFS 8.0.0 or later available in your package repositories.
  - SELinux **must be disabled** (BeeGFS client does not support SELinux).
  - Required firewall ports for BeeGFS client communication **must be open**.
  See [BeeGFS network tuning](https://doc.beegfs.io/latest/advanced_topics/network_tuning.html#firewalls-network-address-translation-nat).
  - On Ubuntu, ensure `ca-certificates` is installed and up-to-date to avoid repository SSL errors.

- **Configuration:**
  - BeeGFS client must be installed and configured on any node running `beegfs-remote` or `beegfs-sync`.
  - Set `sysBypassFileAccessCheckOnMeta=true` in `/etc/beegfs/beegfs-client.conf` on those nodes.

- **High Availability (HA) and NetApp:**
  - If mounting BeeGFS backed by NetApp shared-disk HA,
  set `sysSessionChecksEnabled: false` in `beegfs_client_config` for each mount point.
  - Only set `sysSessionChecksEnabled: false` when underlying ext4/xfs filesystems are mounted
  with the `sync` option.
  See [details](https://git.beegfs.com/pub/v7/-/blob/master/client_module/build/dist/etc/beegfs-client.conf#L312).

  ```yaml
  beegfs_client_mounts:
    - sysMgmtdHost: <BeeGFS Management Server IP or Hostname>
      mount_point: /mnt/beegfs
      beegfs_client_config:
        sysSessionChecksEnabled: false
  ```


User Guide
=========

Before you start:

Deploy a BeeGFS HA building block as described in the BeeGFS HA Role README.


### 1. Clone the Deployment Template

git clone https://github.com/NetApp/beegfs.git ~/beegfs

### 2. Verify BeeGFS HA Building Blocks

Ensure BeeGFS HA building blocks are configured and operational.

Refer to `beegfs_cluster_building_blocks` folder to if the building blocks are not running.

```
cd ~/beegfs/beegfs_deployment_template/beegfs_cluster_building_blocks
```

### 3. Navigate to the `beegfs_remote_sync` Directory

```
cd ~/beegfs/beegfs_deployment_template/beegfs_remote_sync
```

### 4. Update Configuration Files

Edit the configuration files in the beegfs_remote_sync directory to match your environment (inventory, host variables, etc.).

### 5. Update the Password File

Edit `passwords.yml` in `beegfs_deployment_template/beegfs_cluster_building_blocks/global_params` and supply credentials.

**Important**:

  - Do not store credentials in plain text.
  - Use Ansible Vault to encrypt sensitive files.

### 6. Review and Update the Playbook

Edit the playbook in `beegfs_remote_sync` as needed for your deployment settings.

### 7. Install BeeGFS Client and beegfs-remote

Run the playbook to install and configure the client and remote services:

```
ansible-playbook -i beegfs_remote_inventory.yml beegfs_remote_playbook.yml
```

If using Ansible Vault:

```
ansible-playbook --ask-vault-pass -i beegfs_remote_inventory.yml beegfs_remote_playbook.yml
```

### 8. Install BeeGFS Client and beegfs-sync

Run the playbook to install and configure the client and sync services:

```
ansible-playbook -i beegfs_sync_inventory.yml beegfs_sync_playbook.yml
```

If using Ansible Vault:

```
ansible-playbook --ask-vault-pass -i beegfs_sync_inventory.yml beegfs_sync_playbook.yml
```


License
=========

GPL-2.0-or-later



Author Information
=========

- Vu Tran (@VuTran007)
