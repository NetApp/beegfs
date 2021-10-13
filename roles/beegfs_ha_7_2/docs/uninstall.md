## Uninstall (`beegfs_ha_uninstall: False`)
----------------------------------------
Uninstall your BeeGFS HA instance by setting `beegfs_ha_uninstall: True`. At minimum, BeeGFS and HA applications, configuration, performance tunings, and mount points will be removed. The uninstallation process requires the original inventory files so just modify the `beegfs_ha_uninstall_x` variables at the group level.

The following variables are used to control the uninstallation:

- beegfs_ha_uninstall_unmap_volumes: false                              # Whether to unmap the volumes from the host only. This will not effect the data.
- beegfs_ha_uninstall_wipe_format_volumes: false                        # Whether to wipe format signatures from volumes on the host. **WARNING! This action is unrecoverable.**
- beegfs_ha_uninstall_delete_volumes: false                             # Whether to delete the volumes from the storage. **WARNING! This action is unrecoverable.**
- beegfs_ha_uninstall_delete_storage_pools_and_host_mappings: false     # Whether to delete all storage pools/volume groups and host/host group mappings created for BeeGFS HA solution.
                                                                        #   Be aware that removing storage pools/volume groups and host/host group mappings will effect any volumes or
                                                                        #   host mappings dependent on them.  **WARNING! This action is unrecoverable.**
- beegfs_ha_uninstall_storage_setup: false                              # Whether to remove configuration that allows storage to be accessible to the BeeGFS HA node (i.e. multipath,
                                                                        #   communications protocols (iSCSI, IB iSER)).
- beegfs_ha_uninstall_reboot: false                                     # Whether to reboot after uninstallation.

Note that not setting `beegfs_ha_uninstall_wipe_format_volumes: true` when deleting and, subsequently, creating new volumes of the same size may result in recovering the original volume. While this is helpful if you unintentionally deleted the volumes, it can create mounting issues for the host.

#### Implied actions:

The following are an explicit list of implied actions.

- `beegfs_ha_uninstall_unmap_volumes: true`
- `beegfs_ha_uninstall_storage_setup: true`
    - `beegfs_ha_uninstall_unmap_volumes: true`
- `eseries_unmount_delete: true`:
    - `beegfs_ha_uninstall_unmap_volumes: true`
- `beegfs_ha_uninstall_delete_storage_pools_and_host_mappings: true`
    - `beegfs_ha_uninstall_unmap_volumes: true`
    - `eseries_unmount_delete: true`

