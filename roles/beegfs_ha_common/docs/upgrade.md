<a name="upgrade"></a>
# Upgrade

The BeeGFS HA role has allows for online upgrades between roles such as between beegfs_ha_7_2 and beegfs_ha_7_3. Be
aware that this upgrade will reduce BeeGFS file node performance while they are placed into standby.

<a name="table-of-contents"></a>
## Table of Contents

- [Upgrade](#upgrade)
  - [Table of Contents](#table-of-contents)
  - [Online Upgrade](#online-upgrade)
    - [Update Ansible Inventory](#update-ansible-inventory)
    - [Update Ansible Playbook](#update-ansible-playbook)
  - [Version Upgrade Notes](#version-upgrade-notes)
    - [Upgrade for beegfs_ha_7_2 to beegfs_ha_7_3 roles](#upgrade-for-beegfs-ha-7-2-to-beegfs-ha-7-3-roles)

<a name="online-upgrade"></a>
## Online Upgrade

The following steps are required to perform an online upgrade of the nodes in your HA cluster.

<a name="update-ansible-inventory"></a>
### Update Ansible Inventory

Make any required or desired updates to your cluster's Ansible inventory files. See
[Version Upgrade Notes](#version-upgrade-notes) for details about your specific upgrade inventory requirements. See
[Getting Started - Example Inventory File](getting_started.md#example-inventory-file) for more information about
configuring your BeeGFS HA inventory files.


<a name="update-ansible-playbook"></a>
### Update Ansible Playbook

Update your Ansible playbook to import the desired BeeGFS HA role. See
[Getting Started - Example BeeGFS HA Playbook File](getting_started.md#example-beegfs-ha-playbook-file) for more
information about configuring your BeeGFS HA playbook file.

<a name="version-upgrade-notes"></a>
## Version Upgrade Notes

This section provides information for upgrades between BeeGFS collection roles.

<a name="upgrade-for-beegfs-ha-7-2-to-beegfs-ha-7-3-roles"></a>
## Upgrade for beegfs_ha_7_2 to beegfs_ha_7_3 roles

TBD
