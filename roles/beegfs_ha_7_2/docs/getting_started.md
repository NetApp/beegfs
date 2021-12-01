## Requirements
------------
- Ansible control node with Ansible 2.9 or later and the following dependencies installed:
  - NetApp E-Series Ansible Collections:
    - netappeseries.santricity 1.1 or later.
    - netappeseries.host 0.1 or later (later revisions will have more protocol options to extend this roles capabilities).
  - Python (pip) packages:
    - ipaddr
    - netaddr
- Passwordless SSH setup from the Ansible control node to all BeeGFS HA nodes and clients.
- Enabled package manager repository containing pacemaker, corosync and pcs packages 

## Getting Started
----------------
To build an inventory and playbook based your BeeGFS cluster requirements, checkout the [beegfs_ha_7_2 example project readme](https://github.com/netappeseries/beegfs/tree/release-2.1.0/examples/beegfs_ha_7_2/README.md).

This is the recommended way to get started with the BeeGFS HA role. Alternatively users can jump into the examples and detailed descriptions of the various variables found in the sections below.

## Example Playbook, Inventory, Group/Host Variables 
-------------------------------------------------
For users that want to jump right in this section provides examples of how to layout your playbook and inventory files.

### Example Playbook File
Simply import the BeeGFS role where you want to use it in your playbook: 

    - hosts: all
      gather_facts: false
      collections:
        - netapp_eseries.beegfs
      tasks:
        - name: Ensure BeeGFS HA cluster is setup.
          import_role:
            name: beegfs_ha_7_2

### Example Inventory File
The variables in this section are described in greater detail under the "Role Variables" section and may need to be customized to fit each installation:

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

        ha_clients:
          vars:
            beegfs_ha_client_connInterfaces:
              - eth0
              - eth1        
          hosts:
            client_01:
            client_02:

        ha_cluster:
          vars:
            beegfs_ha_ansible_host_group: ha_cluster
            beegfs_ha_ansible_storage_group: eseries_storage_systems
            beegfs_ha_cluster_name: hacluster
            beegfs_ha_cluster_username: hacluster
            beegfs_ha_cluster_password: hapassword
            beegfs_ha_mgmtd_floating_ip: 192.168.1.230
            beegfs_ha_alert_email_list: ["jack@example.com", "jill@example.com"]
            beegfs_ha_fencing_agents:
              fence_apc:
                - pcmk_host_list: "node_mm1,node_ss1"
                  pcmk_host_map: "node_mm1:1;node_ss1:2"
                  ipaddr: 192.168.10.100
                  login: admin
                  passwd: adminpass
              fence_vmware_rest:
                - pcmk_host_list: "node_mm2,node_ss2"
                  pcmk_host_map: "node_mm2:vm_node_mm2;node_ss2:vm_node_ss2"
                  ipaddr: 192.168.10.102
                  login: apcuser
                  passwd: apcpass
            eseries_common_allow_host_reboot: true
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
            meta_01:   # Metadata resource names must end with and underscore followed by the nodeNumID that is designated for the service resource.
              hosts:
                node_mm1:
                node_mm2:
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
            stor_01:    # Storage resource names must end with and underscore followed by the nodeNumID that is designated for the service resource.
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

### Example BeeGFS HA Host Inventory File
This file would typically be created as `host_vars/<hostname>.yml`:

    ansible_host: 192.168.1.10
    ansible_ssh_user: admin
    ansible_become_password: adminpass

    eseries_iscsi_iqn: iqn.1994-05.com.redhat:node_mm1
    eseries_iscsi_interfaces:
      - name: eth1
        address: 192.168.2.226/24
      - name: eth2
        address: 192.168.3.226/24

### Example BeeGFS HA Client Inventory File
This file would typically be created as `host_vars/<hostname>.yml`:

    ansible_host: 192.168.1.100
    ansible_ssh_user: admin
    ansible_become_password: adminpass

### Example E-Series Storage System Inventory File
This file would typically be created as `host_vars/<hostname>.yml`:

    ansible_connection: local
    eseries_system_api_url: https://192.168.1.200:8443/devmgr/v2/
    eseries_system_password: adminpass
    eseries_validate_certs: false
    eseries_initiator_protocol: iscsi

## General Notes
-------------
- All BeeGFS cluster nodes need to be available.
- Fencing agents should be used to ensure failed nodes are definitely down.  
  - WARNING! If beegfs_ha_enable_fence is set to false then a fencing agent will not be configured!
- Uninstall functionality will remove required BeeGFS 7.2 packages. This means that there will be no changes made to the kernel development/NTP/chrony packages whether they previously existed or not.
- BeeGFS is added to the PRUNEFS list in /etc/updatedb.conf to prevent daily indexing scans on clients which causes performance degradations.
- Please refer to the documentation for your Linux distribution/version for guidance on the maximum cluster size. For example the limitations for RedHat can be found [here](https://access.redhat.com/articles/3069031).

