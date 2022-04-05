netappeseries.beegfs.beegfs_ha_7_2 Role
=======================================
This role is a complete end-to-end deployment of the [NetApp E-Series BeeGFS HA (High-Availability) solution](https://blog.netapp.com/high-availability-beegfs). 
This role utilizes the NetApp E-Series SANtricity, Host, and BeeGFS collections which allows users to not only configure 
the BeeGFS file system with HA but also provision, map storage and ensure the cluster storage is ready for use.


## Table of Contents

1. [Requirements](docs/getting_started.md)
2. [Support Matrix](docs/support_matrix.md)
3. [Getting Started](docs/getting_started.md)
4. [Example Playbook, Inventory, Group/Host Variables](docs/getting_started.md)
5. [Role Variables](docs/role_variables.md)
6. [Role Tags](docs/role_tags.md)
7. [Command Reference](docs/command_reference)
8. [Override BeeGFS Configuration Defaults](docs/override_beegfs_configuration_defaults.md)
9. [Override Default Templates](docs/override_default_templates.md)
10. [NTP](docs/ntp.md)
11. [Performance Tuning](docs/performance_tuning.md)
12. [Uninstall](docs/uninstall.md)
13. [Maintenance](docs/maintenance.md)

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
