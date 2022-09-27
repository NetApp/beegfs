<a name="beegfs-configuration-settings"></a>
# BeeGFS Configuration Settings

BeeGFS cluster is installed and operated using a set of configuration settings.

<a name="table-of-contents"></a>
## Table of Contents

- [BeeGFS Configuration Settings](#beegfs-configuration-settings)
  - [Table of Contents](#table-of-contents)
  - [Basic Information About the Configuration Settings](#basic-information-about-the-configuration-settings)
  - [How to Override BeeGFS Configuration Defaults](#how-to-override-beegfs-configuration-defaults)
    - [Resource Group Options Examples](#resource-group-options-examples)
    - [HA Group Options Examples](#ha-group-options-examples)
    - [Importance of Connection Authentication](#importance-of-conn-auth)

<a name="basic-information-about-the-configuration-settings"></a>
## Basic Information About the Configuration Settings

There are several configuration files that contain the settings needed for the BeeGFS cluster to operate. The BeeGFS HA 
role is required to set several of the configuration settings with default values to bring up the cluster. However, 
those are default values and so users may override any of the settings in the configuration files to optimize
the cluster even further.

Refer to BeeGFS documentation for more information on the different configuration settings and files used by the 
cluster.

The locations of each configuration files (management, metadata, storage) are denoted using the below variables in
`beegfs_ha_7_3/defaults/main.yml`:
- `beegfs_ha_beegfs_mgmtd_conf_path`
- `beegfs_ha_beegfs_meta_conf_path`
- `beegfs_ha_beegfs_storage_conf_path`

The default values set can be found under the below variables:
- `beegfs_ha_beegfs_mgmtd_conf_default_options`
- `beegfs_ha_beegfs_meta_conf_default_options`
- `beegfs_ha_beegfs_storage_conf_default_options`

<a name="how-to-override-beegfs-configuration-defaults"></a>
## How to Override BeeGFS Configuration Defaults

The below variables can be used to override the configuration parameters depending on which resource type and group. 
Include the applicable variables in the appropriate inventory files and specify ANY valid parameters with their values 
to override.

Management resource:

    beegfs_ha_beegfs_mgmtd_conf_resource_group_options      # This variable typically goes into the `group_vars/mgmt.yml` file
    beegfs_ha_beegfs_mgmtd_conf_ha_group_options            # This variable typically goes into the `group_vars/ha_cluster.yml` file

Metadata resource:

    beegfs_ha_beegfs_meta_conf_resource_group_options      # This variable typically goes into the `group_vars/meta_<number>.yml` files
    beegfs_ha_beegfs_meta_conf_ha_group_options            # This variable typically goes into the `group_vars/ha_cluster.yml` file

Storage resource:

    beegfs_ha_beegfs_storage_conf_resource_group_options   # This variable typically goes into the `group_vars/stor_<number>.yml` files
    beegfs_ha_beegfs_storage_conf_ha_group_options         # This variable typically goes into the `group_vars/ha_cluster.yml` file


Note: The [Getting Started](getting_started.md) page has usage examples with one or more of the variables. 

<a name="resource-group-options-example"></a>
### Resource Group Options Examples

- Management parameters are typically provided in `group_vars/mgmt.yml`:
  ```
  beegfs_ha_beegfs_mgmtd_conf_resource_group_options:
    connMgmtdPortTCP: <port>
  ```
- Metadata parameters are typically provided in `group_vars/meta_0<number>.yml` (i.e., group_vars/meta_01.yml):
  ``` 
  beegfs_ha_beegfs_meta_conf_resource_group_options:
    connFallbackExpirationSecs: <number>
  ```
- Storage parameters are typically provided in `group_vars/stor_0<number>.yml` (i.e., group_vars/stor_01.yml):
  ```
  beegfs_ha_beegfs_storage_conf_resource_group_options:
    logNumRotatedFiles: <number>
  ```

<a name="ha-group-options-example"></a>
### HA Group Options Examples

- Parameters parameters are typically provided in `group_vars/ha_cluster.yml`:
  ```
  beegfs_ha_beegfs_mgmtd_conf_ha_group_options:
    logStdFile: <log_path>
    connAuthFile: /etc/beegfs/connAuthFile  # IMPORTANT: See the section on connection based authentication below.

  beegfs_ha_beegfs_meta_conf_ha_group_options:
    logStdFile: <log_path>
    connAuthFile: /etc/beegfs/connAuthFile

  beegfs_ha_beegfs_storage_conf_ha_group_options:
    logStdFile: <log_path>
    connAuthFile: /etc/beegfs/connAuthFile    
  ```

<a name="importance-of-conn-auth"></a>
### Importance of Connection Based Authentication

BeeGFS strongly recommends enabling connection based authentication to avoid unintended clients or users interacting
with the file system. This is enabled by distributing a file only readable by the root user containing a shared secret 
for all BeeGFS servers and clients that should participate in the file system. Then specify the path to this file as 
`connAuthFile` in all BeeGFS service and client configuration files. 

At this time there isn't a built-in way to use the Ansible BeeGFS roles to distribute the shared secret file to all 
BeeGFS servers and clients. This can be done manually, or you can add a task similar to the one below to your playbook 
before importing the BeeGFS HA role:

```yaml
  [...]
  tasks:
    - name: Create /etc/beegfs/connAuthFile 
      ansible.builtin.lineinfile:
        path: /etc/beegfs/connAuthFile
        line: "secret"
        create: yes
        owner: root
        group: root
        mode: '0400'
      tags:
        - beegfs_ha
      when: inventory_hostname not in groups[beegfs_ha_ansible_storage_group]

    - name: Verify the BeeGFS HA cluster is properly deployed.
      import_role:
        name: beegfs_ha_7_3
```

See the [HA Group Options Examples](#ha-group-options-example) section above for how to enable the BeeGFS services
to use this file when using Ansible to deploy/manage the cluster. 

IMPORTANT: In later versions of BeeGFS a connAuthFile is required by default, or it must be explicitly disabled.
For better security and to simplify upgrading to future BeeGFS versions, creating a connAuthFile when initially 
deploying the cluster is recommended.

For more details see:

* https://doc.beegfs.io/latest/advanced_topics/authentication.html
* https://www.beegfs.io/c/the-importance-of-using-connauthfile-in-beegfs/
