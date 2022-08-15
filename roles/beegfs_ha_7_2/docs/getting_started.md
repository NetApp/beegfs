<a name="getting-started"></a>
# Getting Started

<a name="table-of-contents"></a>
## Table of Contents

- [Getting Started](#getting-started)
  - [Table of Contents](#table-of-contents)
  - [Requirements](#requirements)
  - [Tested Ansible Versions](#tested-ansible-versions)
  - [Getting Started Guide](#getting-started-guide)
  - [Example Playbook, Inventory, Group/Host Variables](#example-playbook-inventory-grouphost-variables)
    - [Example BeeGFS HA Playbook File](#example-beegfs-ha-playbook-file)
    - [Example Inventory File](#example-inventory-file)
    - [Example group_vars Inventory Files](#example-group_vars-inventory-files)
      - [Example All Group](#example-all-group)
      - [Example E-Series Storage Systems Group](#example-e-series-storage-systems-group)
      - [Example HA Cluster Group](#example-ha-cluster-group)
      - [Example Management Group](#example-management-group)
      - [Example Metadata Group](#example-metadata-group)
      - [Example Storage Group](#example-storage-group)
    - [Example host_vars Inventory Files](#example-host_vars-inventory-files)
      - [Example E-Series Storage System Inventory File](#example-e-series-storage-system-inventory-file)
      - [Example BeeGFS HA Node Inventory File](#example-beegfs-ha-node-inventory-file)
  - [General Notes](#general-notes)

<a name="requirements"></a>
## Requirements

Ensure the following conditions are met:
- Ansible control node has the following installed:
  - Python 3.6 or later
    - The Ansible version above may have a minimum required Python version 
  - NetApp E-Series Ansible Collections:
    - netapp_eseries.santricity 1.3 or later.
    - netapp_eseries.host 1.0 or later.
  - Python (pip) packages installed:
    - ipaddr
    - netaddr
- Passwordless SSH is setup from the Ansible control node to all BeeGFS HA nodes.
- BeeGFS HA nodes have the following configured:
  - HA repositories containing the necessary packages (pacemaker, corosync, fence-agents-all, resource-agents, pcs) are enabled via 
  package manager
    - Enable command example: `subscription-manager repo-override repo=rhel-8-for-x86_64-highavailability-rpms --add=enabled:1`
  - Ensure files with a shared secret are in place for connection based authentication (for more details and options to configure
    see [Importance of Connection Authentication](override_beegfs_configuration_defaults.md#importance-of-conn-auth)).
      - Note: This is optional but **strongly** recommended.

<a name="tested-ansible-versions"></a>
## Tested Ansible Versions

Ansible 5.x (ansible-core 2.12)

<a name="getting-started-guide"></a>
## Getting Started Guide

Build the inventory and playbook files for on your BeeGFS cluster requirements. The inventory will require several passwords.
For security reasons these passwords should not be stored in plain text and, instead, should use [Ansible Vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html).

There are two ways to build the necessary files:
1. Define the inventory and run the `create_inventory_structure.yml` playbook from the `getting_started/beegfs_ha_7_2` folder. This is the recommended 
way to get started with the BeeGFS HA role.
   * Refer to the readme from [beegfs_ha_7_2 getting_started project](../../../getting_started/beegfs_ha_7_2/README.md) 
     for details. 
2. Create the inventory and playbook using the examples and variables found in the below sections.

Once all the files are created, then run the playbook.

    ansible-playbook -i <inventory>.yml <playbook>.yml

<a name="example-playbook-inventory-grouphost-variables"></a>
## Example Playbook, Inventory, Group/Host Variables

This section contains an example of how to layout the playbook and inventory files. The variables used in the inventory 
files are not exhaustive, see additional variables from under [Role Variables](role_variables.md) or other NetApp 
E-Series Ansible Collections ([santricity](https://galaxy.ansible.com/netapp_eseries/santricity), [host](https://galaxy.ansible.com/netapp_eseries/host)).

<a name="example-beegfs-ha-playbook-file"></a>
### Example BeeGFS HA Playbook File

To apply the BeeGFS HA role, execute the following playbook (ansible-playbook -i inventory.yml beegfs_ha_playbook.yml)

This file would be created as `beegfs_ha_playbook.yml`:

    - hosts: all
      gather_facts: false
      any_errors_fatal: true
      collections:
        - netapp_eseries.beegfs
      tasks:
        - name: Ensure BeeGFS HA cluster is setup.
          ansible.builtin.import_role:  # import_role is required for tag availability.
            name: beegfs_ha_7_2

<a name="example-inventory-file"></a>
### Example Inventory File

This file defines the required Ansible groups which are used to designate BeeGFS HA cluster resource groups and related
storage systems. Any variables for a group can be defined in ./group_vars/<GROUP_NAME>.yml and any variable for a specific
node can be defined in ./host_vars/<NODE_NAME>.yml. Currently, there is a recommended limit of 10 BeeGFS HA cluster nodes.

This file would typically be created as `inventory.yml`:

    all:
      vars:
        ansible_python_interpreter: /usr/bin/python3
      
      children:
        eseries_storage_systems:  # BeeGFS HA E-Series storage group
          hosts:
            eseries_storage_system_c1:
            eseries_storage_system_c2:  
            eseries_storage_system_c3:

        ha_cluster:   # BeeGFS HA (Pacemaker) cluster group
          children:
            mgmt:  # A group representing the management resource.
              hosts:
                node_h1:  # Dictionary of nodes that may run the management resource (highest to lowest priority).
                node_h2:

            meta_01:   # A group representing a metadata resource. To add additional metadata resources, define
                       # more meta_XX resource groups within the ha_cluster group.
              hosts:
                node_h1:  # Dictionary of nodes that may run this metadata resource (highest to lowest priority).
                node_h2:

            stor_01:   # A group representing a storage resource. To add additional storage resources, define
                       # more stor_XX resource groups within the ha_cluster group.
              hosts:
                node_h1:  # Dictionary of nodes that may run this storage resource (highest to lowest priority).
                node_h2:

<a name="example-group_vars-inventory-files"></a>
### Example group_vars Inventory Files

<a name="example-all-group"></a>
#### Example All Group

This file would be created as `group_vars/all.yml`:

    beegfs_ha_ntp_server_pools: # Modify the NTP server addresses if desired.
      - "pool 0.pool.ntp.org iburst maxsources 3"
      - "pool 1.pool.ntp.org iburst maxsources 3"

<a name="example-e-series-storage-systems-group"></a>
#### Example E-Series Storage Systems Group

Any variable supported by the netapp_eseries.santricity collection can be set in the storage system inventory files.

This file would be created as `group_vars/eseries_storage_systems.yml`:

    ### eseries_storage_systems Ansible group inventory file. 
    # Place all default/common variables for NetApp E-Series Storage Systems here: 
    ansible_connection: local
    eseries_system_password: <PASSWORD>
    eseries_validate_certs: false

    # Storage Provisioning Defaults
    eseries_volume_size_unit: pct
    eseries_volume_read_cache_enable: true
    eseries_volume_read_ahead_enable: false
    eseries_volume_write_cache_enable: true
    eseries_volume_write_cache_mirror_enable: true
    eseries_volume_cache_without_batteries: false

<a name="example-ha-cluster-group"></a>
#### Example HA Cluster Group

This file would be created as `group_vars/ha_cluster.yml`:

    ### ha_cluster Ansible group inventory file. 
    # Place all default/common variables for BeeGFS HA cluster resources below.

    ### Cluster node defaults
    ansible_ssh_user: root
    ansible_become_password: <PASSWORD>

    # If the following options are specified, then Ansible will automatically reboot nodes when necessary for changes to take effect: 
    eseries_common_allow_host_reboot: true
    eseries_common_reboot_test_command: "! systemctl status eseries_nvme_ib.service || systemctl --state=active,exited | grep eseries_nvme_ib.service"

    ### Cluster information
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
      mydomain: <SEARCH_DOMAIN>  # This parameter specifies the local internet domain name. This is optional when the
                                 #    cluster nodes have fully qualified hostnames (i.e. host.example.com)

    ### Fencing configuration:
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
        
    ### BeeGFS service configuration:
    # Configuration that should apply to all BeeGFS services can be specified as follows:

    beegfs_ha_beegfs_mgmtd_conf_ha_group_options:
      connAuthFile: /etc/beegfs/connAuthFile

    beegfs_ha_beegfs_meta_conf_ha_group_options:
      connAuthFile: /etc/beegfs/connAuthFile

    beegfs_ha_beegfs_storage_conf_ha_group_options:
      connAuthFile: /etc/beegfs/connAuthFile

IMPORTANT: In later versions of BeeGFS a connAuthFile is required by default, or it must be explicitly disabled. 
For security and to simplify upgrading to future BeeGFS versions, configuring a connAuthFile when initially deploying 
the cluster is recommended. At this time a connAuthFile only readable by the root user must be manually distributed 
to all BeeGFS servers and clients before running the BeeGFS HA role with the above configuration.
For more information see [Importance of Connection Authentication](override_beegfs_configuration_defaults.md#importance-of-conn-auth)

See [Override BeeGFS Configuration Defaults](docs/override_beegfs_configuration_defaults.md) for more
details on how to override BeeGFS configuration on a global or per service basis. 

<a name="example-management-group"></a>
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
      <BLOCK NODE>:  # E-Series storage system as defined in the inventory as listed within eseries_storage_systems group.
        eseries_storage_pool_configuration:
          - name: <STORAGE POOL>  # Shared storage pools must be defined exactly the same with the exception of volumes each time.
            raid_level: raid1
            criteria_drive_count: 4
            common_volume_configuration:                
              segment_size_kb: 128
            volumes:
              - size: 1
                owning_controller: <OWNING CONTROLLER>

<a name="example-metadata-group"></a>
#### Example Metadata Group

A file for each metadata resources would be created as `group_vars/meta_<number>.yml` (i.e., group_vars/meta_01.yml):

    # meta_XX - BeeGFS HA Metadata Resource Group
    beegfs_ha_beegfs_meta_conf_resource_group_options:
      connMetaPortTCP: <PORT>
      connMetaPortUDP: <PORT>
      tuneBindToNumaZone: <NUMA ZONE>

    floating_ips:
      - <PREFERRED PORT:IP/SUBNET>    # Example: i1b:192.168.120.1/16
      - <SECONDARY PORT:IP/SUBNET>

    beegfs_service: metadata

    beegfs_targets:
      <BLOCK NODE>:  # E-Series storage system as defined in the inventory as listed within eseries_storage_systems group.
        eseries_storage_pool_configuration:
          - name: <STORAGE POOL>
            raid_level: raid1
            criteria_drive_count: 4
            common_volume_configuration:
              segment_size_kb: 128
            volumes:
              - size: 21.25 # SEE NOTE BELOW!
                owning_controller: <OWNING CONTROLLER>

<a name="example-storage-group"></a>
#### Example Storage Group

A file for each storage resources would be created as `group_vars/stor_<number>.yml` (i.e., group_vars/stor_01.yml):

    # stor_XX - BeeGFS HA Storage Resource Group
    beegfs_ha_beegfs_storage_conf_resource_group_options:
      connStoragePortTCP: <PORT>
      connStoragePortUDP: <PORT>
      tuneBindToNumaZone: <NUMA ZONE>

    floating_ips:
      - <PREFERRED PORT:IP/SUBNET>
      - <SECONDARY PORT:IP/SUBNET>

    beegfs_service: storage

    beegfs_targets:
      <BLOCK NODE>:  # E-Series storage system as defined in the inventory as listed within eseries_storage_systems group.
        eseries_storage_pool_configuration:
          - name: <STORAGE POOL>
            raid_level: raid6
            criteria_drive_count: 10
            common_volume_configuration:
              segment_size_kb: 512
            volumes:  # See the performance tuning defaults section of [BeeGFS HA Defaults](../defaults/main.yml) for
                      # comprehensive list of options.
              - size: 21.50
                owning_controller: <OWNING CONTROLLER>         
              - size: 21.50
                owning_controller: <OWNING CONTROLLER>         

<a name="example-host_vars-inventory-files"></a>
### Example host_vars Inventory Files

<a name="example-e-series-storage-system-inventory-file"></a>
#### Example E-Series Storage System Inventory File

A file for each storage systems would be created as `host_vars/<hostname>.yml` (i.e., host_vars/eseries_storage_system_c1.yml):

    eseries_system_name: <STORAGE_ARRAY_NAME>
    eseries_system_api_url: https://<MANAGEMENT_IP>:8443/devmgr/v2/

    eseries_initiator_protocol: <PROTOCOL>  # Communications protocol. Example: ib_iser or nvme_ib
                                            # See [netapp_eseries.santricity collection](https://galaxy.ansible.com/netapp_eseries/santricity) for more details.

    # Define NVMe over InfiniBand ports.
    eseries_controller_nvme_ib_port:
      controller_a:    
          -  # Ordered list of IPv4 addresses for controller A starting with channel 1
      controller_b:
          -  # Ordered list of IPv4 addresses for controller B starting with channel 1

    # Define InfiniBand iSER ports
    eseries_controller_ib_iser_port:
      controller_a:    
          -  # Ordered list of IPv4 addresses for controller A starting with channel 1
      controller_b:
          -  # Ordered list of IPv4 addresses for controller B starting with channel 1

<a name="example-beegfs-ha-node-inventory-file"></a>
#### Example BeeGFS HA Node Inventory File

A file for each nodes would be created as `host_vars/<hostname>.yml`  (i.e., host_vars/node_h1.yml):

    ansible_host: <MANAGEMENT_IP>
    ansible_ssh_user: <SSH_USER>
    ansible_become_password: <SUPER_USER_PASSWORD>

    # See [netapp_eseries.host collection](https://galaxy.ansible.com/netapp_eseries/host) for more information on
    # configuring host communications.

    # NVMe over InfiniBand (nvme_ib)
    eseries_nvme_ib_interfaces:   # (Required) List of NVMe InfiniBand interfaces.
      - name:                     # (Required) Name of NVMe InfiniBand  interface (i.e. ib0, ib1).
        address:                  # (Required) IPv4 address. Use CIDR form (ex. 192.168.1.1/24).

    # InfiniBand iSER (ib_iser)
    eseries_ib_iser_interfaces:   # (Required) List of iSCSI interfaces.
      - name:                     # (Required) Name of iSCSI interface (i.e. ib0, ib1).
        address:                  # (Required) IPv4 address. Use the format 192.0.2.24.

<a name="general-notes"></a>
## General Notes

- All BeeGFS cluster nodes need to be available.
- Fencing agents should be used to ensure failed nodes are definitely down.  
  - WARNING: If `beegfs_ha_cluster_crm_config_options['stonith-enabled']` is set to false then fencing agent will not be configured!
  - For details on configuring different fencing agents, see [Configuring Fencing in a High Availability Cluster](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/configuring_and_managing_high_availability_clusters/assembly_configuring-fencing-configuring-and-managing-high-availability-clusters).
- Uninstall functionality will remove required BeeGFS 7.2 packages. This means that there will be no changes made to the kernel development/NTP/chrony packages whether they previously existed or not.
- BeeGFS is added to the PRUNEFS list in /etc/updatedb.conf to prevent daily indexing scans on clients which causes performance degradations.
- Please refer to the documentation for your Linux distribution/version for guidance on the maximum cluster size. For example, the limitations for RedHat can be found [here](https://access.redhat.com/articles/3069031).
