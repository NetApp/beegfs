<a name="uninstall"></a>
# Uninstall

The uninstall process will, at the very least, remove the BeeGFS and HA applications, configuration, performance tuning,
and mount points.


<a name="table-of-contents"></a>
## Table of Contents

- [Uninstall](#uninstall)
  - [Table of Contents](#table-of-contents)
  - [How to Uninstall](#how-to-uninstall)
    - [Example Uninstall Playbook](#example-uninstall-playbook)
  - [General Notes](#general-notes)


<a name="how-to-uninstall"></a>
## How to Uninstall

The uninstall process requires the inventory files used during the original beegfs_ha deployment. From your project's
`beegfs_ha_building_block` folder, create a new playbook file. The variable `beegfs_ha_uninstall` can be used in a
playbook to dictate if uninstall tasks should be executed. By default, the `beegfs_ha_uninstall` variable is set to
false. There are additional `beegfs_ha_uninstall_x` variables available for configuration if a deeper clean-up of the
systems is desired. Refer to the list of variables and their description in the
[BeeGFS HA Defaults](../../roles/beegfs_ha_7_4/defaults/main.yml) file.


<a name="example-uninstall-playbook"></a>
### Example Uninstall Playbook

This playbook performs an uninstall of a BeeGFS HA instance to unconfigure BeeGFS HA services but retain provisioned
storage. This example's playbook file is created under the label: `uninstall_beegfs_ha_playbook.yml`.

    - hosts: all
      vars_files: "{{ playbook_dir | dirname }}/passwords.yml"
      collections:
        - netapp_eseries.beegfs
      tasks:
        - name: Ensure BeeGFS HA cluster is uninstalled.
          ansible.builtin.import_role:
            name: beegfs_ha_<VERSION>
          vars:
            beegfs_ha_uninstall: true
            beegfs_ha_uninstall_unmap_volumes: false
            beegfs_ha_uninstall_wipe_format_volumes: false  # **WARNING: If set to true, this action is unrecoverable.**
            beegfs_ha_uninstall_delete_volumes: false  # **WARNING: If set to true, this action is unrecoverable.**
            beegfs_ha_uninstall_delete_storage_pools_and_host_mappings: false # **WARNING: If set to true, this action
            is unrecoverable.**
            beegfs_ha_uninstall_storage_setup: false
            beegfs_ha_uninstall_reboot: true

Once the playbook has been created and configured to match your uninstall preferences, execute the
playbook:

  ```
  ansible-playbook -i <inventory>.yml uninstall_beegfs_ha_playbook.yml
  ```


<a name="general-notes"></a>
## General Notes

- If `beegfs_ha_uninstall_wipe_format_volumes: true` is not set, then when a user deletes volumes and subsequently
creates new volumes of the same size, they may recover the original volume.. While this is helpful if the volumes were
unintentionally deleted, it can create mounting issues for the BeeGFS HA cluster nodes.
- The uninstall mode is primarily intended for use in training and testing environments. It may not fully remove all
remnants of the previous installation, so reinstalling the operating system before redeploying BeeGFS is recommended in
production environments.