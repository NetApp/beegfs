## Table of Contents
1. Role Tags(#role-tags)

## Role Tags
---------
Use the following tags when executing you BeeGFS HA playbook to only execute select tasks:

        example: ansible-playbook -i inventory.yml playbook.yml --tags beegfs_ha_configure

    - storage                                    # Provisions storage and ensures volumes are presented on hosts.
    - storage_provision                          # Provision storage.
    - storage_communication                      # Setup communication protocol between storage and cluster nodes.
    - storage_format                             # Format all provisioned storage.
    - beegfs_ha                                  # All BeeGFS HA tasks (Ensure volumes have been presented to the cluster nodes).
    - beegfs_ha_package                          # All BeeGFS HA package tasks.
    - beegfs_ha_configure                        # All BeeGFS HA configuration tasks (Ensure volumes are present and BeeGFS packages are installed).
    - beegfs_ha_configure_resource               # All BeeGFS HA pacemaker resource tasks.
    - beegfs_ha_move_resource_to_preferred_node  # Restore all resources to their preferred nodes.
    - beegfs_ha_performance_tuning               # All BeeGFS HA performance tuning tasks (Ensure volumes are present and BeeGFS packages are installed).
    - beegfs_ha_backup                           # Backup Pacemaker and Corosync configuration files.
    - beegfs_ha_client                           # Configures BeeGFS clients (Ensure BeeGFS is configured and running).