<a name="performance-tuning"></a>
# Performance Tuning

With the BeeGFS HA role, we provide access to many different tuning parameters that allow users to customize their 
performance to suit their needs. Below describes how to tune different aspects of the BeeGFS HA role.


<a name="table-of-contents"></a>
## Table of Contents

- [Performance Tuning](#performance-tuning)
  - [Table of Contents](#table-of-contents)
  - [BeeGFS Performance Tuning](#beegfs-performance-tuning)
    - [Tuning Kernel Parameters Using Sysctl](#tuning-kernel-parameters-using-sysctl)
    - [Tuning Parameters on E-Series Block Devices and Paths Using Udev](#tuning-parameters-on-e-series-block-devices-and-paths-using-udev)
  - [Using mixed drives](#using-mixed-drives)
  - [Advanced](#advanced)
  - [Restrictions](#restrictions)


<a name="beegfs-performance-tuning"></a>
## BeeGFS Performance Tuning

BeeGFS calls out a number of parameters at https://www.beegfs.io/wiki/StorageServerTuning and 
https://www.beegfs.io/wiki/MetaServerTuning that can be used to improve the performance of BeeGFS storage and metadata
services. We provide the variable, `beegfs_ha_enable_performance_tuning`, to enable the easy performance tuning of a 
BeeGFS filesystem. Performance tuning is **disabled** by default, but can be enabled by setting 
`beegfs_ha_enable_performance_tuning: True`. The default is used to avoid a scenario where users are unaware tuning has
been done, resulting in a poorly optimized configuration for their use. This could result in poor performance or
stability issues that are difficult to troubleshoot. The default values will likely need to be adjusted to achieve
optimal performance for a given hardware configuration.

The BeeGFS role provides the following functionality:

1) Tuning kernel parameters using sysctl.
2) Tuning parameters on E-Series block devices/paths using udev.

All default tuning parameters are defined at [BeeGFS Tuning](../../roles/beegfs_ha_7_4/defaults/main.yml), these may need to
be adjusted to tune based on the environment. As with any Ansible variable, you can override these defaults on a
host-by-host or group basis to tune each node or sets of nodes differently. See [Role Variables](role_variables.md) to
see the order of precedence for setting variables.

To only run tasks related to BeeGFS performance tuning, use the tag `beegfs_ha_performance_tuning` in your Ansible
playbook command (e.g. `ansible-playbook -i inventory.yml playbook.yml --tags beegfs_ha_performance_tuning`). For more
information about all available tags check out [BeeGFS HA Role Tags](role_tags.md). This will greatly reduce playbook
runtime when you're making incremental adjustments to these parameters during benchmark testing.


<a name="tuning-kernel-parameters-using-sysctl"></a>
### Tuning Kernel Parameters Using Sysctl

BeeGFS recommends setting various kernel parameters under `/proc/sys` to help optimize the performance of BeeGFS
storage/metadata nodes. One option to ensure these changes are persistent is to set them using sysctl. By default this
role will override the following parameters on BeeGFS storage and metadata nodes in /etc/sysctl.d/99-eseries-beegfs.conf

    beegfs_ha_sysctl_entries:
      vm.dirty_background_ratio: 5
      vm.dirty_ratio: 20
      vm.vfs_cache_pressure: 50
      vm.min_free_kbytes: 262144
      vm.zone_reclaim_mode: 1

**Important:**
- If you define your own `beegfs_ha_sysctl_entries` you will need to explicitly list all sysctl key/value pairs you wish
to be set.


<a name="tuning-parameters-on-eseries-block-devicespaths-using-udev"></a>
### Tuning Parameters on E-Series Block Devices and Paths Using Udev

The following variables should be used to optimize performance for storage and metadata volumes:

- `beegfs_ha_eseries_scheduler: noop` -> `/sys/block/<device>/queue/scheduler`
- `beegfs_ha_eseries_nr_requests: 64` -> `/sys/block/<device>/queue/nr_requests`
- `beegfs_ha_eseries_read_ahead_kb: 4096` -> `/sys/block/<device>/queue/read_ahead_kb`
- `beegfs_ha_eseries_max_sectors_kb: 1024` -> `/sys/block/<device>/queue/max_sectors_kb`

Note these will be applied to both the device mapper entry (e.g. dm-X) and underlying path (e.g. sdX).


<a name="using-mixed-drives"></a>
## Using mixed drives

When deploying a system with mixed drive types or drive sizes, you may want to select certain drives for each volume
group. This can be done by using the `eseries_storage_pool_usable_drives` variable. Note, you will have to supply 
enough useable drives to be able to build the volume group. When defining the useable drives, the first digit is the 
drive shelf number followed by the drive number such as `99:0`. 

Example:
- `eseries_storage_pool_usable_drives: "99:0,99:23,99:1,99:22,99:2,99:21,99:3,99:20,99:4,99:19,99:5,99:18,99:6,99:17,`
`99:7,99:16,99:8,99:15,99:9,99:14,99:10,99:13,99:11,99:12"`

For enclosure with drawers, use the format `shelf_id:drawer_number:drive_number`.

The `eseries_storage_pool_usable_drives` variable can be defined for each volume group under 
`eseries_storage_pool_configuration` for each resource group.


<a name="advanced"></a>
## Advanced

- If it is desired to set additional parameters on E-Series devices using udev, the template for the rule is located at
[BeeGFS HA udev Rule](../templates/common/eseries_beegfs_ha_udev_rule.j2). **Please note modifications to this file
require an understanding of Ansible, Jinja2, udev and bash scripting and are made at the user's risk.**
- The udev rule will be created on BeeGFS storage/metadata nodes at `/etc/udev/rules.d/99-eseries-beegfs-ha.rules`.


<a name="restrictions"></a>
## Restrictions

- If BeeGFS storage and metadata services are running on the same node, there is no way to set different sysctl entries 
or udev rules to tune servers and LUNs used for metadata vs. storage differently.
- If the value of `max_hw_sectors_kb` on a device is lower than the `max_sectors_kb` variable (to be set using udev),
from our testing, the device will be set at the `max_hw_sectors_kb` value and the udev setting is ignored.
  - The `hw_max_sectors_kb` value can vary depending on the device (example: InfiniBand HCA) used to attach the host to
  external storage (either direct or through a fabric). Some device drivers may support changing parameters that allow 
  the hw_max_sectors value to increase, but this is outside the scope of this documentation and Ansible role.
  - The hardware versus configured value can be verified by substituting your devices in the following commands:
    - `cat /sys/block/[sdX|dm-X]/queue/max_hw_sectors_kb`
    - `cat /sys/block/[sdX|dm-X]/queue/max_sectors_kb.`
