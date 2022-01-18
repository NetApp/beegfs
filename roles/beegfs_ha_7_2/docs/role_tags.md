# Role Tags
The BeeGFS HA Role has a set of tags that can be used to perform a subset of tasks instead of running an entire playbook. Running with tags can save a substantial amount to time when executing a playbook. Below is a list of all the tags supported by the BeeGFS HA Role. Tags run all ansible tasks that are associated with the tag.
## Table of Contents
1. [Role Tags](#role-tags)

<a name="role-tags"></a>
## All Role Tags
---------
Use the following tags when executing your BeeGFS HA playbook to only execute select tasks:

        example: `ansible-playbook -i inventory.yml playbook.yml --tags beegfs_ha_configure`
        
    - journald                                   # Configure journald defaults.
    - storage                                    # Provisions storage and ensures volumes are presented on hosts.
    - storage_provision                          # Provision storage.
    - storage_communication                      # Setup communication protocol between storage and cluster nodes.
    - storage_format                             # Format all provisioned storage.
    - beegfs_ha                                  # All BeeGFS HA tasks (Ensure volumes have been presented to the cluster nodes).
    - beegfs_ha_package                          # All BeeGFS HA package tasks.
    - beegfs_ha_configure                        # All BeeGFS HA configuration tasks (Ensure volumes are present and BeeGFS packages are installed).
    - beegfs_ha_configure_resource               # All BeeGFS HA pacemaker resource tasks.
    - beegfs_ha_move_all_to_preferred            # Restore all resources to their preferred nodes.
    - beegfs_ha_performance_tuning               # All BeeGFS HA performance tuning tasks (Ensure volumes are present and BeeGFS packages are installed).
    - beegfs_ha_backup                           # Backup Pacemaker and Corosync configuration files.
    - beegfs_ha_client                           # Configures BeeGFS clients (Ensure BeeGFS is configured and running).