netapp_eseries.beegfs_beegfs_ha_7_1 Role
========================================
    The netapp_eseries.beegfs_beegfs_ha_7_1 role is a complete end-to-end deployment of the NetApp E-Series BeeGFS HA solution (LINK TO TR). This role utilizes the netapp_eseries santricity and host collections which allows users to not only configure the BeeGFS file system with HA but will also provision storage and ensure the communications between the storage and hosts.
    For a complete inventory and playbook examples checkout https://github.com/netappeseries/beegfs/examples/beegfs_ha_7_1. This directory provides useful examples of working BeeGFS group and host inventory files.

Requirements
------------
    - Ansible 2.9 or later
    - NetApp E-Series E2800 platform or newer or NetApp E-Series SANtricity Web Services Proxy configured for older E-Series Storage arrays.
    - Redhat 7+ for all BeeGFS HA nodes.

Example Playbook
----------------
    - hosts: all
      gather_facts: false
      collections:
        - netapp_eseries.beegfs
      tasks:
        - name: Ensure BeeGFS HA cluster is setup.
          import_role:
            name: beegfs_ha_7_1

Example Inventory
-----------------
    all:
      vars:
        ansible_python_interpreter: /usr/bin/python
      children:

        eseries_storage_systems:
          hosts:
            eseries_storage_system_01:
              eseries_system_api_url: https://192.168.1.200:8443/devmgr/v2/
              eseries_system_password: adminpass
              eseries_validate_certs: false
              eseries_initiator_protocol: iscsi

        ha_cluster:
          vars:
            beegfs_ha_ansible_host_group: ha_cluster
            beegfs_ha_ansible_storage_group: eseries_storage_systems
            beegfs_ha_cluster_name: hacluster
            beegfs_ha_cluster_username: hacluster
            beegfs_ha_cluster_password: hapassword
            beegfs_ha_mgmtd_floating_ip: 192.168.1.230
            filter_ip_ranges:
              - 192.168.2.0/24
              - 192.168.3.0/24
            beegfs_ha_alert_email_list: ["jack@example.com", "jill@example.com"]
            beegfs_ha_fencing_agents:
              fence_vmware_rest: # Each entry is name fence_vmware_rest_X where X is the ordered list index.
                - pcmk_host_map: "node_mm1:vm_node_mm1;node_mm2:vm_node_mm2;node_ss1:vm_node_ss1;node_ss2:vm_node_ss2"
                  ipaddr: 192.168.4.10
                  ssl: 1
                  ssl_insecure: 1
                  login: example@vsphere.local
                  passwd: vspherepass
          children:
            mgmt:       # Resource group name must be 10 characters or less because the resource group is used to name the floating ip resource iflabel.
              hosts:    # hosts ordering will be used to determine resource constraint opt-in preferences (highest to lowest).
                node_mm1:
                node_mm2:
              vars:
                port: 8008
                floating_ips:
                  - "eth1:192.168.2.230/24"
                  - "eth2:192.168.3.231/24"
                beegfs_service: management
                beegfs_targets:                            # Only one target volume is needed for the management service.
                  eseries_storage_system_01:               # Ansible hostname for E-Series storage system.
                    eseries_storage_pool_configuration:    # netapp_eseries.santricity.nar_santricity_host role structure. See https://galaxy.ansible.com/netapp_eseries/santricity.
                      - name: mgmt_meta_01_02              # The name parameter is only required when multiple service targets are utilizing the same volume group.
                        raid_level: raid1                  # RAID level
                        criteria_drive_count: 2            # Required number of drives
                        volumes:                           # Do not specify volume name parameter; it will be automatically determined.
                          - size: 10                       # Size parameter default size is gibibytes.
            meta_01:
              hosts:
                node_mm2:
                node_mm1:
              vars:
                port: 8005
                floating_ips:
                  - "eth1:192.168.2.232/24"
                  - "eth2:192.168.3.233/24"
                beegfs_service: metadata
                beegfs_targets:
                  eseries_storage_system_01:
                    eseries_storage_pool_configuration:
                      - name: mgmt_meta_01_02
                        raid_level: raid1
                        criteria_drive_count: 2
                        volumes:
                          - size: 100
            meta_02:
              hosts:
                node_mm1:
                node_mm2:
              vars:
                port: 8045
                floating_ips:
                  - "eth1:192.168.2.234/24"
                  - "eth2:192.168.3.235/24"
                beegfs_service: metadata
                beegfs_targets:
                  eseries_storage_system_01:
                    eseries_storage_pool_configuration:
                      - name: mgmt_meta_01_02
                        raid_level: raid1
                        criteria_drive_count: 2
                        volumes:
                          - size: 100
            stor_01:
              hosts:
                node_ss1:
                node_ss2:
              vars:
                port: 8012
                floating_ips:
                  - "eth1:192.168.2.236/24"
                  - "eth2:192.168.3.237/24"
                beegfs_service: storage
                beegfs_targets:
                  eseries_storage_system_01:
                    eseries_storage_pool_configuration:
                      - raid_level: raid6
                        criteria_drive_count: 10
                        volumes:
                          - size: 2048
                          - size: 2048
                          - size: 2048
                          - size: 2048
                      - raid_level: raid6
                        criteria_drive_count: 10
                        volumes:
                          - size: 2048
                          - size: 2048
                          - size: 2048
                          - size: 2048
            stor_02:
              hosts:
                node_ss1:
                node_ss2:
              vars:
                port: 8050
                floating_ips:
                  - "eth1:192.168.2.238/24"
                  - "eth2:192.168.3.239/24"
                beegfs_service: storage
                beegfs_targets:
                  eseries_storage_system_01:
                    eseries_storage_pool_configuration:
                      - raid_level: raid6
                        criteria_drive_count: 10
                        volumes:
                          - size: 2048
                          - size: 2048
                          - size: 2048
                          - size: 2048
                      - raid_level: raid6
                        criteria_drive_count: 10
                        volumes:
                          - size: 2048
                          - size: 2048
                          - size: 2048
                          - size: 2048

Example Host Inventory File
---------------------------
    ansible_host: 192.168.1.226
    ansible_ssh_user: admin
    ansible_become_password: adminpass

    eseries_iscsi_iqn: iqn.1994-05.com.redhat:node_mm1
    eseries_iscsi_interfaces:
      - name: eth1
        address: 192.168.2.226/24
      - name: eth2
        address: 192.168.3.226/24

    beegfs_ha_client: true
    beegfs_ha_client_connInterfaces:
      - eth0
      - eth1

Example Project
---------------
    See https://github.com/netappeseries/host/tree/master/beegfs_ha_7_1 example_project.

Role Tags
---------
    Use the following tags when executing you BeeGFS HA playbook to only execute select tasks.
        example: ansible-playbook -i inventory.yml playbook.yml --tags beegfs_ha_configure

    - storage                       # Provisions storage and ensures volumes are presented on hosts.
    - beegfs_ha                     # All BeeGFS HA tasks.
    - beegfs_ha_package             # All BeeGFS HA package tasks.
    - beegfs_ha_configure           # All BeeGFS HA configuration tasks (Ensure volumes are present and BeeGFS packages are installed).
    - beegfs_ha_performance_tuning  # All BeeGFS HA performance tuning tasks (Ensure volumes are present and BeeGFS packages are installed).

General Notes
-------------
    - All nodes need to be available and if the BeeGFS HA solution is active then all services need to be running on their preferred nodes.
    - Fencing agents should be used to ensure failed nodes are definitely down.  WARNING! If beegfs_ha_enable_fence is set to false then a fencing agent will not be configured!
    - Uninstall functionality will remove required BeeGFS 7.1 packages. This means that there will be no changes made to the kernel development/NTP/chrony packages whether they previously existed or not.
    - BeeGFS is added to the PRUNEFS list in /etc/updatedb.conf to prevent daily indexing scans on clients which causes performance degradations.

NTP (`beegfs_ha_ntp_enabled: true`)
-----------------------------------
    Time synchronization is required for BeeGFS to function properly. As a convenience to users the BeeGFS role provides functionality that can configure the ntpd service on all BeeGFS nodes by setting `beegfs_ha_ntp_enabled: True`. By default this variable is set to `False` to avoid conflicts with any existing NTP configuration that might be in place. If this variable is set to `True` please note any existing Chrony installations will be removed as they would conflict with ntpd.
    The template used to generate the /etc/ntp.conf file can be found at `roles/beegfs_ha_7_1/templates/common/ntp_conf.j2`. Depending on the security policies of your organization, you way wish to adjust the default configuration.
    * Some Linux installations may be setup to have the DHCP client periodically update /etc/ntp.conf with NTP servers from the DHCP server. You can tell this is happening if text like the following is appended to the bottom of /etc/ntp.conf:
    ```
    server <IP_ADDR>  # added by /sbin/dhclient-script
    ```
    As a result the NTP related Ansible tasks will be marked as changed whenever the role is reapplied. If you're wanting to manage the NTP configuration outside Ansible simply set `beegfs_ha_ntp_enabled: False` to prevent the role from configuring NTP.

Performance Tuning (`beegfs_ha_enable_performance_tuning: False`)
-------------------------------------------------------------
    Performance tuning is disabled by default, but can be enabled by setting `beegfs_ha_enable_performance_tuning: True`. The default is to avoid a scenario where users are unaware these are being set, and they result in poor performance or stability issues that are difficult to troubleshoot. There is also the added consideration the default values will likely need to be adjusted to achieve optimal performance for a given hardware configuration.

    BeeGFS calls out a number of parameters at https://www.beegfs.io/wiki/StorageServerTuning and https://www.beegfs.io/wiki/MetaServerTuning that can be used to improve the performance of BeeGFS storage and metadata services. To help simplify performance tuning for BeeGFS storage and metadata nodes, the BeeGFS role provides the following functionality:

    1) Tuning kernel parameters using sysctl.
    2) Tuning parameters on E-Series block devices/paths using udev.

    While default values for all tuning parameters are defined at `roles/beegfs_ha_7_1/defaults/main.yml`, more than likely these will need to be adjusted to tune based on the environment. As with any Ansible variable, you can override these defaults on a host-by-host or group basis to tune each node or sets of nodes differently.

    To only run tasks related to BeeGFS performance tuning, use the tag "beegfs_ha_performance_tuning" in your Ansible playbook command (e.g. `ansible-playbook -i inventory.yml playbook.yml --tags beegfs_ha_performance_tuning`). This will greatly reduce playbook runtime when simply wishing to make incremental adjustments to these parameters during benchmark testing.

    #### Tuning kernel parameters using sysctl:

    BeeGFS recommends setting various kernel parameters under /proc/sys to help optimize the performance of BeeGFS storage/metadata nodes. One option to ensure these changes are persistent are setting them using sysctl. By default this role will will override the following parameters on BeeGFS storage and metadata nodes in /etc/sysctl.conf on RedHat or /etc/sysctl.d/99-eseries-beegfs.conf on SUSE:

        beegfs_ha_sysctl_entries:
          vm.dirty_background_ratio: 5
          vm.dirty_ratio: 20
          vm.vfs_cache_pressure: 50
          vm.min_free_kbytes: 262144
          vm.zone_reclaim_mode: 1

    Important:
    - If you define your own `beegfs_ha_sysctl_entries` you will need to explicitly list all sysctl key/value pairs you wish to be set.
    - The documentation for some Linux distributions indicates you need to rebuild the initramfs after modifying the values of kernel variables using sysctl (reference: https://documentation.suse.com/sles/12-SP4/html/SLES-all/cha-boot.html#var-initrd-regenerate-kernelvars). Based on testing these values do persist through a reboot for the operating systems listed on the support matrix, and thus is not done automatically by the role. It is recommended users verify these settings persist in their environment, and rebuild the initramfs if needed.

    #### Tuning parameters on E-Series block devices/paths using udev:

    The following variables should be used to optimize performance for storage and metadata volumes:

    - `beegfs_ha_eseries_scheduler: noop` -> `/sys/block/<device>/queue/scheduler`
    - `beegfs_ha_eseries_nr_requests: 64` -> `/sys/block/<device>/queue/nr_requests`
    - `beegfs_ha_eseries_read_ahead_kb: 4096` -> `/sys/block/<device>/queue/read_ahead_kb`
    - `beegfs_ha_eseries_max_sectors_kb: 1024` -> `/sys/block/<device>/queue/max_sectors_kb`

    Note these will be applied to both the device mapper entry (e.g. dm-X) and underlying path (e.g. sdX).

    ##### Advanced:
    - If it is desired to set additional parameters on E-Series devices using udev, the template for the rule is located at `roles/beegfs_ha_7_1/templates/common/eseries_beegfs_ha_udev_rule.j2`. Please note modifications to this file require an understanding of Ansible, Jinja2, udev and bash scripting and are made at the user's risk.
    - The udev rule will be created on BeeGFS storage/metadata nodes at `/etc/udev/rules.d/99-eseries-beegfs-ha.rules`.

    #### Restrictions:
    - If BeeGFS Metadata and Storage services are running on the same node, there is no way to set different sysctl entries or udev rules to tune servers and LUNs used for metadata vs. storage differently.
    - If `max_hw_sectors_kb` on a device is lower than max_sectors_kb you attempt to configure using udev, based on testing the device will be set at the max_hw_sectors_kb value and the udev setting is ignored.
      - The `hw_max_sectors_kb` value can vary depending on the device (example: InfiniBand HCA) used to attach the host to external storage (either direct or through a fabric). Some device drivers may support changing parameters that allow the hw_max_sectors value to increase, but this is outside the scope of this documentation and Ansible role.
      - The hardware versus configured value can be verified by substituting your devices in the following commands `cat /sys/block/[sdX|dm-X]/queue/max_hw_sectors_kb` and `cat /sys/block/[sdX|dm-X]/queue/max_sectors_kb`.

Role Variables
--------------
    # General configuration defaults
    beegfs_ha_ansible_host_group: ha_cluster                    # Ansible inventory group name for the BeeGFS HA cluster. Define all resource group in this group.
    beegfs_ha_ansible_storage_group: eseries_storage_systems    # Ansible inventory group name for the BeeGFS HA E-Series storage systems.
    beegfs_ha_cluster_name: hacluster                           # Name for the pacemaker cluster.
    beegfs_ha_cluster_username: hacluster                       # Pacemaker cluster username.
    beegfs_ha_cluster_password: hapassword                      # Pacemaker cluster password.
    beegfs_ha_cluster_password_sha512_salt: random$alt          # Pacemaker cluster password sha512 encryption salt.
    beegfs_ha_ntp_enabled: true                                 # Whether NTP should be enabled.
    beegfs_ha_enable_alerts: true                               # Whether to enable pacemaker email alerts.
    beegfs_ha_alert_email_list: []                              # Pacemaker alert email recipients.
    beegfs_ha_alert_email_subject: "ClusterNotification"        # Alert email subject line.
    beegfs_ha_enable_auto_tie_breaker: true                     # Whether to enable automatic node quorum tie breaker.
    beegfs_ha_enable_auto_tie_breaker_force_update: false       # Whether to change automatic node quorum tie breaker settings when BeeGFS HA services are active.
                                                                #   WARNING! This will force the BeeGFS HA services to restart.
    beegfs_ha_enable_quota: false                               # Whether to enable BeeGFS file system quotas.
    beegfs_ha_enable_fence: true                                # Whether to enable pacemaker STONITH fencing agents.
    beegfs_ha_filter_ip_ranges: []                              # BeeGFS IPv4 CIDR subnet filters. This forces BeeGFS to only listen on these subnets.
    beegfs_ha_node_preference_scope_step: 200                   # Arbitrary constraint scope step between ordered hosts in the inventory file resource host group.
    beegfs_ha_cluster_resource_defaults:                        # Pacemaker resource defaults dictionary. These will be applied across all resource groups.
      resource-stickiness: 15000
    beegfs_ha_backup: true                                      # Whether to create a PCS backup which can be used to restore to a previous configuration.
                                                                #   Use the following command to restore a previous configuration: pcs config restore <backup>
    beegfs_ha_backup_path: /tmp/                                # PCS backup file path.

    # BeeGFS client defaults
    beegfs_ha_client: false                                     # Whether node should be a BeeGFS client.
    beegfs_ha_client_connInterfaces:                            # List of node interfaces to use to communicate with the BeeGFS file system.
    beegfs_ha_client_udp_port: 8004                             # Client UDP port to communicate with the BeeGFS file system.
    beegfs_ha_helperd_tcp_port: 8006                            # Client helper daemon TCP port.
    beegfs_ha_client_configuration_directory: "/etc/beegfs/"    # Client directory path for the BeeGFS client configuration.
    beegfs_ha_client_updatedb_conf_path: "/etc/updatedb.conf"   # Client directory path for mlocate package configuration file.

    # RDMA defaults
    beegfs_ha_enable_rdma: false                                # Whether to enable RDMA.
    beegfs_ha_ofed_include_path: /usr/src/openib/include        # OFED library include path.

    # Performance tuning defaults (See `Performance Tuning` section above more information)
    beegfs_ha_enable_performance_tuning: False                  # Whether to enable performance tuning.
    beegfs_ha_eseries_scheduler: noop                           # Raw volume device (dmX) scheduler value.
    beegfs_ha_eseries_nr_requests: 64                           # Raw volume device (dmX) nr_requests value.
    beegfs_ha_eseries_read_ahead_kb: 4096                       # Raw volume device (dmX) read_ahead_kb value.
    beegfs_ha_eseries_max_sectors_kb: 1024                      # Raw volume device (dmX) max_sectors_kb value.
    beegfs_ha_sysctl_entries:                                   # Kernel paremeter settings
      vm.dirty_background_ratio: 5
      vm.dirty_ratio: 20
      vm.vfs_cache_pressure: 50
      vm.min_free_kbytes: 262144
      vm.zone_reclaim_mode: 1

    # NTP configuration defaults
    beegfs_ha_ntp_configuration_file: /etc/ntp.conf   # Absolute file path for ntp.conf
    beegfs_ha_ntp_server_pools:                       # List of ntp server pools.
      - "server 0.ubuntu.pool.ntp.org iburst"
      - "server 1.ubuntu.pool.ntp.org iburst"
      - "server 2.ubuntu.pool.ntp.org iburst"
      - "server 3.ubuntu.pool.ntp.org iburst"
    beegfs_ha_ntp_restricts:                          # Band addresses to acquire time from NTP services.
      - 127.0.0.1
      - ::1

    # Uninstall defaults
    beegfs_ha_delete_data_and_uninstall_beegfs: false   # Uninstall flag for all BeeGFS HA install packages and configuration.
    beegfs_ha_uninstall_reboot: true                    # Whether to reboot after uninstallation.

    # Package version defaults
    beegfs_ha_beegfs_version: 7.1                # Default BeeGFS package version
    beegfs_ha_corosync_version: 2.4.5-4          # Default Corosync package version
    beegfs_ha_pacemaker_version: 1.1.21-4        # Default Pacemaker package version
    beegfs_ha_pcs_version: 0.9.168               # Default PCS package version
    beegfs_ha_fence_agents_all_version:          # Default Fence agent package version
    beegfs_ha_force_beegfs_patch_upgrade: true   # Whether to upgrade the patch version of packages.

    # Volume formatting and mounting defaults
    beegfs_ha_service_volume_configuration:
      management:                                                           # BeeGFS management service volume definition.
        format_type: ext4                                                   # Volume format type
        format_options: "-i 2048 -I 512 -J size=400 -Odir_index,filetype"   # Volume format options
        mount_options: "noatime,nodiratime,nobarrier,_netdev"               # Volume mount options
        mount_dir: /mnt/                                                    # Volume mount directory
      metadata:                                                             # BeeGFS metadata service volume definition.
        format_type: ext4                                                   # (...)
        format_options: "-i 2048 -I 512 -J size=400 -Odir_index,filetype"
        mount_options: "noatime,nodiratime,nobarrier,_netdev"
        mount_dir: /mnt/
      storage:                                                              # BeeGFS storage service volume definition.
        format_type: xfs                                                    # (...)
        format_options: "-d su=VOLUME_SEGMENT_SIZE_KBk,sw=VOLUME_STRIPE_COUNT -l version=2,su=VOLUME_SEGMENT_SIZE_KBk"
        mount_options: "noatime,nodiratime,logbufs=8,logbsize=256k,largeio,inode64,swalloc,allocsize=131072k,nobarrier,_netdev"
        mount_dir: /mnt/

    # General path defaults
    beegfs_ha_pcsd_tokens: /var/lib/pcsd/tokens                       # PCS daemon tokens absolute file path.
    beegfs_ha_pacemaker_cib_xml: /var/lib/pacemaker/cib/cib.xml       # Pacemaker cib.xml absolute file path.
    beegfs_ha_uninstall_pacemaker_cib_dir: /var/lib/pacemaker/cib/    # Pacemaker cib directory absolute path.
    beegfs_ha_uninstall_pcsd_dir: /var/lib/pcsd/                      # PCS daemon directory absolute path.

    # Debian / Ubuntu repository defaults
    beegfs_debian_repository_base_url: https://www.beegfs.io/release/beegfs_7_1
    beegfs_debian_repository_gpgkey: https://www.beegfs.io/release/beegfs_7_1/gpg/DEB-GPG-KEY-beegfs


    # RedHat / CentOS repository defaults
    beegfs_rhel_repository_base_url: https://www.beegfs.io/release/beegfs_7_1/dists/rhel7
    beegfs_rhel_repository_gpgkey: https://www.beegfs.io/release/beegfs_7_1/gpg/RPM-GPG-KEY-beegfs


    # SUSE repository defaults
    beegfs_suse_repository_base_url: https://www.beegfs.io/release/beegfs_7_1/dists/sles12
    beegfs_suse_repository_gpgkey: https://www.beegfs.io/release/beegfs_7_1/gpg/RPM-GPG-KEY-beegfs

Dependencies
------------
    netapp_eseries.santricity
    netapp_eseries.host

License
-------
    BSD

Author Information
------------------
    Nathan Swartz (@ndswartz)
