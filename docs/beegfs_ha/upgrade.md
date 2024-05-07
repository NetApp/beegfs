<a name="upgrade"></a>
# Upgrade

The BeeGFS HA role allows for upgrades between major and minor versions of BeeGFS.


<a name="table-of-contents"></a>
## Table of Contents

- [Upgrade](#upgrade)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Tested Upgrade Paths](#tested-upgrade-paths)
  - [BeeGFS Patch Version Upgrade Steps](#beegfs-patch-version-upgrade-steps)
    - [Upgrade BeeGFS Collection](#upgrade-beegfs-collection)
    - [Update Ansible Inventory](#update-ansible-inventory)
    - [Apply BeeGFS Patch Upgrade](#apply-beegfs-patch-upgrade)
  - [BeeGFS Major or Minor Version Upgrade Steps](#beegfs-major-or-minor-version-upgrade-steps)
    - [Update Ansible Inventory](#update-ansible-inventory-1)
    - [Update Ansible Playbook](#update-ansible-playbook)
    - [Apply BeeGFS Upgrade](#apply-beegfs-upgrade)
  - [Version Upgrade Notes](#version-upgrade-notes)
    - [Upgrading from BeeGFS version 7.2.6 or 7.3.0](#upgrading-from-beegfs-version-7.2.6-or-7.3.0)
  - [BeeGFS Release Notes](#beegfs-release-notes)


<a name="overview"></a>
## Overview

To upgrade the BeeGFS version in a cluster, first ensure it is in an optimal state and each BeeGFS service is located on
its preferred node. Proceed to upgrade one file node at a time by placing it into standby, wait for its services to 
migrate to the secondary node, then upgrade the BeeGFS packages. Finally, start the services and verify the system works
as expected.

For more information, see [BeeGFS Upgrade](https://doc.beegfs.io/latest/advanced_topics/upgrade.html) documentation.


<a name="tested-upgrade-paths"></a>
## Tested Upgrade Paths

| Original Version | Upgrade Version | Multirail | Details                                                            |
|------------------|-----------------|-----------|--------------------------------------------------------------------|
| 7.2.6            | 7.3.2           | Yes       | Upgrading beegfs collection from v3.0.1 to v3.1.0, multirail added |
| 7.2.6            | 7.2.8           | No        | Upgrading beegfs collection from v3.0.1 to v3.1.0                  |
| 7.2.8            | 7.3.1           | Yes       | Upgrade using beegfs collection v3.1.0, multirail added            |
| 7.3.1            | 7.3.2           | Yes       | Upgrade using beegfs collection v3.1.0                             |
| 7.3.2            | 7.4.3           | Yes       | Upgrade using beegfs collection v3.2.0                             |


<a name="beegfs-patch-version-upgrade-steps"></a>
## BeeGFS Patch Version Upgrade Steps

The beegfs ha roles are separated based on major and minor BeeGFS versions, therefore, any supported BeeGFS patch will
be released in different collection versions. The following subsections provide steps to update collection versions.


<a name="upgrade-beegfs-collection"></a>
### Upgrade BeeGFS Collection

For collection upgrades with access to [Ansible Galaxy](https://galaxy.ansible.com/netapp_eseries/beegfs), run the
follow command.

    ansible-galaxy collection install netapp_eseries.beegfs --upgrade


For offline collection upgrades, download the collection from
[Ansible Galaxy](https://galaxy.ansible.com/netapp_eseries/beegfs) by clicking on the desired `Install Version` and then
`Download tarball`. Transfer the tarball to your Ansible control node and run the following command.

    ansible-galaxy collection install netapp_eseries-beegfs-<VERSION>.tar.gz --upgrade

See [Ansible Installing Collection](https://docs.ansible.com/ansible/latest/user_guide/collections_using.html#installing-collections)
for more information.


<a name="update-ansible-inventory"></a>
### Update Ansible Inventory

Make any required or desired updates to your cluster's Ansible inventory files. See
[Version Upgrade Notes](#version-upgrade-notes) for details about your specific upgrade requirements. Also, see
[Getting Started - Example Inventory File](../../getting_started/beegfs_on_custom_configurations/beegfs_ha_building_block/README.md#update-the-inventory-file) for more information about
configuring your BeeGFS HA inventory files.


<a name="apply-beegfs-patch-upgrade"></a>
### Apply BeeGFS Patch Upgrade

Run `ansible-playbook -i inventory.yml beegfs_ha_playbook.yml -e "beegfs_ha_force_upgrade=true" --tags beegfs_ha` to
upgrade.


<a name="beegfs-major-or-minor-version-upgrade-steps"></a>
## BeeGFS Major or Minor Version Upgrade Steps

This section provides the steps necessary to upgrade to a different major or minor BeeGFS version. Upgrading the
collection is optional but recommended. See [Upgrade BeeGFS Collection](#upgrade-beegfs-collection) for collection
upgrade information.


<a name="update-ansible-inventory-1"></a>
### Update Ansible Inventory

Make any required or desired updates to your cluster's Ansible inventory files. See
[Version Upgrade Notes](#version-upgrade-notes) for any details about your specific upgrade inventory requirements.
Also, see [Getting Started - Example Inventory File](../../getting_started/beegfs_on_custom_configurations/beegfs_ha_building_block/README.md) for information about
configuring your BeeGFS HA inventory files.


<a name="update-ansible-playbook"></a>
### Update Ansible Playbook

Update the beegfs_ha_<VERSION> role in the import_role task to the desired version. Below is the beegfs_ha_playbook.yml
file provided in the [Getting Started - Example BeeGFS HA Playbook File](../../getting_started/beegfs_on_custom_configurations/beegfs_ha_building_block/README.md)

    - hosts: all
      gather_facts: false
      any_errors_fatal: true
      collections:
        - netapp_eseries.beegfs
      tasks:
        - name: Ensure BeeGFS HA cluster is setup.
          ansible.builtin.import_role:  # import_role is required for tag availability.
            name: beegfs_ha_<VERSION>


<a name="apply-beegfs-upgrade"></a>
### Apply BeeGFS Upgrade

Run `ansible-playbook -i inventory.yml beegfs_ha_playbook.yml -e "beegfs_ha_force_upgrade=true" --tags beegfs_ha` to
upgrade.


<a name="version-upgrade-notes"></a>
## Version Upgrade Notes

This section provides notable information for upgrades.


<a name="upgrading-from-beegfs-version-7.2.6-or-7.3.0"></a>
### Upgrading from BeeGFS version 7.2.6 or 7.3.0

BeeGFS versions released after 7.3.1 will no longer start unless a connAuthFile is specified or
'connDisableAuthentication=true' is set in the service's configuration file. By default, the beegfs_ha* roles will
generate the file and add it to the Ansible control node at
<playbook_directory>/files/beegfs/<beegfs_mgmt_ip_address>_connAuthFile. The beegfs_client role will check for the
presence of this file and supply it to the clients. However, if the beegfs_client role is not used to configure the
clients, then this file will need to be shared with them before they can gain access. It is highly recommended to enable
connection based authentication security. See
[BeeGFS Connection Based Authentication](https://doc.beegfs.io/7.3.2/advanced_topics/authentication.html#connectionbasedauth)
for more information.


<a name="beegfs-release-notes"></a>
## BeeGFS Release Notes

- [Release Notes for BeeGFS 7.2.8](https://doc.beegfs.io/7.2.8/release_notes.html)
- [Release Notes for BeeGFS 7.3.2](https://doc.beegfs.io/7.3.2/release_notes.html)
- [Release Notes for BeeGFS 7.4.3](https://doc.beegfs.io/7.4.3/release_notes.html)
