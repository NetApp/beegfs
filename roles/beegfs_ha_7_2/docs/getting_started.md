# Getting Started

<br>

## Table of Contents:
------------
1. [Requirements](#requirements)
2. [Getting Started](#getting-started)
3. [Example Playbook, Inventory, Group/Host Variables](#example-playbook-inventory-grouphost-variables)
    1. [Example Playbook File](#example-playbook-file)
    2. [Example Inventory File](#example-inventory-file)
    3. [Example group_vars Inventory Files](#example-group_vars-inventory-files)
    4. [Example host_vars Inventory Files](#example-host_vars-inventory-files)
4. [General Notes](#general-notes)

<br>

<a name="requirements"></a>
## Requirements
------------
Ensure the following conditions are met:
- Ansible control node has the following installed:
  - Ansible 2.9 or later
  - Python 3.6 or later
    - The Ansible version above may have a minimum required Python version 
  - NetApp E-Series Ansible Collections:
    - netappeseries.santricity 1.1 or later.
    - netappeseries.host 0.1 or later (later revisions will have more protocol options to extend this role's 
      capabilities).
  - Python (pip) packages installed:
    - ipaddr
    - netaddr
- Passwordless SSH is setup from the Ansible control node to all BeeGFS HA nodes.
- BeeGFS HA nodes have the following installed:
  - HA repositories containing the necessary packages (pacemaker, corosync, fence-agents-all, pcs) are enabled via 
  package manager
    - Enable command example: `subscription-manager repo-override repo=rhel-8-for-x86_64-highavailability-rpms --add=enabled:1`

<br>

<a name="getting-started"></a>
## Getting Started
----------------
Build the inventory and playbook files for on your BeeGFS cluster requirements.

There are two ways to build the necessary files:
1. Run the `create_inventory_structure.yml` playbook from the `examples/beegfs_ha_7_2` folder. This is the recommended 
way to get started with the BeeGFS HA role.
   * Refer to the readme from [beegfs_ha_7_2 getting_started project](../../../getting_started/beegfs_ha_7_2/README.md) 
     for details. 
2. Create the inventory and playbook using the examples and variables found in the below sections.

Once all the files are created, then run the playbook.

    ansible-playbook -i <inventory>.yml <playbook>.yml

<br>

<a name="example-playbook-inventory-grouphost-variables"></a>
## Example Playbook, Inventory, Group/Host Variables 
-------------------------------------------------
This section contains an example of how to layout the playbook and inventory files. The variables used in the inventory 
files are not exclusive, see additional variables from under [Role Variables](role_variables.md) or other NetApp 
E-Series Ansible Collections.

<br>

<a name="example-playbook-file"></a>
### Example Playbook File
To use the BeeGFS HA role, import the role where it is to be used in the playbook YAML file.

This file would typically be created as `playbook.yml`:

    - hosts: all
      gather_facts: false
      collections:
        - netapp_eseries.beegfs
      tasks:
        - name: Ensure BeeGFS HA cluster is setup.
          import_role:
            name: beegfs_ha_7_2

<a name="example-inventory-file"></a>
### Example Inventory File
This file contains the setup of the BeeGFS HA nodes and the storage systems used to configure BeeGFS HA.

This file would typically be created as `inventory.yml`:

    all:
      vars:
        ansible_python_interpreter: /usr/bin/python
      
      children:
        eseries_storage_systems:  # A group that has variables that are applied to the below 
                                  #   associated storage systems.
          hosts:
            eseries_storage_system_c1:  # A host_vars that represents an E-Series storage system.
            eseries_storage_system_c2:  
            eseries_storage_system_c3:

        ha_cluster:    # A group that has variables that are applied to the below associated 
                       #   BeeGFS HA nodes.
          children:
            mgmt:       # A group representing the management resource.
                        #   Management resource group name must be 10 characters or less.
                        #   The resource group is used to name the floating ip resource iflabel.
                        #   This label must match the "beegfs_ha_mgmtd_group" variable.
              hosts:    # The ordering of hosts will be used to determine the resource constraint 
                        #   opt-in preferences (highest to lowest).
                node_h1:    # A BeeGFS node
                node_h2:

            meta_01:   # A group representing a metadata resource.
                       #   Metadata resource name must end with and underscore followed 
                       #   by the nodeNumID that is designated for the service resource.
                       #   There can be up to 8 metadata resources.
              hosts:
                node_h1:    # A BeeGFS node
                node_h2:
              
            stor_01:    # A group representing a storage resource.
                        #   Storage resource name must end with an underscore followed 
                        #   by the nodeNumID that is designated for the service resource.
                        #   There can be up to 8 storage resources.
              hosts:
                node_h1:    # A BeeGFS node
                node_h2:

<a name="example-group_vars-inventory-files"></a>
### Example group_vars Inventory Files
#### Example All Group
This file would be created as `group_vars/all.yml`:

    beegfs_ha_ntp_server_pools: # Modify the NTP server addressess if desired.
      - "pool 0.pool.ntp.org iburst maxsources 3"
      - "pool 1.pool.ntp.org iburst maxsources 3"

<br>

#### Example E-Series Storage Systems Group
Any variables supported by the netappeseries.santricity can set in this inventory file.

This file would be created as `group_vars/eseries_storage_systems.yml`:

    ### eseries_storage_systems Ansible group inventory file. 
    # Place all default/common variables for NetApp E-Series Storage Systems here: 
    ansible_connection: local
    eseries_system_password: <PASSWORD>          # Listing any passwords in plaintext is not recommended.
                                                 #   Use Ansible vault or provide the eseries_system_password 
                                                 #   when running Ansible using --extra-vars.
    eseries_validate_certs: false

    # Firmware, NVSRAM, and Drive Firmware (modify the filenames as needed):
    eseries_firmware_firmware: "packages/RCB_11.70.1R1_6000_60fa2a9f.dlp"
    eseries_firmware_nvsram: "packages/N6000-871834-D05.dlp"
    eseries_drive_firmware_firmware_list:
      - "packages/D_MZWLJ3T8HBLS-0G5_30604635_NA51_XXXX_000.dlp"

    eseries_drive_firmware_firmware_list:
      - "packages/<FILENAME>.dlp"
    eseries_drive_firmware_upgrade_drives_online: true

    # Global Configuration Defaults
    eseries_system_cache_block_size: 32768
    eseries_system_cache_flush_threshold: 80
    eseries_system_default_host_type: linux dm-mp
    eseries_system_autoload_balance: disabled
    eseries_system_host_connectivity_reporting: disabled
    eseries_system_controller_shelf_id: 99                  # Required variable.

    # Storage Provisioning Defaults
    eseries_volume_size_unit: pct
    eseries_volume_read_cache_enable: true
    eseries_volume_read_ahead_enable: false
    eseries_volume_write_cache_enable: true
    eseries_volume_write_cache_mirror_enable: true
    eseries_volume_cache_without_batteries: false
    eseries_storage_pool_usable_drives: "99:0,99:23,99:1,99:22,99:2,99:21,99:3,99:20,99:4,99:19,99:5,99:18,99:6,99:17,99:7,99:16,99:8,99:15,99:9,99:14,99:10,99:13,99:11,99:12"

<br>

#### Example HA Cluster Group
This file would be created as `group_vars/ha_cluster.yml`:

    ### ha_cluster Ansible group inventory file. 
    # Place all default/common variables for BeeGFS HA cluster resources below.

    ### Cluster node defaults
    ansible_ssh_user: root
    ansible_become_password: <PASSWORD>

    # If the following options are specified, then Ansible will automatically reboot nodes when necessary for changes to take effect: 
    eseries_common_allow_host_reboot: true
    eseries_common_reboot_test_command: "systemctl --state=active,exited | grep eseries_nvme_ib.service"

    ### Cluster information
    # The following variables define the default Ansible group names and should not be changed: 
    beegfs_ha_cluster_ansible_host_group: ha_cluster                    
    beegfs_ha_ansible_client_group: ha_clients                          
    beegfs_ha_cluster_ansible_storage_group: eseries_storage_systems    
    beegfs_ha_mgmtd_group: mgmt

    # The following variables should not typically need to be modified:
    beegfs_ha_storage_system_hostgroup_prefix: beegfs  # Prefixed to the E-Series storage host groups.
    beegfs_ha_pacemaker_ipc_buffer_bytes: 13213776
    beegfs_ha_cluster_resource_defaults:
      resource-stickiness: 15000
      cluster-ipc-limit: 5500

    # The following variables should be adjusted depending on the desired configuration: 
    beegfs_ha_cluster_name: hacluster                  # BeeGFS HA cluster name.
    beegfs_ha_cluster_username: hacluster              # BeeGFS HA cluster username.
    beegfs_ha_cluster_password: hapassword             # BeeGFS HA cluster username's password.
    beegfs_ha_cluster_password_sha512_salt: randomSalt # BeeGFS HA cluster username's password salt.
    beegfs_ha_mgmtd_floating_ip: 100.127.101.0         # BeeGFS management service IP address.
    beegfs_ha_alert_email_list: ["email@example.com"]  # E-mail recipient list for notifications when BeeGFS HA
                                                       #   resources change or fail. Often a distribution list 
                                                       #   for the team responsible for managing the cluster.
    beegfs_ha_alert_conf_ha_group_options:
      mydomain: <SEARCH DOMAIN>  # This parameter specifies the local internet domain name. This is optional when the
                                 #    cluster nodes have fully qualified hostnames (i.e. host.example.com)

    ### Fencing configuration: 
    beegfs_ha_enable_fence: true

    # OPTION 1: To enable fencing using APC Power Distribution Units (PDUs): 
    beegfs_ha_fencing_agents:
      fence_apc:
        - ipaddr: <PDU_IP_ADDRESS>
          login: <PDU_USERNAME>
          passwd: <PDU_PASSWORD>
          pcmk_host_map: "<HOSTNAME>:<PDU_PORT>,<PDU_PORT>;<HOSTNAME>:<PDU_PORT>,<PDU_PORT>"

    # OPTION 2: To enable fencing using the Redfish APIs provided by the Lenovo XCC (and other BMCs):  
    redfish: &redfish
      username: <BMC_USERNAME>
      password: <BMC_PASSWORD>
      ssl_insecure: 1 # If a valid SSL certificate is not available specify “1”. 

    beegfs_ha_fencing_agents:
      fence_redfish:
        - pcmk_host_list: <HOSTNAME>
          ip: <BMC_IP>
          <<: *redfish
        - pcmk_host_list: <HOSTNAME>
          ip: <BMC_IP>
          <<: *redfish

    ### Performance Configuration:
    beegfs_ha_enable_performance_tuning: True

    ### Ensure Consistent Logical IB Port Numbering
    # Name of the udev rule to create (do not modify): 
    eseries_ib_base_udev_name: 99-beegfs-ib.rules

    # Lenovo SR665 PCIe address-to-logical IB port mapping:  
    eseries_ib_base_udev_rules:
      "0000:41:00.0": i1a
      "0000:41:00.1": i1b
      "0000:01:00.0": i2a
      "0000:01:00.1": i2b  
      "0000:a1:00.0": i3a
      "0000:a1:00.1": i3b
      "0000:81:00.0": i4a
      "0000:81:00.1": i4b

<br>

#### Example Management Group
This file would be created as `group_vars/mgmt.yml`:

    # mgmt - BeeGFS HA Management Resource Group
    # OPTIONAL: Override default BeeGFS management configuration:
    # beegfs_ha_beegfs_mgmtd_conf_resource_group_options:
    #  <beegfs-mgmt.conf:key>:<beegfs-mgmt.conf:value>

    floating_ips:
      - i1b:100.127.101.0/16
      - i2b:100.128.102.0/16

    beegfs_service: management

    beegfs_targets:
      ictm1620c1:
        eseries_storage_pool_configuration:
          - name: beegfs_m1_m2_m5_m6
            raid_level: raid1
            criteria_drive_count: 4
            common_volume_configuration:                
              segment_size_kb: 128
            volumes:
              - size: 1
                owning_controller: A

<br>

#### Example Metadata Group
A file for each metadata resources would be created as `group_vars/meta_0<number>.yml` (i.e., group_vars/meta_01.yml):

    # meta_0X - BeeGFS HA Metadata Resource Group
    beegfs_ha_beegfs_meta_conf_resource_group_options:
      connMetaPortTCP: <PORT>
      connMetaPortUDP: <PORT>
      tuneBindToNumaZone: <NUMA ZONE>

    floating_ips:
      - <PREFERRED PORT:IP/SUBNET>    # Example: i1b:192.168.120.1/16
      - <SECONDARY PORT:IP/SUBNET>

    beegfs_service: metadata

    beegfs_targets:
      <BLOCK NODE>:
        eseries_storage_pool_configuration:
          - name: <STORAGE POOL>
            raid_level: raid1
            criteria_drive_count: 4
            common_volume_configuration:
              segment_size_kb: 128
            volumes:
              - size: 21.25 # SEE NOTE BELOW!
                owning_controller: <OWNING CONTROLLER>

<br>

#### Example Storage Group
A file for each storage resources would be created as `group_vars/stor_0<number>.yml` (i.e., group_vars/stor_01.yml):

    # stor_0X - BeeGFS HA Storage Resource Group
    beegfs_ha_beegfs_storage_conf_resource_group_options:
      connStoragePortTCP: <PORT>
      connStoragePortUDP: <PORT>
      tuneBindToNumaZone: <NUMA ZONE>

    floating_ips:
      - <PREFERRED PORT:IP/SUBNET>
      - <SECONDARY PORT:IP/SUBNET>

    beegfs_service: storage

    beegfs_targets:
      <BLOCK NODE>:
        eseries_storage_pool_configuration:
          - name: <STORAGE POOL>
            raid_level: raid6
            criteria_drive_count: 10
            common_volume_configuration:
              segment_size_kb: 512
            volumes:
              - size: 21.50 # See note below! 
                owning_controller: <OWNING CONTROLLER>         
              - size: 21.50
                owning_controller: <OWNING CONTROLLER>         

<br>

<a name="example-host_vars-inventory-files"></a>
### Example host_vars Inventory Files
#### Example E-Series Storage System Inventory File
A file for each storage systems would be created as `host_vars/<hostname>.yml` (i.e., host_vars/eseries_storage_system_c1.yml):

    eseries_system_name: <STORAGE_ARRAY_NAME>
    eseries_system_api_url: https://<MANAGEMENT_IP>:8443/devmgr/v2/

    eseries_initiator_protocol: nvme_ib

    # For odd numbered block nodes (i.e., c1, c3, ..):
    eseries_controller_nvme_ib_port:
      controller_a:
        - 192.168.1.101
        - 192.168.2.101
        - 192.168.1.100
        - 192.168.2.100
      controller_b:
        - 192.168.3.101
        - 192.168.4.101
        - 192.168.3.100
        - 192.168.4.100

    # For even numbered block nodes (i.e., c2, c4, ..):
    eseries_controller_nvme_ib_port:
      controller_a:
        - 192.168.5.101
        - 192.168.6.101
        - 192.168.5.100
        - 192.168.6.100
      controller_b:
        - 192.168.7.101
        - 192.168.8.101
        - 192.168.7.100
        - 192.168.8.100

<br>

#### Example BeeGFS HA Node Inventory File
A file for each nodes would be created as `host_vars/<hostname>.yml`  (i.e., host_vars/node_h1.yml):

    ansible_host: “<MANAGEMENT_IP>”
    # NVMe over InfiniBand storage communication protocol information
    # For odd numbered file nodes (i.e., h1, h3, ..):
    eseries_nvme_ib_interfaces:
      - name: i1a
        address: 192.168.1.10/24
        configure: true
      - name: i2a
        address: 192.168.3.10/24
        configure: true
      - name: i3a
        address: 192.168.5.10/24
        configure: true
      - name: i4a
        address: 192.168.7.10/24
        configure: true

    # For even numbered file nodes (i.e., h2, h4, ..):
    # NVMe over InfiniBand storage communication protocol information
    eseries_nvme_ib_interfaces:
      - name: i1a
        address: 192.168.2.10/24
        configure: true
      - name: i2a
        address: 192.168.4.10/24
        configure: true
      - name: i3a
        address: 192.168.6.10/24
        configure: true
      - name: i4a
        address: 192.168.8.10/24
        configure: true

<br>

<a name="general-notes"></a>
## General Notes
-------------
- All BeeGFS cluster nodes need to be available.
- Fencing agents should be used to ensure failed nodes are definitely down.  
  - WARNING: If `beegfs_ha_enable_fence` is set to false then fencing agent will not be configured!
  - For details on configuring different fencing agents, see [Configuring Fencing in a High Availability Cluster](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/configuring_and_managing_high_availability_clusters/assembly_configuring-fencing-configuring-and-managing-high-availability-clusters).
- Uninstall functionality will remove required BeeGFS 7.2 packages. This means that there will be no changes made to the kernel development/NTP/chrony packages whether they previously existed or not.
- BeeGFS is added to the PRUNEFS list in /etc/updatedb.conf to prevent daily indexing scans on clients which causes performance degradations.
- Please refer to the documentation for your Linux distribution/version for guidance on the maximum cluster size. For example, the limitations for RedHat can be found [here](https://access.redhat.com/articles/3069031).
- For a comprehensive list of available performance tuning parameters, see the performance tuning defaults section of [BeeGFS HA Defaults](../defaults/main.yml).