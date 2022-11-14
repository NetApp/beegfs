netappeseries.beegfs.beegfs_ha_7_2 Role (Deprecated)
====================================================
This role is a complete end-to-end deployment of the [NetApp E-Series BeeGFS HA (High-Availability) solution](https://blog.netapp.com/high-availability-beegfs). 
This role utilizes the NetApp E-Series SANtricity, Host, and BeeGFS collections which allows users to not only configure 
the BeeGFS file system with HA but also provision, map storage and ensure the cluster storage is ready for use.

Note that this role has been deprecated and will be removed in a future release. Please upgrade to beegfs_ha_7_3 at your earliest convenience.

## Table of Contents

1. [Requirements](../beegfs_ha_common/docs/getting_started.md)
2. [Support Matrix](../beegfs_ha_common/docs/support_matrix.md)
3. [Getting Started](../beegfs_ha_common/docs/getting_started.md)
4. [Example Playbook, Inventory, Group/Host Variables](../beegfs_ha_common/docs/getting_started.md)
5. [Role Variables](../beegfs_ha_common/docs/role_variables.md)
6. [Role Tags](../beegfs_ha_common/docs/role_tags.md)
7. [Command Reference](../beegfs_ha_common/docs/command_reference)
8. [Override BeeGFS Configuration Defaults](../beegfs_ha_common/docs/override_beegfs_configuration_defaults.md)
9. [Override Default Templates](../beegfs_ha_common/docs/override_default_templates.md)
10. [NTP](../beegfs_ha_common/docs/ntp.md)
11. [Performance Tuning](../beegfs_ha_common/docs/performance_tuning.md)
12. [Upgrade](../beegfs_ha_common/docs/upgrade.md)
13. [Uninstall](../beegfs_ha_common/docs/uninstall.md)
14. [Maintenance](../beegfs_ha_common/docs/maintenance.md)

### Dependencies
------------
- netapp_eseries.santricity
- netapp_eseries.host

License
-------
BSD

Author Information
------------------
- Joe McCormick (@iamjoemccormick)
- Nathan Swartz (@ndswartz)
