<a name="getting-started-guide-for-latest-netappeseriesbeegfsbeegfshabuildingblock-role"></a>
# Getting Started Guide for beegfs_ha_building_block

The files in this directory expedite the process of getting started with the HA building block role by guiding users to
fill in a few details about their environment in the `beegfs_ha_inventory.yml` file. This is run against the
`create_inventory_structure.yml` playbook which will ask for details about the desired deployment and generate a full
skeleton inventory. Lastly, users should review the generated files filling in necessary details and changing default
values where needed before running with the `beegfs_ha_playbook.yml` to deploy BeeGFS with HA.

<a name="requirements"></a>
## Requirements

Adhere to the requirements outlined in this collection's [README](../../README.md#requirements) prior to following these
instructions.

<a name="getting-started"></a>
## Getting Started

<a name="clone-the-playbooks-directory"></a>
### 1. Clone the Playbooks Directory

From your Ansible control node, create a project directory and clone the NetApp BeeGFS collection's `playbooks`
directory into it:
```
mkdir <your_project_directory>
cd <your_project_directory>
git clone -b <release-version> --single-branch https://github.com/netappeseries/beegfs.git && cp -r beegfs/getting_started/beegfs_on_custom_configurations/* . && rm -rf beegfs && cd beegfs_ha_building_block
```
Note: These instructions are altered from releases prior to 3.2.0. Refer to the prior release's documentation for
previous deployment instructions.

<a name="update-the-inventory-file"></a>
### 2. Update the Inventory File

From the cloned `beegfs_ha_building_block` folder, update the `beegfs_ha_inventory.yml` file to define your BeeGFS HA
cluster resource groups and storage targets. Refer to the comments in the `beegfs_ha_inventory.yml` file for
modification details.

An example inventory file for a single cluster can be referenced in the
[examples](/getting_started/beegfs_on_custom_configurations/examples) folder.

<a name="create-the-inventory-structure"></a>
### 3. Create the Inventory Structure

Set up a skeleton inventory structure based on the modified `beegfs_ha_inventory.yml` file by running the following
command:
```
ansible-playbook -i beegfs_ha_inventory.yml create_inventory_structure_playbook.yml
```
You will be prompted to answer a few questions about the configuration of your BeeGFS HA cluster. Note that if you run
the playbook again after the inventory files have already been created, only new files that correspond to additions in
the beegfs_ha_inventory.yml file, such as new resource groups or storage targets, will be created. Existing files will
not be modified.

<a name="review-the-group-variable-files"></a>
### 4. Review the Group Variable Files

Review and update the generated files found in the `group_vars` directory. This directory contains all group-level
variable files. Carefully read the comments in each file for guidance.

Example group_var files can be found in the [examples](/getting_started/beegfs_on_custom_configurations/examples) folder.

<a name="review-the-host-variable-files"></a>
### 5. Review the Host Variable Files

Review and update the generated files found in the `host_vars` directory. This directory contains files for each BeeGFS
HA node and E-Series storage. Again, carefully read the comments in each file for guidance.

Example host_var files can be found in the [examples](/getting_started/beegfs_on_custom_configurations/examples) folder.

<a name="review-the-password-configuration-file"></a>
### 6. Review the Password Configuration File

Modify the `passwords.yml` file in the `beegfs_ha_building_block/group_vars/all` directory. Supply credentials in the
required fields. It is not recommended to store these credentials in plain text. Use
[Ansible Vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html) to encrypt the passwords file.

<a name="configure-beegfs-ha-services"></a>
### 7. Configure BeeGFS HA Services

Finally, to deploy BeeGFS HA services across your configured inventory, run the following playbook:
```
ansible-playbook -i beegfs_ha_inventory.yml beegfs_ha_playbook.yml
```

If utilizing Ansible Vault, you must include the `--ask-vault-pass` parameter to the playbook command.

<a name="complete-beegfs-ha-resource-group-beegfstargets-substructure-eseriestoragepoolconfiguration"></a>
## Complete BeeGFS HA resource group beegfs_targets sub-structure - eseries_storage_pool_configuration

This is a complete reference for the `eseries_storage_pool_configuration` variable, used to specify the `beegfs_targets` 
for each resource group. You only need to specify the options that are relevant to your configuration. Required options
that must be included are outlined in the `group_var` file representing each resource group.

<a name="additional-background"></a>
### Additional background

The `eseries_storage_pool_configuration` structure is a variable utilized in `netappeseries.santricity.host` role. Since
the `eseries_storage_pool_configuration` complete structure is generated dynamically at runtime, the variable has been
adapted to combine all BeeGFS HA resource group `beegfs_targets` into a single definition for each defined target. This
modification allows the role to control volume naming convention and merge storage pools, optimizing the use of E-Series
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
            name:                                  # DO NOT SPECIFY! THIS IS WILL BE GENERATED AT RUNTIME BY THE beegfs_ha_X ROLE.
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

<a name="license"></a>
## License

BSD

<a name="maintainer-information"></a>
## Maintainer Information

- Christian Whiteside (@mcwhiteside)
- Vu Tran (@VuTran007)