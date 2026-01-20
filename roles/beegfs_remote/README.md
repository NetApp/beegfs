netapp_eseries.beegfs.beegfs_remote
=========
```
This Ansible role automates the installation and configuration of beegfs-remote service, enabling
BeeGFS to synchronize files and directories with one or more S3-compatible remote storage targets.
```


Requirements
------------
```
- BeeGFS 8.0 or later must be available in your package repositories.
- The BeeGFS management, metadata, and storage services should be installed and configured if you
wish to integrate beegfs-remote with an existing BeeGFS cluster.
- TLS certificates and keys must be available for secure communication, unless you explicitly
disable TLS.
- The beegfs-client must be installed and configured on the node running beegfs-remote service.
- The following configuration must be set in /etc/beegfs/beegfs-client.conf
on the beegfs-remote node: `sysBypassFileAccessCheckOnMeta=true`

NOTE: Do not use the beegfs-client mounts on beegfs-remote nodes for other applications,
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

- **`beegfs_remote_tls_config_options`** (type: `dict`, required: `true`)
  - Override `beegfs_remote_tls_config_defaults` parameters.
  - Set this variable to define the `alt_names` value.
    If `alt_names` is left empty, local certificates will be used.
    Otherwise, a self-signed certificate will be generated using the specified `alt_names`.
  - Set these variables if using local certificates.
    - `beegfs_remote_tls_cert_src_path`
    - `beegfs_remote_tls_key_src_path`
    - `beegfs_ca_cert_src_path`
  - Example:
    ``` yaml
    beegfs_remote_tls_config_options:
      common_name: beegfs_remote.netapp.com
      alt_names:
        - beegfs-mgmtd.example.com
        - 192.168.1.100
    ```

- **`beegfs_remote_config_options`** (type: `dict`, required: `true`)
  - Override `beegfs_remote_config_defaults` parameters.
  - Set this variable to configure the list of `workers` and `remote-storage-targets`.
  - Specify parameters in this variable using the same keys as those defined in beegfs-remote.toml.
  - Example:
    ```yaml
    beegfs_remote_config_options:
      mount-point: /mnt/beegfs_remote_sync
      management:
        address: beegfs_mgmtd_ip:8010
        auth-file: /etc/beegfs/conn.auth
        tls-cert-file: /etc/beegfs/cert.pem
        tls-disable-verification: false
        tls-disable: false
      log:
        level: 3
        type: syslog
      server:
        address: beegfs_remote_ip:9010
        tls-cert-file: /etc/beegfs/beegfs_remote/beegfs_remote_cert.pem
        tls-key-file: /etc/beegfs/beegfs_remote/beegfs_remote_key.pem
        tls-disable: false
      job:
        path-db: /var/lib/beegfs/remote/path.badger
      workers:
        - id: 1
          name: beesync-01
          type: beesync
          address: beegfs_sync_ip:9011
          tls-cert-file: /etc/beegfs/beegfs_sync/beegfs_sync_cert.pem
          tls-disable-verification: false
          tls-disable: false
      remote-storage-targets:
        - id: 1
          name: storageGRID
          policies:
            FastStartMaxSize: 104857600
          s3.endpoint-url: http://sgdemo.netapp.com:10444
          s3.region: us-east-1
          s3.bucket: beegfs-export
          s3.access-key: access_key
          s3.secret-key: secret_key
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
- hosts: beegfs_remote_node
  become: true
  roles:
    - role: netapp_eseries.beegfs.beegfs_remote
      vars:
        beegfs_tls_enabled: true
        beegfs_tls_config_options:
          common_name: netapp.com
          alt_names:
            - 10.0.0.100
        beegfs_remote_config_options:
          mount-point: /mnt/beegfs_remote_sync
          management:
            address: "{{ beegfs_ha_mgmtd_floating_ip }}:8010"
            auth-file: "/etc/beegfs/conn.auth"
            tls-cert-file: "/etc/beegfs/beegfs_mgmtd_cert.pem"
          server:
            address: 0.0.0.0:9010
            tls-cert-file: /etc/beegfs/beegfs_remote/beegfs_remote_cert.pem
            tls-key-file: /etc/beegfs/beegfs_remote/beegfs_remote_key.pem
          job:
            path-db: /var/lib/beegfs/remote/path.badger
          workers:
            - id: 1
              name: beesync-01
              type: beesync
              address: 10.0.0.1:9011
              tls-cert-file: /etc/beegfs/beegfs_sync/beegfs_sync_cert.pem
          remote-storage-targets:
            - id: 1
              name: "storageGRID"
              policies:
                FastStartMaxSize: 104857600
              s3.endpoint-url: "http://sgdemo.netapp.com:10444"
              s3.region: "us-east-1"
              s3.bucket: "beegfs-export"
              s3.access-key: "access_key"
              s3.secret-key: "secret_key"
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
