netappeseries.beegfs.nar_santricity_beegfs_7_1 Role
=============================================================
This role deploys BeeGFS without high availability as described in the (BeeGFS with NetApp E-Series solution deployment guide)[https://www.netapp.com/us/media/tr-4755.pdf]. Note this role requires NetApp E-Series storage be configured and attached to the respective BeeGFS nodes before execution. Combined with the NetApp E-Series SANtricity and Host collections users can perform an end-to-end automated deployment.

Requirements:
-------------
 * Ansible control node running Ansible 2.9 or later and the latest version of the `netapp_eseries.santricity` collection installed.
    * For a quick way to setup Ansible 2.9 with all required dependencies for this collection, check out `docker/README.md`.
 * Management and data network interfaces configured on all BeeGFS nodes.
 * Passwordless SSH setup from the Ansible control node to all BeeGFS nodes.
 * Multipath must be setup and configured on any nodes designated as BeeGFS storage or metadata nodes.
    * Explanation: This ensures stable connections to E-Series volumes used as BeeGFS metadata/storage targets. There is a prerequisite check that verifies the multipathd.service is started/enabled on each node designated for storage and/or metadata.
 * A single volume with the workload tag "beegfs_metadata" should be mapped to each host designated as a BeeGFS metadata node.
    * Explanation: BeeGFS only supports a single metadata target at this time. There is a prerequisite check in place to ensure there is not more than one BeeGFS metadata target per metadata node.

Support Matrix:
--------------
The BeeGFS role has been tested with the following BeeGFS versions, operating systems, and backend/frontend protocols:

| Component              | BeeGFS Version | Operating System        | Storage Protocols             | Client Protocols    |
| ---------------------- | -------------- | ----------------------- | ----------------------------- | ------------------- |
| BeeGFS Client service  | 7.1.4          | RedHat 7.7, SLES 12 SP4 | N/A                           | TCP/UDP and RDMA    |
| BeeGFS Server services | 7.1.4          | RedHat 7.7, SLES 12 SP4 | IB-iSER, SAS, iSCSI, NVMe/IB  | N/A                 |

Notes:
- BeeGFS Server services include BeeGFS management, metadata and storage services.
- While not explicitly tested, it is reasonable to expect implicit support for the following:
  - RedHat/SLES versions within the same major release family (for example SLES 12 SP3) and downstream distributions (for example CentOS).
  - Versions of BeeGFS within the same major release family (for example 7.1.3).

The BeeGFS role has been tested with the following E-Series storage systems and protocols:

| Platform | Firmware | Protocols           |
| -------- | -------- | ------------------- |
| E5700    | 11.52    | iSCSI, SAS, IB-iSER |
| EF600    | 11.61    | NVMe/IB             |

Notes:
- While not explicitly included in testing, other firmware versions and storage systems including the E2800 and SAN protocols including IB-SRP, FCP, and NVMe/FC are expected to work.

Instructions (quick start):
--------------------------
On your Ansible control node:
1. Use the ansible-galaxy command line tool to install the BeeGFS collection: `ansible-galaxy collection install netapp_eseries.beegfs`.
    * If you don't have it installed already you will also need the SANtricity collection: `ansible-galaxy collection install netapp_eseries.santricity`.
2. Create a directory that will contain the inventory and playbook files to use with the BeeGFS role.
3. Use the example files from the `examples/` directory to help build your playbook and inventory files in the newly created directory from step 2.
4. When you have the desired BeeGFS configuration described in your inventory and related files, run the playbook and deploy BeeGFS using: `ansible-playbook -i beegfs_inventory.yml beegfs_playbook.yml`.
    * Note you can define/deploy multiple BeeGFS file systems using the same inventory. The only limitation is that each Ansible host can only be included in one of the file system instances. For example the role does not currently support deploying a BeeGFS client that mounts two different BeeGFS file systems.

Please refer to the sections below for guidance setting up required and optional variables to describe your desired BeeGFS configuration.

Basic Variables:
----------------
This section describes basic variables the user needs to consider. The following variables are commonly defined on the Ansible group containing the BeeGFS hosts (`eseries_beegfs_hosts` in the examples). Please note these variables can also be overridden or defined on individual hosts if needed:

    beegfs_mgmt_node_ip:             # Required: The IP of the network interface other services will use to connect to the BeeGFS management node.
    beegfs_enable_rdma: False        # Optional: Set to 'True' to deploy BeeGFS with support for remote direct memory access (RDMA).
    beegfs_ofed_include_path:        # Optional: Unless a path is specified for this variable, the default kernel InfiniBand modules are used.
                                        # BeeGFS also supports specifying a path to seperate OFED modules which can be done through this variable.
    beegfs_data_directory: "/data/"  # Optional: Specify an alternate location for the management service to store data and BeeGFS targets to be mounted.
                                        # IMPORTANT: The path must end in a forward slash and a prerequisite check will fail if it does not.
                                        # The role always appends "beegfs/" to the end of this path, and only the "beegfs/" directory is removed in the uninstall mode.
    beegfs_connInterfaces:           # Optional: Set a prioritized list of network interfaces BeeGFS services should use for communication.
      - ib0                             # While not required, it is strongly recommended to avoid BeeGFS traffic using non-optimized networks/paths.
      - eth1
      - ens160

The following variable will need to be specified on each BeeGFS host (include one or more of the listed roles):

    beegfs_node_roles: [mangement, metadata, storage, client]

Other variables too long to be summarized in this section are covered in the sections below. Unless otherwise noted all variables can be defined on the Ansible group containing the BeeGFS hosts, or individual hosts. For a comprehensive list of available variables see the `roles/nar_santricity_beegfs_7_1/defaults/main.yml` file.

Firewall Configuration (`beegfs_open_firewall_ports: False`)
------------------------------------------------------------
This role contains functionality that can open the firewall ports required for the BeeGFS services to function. By default this option is disabled, but can be toggled by setting `beegfs_open_firewall_ports: True`. Please note this only works to configure firewalld, and does not currently work for the default SUSE firewall (SuSEfirewall2.service). If you are using a firewall other than firewalld, you will need to manually open the required firewall ports.

These are the default UDP and TCP port numbers for each BeeGFS service:

- Management service (beegfs-mgmtd): 8008
- Metadata service (beegfs-meta): 8005
- Storage service (beegfs-storage): 8003
- Client service (beegfs-client): 8004

Reference: https://www.beegfs.io/wiki/NetworkTuning#hn_59ca4f8bbb_4.

NTP Configuration (`beegfs_ntp_enabled: False`)
-----------------------------------------------
Time synchronization is required for BeeGFS to function properly. As a convenience to users the BeeGFS role provides functionality that can configure the ntpd service on all BeeGFS nodes by setting `beegfs_ntp_enabled: True`. By default this variable is set to `False` to avoid conflicts with any existing NTP configuration that might be in place. If this variable is set to `True` please note any existing Chrony installations will be removed as they would conflict with ntpd.

The following variables are available to adjust the NTP configuration:

    beegfs_ntp_enabled: True
    beegfs_ntp_configuration_file: /etc/ntp.conf  # OPTIONAL: Override the location of the ntp.conf file.
    beegfs_ntp_server_pools:                      # OPTIONAL: Configure an alternate pool of timeservers.
      - "server 0.ubuntu.pool.ntp.org iburst"
      - "server 1.ubuntu.pool.ntp.org iburst"
      - "server 2.ubuntu.pool.ntp.org iburst"
      - "server 3.ubuntu.pool.ntp.org iburst"
    beegfs_ntp_restricts:                         # OPTIONAL: Configure alternative access control entries.
      - 127.0.0.1
      - ::1

The template used to generate the /etc/ntp.conf file can be found at `roles/nar_santricity_beegfs_7_1/templates/common/beegfs_ntp_conf.j2`. Depending on the security policies of your organization, you way wish to adjust the default configuration.

#### Special Considerations:

* Some Linux installations may be setup to have the DHCP client periodically update /etc/ntp.conf with NTP servers from the DHCP server. You can tell this is happening if text like the following is appended to the bottom of /etc/ntp.conf:
```
server <IP_ADDR>  # added by /sbin/dhclient-script
```
As a result the NTP related Ansible tasks will be marked as changed whenever the role is reapplied. If you're wanting to manage the NTP configuration outside Ansible simply set `beegfs_ntp_enabled: False` to prevent the role from configuring NTP.


Selecting BeeGFS Metadata/Storage targets (`beegfs_eseries_group: eseries_storage_systems`)
-------------------------------------------------------------------------------------------
When setting up the inventory file for use with the BeeGFS role, you must list all E-Series storage systems with volumes intended for use as BeeGFS storage and/or metadata targets. By default these storage systems must be defined under a group called `eseries_storage_systems`, though this can be changed by overriding the `beegfs_eseries_group` variable on the Ansible group containing the BeeGFS nodes.

At minimum you must provide the following details for each Ansible host representing an E-Series storage system:

    eseries_system_api_url: https://<url>/devmgr/v2             # For storage systems with embedded web services this will be the IP/hostname of one controller.
                                                                   # Otherwise specify the URL to the web services proxy managing the storage system.
    eseries_system_password: <eseries_array_admin_password>     # Admin password for the storage system or web services proxy.
                                                                    # Use of Ansible Vault over storing passwords in plaintext is strongly recommended.
    eseries_validate_certs:  [true|false]                       # Set "true" to verify SSL certificates or "false" to disable.
                                                                    # This would typically be set to "false" if you get certificate errors using the above URL in a browser.

When the BeeGFS role is executed it will reach out to each of these E-Series storage systems to collect a list of which BeeGFS nodes in the inventory have volumes mapped with the workload name `beegfs_storage` or `beegfs_metadata`. The role will subsequently verify all required volumes are visible on each host, and will attempt to rescan and reboot hosts as needed to ensure all newly mapped volumes are present.

You can either manually configure the E-Series storage systems or automate this process using the `nar_santricity_host` role available in the NetApp Ansible SANtricity collection. Regardless of how the E-Series storage systems are configured, there are a few important considerations to ensure the BeeGFS role can correctly associate the BeeGFS nodes in the inventory with the corresponding host and desired volumes on the storage system:

- The `inventory_hostname` for each BeeGFS node in the Ansible inventory must match the name used for the host object on the E-Series storage system.
  - If needed you can leverage the `ansible_host` variable to specify an alternate IP/name for the target host connection instead of the `inventory_hostname` value.
- You must assign a workload with the name `beegfs_metadata` or `beegfs_storage` to each volume intended as either a BeeGFS storage or metadata target.
  - This allows you to denote volumes used for BeeGFS storage versus metadata if you want to run both services on the same host. This also prevents the BeeGFS role from trying to configure other volumes mapped to the hosts that may be intended for another purpose.


Performance Tuning (`beegfs_enable_performance_tuning: False`)
-------------------------------------------------------------
Performance tuning is disabled by default, but can be enabled by setting `beegfs_enable_performance_tuning: True`. The default is to avoid a scenario where users are unaware these are being set, and they result in poor performance or stability issues that are difficult to troubleshoot. There is also the added consideration the default values will likely need to be adjusted to achieve optimal performance for a given hardware configuration.

BeeGFS calls out a number of parameters at https://www.beegfs.io/wiki/StorageServerTuning and https://www.beegfs.io/wiki/MetaServerTuning that can be used to improve the performance of BeeGFS storage and metadata services. To help simplify performance tuning for BeeGFS storage and metadata nodes, the BeeGFS role provides the following functionality:

1) Tuning kernel parameters using sysctl.
2) Tuning parameters on E-Series block devices/paths using udev.

While default values for all tuning parameters are defined at `roles/nar_santricity_beegfs_7_1/defaults/main.yml`, more than likely these will need to be adjusted to tune based on the environment. As with any Ansible variable, you can override these defaults on a host-by-host or group basis to tune each node or sets of nodes differently.

To only run tasks related to BeeGFS performance tuning, use the tag "beegfs_performance_tuning" in your Ansible playbook command (e.g. `ansible-playbook -i inventory.yml playbook.yml --tags beegfs_performance_tuning`). This will greatly reduce playbook runtime when simply wishing to make incremental adjustments to these parameters during benchmark testing.

#### Tuning kernel parameters using sysctl:

BeeGFS recommends setting various kernel parameters under /proc/sys to help optimize the performance of BeeGFS storage/metadata nodes. One option to ensure these changes are persistent are setting them using sysctl. By default this role will will override the following parameters on BeeGFS storage and metadata nodes in /etc/sysctl.conf on RedHat or /etc/sysctl.d/99-eseries-beegfs.conf on SUSE:

    beegfs_sysctl_entries:
      vm.dirty_background_ratio: 5
      vm.dirty_ratio: 20
      vm.vfs_cache_pressure: 50
      vm.min_free_kbytes: 262144
      vm.zone_reclaim_mode: 1

Important:
- If you define your own `beegfs_sysctl_entries` you will need to explicitly list all sysctl key/value pairs you wish to be set.
- The documentation for some Linux distributions indicates you need to rebuild the initramfs after modifying the values of kernel variables using sysctl (reference: https://documentation.suse.com/sles/12-SP4/html/SLES-all/cha-boot.html#var-initrd-regenerate-kernelvars). Based on testing these values do persist through a reboot for the operating systems listed on the support matrix, and thus is not done automatically by the role. It is recommended users verify these settings persist in their environment, and rebuild the initramfs if needed.

#### Tuning parameters on E-Series block devices/paths using udev:

The following variables should be used to optimize performance for storage and metadata volumes:

- `beegfs_eseries_scheduler: noop` -> `/sys/block/<device>/queue/scheduler`
- `beegfs_eseries_nr_requests: 64` -> `/sys/block/<device>/queue/nr_requests`
- `beegfs_eseries_read_ahead_kb: 4096` -> `/sys/block/<device>/queue/read_ahead_kb`
- `beegfs_eseries_max_sectors_kb: 1024` -> `/sys/block/<device>/queue/max_sectors_kb`

Note these will be applied to both the device mapper entry (e.g. dm-X) and underlying path (e.g. sdX).

##### Advanced:
- If it is desired to set additional parameters on E-Series devices using udev, the template for the rule is located at `roles/nar_santricity_beegfs_7_1/templates/common/eseries_beegfs_udev_rule.j2`. Please note modifications to this file require an understanding of Ansible, Jinja2, udev and bash scripting and are made at the user's risk.
- The udev rule will be created on BeeGFS storage/metadata nodes at `/etc/udev/rules.d/99-eseries-beegfs.rules`.

#### Restrictions:
- If BeeGFS Metadata and Storage services are running on the same node, there is no way to set different sysctl entries or udev rules to tune servers and LUNs used for metadata vs. storage differently.
- If `max_hw_sectors_kb` on a device is lower than max_sectors_kb you attempt to configure using udev, based on testing the device will be set at the max_hw_sectors_kb value and the udev setting is ignored.
  - The `hw_max_sectors_kb` value can vary depending on the device (example: InfiniBand HCA) used to attach the host to external storage (either direct or through a fabric). Some device drivers may support changing parameters that allow the hw_max_sectors value to increase, but this is outside the scope of this documentation and Ansible role.
  - The hardware versus configured value can be verified by substituting your devices in the following commands `cat /sys/block/[sdX|dm-X]/queue/max_hw_sectors_kb` and `cat /sys/block/[sdX|dm-X]/queue/max_sectors_kb`.


Formatting and Mount Parameters for BeeGFS Metadata/Storage Targets:
-------------------------------------------------------------------
In addition to the parameters set using sysctl and udev in the last section, BeeGFS calls out a number of recommended xfs/ext4 formatting and mount parameters at https://www.beegfs.io/wiki/StorageServerTuning and https://www.beegfs.io/wiki/MetaServerTuning.

While the defaults set at `roles/nar_santricity_beegfs_7_1/defaults/main.yml` are meant to account for most use cases, it is important for the user to understand what values are being set, and in some cases be able to override these parameters if necessary.

Important Notes:
- Changes to formatting parameters (e.g. mkfs.ext4 or mkfs.xfs) cannot be made after the device used as a BeeGFS storage/metadata target has already been formatted.
- Changes to mount parameters will update `/etc/fstab`, but will not take effect until the node is rebooted.

#### Parameters set on BeeGFS Metadata Targets:

E-Series volumes designated as BeeGFS metadata targets will be formatted with ext4 and the following parameters:

- `beegfs_metadata_format_options: "-i 2048 -I 512 -J size=400 -Odir_index,filetype"`

E-Series volumes designated as BeeGFS metadata targets will be mounted with the following parameters:

- `beegfs_metadata_mounting_options: "noatime,nodiratime,nobarrier,_netdev"`

#### Parameters set on BeeGFS Storage Targets:

E-Series volumes designated as BeeGFS storage targets will be formatted using XFS, and there are a few optimizations recommended to create a RAID-optimized filesystem:

- The "su" or stripe unit parameter should be set to the E-Series segment size (i.e. how much data is written per stripe to each disk in the E-Series volume/RAID group).
- The "sw" or stripe width parameter should be set to the number of disks in the E-Series volume/RAID group, minus any parity disks.

Selections for the above parameters are made automatically by looking at the E-Series volume selected for each BeeGFS storage target. Because of this automatic configuration, there is no variable in `nar_santricity_beegfs_7_1/defaults/main.yml` to adjust BeeGFS storage format options. The full list of XFS parameters applied to BeeGFS storage targets including dynamic/static values are `"-d su={{ item['segment_size_kb'] }}k,sw={{ item['stripe_count'] }} -l version=2,su={{ item['segment_size_kb'] }}k"`.

E-Series volumes designated as BeeGFS storage targets will be mounted with one of the following parameter sets, depending if quotas are enabled:

- `beegfs_storage_mounting_options: "noatime,nodiratime,logbufs=8,logbsize=256k,largeio,inode64,swalloc,allocsize=131072k,nobarrier,_netdev"`
- `beegfs_storage_mounting_options_quotas: "uqnoenforce,gqnoenforce,noatime,nodiratime,logbufs=8,logbsize=256k,largeio,inode64,swalloc,allocsize=131072k,nobarrier,_netdev"`

##### Advanced:
Though not recommended, if it is absolutely necessary to override the XFS formatting options this would need to be done in `roles/nar_santricity_beegfs_7_1/tasks/mount.yml` (see task: "Format BeeGFS Storage volumes using xfs").


Enabling BeeGFS Quota Tracking/Enforcement
------------------------------------------
There are two parameters that control BeeGFS quota functionality, `beegfs_enable_quota` (quota tracking) and `beegfs_quota_enable_enforcement` (quota enforcement). By default both options are set to "false". It is important to highlight the BeeGFS quota feature is considered an enterprise feature requiring a BeeGFS support contract through a partner like NetApp (https://www.beegfs.io/content/support/). Provided the user meets all prerequisites to enabling quotas, when initially deploying a new filesystem one or both variables can be set to "true" to deploy with quota support enabled.

If you want to add quota support to an existing BeeGFS installation after initially deploying with quotas disabled, please follow the official BeeGFS procedures to manually enable quotas (https://www.beegfs.io/wiki/EnableQuota) before toggling these variables. To reiterate, after manually enabling quotas on the filesystem, you must toggle one or both variables to "True" before running the BeeGFS role again.


Upgrading BeeGFS (`beegfs_force_beegfs_upgrade: False`)
-------------------------------------------------------
By default the BeeGFS role will add the BeeGFS 7.1 repository to all of the BeeGFS nodes. When the role is first executed the latest BeeGFS packages available in the repository will be installed to the appropriate BeeGFS nodes. When the BeeGFS role is run after BeeGFS has already been deployed, we will only ensure the appropriate BeeGFS packages are present on each node unless `beegfs_force_beegfs_upgrade` is set to "True". Setting this variable to "True" will tell the yum/zypper/apt Ansible modules to ensure the latest BeeGFS services are installed, which could result in a service being upgraded.


Other Notable Configuration Changes
-----------------------------------
The items listed in this section are notable changes to the BeeGFS and/or operating system configuration the BeeGFS role makes not captured in previous sections. This is not meant to be a complete list of changes made by the role, mainly ones users may need to be aware of for troubleshooting or other purposes.

#### Systemd:
Before the BeeGFS storage and metadata services can start, the filesystems on E-Series volumes used for metadata/storage targets must be mounted. To prevent the services from trying to start before remote filesystems are available, the beegfs-meta.service and beegfs-storage.service systemd unit files are overridden via systemd drop-in units located at `/etc/systemd/system/beegfs-[meta|storage].service.d/99-nar_santricity_beegfs_override.conf` to add `remote-fs.target` to both the "Requires" and "After" systemd directives.


Known Issues/Limitations of the BeeGFS Role
--------------------------------------------
* The Ansible "Check Mode" (dry run) feature does not currently work with the BeeGFS role.
* During the first run after enabling quota support, you may notice "changed" logged for the following tasks:
    * The tasks that populate service configuration files due to how Ansible determines changes between files (or subtle difference in the config templates/actual file).
    * The task responsible for mounting BeeGFS storage targets, especially if /etc/fstab was not updated with the new mount options.
* When using the yum package manager, if the role is used to deploy, wipe, then redeploy BeeGFS regularly (on the order of 10s to 100s of times) depending how yum is configured the contents of `/var/cache` may grow exponentially over time. This cache can be purged by running `yum clean all`. More permanent workarounds may be possible by toggling the yum `/etc/yum.conf:keepcache` parameter, but have not been tested extensively thus are outside the scope of this documentation.

Troubleshooting
---------------
* When deploying the BeeGFS client service on SLES, the client service may fail to start and indicate the BeeGFS kernel module is unsupported.
    * Solution: You can set the variable `beegfs_allow_unsupported_module: True` on any affected hosts. This will set `allow_unsupported_modules: 1` in `/etc/modprobe.d/10-unsupported-modules.conf` the next time the BeeGFS role is executed. Please note this will allow all unsupported modules, not just the ones required for BeeGFS.
* BeeGFS client fails to start and `journalctl -xe` indicates `kernel: beegfs: mount(2630): App (init local node info): Couldn't find any usable NIC`.
    * This indicates required network interfaces were not available before the kernel tried to mount the BeeGFS filesystem. Manually starting the BeeGFS Client service should succeed after verifying all required network interfaces are ready. To allow the service to start automatically at boot you would need to confirm there are no network or configuration issues delaying interface initialization. If needed adjust the systemd unit configuration to delay startup of the BeeGFS client service if any delays are unavoidable.
* Issues using a non-root user to deploy BeeGFS using Ansible.
    * If you are planning to use a non-root user to deploy BeeGFS using Ansible ensure you have passwordless SSH setup for this user, and you override the `ansible_user` variable.
    * Depending on how this user is setup to run privileged commands you may also need to set additional variables. See https://docs.ansible.com/ansible/latest/user_guide/become.html for additional details.

Tip: Run your beegfs playbook with --tags=beegfs_validate_deployment to validate your management server can communicate with all the expected inventory BeeGFS nodes. This will also provide a report in the failed messages should any node be missing.


Uninstalling BeeGFS and Cleaning Up Configuration
-------------------------------------------------
The BeeGFS role contains tasks that will uninstall all BeeGFS services, unmount any BeeGFS storage/metadata targets, and format the corresponding volumes. This is a convenient way to cleanup a BeeGFS filesystem during testing phases or when repurposing servers. In order to run the BeeGFS role in this mode you need to specify the tag `beegfs_uninstall` and override the variable `beegfs_delete_data_and_uninstall_beegfs`. The following command will run the BeeGFS role in this uninstall/cleanup mode:

    ansible-playbook -i inventory.yml playbook.yml --tags=beegfs_uninstall --extra-vars '{"beegfs_delete_data_and_uninstall_beegfs":True}'

By default this process wipes the filesystem signature from all volumes used as BeeGFS storage/metadata targets using wipefs. On SLES12SP4 (but not RHEL) signature backups will be created at `$HOME/wipefs-{devname}-{offset}.bak`. To bypass wipefs and only unmount the storage/metadata volumes set `beegfs_disable_format_storage_metadata_disks: True`. Note the contents of the BeeGFS Management directory will still be cleared out even with this set. The following command will run the BeeGFS role in the uninstall mode and bypass any wipefs operations:

     ansible-playbook -i inventory.yml playbook.yml --tags=beegfs_uninstall --extra-vars '{"beegfs_delete_data_and_uninstall_beegfs":True,"beegfs_disable_format_storage_metadata_disks":True}'

Based on testing if you rerun the role with the same configuration without wiping the metadata/storage target filesystems you may end up with an identical BeeGFS filesystem as before running the remove tasks. Please note this is not an officially supported state, and notable as omitting to wipe the BeeGFS metadata/storage targets can cause problems deploying BeeGFS when reusing the same E-Series volumes for a different configuration.

#### Limitations of the uninstall/cleanup mode:

##### Tasks not reverted:

- During deployment if needed we install the kernel development packages (e.g. kernel-devel on RHEL7) that matches the current kernel version on each BeeGFS client node. As we have no way of verifying if this was originally installed by the BeeGFS role or previously to meet some other dependency, we do not remove it as part of the remove/uninstall workflow.
- The variable `beegfs_data_directory` (default `/data/`) is used to specify where BeeGFS storage/metadata targets will be mounted, and a mgmt/ directory created on the management node. The BeeGFS role will automatically append `beegfs/` to this variable (e.g. the full default path is `/data/beegfs/`). To avoid deleting user data (for example if the user specified `/mnt`) only the `beegfs/` directory is removed, even though the full directory path would be created if needed when the role initially ran.

#### Tasks conditionally reverted:
There are few changes that are only reverted if the corresponding variable is still set, as this indicates it was initially configured by the BeeGFS role:

- During deployment we will ensure NTP is configured if `beegfs_ntp_enabled: True`. We will only remove NTP if this variable is still set to true.
- During deployment we open firewall ports required for BeeGFS if `beegfs_open_firewall_ports: True`. We will only close the ports if this variable is still set to true.
- During deployment if `beegfs_allow_unsupported_module: True` we toggle the option `/etc/modprobe.d/10-unsupported-modules.conf: allow_unsupported_modules 1`. This change is only reverted back to "0" if the variable is still set to true.

Submitting Questions and Feedback:
----------------------------------
If you have any questions, feature requests, or would like to report an issue please submit them at https://github.com/netappeseries/beegfs/issues.

License
-------
BSD-3-Clause

Author Information
------------------
- Christopher Seirer (@CSeirer)
- Janey Le (@janeyle)
- Joe McCormick (@iamjoemccormick)
- Nathan Swartz (@ndswartz)
