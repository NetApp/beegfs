Getting Started Project for netappeseries.beegfs.beegfs_ha_7_2 Role 
=========================================================
The files in this directory expedite getting started with the role by having users fill in a few details about their 
environment in the `beegfs_ha_inventory.yml` file. This is run against the `create_inventory_structure.yml` playbook 
which will ask for details about the desired deployment and generate a full skeleton inventory. Lastly users review the 
generated files filling in necessary details and changing default values where needed before running with the 
`beegfs_ha_playbook.yml` to deploy BeeGFS with HA.

Requirements
------------
- Ansible control node with Ansible 2.9 or later and the following dependencies installed:
  - NetApp E-Series Ansible Collections:
    - netappeseries.santricity 1.2 or later.
    - netappeseries.host 1.0 or later.
  - Python (pip) packages:
    - ipaddr
    - netaddr
- Passwordless SSH setup from the Ansible control node to all BeeGFS HA nodes.

Getting Started
---------------
Step 1) Get the `beegfs_ha_7_2` example directory to you Ansible control node.

    mkdir <your_project_directory>
    cd <your_project_directory>
    git clone -b release-3.0.0 --single-branch https://github.com/netappeseries/beegfs.git && cp -r beegfs/examples/beegfs_ha_7_2/* . && rm -rf beegfs

Step 2) Modify the `beegfs_ha_inventory.yml` file. In this step, you'll define BeeGFS HA cluster resource groups, and 
storage targets.
- Read the comments in the `beegfs_ha_inventory.yml` file for modification details.

Step 3) Setup a skeleton inventory structure based on the modified `beegfs_ha_inventory.yml` file from step 2.
- Run the following command and answer a few questions about you BeeGFS HA cluster. 
```
ansible-playbook -i beegfs_ha_inventory.yml create_inventory_structure.yml
```
- Note that once the inventory files have been created, running the playbook again will only create new files that 
  correspond to additions to the `beegfs_ha_inventory.yml` file (i.e. new resource groups, storage targets), no existing 
  files will be modified.

Step 4) Review and update the generated files found in `group_vars` directory.
* The `group_vars` directory contains all group-level variable files. Be sure to carefully read the comments in each file.

Step 5) Review and update the generated files found in `host_vars` directory.
* The `host_vars` directory contains files for each BeeGFS HA node and E-Series storage. Carefully read the comments 
  in each file.

Step 6) Configure the BeeGFS HA services.
```
ansible-playbook -i beegfs_ha_inventory.yml beegfs_ha_playbook.yml
```

Complete BeeGFS HA resource group beegfs_targets sub-structure - eseries_storage_pool_configuration
---------------------------------------------------------------------------------------------------
This is a complete reference for the `eseries_storage_pool_configuration` variable used to specify the `beegfs_targets` 
for each resource group. You only need to specify the options you need, required options that must be included are 
outlined in the `group_var` file representing each resource group.

Additional background: The `eseries_storage_pool_configuration` structure is a variable used in 
netappeseries.santricity.host role. This has been slightly modified since the complete structure is generated 
dynamically at runtime to combine all BeeGFS HA resource group beegfs_targets into a single definitions for each target 
defined. This allows the role to control volume naming convention and combine storage pools to better utilize E-Series 
storage for BeeGFS management and metadata services.

    eseries_storage_pool_configuration:
      - name:                                      # Name or name scheme (see above) for the storage pool.
        state:                                     # Specifies whether the storage pool should exist. Choices: present, absent
        raid_level                                 # Volume group raid level. Choices: raid0, raid1, raid5, raid6, raidDiskPool (Default: raidDiskPool)
        secure_pool:                               # Default for storage pool drive security. This flag will enable the security at rest feature. There must be
                                                   #    sufficient FDE or FIPS security capable drives. Choices: true, false
        criteria_drive_count:                      # Default storage pool drive count.
        reserve_drive_count:                       # Default reserve drive count for drive reconstruction for storage pools using dynamic disk pool and the raid
                                                   #    level must be set for raidDiskPool.
        criteria_min_usable_capacity:              # Default minimum required capacity for storage pools.
        criteria_drive_type:                       # Default drive type for storage pools. Choices: hdd, ssd
        criteria_size_unit:                        # Default unit size for all storage pool related sizing. Choices: bytes, b, kb, mb, gb, tb, pb, eb, zb, yb
        criteria_drive_min_size:                   # Default minimum drive size for storage pools.
        criteria_drive_require_da:                 # Ensures storage pools have data assurance (DA) compatible drives. Choices: true, false
        criteria_drive_require_fde:                # Ensures storage pools have drive security compatible drives. Choices: true, false
        remove_volumes:                            # Ensures volumes are deleted prior to removing storage pools.
        erase_secured_drives:                      # Ensures data is erased during create and delete storage pool operations. Choices: true, false
        common_volume_configuration:               # Any option that can be specified at the volume level can be generalized here at the storage pool level.
        volumes:                                   # List of volumes associated the storage pool.
          - state:                                 # Specifies whether the volume should exist (present, absent)
            name:                                  # DO NOT SPECIFY! THIS IS WILL BE GENERATED AT RUNTIME BY THE beegfs_ha_7_2 ROLE.
            host:                                  # host or host group for the volume should be mapped to.
            host_type:                             # Only required when using something other than Linux kernel 3.10 or later with DM-MP (Linux DM-MP),
                                                   #    non-clustered Windows (Windows), or the storage system default host type is incorrect.
                                                   # Common host type definitions:
                                                   #    - AIX MPIO: The Advanced Interactive Executive (AIX) OS and the native MPIO driver
                                                   #    - AVT 4M: Silicon Graphics, Inc. (SGI) proprietary multipath driver
                                                   #    - HP-UX: The HP-UX OS with native multipath driver
                                                   #    - Linux ATTO: The Linux OS and the ATTO Technology, Inc. driver (must use ATTO FC HBAs)
                                                   #    - Linux DM-MP: The Linux OS and the native DM-MP driver
                                                   #    - Linux Pathmanager: The Linux OS and the SGI proprietary multipath driver
                                                   #    - Mac: The Mac OS and the ATTO Technology, Inc. driver
                                                   #    - ONTAP: FlexArray
                                                   #    - Solaris 11 or later: The Solaris 11 or later OS and the native MPxIO driver
                                                   #    - Solaris 10 or earlier: The Solaris 10 or earlier OS and the native MPxIO driver
                                                   #    - SVC: IBM SAN Volume Controller
                                                   #    - VMware: ESXi OS
                                                   #    - Windows: Windows Server OS and Windows MPIO with a DSM driver
                                                   #    - Windows Clustered: Clustered Windows Server OS and Windows MPIO with a DSM driver
                                                   #    - Windows ATTO: Windows OS and the ATTO Technology, Inc. driver
            owning_controller:                     # Specifies which controller will be the primary owner of the volume. Not specifying will allow the
                                                   #    controller to choose ownership. (Choices: A, B)
            read_ahead_enable:                     # Enables read ahead caching; this is good for sequential workloads to cache subsequent blocks.
            read_cache_enable:                     # Enables read caching which will cache all read requests.
            size:                                  # Size of the volume or presented size of the thinly provisioned volume.
            size_unit:                             # Unit size for the size, thin_volume_repo_size, and thin_volume_max_repo_size
                                                   #    Choices: bytes, b, kb, mb, gb, tb, pb, eb, zb, yb
            segment_size_kb:                       # Indicates the amount of data stored on a drive before moving on to the next drive in the volume group.
            ssd_cache_enabled:                     # Enables ssd cache which will enable the volume to use an existing SSD cache on the storage array.
            thin_provision:                        # Whether volumes should be thinly provisioned.
            thin_volume_repo_size:                 # Actually allocated space for thinly provisioned volumes.
            thin_volume_max_repo_size:             # Maximum allocated space allowed for thinly provisioned volumes.
            thin_volume_expansion_policy:          # Thin volume expansion policy. Choices: automatic, manual
            thin_volume_growth_alert_threshold:    # Thin volume growth alert threshold; this is the threshold for when the thin volume expansion
                                                   #    policy will be enacted. Allowable values are between and including 10% and 99%
            data_assurance_enabled:                # Enables whether data assurance(DA) is required to be enabled.
            wait_for_initialization:               # Whether volume creation with wait for initialization to complete
            workload_name:                         # Name of the volume's workload
            workload_metadata:                     # Dictionary containing arbitrary entries normally used for defining the volume(s) workload.
            volume_metadata                        # Dictionary containing arbitrary entries used to define information about the volume itself.
                                                   #    Note: mount_to_host, format_type, format_options, mount_directory, mount_options are used by netapp_eseries.host.mount role to format and mount volumes.
            write_cache_enable:                    # Enables write caching which will cache all writes.
                                                   #    created on the storage array.
License
-------
BSD

Author Information
------------------
- Joe McCormick (@iamjoemccormick)
- Nathan Swartz (@ndswartz)
