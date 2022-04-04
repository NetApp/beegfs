<a name="role-tags"></a>
# Role Tags

The BeeGFS HA Role has a set of tags that can be used to perform a subset of tasks instead of running an entire playbook.
Running with tags can save a substantial amount to time when executing a playbook. Below is a list of all the tags
supported by the BeeGFS HA Role. Tags run all ansible tasks that are associated with the tag.

<a name="table-of-contents"></a>
## Table of Contents

- [Role Tags](#role-tags)
  - [Table of Contents](#table-of-contents)
  - [All Role Tags](#all-role-tags)

<a name="role-tags"></a>
## All Role Tags

Use the following tags when executing your BeeGFS HA playbook to only execute select tasks:

    example: `ansible-playbook -i inventory.yml playbook.yml --tags beegfs_ha_configure`
            
        - journald                          # Configure journald defaults.
        - storage                           # Provisions storage and ensures volumes are presented on hosts.
        - storage_provision                 # Provision storage.
        - storage_communication             # Setup communication protocol between storage and cluster nodes.
        - storage_format                    # Format all provisioned storage when not previously formatted.
        - beegfs_ha                         # Install and configure the BeeGFS HA cluster (ensure volumes have been presented to the cluster nodes).
        - beegfs_ha_package                 # Install the BeeGFS HA packages.
        - beegfs_ha_configure               # All BeeGFS HA configuration tasks (Ensure volumes are present and BeeGFS packages are installed).
        - beegfs_ha_configure_resource      # All BeeGFS HA pacemaker resource tasks.
        - beegfs_ha_move_all_to_preferred   # Restore all resources to their preferred nodes.
        - beegfs_ha_performance_tuning      # All BeeGFS HA performance tuning tasks (Ensure volumes are present and BeeGFS packages are installed).
        - beegfs_ha_backup                  # Backup Pacemaker and Corosync configuration files.
