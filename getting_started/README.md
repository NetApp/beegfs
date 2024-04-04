<a name="getting-started"></a>
# Getting Started

This document serves as a starting guide for users to utilize the `netapp_eseries.beegfs` collection. It provides
resources to assist users in configuring the neccesary Ansible files for a comprehensive deployment of BeeGFS within
a High Availability (HA) Cluster environment.

<a name="table-of-contents"></a>
## Table of Contents

- [Getting Started](#getting-started)
  - [Table of Contents](#table-of-contents)
  - [Requirements](#requirements)
  - [Getting Started Guide](#getting-started-guide)
    - [Building Your BeeGFS HA Building Block Inventory and Playbook Files](#building-your-beegfs-ha-building-block-inventory-and-playbook-files)
    - [Building Your BeeGFS Client Inventory and Playbook Files](#building-your-beegfs-client-inventory-and-playbook-files)
  - [Example Playbook, Inventory, Group/Host Variables](#example-playbook-inventory-grouphost-variables)
  - [General Notes](#general-notes)

<a name="requirements"></a>
## Requirements

Before following this guide, please adhere to the requirements outlined in this collection's
[README](../README.md#requirements).

<a name="getting-started-guide"></a>
## Getting Started Guide

Each role in the collection operates independently to deploy a specific version of BeeGFS, configured for a particular
mode of operation. For more detailed information about a role's use case and variables, please refer to its
corresponding readme file.

* [BeeGFS 7.4 with High-Availability (HA)](../roles/beegfs_ha_7_4/README.md): Provides end-to-end deployment of the
NetApp E-Series BeeGFS HA solution. It includes provisioning and mapping E-Series storage, creating a Linux HA cluster
using Pacemaker and Corosync, deploying BeeGFS into the cluster, and configuring clients.

* [BeeGFS Client](../roles/beegfs_client/README.md): Installs the BeeGFS Client and, if requested, mounts one or more
BeeGFS file systems, or the same BeeGFS file system multiple times. The role can also unmount one or more BeeGFS file
systems if requested.

To utilize these roles and begin deploying BeeGFS to storage clusters or client nodes, you will need to configure the
inventory, host/group variables, passwords, and playbook files. Follow the instructions in the next
[section](#building-your-beegfs-client-inventory-and-playbook-files) to build these files according to your BeeGFS
cluster environment. The `passwords.yml` file requires credentials for various components in the HA structure. For a
secure environment, the supplied passwords should not be stored in plain text. Use
[Ansible Vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html) to encrypt passwords.

<a name="building-your-beegfs-ha-building-block-inventory-and-playbook-files"></a>
### Building Your BeeGFS HA Building Block Inventory and Playbook Files

#### NetApp Verified Architecture (NVA)

Standard BeeGFS configurations that are optimized to meet the performance requirements of demanding workloads which defined in `NVA` [generations](https://docs.netapp.com/us-en/beegfs/beegfs-gens.html). Use one of the `gen` folders in `beegfs_on_netapp` folder to deploy a standard BeeGFS configuration for your system.

#### Custom Architecture

Custom configurations are defined by users. There are two methods to build your inventory and playbook files:

* The first, and recommended method, is to follow the instructions provided in the `beegfs_ha_building_block`
[README](beegfs_on_custom_configurations/beegfs_ha_building_block/README.md). The instructions walk the user through creating an inventory
structure, populating the inventory variables, and deploying BeeGFS HA services.

* The second method involves manually creating the inventory, playbook, group variables, and host variables using the
examples found in the `beegfs_on_custom_configurations/examples/` folder.
Once all the files are populated according to your configuration, BeeGFS HA services can be deployed by running
the following playbook:

  ```
  ansible-playbook -i <inventory>.yml <playbook>.yml
  ```

<a name="building-your-beegfs-client-inventory-and-playbook-files"></a>
### Building Your BeeGFS Client Inventory and Playbook Files

#### NetApp Verified Architecture (NVA)

Use one of the `gen` folders in `beegfs_on_netapp` folder to deploy a standard BeeGFS configuration for your system.

#### Custom Architecture

Follow the instructions provided in the `beegfs_client` [README](beegfs_on_custom_configurations/beegfs_client/README.md). The instructions
walk the user through creating an inventory, host variables, and a playbook to install the BeeGFS client service to a
node and, if desired, mount one or more beeGFS file systems (or the same file system multiple times).

<a name="example-playbook-inventory-grouphost-variables"></a>
## Example Playbook, Inventory, Group/Host Variables

Example playbook, inventory, and group/host variable files can be referenced in the `beegfs_on_netapp` OR `beegfs_on_custom_configurations/examples` folder. There
you can find examples of how to layout the playbook and inventory files. In depth configuration instructions can be
found on the NetApp Docs portal: [BeeGFS on NetApp with E-Series Storage](https://docs.netapp.com/us-en/beegfs/beegfs-deploy-create-inventory.html#step-1-define-configuration-for-all-building-blocks).

The variables used in the inventory files are not exhaustive, see additional variables from under
[role variables](../docs/beegfs_ha/role_variables.md) or other NetApp E-Series Ansible Collections
([santricity](https://galaxy.ansible.com/netapp_eseries/santricity),
[host](https://galaxy.ansible.com/netapp_eseries/host)).

<a name="general-notes"></a>
## General Notes

- All BeeGFS cluster nodes must be available for the deployment process to function properly.
- Fencing agents should be used to ensure failed nodes are definitely down.
  - WARNING: If `beegfs_ha_cluster_crm_config_options['stonith-enabled']` is set to false, then the fencing agent will
  not be configured!
  - For details on configuring different fencing agents, see [Configuring Fencing in a High Availability Cluster](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html/configuring_and_managing_high_availability_clusters/assembly_configuring-fencing-configuring-and-managing-high-availability-clusters).
- BeeGFS is added to the PRUNEFS list in /etc/updatedb.conf to prevent daily indexing scans on clients which causes
performance degradations.
- Please refer to the documentation for your Linux distribution/version for guidance on the maximum cluster size. For
example, the limitations for RedHat can be found [here](https://access.redhat.com/articles/3069031).

<a name="maintainer-information"></a>
## Maintainer Information

- Christian Whiteside (@mcwhiteside)
- Vu Tran (@VuTran007)