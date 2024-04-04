# netappeseries.beegfs.beegfs_ha_7_3 Role
This role is a complete end-to-end deployment of the [NetApp E-Series BeeGFS HA (High-Availability) solution](https://blog.netapp.com/high-availability-beegfs). 
This role utilizes the NetApp E-Series SANtricity, Host, and BeeGFS collections which allows users to not only configure 
the BeeGFS file system with HA but also provision, map storage and ensure the cluster storage is ready for use.


## Table of Contents

1. [Requirements](/README.md#requirements)
2. [Test Matrix](../../docs/beegfs_ha/test_matrix.md)
3. [Getting Started](/getting_started/README.md)
4. [Example Playbook, Inventory, Group/Host Variables](/getting_started/README.md#example-playbook-inventory-grouphost-variables)
5. [Role Variables](../../docs/beegfs_ha/role_variables.md)
6. [Role Tags](../../docs/beegfs_ha/role_tags.md)
7. [Command Reference](../../docs/beegfs_ha/command_reference)
8. [Override BeeGFS Configuration Defaults](../../docs/beegfs_ha/override_beegfs_configuration_defaults.md)
9. [Override Default Templates](../../docs/beegfs_ha/override_default_templates.md)
10. [NTP](../../docs/beegfs_ha/ntp.md)
11. [Performance Tuning](../../docs/beegfs_ha/performance_tuning.md)
12. [Upgrade](../../docs/beegfs_ha/upgrade.md)
13. [Uninstall](../../docs/beegfs_ha/uninstall.md)
14. [Maintenance](../../docs/beegfs_ha/maintenance.md)

## Dependencies
- [netapp_eseries.santricity](https://galaxy.ansible.com/ui/repo/published/netapp_eseries/santricity/)
- [netapp_eseries.host](https://galaxy.ansible.com/ui/repo/published/netapp_eseries/host/)

## License
BSD

## Maintainer Information
- Christian Whiteside (@mcwhiteside)
- Vu Tran (@VuTran007)