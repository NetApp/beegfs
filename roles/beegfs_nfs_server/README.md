# BeeGFS NFS Server

Install and manage a network file share (NFSv4) on hosts.


## Requirements

* NFS client supports version 4.2.
* NFS network already in place for BeeGFS NFS Server.
  * The network interfaces are already configured.
  * The firewall zone is already configured.
  * The firewall ports are open for NFS service to communicate.


## Dependencies

### Collections
* ansible.posix
* community.general


## Support Matrix

| Component              | Version        | Operating System             | Network Protocols  |
| ---------------------- | -------------- | ---------------------------- | ------------------ |
| NFS Server             | 4.2            | RHEL 9.3                     | TCP                |


## Supported Tags

None


## Variables

### Required

```
nfs_firewall_rule:                              # Define firewall rule for NFS services
  zone: `string: none`                          # Firewall zone. Ex: "beegfs"
  service: `string: nfs`                        # Firewall service.
  permanent: `bool: true`                       # Set to false to not persist after reboot

beegfs_nfs_server_exports:                      # Define NFS server export configuration
  - path: `string: none`                        # Define path for NFS export. Ex: "/mnt/beegfs"
    options: `string: none`                     # Define NFS export option. Ex: "rw,async,fsid=0,crossmnt,no_subtree_check,no_root_squash"
    mode: `int: 2770`                           # Define directory mode.
    owner: `string: root`                       # Define directory owner.
    group: `string: root`                       # Define group owner for directory.
    subnet_permissions:
      - `string: none`                          # Define subnet permissions. Ex: "*", "192.168.100.0/24"
```

#### Uninstall NFS server
```
beegfs_nfs_server_uninstall: `bool: false`      # Set to true to uninstall the beegfs_nfs_server role.
```

#### Refer to [defaults file](defaults/main.yml) for optional variables.


## Example Playbook

```
- hosts: beegfs_clients
  any_errors_fatal: true
  become: True
  vars:
    nfs_firewall_rule:
      zone: beegfs
      service: nfs
      permanent: true

    beegfs_nfs_server_exports:
      - path: /mnt/beegfs
        options: "rw,async,fsid=0,crossmnt,no_subtree_check,no_root_squash"
        mode: 2770
        owner: root
        group: root
        subnet_permissions:
          - "*"                   # allow all IPs to connect
          - 192.168.200.1/24      # allow only IPs in the specified subnet to connect

  tasks:
    - name: Install BeeGFS NFSv4 service on HA cluster
      import_role:
        name: beegfs_nfs_server
```

## Limitations

* Support only NFSv4 or newer


## Maintainer Information

- Nathan Swartz (@swartzn)
- Vu Tran (@VuTran007)
