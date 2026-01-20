netapp_eseries.beegfs.beegfs_sync
=========
```
This Ansible role automates the installation and configuration of beegfs-sync service, enabling
BeeGFS to synchronize files and directories with one or more S3-compatible remote storage targets.
```


Requirements
------------
```
- BeeGFS 8.0 or later must be available in your package repositories.
- The BeeGFS management, metadata, and storage services should be installed and configured if you
wish to integrate beegfs-sync with an existing BeeGFS cluster.
- TLS certificates and keys must be available for secure communication, unless you explicitly
disable TLS.
- The beegfs-client must be installed and configured on the node running beegfs-sync service.
- The following configuration must be set in /etc/beegfs/beegfs-client.conf
on the beegfs-sync node: `sysBypassFileAccessCheckOnMeta=true`

NOTE: Do not use the beegfs-client mounts on beegfs-sync nodes for other applications,
as these mounts allow access to files managed by the BeeGFS Data Management API.
```


Role Variables
--------------
```
For a list of all variables with default values, see [`defaults/main.yml`](defaults/main.yml)
```

- **`beegfs_version`** (type: `string`, required: `true`)
  - BeeGFS version to install.
  - Example:
    ```yaml
    beegfs_version: "beegfs_8.2"
    ```

- **`beegfs_sync_tls_config_options`** (type: `dict`, required: `true`)
  - Override `beegfs_sync_tls_config_defaults` parameters.
  - Set this variable to define the `alt_names` value.
    If `alt_names` is left empty, local certificates will be used.
    Otherwise, a self-signed certificate will be generated using the specified `alt_names`.
  - Set these variables if using local certificates.
    - `beegfs_sync_tls_cert_src_path`
    - `beegfs_sync_tls_key_src_path`
    - `beegfs_ca_cert_src_path`
  - Example:
    ``` yaml
    beegfs_sync_tls_config_options:
      common_name: beegfs_remote.netapp.com
      alt_names:
        - beegfs-mgmtd.example.com
        - 192.168.1.100
    ```

- **`beegfs_sync_config_options`** (type: `dict`, required: `true`)
  - Override `beegfs_sync_config_defaults` parameters.
  - Specify parameters in this variable using the same keys as those defined in beegfs-sync.toml.
  - Example:
    ```yaml
    beegfs_sync_config_options:
      mount-point: /mnt/beegfs_remote_sync

      log:
        level: 3
        type: syslog

      server:
        address: beegfs_sync_ip:9011
        tls-cert-file: /etc/beegfs/beegfs_sync/beegfs_sync_cert.pem
        tls-key-file: /etc/beegfs/beegfs_sync/beegfs_sync_key.pem
        tls-disable: false

      manager:
        journal-db: /var/lib/beegfs/sync/journal.badger
        job-db: /var/lib/beegfs/sync/job.badger

      remote:
        tls-cert-file: /etc/beegfs/beegfs_remote/beegfs_remote_cert.pem
        tls-disable-verification: false
        tls-disable: false
    ```

- **`rhel_version`** (type: `string`, required: `false`)
  - RHEL/CentOS version for repository URLs.
  - Example:
    ```yaml
    rhel_version: "rhel9"
    ```

- **`sles_version`** (type: `string`, required: `false`)
  - SUSE version for repository URLs.
  - Example:
    ```yaml
    sles_version: "sles15"
    ```


Dependencies
------------
```
- [netapp_eseries.santricity](https://galaxy.ansible.com/ui/repo/published/netapp_eseries/santricity/)
- [netapp_eseries.host](https://galaxy.ansible.com/ui/repo/published/netapp_eseries/host/)
```


Example Playbook
----------------
```
- hosts: beegfs_sync_node
  become: true
  roles:
    - role: netapp_eseries.beegfs.beegfs_sync
      vars:
        beegfs_tls_enabled: true
        beegfs_tls_config_options:
          common_name: netapp.com
          alt_names:
            - 10.0.0.100
        beegfs_sync_config_options:
          mount-point: /mnt/beegfs_remote_sync

          log:
            level: 3
            type: syslog

          server:
            address: "{{ ansible_host }}:9011"
            tls-cert-file: /etc/beegfs/beegfs_sync/beegfs_sync_cert.pem
            tls-key-file: /etc/beegfs/beegfs_sync/beegfs_sync_key.pem
            tls-disable: "{{ not beegfs_tls_enabled }}"

          manager:
            journal-db: /var/lib/beegfs/sync/journal.badger
            job-db: /var/lib/beegfs/sync/job.badger

          remote:
            tls-cert-file: /etc/beegfs/beegfs_remote/beegfs_remote_cert.pem
            tls-disable-verification: "{{ not beegfs_tls_enabled }}"
            tls-disable: "{{ not beegfs_tls_enabled }}"
```


License
-------
```
GPL-2.0-or-later
```


Author Information
------------------
```
- Vu Tran (@VuTran007)
```
