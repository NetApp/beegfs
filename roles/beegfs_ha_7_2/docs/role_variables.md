# Role Variables

## Table of Contents

1. [All Role Variables](#all-role-variables)
## All Role Variables
--------------
This section gives a quick summary of the available variables to configure the BeeGFS HA role. For additional details on select variables please see the follow on sections.
    
    # These variables need to be set:
    beegfs_ha_cluster_name: hacluster                           # Name for the pacemaker cluster.
    beegfs_ha_cluster_username: hacluster                       # Pcs cluster username.
    beegfs_ha_cluster_password: hapassword                      # Pcs cluster password.
    beegfs_ha_cluster_password_sha512_salt: random$alt          # Pcs cluster password sha512 encryption salt.

    # The default values for these variables may need to be overridden:      
    beegfs_ha_cluster_node_ips: []                              # Defines an order list of IP addresses or hostnames with the first having the highest priority. When there are no listed IPs then node name will be used. Node names are defined in /etc/hosts.
    beegfs_ha_ntp_enabled: true                                 # Whether NTP should be enabled. **This will disable Chrony!
    beegfs_ha_chrony_enabled: false                             # Whether Chrony should be enabled. **This will disable NTP!
    beegfs_ha_allow_firewall_high_availability_service: true    # Open firewall ports required by the high-availability services.
    beegfs_ha_alert_email_subject: "ClusterNotification"        # Alert email subject line.
    beegfs_ha_alert_email_list: []                              # Pacemaker alert email recipients.
    beegfs_ha_enable_alerts: true                               # Whether to enable pacemaker email alerts.
    beegfs_ha_enable_quota: false                               # Whether to enable BeeGFS file system quotas.
    beegfs_ha_enable_fence: true                                # Whether to enable pacemaker STONITH fencing agents.
    beegfs_ha_filter_ip_ranges: []                              # Specified the allowed IP subnets which may be used for outgoing communication by BeeGFS services (example: "192.168.10.0/24"). Defaults to any. 
                                                                #   This is useful if BeeGFS server/client and server/storage system traffic are using the same interfaces but you want to isolate traffic to different subnets.
    eseries_common_allow_host_reboot: false                     # Whether to allow a host reboots when attempting to discover BeeGFS storage volumes.

    # Backup defaults
    beegfs_ha_backup: true                                      # Whether to create a pcs backup which can be used to restore to a previous configuration.
                                                                #   Use the following command to restore a previous configuration: pcs config restore <backup>
    beegfs_ha_backup_path: /tmp/                                # Pcs backup file path.            

    # Required sysctl configuration defaults  
    beegfs_ha_required_sysctl_entries:
      net.ipv4.conf.all.rp_filter: 1
      net.ipv4.conf.all.arp_filter: 1
      net.ipv4.conf.all.arp_announce: 2
      net.ipv4.conf.all.arp_ignore: 2

    # Performance tuning defaults (See `Performance Tuning` section below more information)
    beegfs_ha_enable_performance_tuning: False                  # Whether to enable performance tuning.
    beegfs_ha_eseries_scheduler: noop                           # Raw volume device (dm-X) scheduler value.
    beegfs_ha_eseries_nr_requests: 64                           # Raw volume device (dm-X) nr_requests value.
    beegfs_ha_eseries_read_ahead_kb: 4096                       # Raw volume device (dm-X) read_ahead_kb value.
    beegfs_ha_eseries_max_sectors_kb: 1024                      # Raw volume device (dm-X) max_sectors_kb value.
    beegfs_ha_performance_sysctl_entries:
      vm.dirty_background_ratio: 1
      vm.dirty_ratio: 75
      vm.vfs_cache_pressure: 50
      vm.min_free_kbytes: 262144
      vm.zone_reclaim_mode: 1
      vm.watermark_scale_factor: 1000

    # Performance tuning defaults for metadata service settings
    beegfs_metadata_maximum_node_connections: 128               # beegfs_meta.conf connMaxInternodeNum value - maximum number of simultaneous connections to the same node. Default: 32
    beegfs_metadata_worker_threads: 32                          # beegfs_meta.conf tuneNumWorkers value - number of worker threads. Higher number of workers allows the server to handle more client requests in parallel.
                                                                #   On dedicated metadata servers, this is typically set to a value between four and eight times the number of CPU cores. Note: 0 means use twice the number
                                                                #   of CPU cores (but at least 4). Default: 0
    beegfs_metadata_file_creation_target_algorithm: randomized  # beegfs_meta.conf TuneTargetChooser value - The algorithm to choose storage targets for file creation.
                                                                #   Choices: [randomized, roundrobin, randomrobin, randominternode, randomintranode] Default: randomized
        
    # Performance tuning defaults for storage service settings
    beegfs_storage_maximum_node_connections: 128                # beegfs_storage.conf connMaxInternodeNum value - maximum number of simultaneous connections to the same node. Default: 12
    beegfs_storage_incoming_data_event_threads: 2               # The number of threads waiting for incoming data events. Connections with incoming data will be handed over to the worker threads for actual message processing. Default: 1
    beegfs_storage_worker_threads: 14                           # beegfs_storage.conf tuneNumWorkers value - number of worker threads. Higher number of workers allows the server to handle more client requests in parallel.
                                                                #   On dedicated metadata servers, this is typically set to a value between four and eight times the number of CPU cores.
                                                                #   Note: 0 means use twice the number of CPU cores (but at least 4). Default: 12
    beegfs_storage_use_aggressive_stream_polling: true          # If set to true, the StreamListener component, which waits for incoming requests, will keep actively polling for events instead of sleeping until an event occurs.
                                                                #   Active polling will reduce latency for processing of incoming requests at the cost of higher CPU usage. Default: false
    beegfs_storage_maximum_write_chunk_size: 2048k              # The maximum amount of data that the server should write to the underlying local file system in a single operation. Default: 2048k
    beegfs_storage_maximum_read_chunk_size: 2048k               # The maximum amount of data that the server should read to the underlying local file system in a single operation. Default: 2048k

    # NTP configuration defaults (see the `NTP` section below for more information) 
    beegfs_ha_ntp_configuration_file: /etc/ntp.conf             # Absolute file path for ntp.conf
    beegfs_ha_ntp_server_pools:                                 # List of ntp server pools.
      - "server 0.ubuntu.pool.ntp.org iburst"
      - "server 1.ubuntu.pool.ntp.org iburst"
      - "server 2.ubuntu.pool.ntp.org iburst"
      - "server 3.ubuntu.pool.ntp.org iburst"
    beegfs_ha_ntp_restricts:                                    # Band addresses to acquire time from NTP services.
      - 127.0.0.1
      - ::1

    # These variables don't need to be changed unless you want to use use different inventory group names:     
    beegfs_ha_ansible_cluster_group: ha_cluster                 # Ansible inventory group name for the BeeGFS HA cluster. Define all resource group in this group.
    beegfs_ha_ansible_storage_group: eseries_storage_systems    # Ansible inventory group name for the BeeGFS HA E-Series storage systems.

    # These values will likely not need to be changed:
    beegfs_ha_node_preference_scope_step: 200                   # Arbitrary constraint scope step between ordered hosts in the inventory file resource host group.
    beegfs_ha_cluster_resource_defaults:                        # Pacemaker resource defaults dictionary. These will be applied across all resource groups.
      resource-stickiness: 15000
    beegfs_ha_force_resource_move: true                         # Forces node and resource changes to migrate services to preferred nodes.
    beegfs_ha_storage_system_hostgroup_prefix: beegfs           # Prefix that is added to the storage system's host group name which is created to map volumes to
                                                                #   all cluster nodes within the specific resource group.

    # Corosync defaults
    beegfs_ha_corosync_authkey_path: /etc/corosync/authkey                # Absolute path for the Corosync authkey file.
    beegfs_ha_corosync_conf_path: /etc/corosync/corosync.conf             # Absolute path for the Corosync configuration file.
    beegfs_ha_corosync_log_path: /var/log/corosync.log                    # Absolute path for the Corosync log file.

    # Pcs defaults
    beegfs_ha_pcsd_pcsd_path: /var/lib/pcsd/                    # Absolute path for the pcsd directory.

    # Performance tuning defaults for both metadata and storage service settings
    beegfs_ha_numa:                                             # NUMA node binding for BeeGFS service. This should be defined at the resource group level. This NUMA policy will be applied whenever and
                                                                #   wherever the BeeGFS service resides. This can provide significant performance increases by avoiding the cache misses between NUMA nodes.

    # Performance tuning defaults for metadata service settings
    beegfs_ha_metadata_maximum_node_connections:                # beegfs_meta.conf connMaxInternodeNum value - maximum number of simultaneous connections to the same node. Default: 32
    beegfs_ha_metadata_worker_threads:                          # beegfs_meta.conf tuneNumWorkers value - number of worker threads. Higher number of workers allows the server to handle more client requests in parallel. On dedicated metadata
                                                                #   servers, this is typically set to a value between four and eight times the number of CPU cores. Note: 0 means use twice the number of CPU cores (but at least 4). Default: 32
    beegfs_ha_metadata_file_creation_target_algorithm:          # beegfs_meta.conf TuneTargetChooser value - The algorithm to choose storage targets for file creation.
                                                                #   Choices: [randomized, roundrobin, randomrobin, randominternode, randomintranode] Default: roundrobin

    # Performance tuning defaults for storage service settings
    beegfs_ha_storage_maximum_node_connections:                 # beegfs_storage.conf connMaxInternodeNum value - maximum number of simultaneous connections to the same node. Default: 128
    beegfs_ha_storage_incoming_data_event_threads:              # The number of threads waiting for incoming data events. Connections with incoming data will be handed over to the worker threads for actual message processing. Default: 2
    beegfs_ha_storage_worker_threads:                           # beegfs_storage.conf tuneNumWorkers value - number of worker threads. Higher number of workers allows the server to handle more client requests in parallel. On dedicated metadata servers,
                                                                #   this is typically set to a value between four and eight times the number of CPU cores. Note: 0 means use twice the number of CPU cores (but at least 4). Default: 14
    beegfs_ha_storage_use_aggressive_stream_polling:            # If set to true, the StreamListener component, which waits for incoming requests, will keep actively polling for events instead of sleeping until an
                                                                #   event occurs. Active polling will reduce latency for processing of incoming requests at the cost of higher CPU usage. Default: true
    beegfs_ha_storage_maximum_write_chunk_size:                 # The maximum amount of data that the server should write to the underlying local file system in a single operation. Default: 2048k
    beegfs_ha_storage_maximum_read_chunk_size:                  # The maximum amount of data that the server should read to the underlying local file system in a single operation. Default: 2048k


    # Package version defaults (Warning! Only the patch version can change.)
    beegfs_ha_beegfs_version:                                   # BeeGFS package version.
    beegfs_ha_pacemaker_version:                                # Pacemaker package version.
    beegfs_ha_corosync_version:                                 # Corosync package version.
    beegfs_ha_pcs_version:                                      # PCS package version.
    beegfs_ha_fence_agents_all_version:                         # Fence-agent-all package.
    beegfs_ha_force_beegfs_patch_upgrade:                       # Major and master versions must not change; however the patch versions can and this flag will ensure that its the latest version. Default: false

    # Uninstall defaults (See `Uninstall` section below more information)
    beegfs_ha_uninstall: false                                          # Whether to uninstall the entire BeeGFS HA solution excluding the storage provisioning and host storage setup.
    beegfs_ha_uninstall_unmap_volumes: false                            # Whether to unmap the volumes from the host only. This will not effect the data.
    beegfs_ha_uninstall_wipe_format_volumes: false                      # Whether to wipe format signitures from volumes on the host. **WARNING! This action is unrecoverable.**
    beegfs_ha_uninstall_delete_volumes: false                           # Whether to delete the volumes from the storage. **WARNING! This action is unrecoverable.**
    beegfs_ha_uninstall_delete_storage_pools_and_host_mappings: false   # Whether to delete all storage pools/volume groups and host/host group mappings created for BeeGFS HA solution.
                                                                        #   Be aware that removing storage pools/volume groups and host/host group mappings will effect any volumes or
                                                                        #   host mappings dependent on them.  **WARNING! This action is unrecoverable.**
    beegfs_ha_uninstall_storage_setup: false                            # Whether to remove configuration that allows storage to be accessible to the BeeGFS HA node (i.e. multipath, communications protocols (iSCSI, IB iSER)).
    beegfs_ha_uninstall_reboot: false                                   # Whether to reboot after uninstallation.


    # Volume formatting and mounting defaults. Note: sync must always be included in mount_options otherwise data loss may occur (sync disables caching)
    beegfs_ha_service_volume_configuration:
      management:                                                           # BeeGFS management service volume definition.
        format_type: ext4                                                   # Volume format type
        format_options: "-i 2048 -I 512 -J size=400 -Odir_index,filetype"   # Volume format options
        mount_options: "sync,noatime,nodiratime,nobarrier"                  # Volume mount options
        mount_dir: /mnt/                                                    # Volume mount directory
      metadata:                                                             # BeeGFS metadata service volume definition.
        format_type: ext4                                                   # (...)
        format_options: "-i 2048 -I 512 -J size=400 -Odir_index,filetype"
        mount_options: "sync,noatime,nodiratime,nobarrier
        mount_dir: /mnt/
      storage:                                                              # BeeGFS storage service volume definition.
        format_type: xfs                                                    # (...)
        format_options: "-d su=VOLUME_SEGMENT_SIZE_KBk,sw=VOLUME_STRIPE_COUNT -l version=2,su=VOLUME_SEGMENT_SIZE_KBk"
        mount_options: "sync,noatime,nodiratime,logbufs=8,logbsize=256k,largeio,inode64,swalloc,allocsize=131072k,nobarrier"
        mount_dir: /mnt/

    # General path defaults
    beegfs_ha_pcsd_tokens: /var/lib/pcsd/tokens                       # PCS daemon tokens absolute file path.
    beegfs_ha_pacemaker_cib_xml: /var/lib/pacemaker/cib/cib.xml       # Pacemaker cib.xml absolute file path.
    beegfs_ha_uninstall_pacemaker_cib_dir: /var/lib/pacemaker/cib/    # Pacemaker cib directory absolute path.
    beegfs_ha_uninstall_pcsd_dir: /var/lib/pcsd/                      # PCS daemon directory absolute path.

    # Debian / Ubuntu repository defaults
    beegfs_ha_debian_repository_base_url: https://www.beegfs.io/release/beegfs_7.2.5
    beegfs_ha_debian_repository_gpgkey: https://www.beegfs.io/release/beegfs_7.2.5/gpg/DEB-GPG-KEY-beegfs


    # RedHat / CentOS repository defaults
    beegfs_ha_rhel_repository_base_url: https://www.beegfs.io/release/beegfs_7.2.5/dists/rhel8
    beegfs_ha_rhel_repository_gpgkey: https://www.beegfs.io/release/beegfs_7.2.5/gpg/RPM-GPG-KEY-beegfs


    # SUSE repository defaults
    beegfs_ha_suse_allow_unsupported_module: true
    beegfs_ha_suse_repository_base_url: https://www.beegfs.io/release/beegfs_7.2.5/dists/sles15
    beegfs_ha_suse_repository_gpgkey: https://www.beegfs.io/release/beegfs_7.2.5/gpg/RPM-GPG-KEY-beegfs


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

## General Notes
-------------
- All BeeGFS cluster nodes need to be available.
- Fencing agents should be used to ensure failed nodes are definitely down.  
  - WARNING! If beegfs_ha_enable_fence is set to false then a fencing agent will not be configured!
- Uninstall functionality will remove required BeeGFS 7.2 packages. This means that there will be no changes made to the kernel development/NTP/chrony packages whether they previously existed or not.
- Please refer to the documentation for your Linux distribution/version for guidance on the maximum cluster size. For example the limitations for RedHat can be found [here](https://access.redhat.com/articles/3069031).

## Override Default Templates
--------------------------
All templates found in beegfs_ha_7_2/templates/ can be overridden by create a template in <PLAYBOOK_DIRECTORY>/templates/beegfs_ha_7_2/<RELATIVE_TEMPLATE_PATH>/<TEMPLATE_NAME>. Start by copying the default template and make your modifications to it. Do not modify the existing Jinja2 statements.

    beegfs_project/
        templates/
            beegfs_ha_7_2/
                metadata/
                    beegfs_meta_conf.j2
                storage/
                    beegfs_storage_conf.j2
        playbook.yml
        inventory.yml

You may wish to override some configuration parameters found in these templates on a per-resource group basis. While common parameters (for example NUMA zones) already have a variable that can be set in each resource group's "group_vars" file, you can easily modify the templates to be able to specify your own variables by replacing the default configuration value with a Jinja2 expression. For consistency and to ensure a default is provided if the variable is unset, we recommend the following Jinja2 expression: {{ beegfs_ha_X | default(<DEFAULT_VALUE>) }}. For example you could replace the line tuneNumStreamListeners = 1 with tuneNumStreamListeners = {{ beegfs_ha_tuneNumeStreamListeners | default('1') }}. Then simply set beegfs_ha_tuneNumeStreamListeners under any of the group_vars/<resource_group>.yml you want to override.

## NTP (`beegfs_ha_ntp_enabled: true`)
-----------------------------------
Time synchronization is required for BeeGFS to function properly. As a convenience to users the BeeGFS role provides functionality that can configure the ntpd service on all BeeGFS nodes by setting `beegfs_ha_ntp_enabled: True`. By default this variable is set to `False` to avoid conflicts with any existing NTP configuration that might be in place. If this variable is set to `True` please note any existing Chrony installations will be removed as they would conflict with ntpd.

The template used to generate the /etc/ntp.conf file can be found at `roles/beegfs_ha_7_2/templates/common/ntp_conf.j2`. Depending on the security policies of your organization, you way wish to adjust the default configuration.

* Some Linux installations may be setup to have the DHCP client periodically update /etc/ntp.conf with NTP servers from the DHCP server. You can tell this is happening if text like the following is appended to the bottom of /etc/ntp.conf:
    ```
    server <IP_ADDR>  # added by /sbin/dhclient-script
    ```
    As a result the NTP related Ansible tasks will be marked as changed whenever the role is reapplied. If you're wanting to manage the NTP configuration outside Ansible simply set `beegfs_ha_ntp_enabled: False` to prevent the role from configuring NTP.

## Performance Tuning (`beegfs_ha_enable_performance_tuning: False`)
-----------------------------------------------------------------
Performance tuning is disabled by default, but can be enabled by setting `beegfs_ha_enable_performance_tuning: True`. The default is to avoid a scenario where users are unaware these are being set, and they result in poor performance or stability issues that are difficult to troubleshoot. There is also the added consideration the default values will likely need to be adjusted to achieve optimal performance for a given hardware configuration.

BeeGFS calls out a number of parameters at https://www.beegfs.io/wiki/StorageServerTuning and https://www.beegfs.io/wiki/MetaServerTuning that can be used to improve the performance of BeeGFS storage and metadata services. To help simplify performance tuning for BeeGFS storage and metadata nodes, the BeeGFS role provides the following functionality:

1) Tuning kernel parameters using sysctl.
2) Tuning parameters on E-Series block devices/paths using udev.

While default values for all tuning parameters are defined at `roles/beegfs_ha_7_2/defaults/main.yml`, more than likely these will need to be adjusted to tune based on the environment. As with any Ansible variable, you can override these defaults on a host-by-host or group basis to tune each node or sets of nodes differently.

To only run tasks related to BeeGFS performance tuning, use the tag "beegfs_ha_performance_tuning" in your Ansible playbook command (e.g. `ansible-playbook -i inventory.yml playbook.yml --tags beegfs_ha_performance_tuning`). This will greatly reduce playbook runtime when simply wishing to make incremental adjustments to these parameters during benchmark testing.

#### Tuning kernel parameters using sysctl:

BeeGFS recommends setting various kernel parameters under /proc/sys to help optimize the performance of BeeGFS storage/metadata nodes. One option to ensure these changes are persistent are setting them using sysctl. By default this role will will override the following parameters on BeeGFS storage and metadata nodes in /etc/sysctl.conf on RedHat or /etc/sysctl.d/99-eseries-beegfs.conf on SUSE:

    beegfs_ha_performance_sysctl_entries:
      vm.dirty_background_ratio: 5
      vm.dirty_ratio: 20
      vm.vfs_cache_pressure: 50
      vm.min_free_kbytes: 262144
      vm.zone_reclaim_mode: 1

Important:
- If you define your own `beegfs_ha_performance_sysctl_entries` you will need to explicitly list all sysctl key/value pairs you wish to be set.
- The documentation for some Linux distributions indicates you need to rebuild the initramfs after modifying the values of kernel variables using sysctl (reference: https://documentation.suse.com/sles/12-SP4/html/SLES-all/cha-boot.html#var-initrd-regenerate-kernelvars). Based on testing these values do persist through a reboot for the operating systems listed on the support matrix, and thus is not done automatically by the role. It is recommended users verify these settings persist in their environment, and rebuild the initramfs if needed.

#### Tuning parameters on E-Series block devices/paths using udev:

The following variables should be used to optimize performance for storage and metadata volumes:

- `beegfs_ha_eseries_scheduler: noop` -> `/sys/block/<device>/queue/scheduler`
- `beegfs_ha_eseries_nr_requests: 64` -> `/sys/block/<device>/queue/nr_requests`
- `beegfs_ha_eseries_read_ahead_kb: 4096` -> `/sys/block/<device>/queue/read_ahead_kb`
- `beegfs_ha_eseries_max_sectors_kb: 1024` -> `/sys/block/<device>/queue/max_sectors_kb`

Note these will be applied to both the device mapper entry (e.g. dm-X) and underlying path (e.g. sdX).

#### Advanced:
- If it is desired to set additional parameters on E-Series devices using udev, the template for the rule is located at `roles/beegfs_ha_7_2/templates/common/eseries_beegfs_ha_udev_rule.j2`. Please note modifications to this file require an understanding of Ansible, Jinja2, udev and bash scripting and are made at the user's risk.
- The udev rule will be created on BeeGFS storage/metadata nodes at `/etc/udev/rules.d/99-eseries-beegfs-ha.rules`.

#### Restrictions:
- If BeeGFS Metadata and Storage services are running on the same node, there is no way to set different sysctl entries or udev rules to tune servers and LUNs used for metadata vs. storage differently.
- If `max_hw_sectors_kb` on a device is lower than max_sectors_kb you attempt to configure using udev, based on testing the device will be set at the max_hw_sectors_kb value and the udev setting is ignored.
  - The `hw_max_sectors_kb` value can vary depending on the device (example: InfiniBand HCA) used to attach the host to external storage (either direct or through a fabric). Some device drivers may support changing parameters that allow the hw_max_sectors value to increase, but this is outside the scope of this documentation and Ansible role.
  - The hardware versus configured value can be verified by substituting your devices in the following commands `cat /sys/block/[sdX|dm-X]/queue/max_hw_sectors_kb` and `cat /sys/block/[sdX|dm-X]/queue/max_sectors_kb`.    
