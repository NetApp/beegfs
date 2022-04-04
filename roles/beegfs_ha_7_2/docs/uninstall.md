<a name="uninstall"></a>
# Uninstall
Uninstall will have the BeeGFS and HA applications, configuration, performance tunings, and mount points removed at 
the minimum.

<a name="table-of-contents"></a>
## Table of Contents
- [Uninstall](#uninstall)
  - [Table of Contents](#table-of-contents)
  - [How to Uninstall](#how-to-uninstall)
    - [Example Uninstall Playbook](#example-uninstall-playbook)
  - [General Notes](#general-notes)

<a name="how-to-uninstall"></a>
## How to Uninstall

The uninstall process requires the original inventory files used during the installation. Create an uninstall playbook 
if not already has one from the same directory as the install playbook and set `beegfs_ha_uninstall: true`.

By default, the `beegfs_ha_uninstall` variable is set to false. When it is set to true, the uninstall tasks will be 
executed. 

There are other additional `beegfs_ha_uninstall_x` variables that can be set to perform more vigorous clean-up of the 
systems. Please see the list of additional variables and their description at: 
[BeeGFS HA Defaults](../defaults/main.yml)

<a name="example-uninstall-playbook"></a>
### Example Uninstall Playbook

This playbook performs an uninstall of a BeeGFS HA instance where the BeeGFS HA services are unconfigured while the
provisioned storage is retained. This file would be created as `uninstall_beegfs_ha_playbook.yml`:

    - hosts: all
      collections:
        - netapp_eseries.beegfs
      tasks:
        - name: Ensure BeeGFS HA cluster is uninstalled.
          import_role:
            name: beegfs_ha_7_2
          vars:
            beegfs_ha_uninstall: true
            beegfs_ha_uninstall_unmap_volumes: false
            beegfs_ha_uninstall_wipe_format_volumes: false  # **WARNING: If set to true, this action is unrecoverable.**
            beegfs_ha_uninstall_delete_volumes: false  # **WARNING: If set to true, this action is unrecoverable.**
            beegfs_ha_uninstall_delete_storage_pools_and_host_mappings: false # **WARNING: If set to true, this action is unrecoverable.**
            beegfs_ha_uninstall_storage_setup: false
            beegfs_ha_uninstall_reboot: true

<a name="general-notes"></a>
## General Notes

If `beegfs_ha_uninstall_wipe_format_volumes: true` is not set, then when user performs a volumes delete and, 
subsequently, creates new volumes of the same size may result in recovering the original volume. While this is helpful 
if the volumes were unintentionally deleted, it can create mounting issues for the BeeGFS HA cluster nodes.
