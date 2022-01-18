# Performance Tuning
With the BeeGFS HA Role we provide access to many different tuning parameters that allow users to customize their performance to suit their needs. Below we describe how to tune different aspects of the BeeGFS HA Role.

<br>
## Table of Contents
1. [Performance Tuning](#performance-tuning)
2. [Tuning Kernel Parameters Using sysctl](#tuning-kernel-parameters-using-sysctl)
3. [Tuning parameters on E-Series block devices/paths using udev](#tuning-parameters-on-eseries-block-devices)
4. [Advanced](#advanced)
5. [Restrictions](#restrictions)

<br>

<a name="performance-tuning"> </a>
## Performance Tuning (`beegfs_ha_enable_performance_tuning: False`)
-----------------------------------------------------------------
Performance tuning is **disabled** by default, but can be enabled by setting `beegfs_ha_enable_performance_tuning: True`. The default is used to avoid a scenario where users are unaware tuning has been done, resulting in a poorly optimized configuration for their use. This could result in poor performance or stability issues that are difficult to troubleshoot. The default values will likely need to be adjusted to achieve optimal performance for a given hardware configuration.

BeeGFS calls out a number of parameters at https://www.beegfs.io/wiki/StorageServerTuning and https://www.beegfs.io/wiki/MetaServerTuning that can be used to improve the performance of BeeGFS storage and metadata services. To help simplify performance tuning for BeeGFS storage and metadata nodes, the BeeGFS role provides the following functionality:

1) Tuning kernel parameters using sysctl.
2) Tuning parameters on E-Series block devices/paths using udev.

All default tuning parameters are defined at [BeeGFS Tuning](../defaults/main.yml), more than likely these will need to be adjusted to tune based on the environment. As with any Ansible variable, you can override these defaults on a host-by-host or group basis to tune each node or sets of nodes differently. See [Role Variables](role_variables.md) to see the order of precedence for setting variables.

To only run tasks related to BeeGFS performance tuning, use the tag `beegfs_ha_performance_tuning` in your Ansible playbook command (e.g. `ansible-playbook -i inventory.yml playbook.yml --tags beegfs_ha_performance_tuning`). For more information about all available tags check out [BeeGFS HA Role Tags](role_tags.md) This will greatly reduce playbook runtime when you're making incremental adjustments to these parameters during benchmark testing.

<br>

<a name="tuning-kernel-parameters-using-sysctl"></a>
## Tuning kernel parameters using sysctl:
-----------------------------------------
BeeGFS recommends setting various kernel parameters under `/proc/sys` to help optimize the performance of BeeGFS storage/metadata nodes. One option to ensure these changes are persistent is to set them using sysctl. By default this role will override the following parameters on BeeGFS storage and metadata nodes in /etc/sysctl.conf on RedHat or /etc/sysctl.d/99-eseries-beegfs.conf on SUSE:

    beegfs_ha_sysctl_entries:
      vm.dirty_background_ratio: 5
      vm.dirty_ratio: 20
      vm.vfs_cache_pressure: 50
      vm.min_free_kbytes: 262144
      vm.zone_reclaim_mode: 1

**Important:**
- If you define your own `beegfs_ha_sysctl_entries` you will need to explicitly list all sysctl key/value pairs you wish to be set.
- The documentation for some Linux distributions indicates you need to rebuild the initramfs after modifying the values of kernel variables using sysctl (reference: https://documentation.suse.com/sles/12-SP4/html/SLES-all/cha-boot.html#var-initrd-regenerate-kernelvars). Based on testing these values do persist through a reboot for the operating systems listed on the support matrix, and thus is not done automatically by the role. It is recommended users verify these settings persist in their environment, and rebuild the initramfs if needed.

<br>

<a name="tuning-parameters-on-eseries-block-devices"></a>
## Tuning parameters on E-Series block devices/paths using udev:
-----------------------
The following variables should be used to optimize performance for storage and metadata volumes:

- `beegfs_ha_eseries_scheduler: noop` -> `/sys/block/<device>/queue/scheduler`
- `beegfs_ha_eseries_nr_requests: 64` -> `/sys/block/<device>/queue/nr_requests`
- `beegfs_ha_eseries_read_ahead_kb: 4096` -> `/sys/block/<device>/queue/read_ahead_kb`
- `beegfs_ha_eseries_max_sectors_kb: 1024` -> `/sys/block/<device>/queue/max_sectors_kb`

Note these will be applied to both the device mapper entry (e.g. dm-X) and underlying path (e.g. sdX).

<br>

<a name="advanced"></a>
## Advanced:
------------
- If it is desired to set additional parameters on E-Series devices using udev, the template for the rule is located at [BeeGFS HA udev Rule](../templates/common/eseries_beegfs_ha_udev_rule.j2). **Please note modifications to this file require an understanding of Ansible, Jinja2, udev and bash scripting and are made at the user's risk.**
- The udev rule will be created on BeeGFS storage/metadata nodes at `/etc/udev/rules.d/99-eseries-beegfs-ha.rules`.

<br>

<a name="restrictions"></a>
## Restrictions:
---------------
- If BeeGFS Metadata and Storage services are running on the same node, there is no way to set different sysctl entries or udev rules to tune servers and LUNs used for metadata vs. storage differently.
- If `max_hw_sectors_kb` on a device is lower than max_sectors_kb you attempt to configure using udev, based on testing the device will be set at the max_hw_sectors_kb value and the udev setting is ignored.
  - The `hw_max_sectors_kb` value can vary depending on the device (example: InfiniBand HCA) used to attach the host to external storage (either direct or through a fabric). Some device drivers may support changing parameters that allow the hw_max_sectors value to increase, but this is outside the scope of this documentation and Ansible role.
  - The hardware versus configured value can be verified by substituting your devices in the following commands `cat /sys/block/[sdX|dm-X]/queue/max_hw_sectors_kb` and `cat /sys/block/[sdX|dm-X]/queue/max_sectors_kb`.    