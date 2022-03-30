# BeeGFS Configuration Settings
BeeGFS cluster is installed and operated using a set of configuration settings.

## Table of Contents
------------
- [BeeGFS Configuration Settings](#beegfs-configuration-settings)
  - [## Table of Contents](#-table-of-contents)
  - [## Basic Information About the Configuration Settings](#-basic-information-about-the-configuration-settings)
  - [## How to Override BeeGFS Configuration Defaults](#-how-to-override-beegfs-configuration-defaults)
    - [Resource Group Options Examples:](#resource-group-options-examples)
    - [HA Group Options Examples](#ha-group-options-examples)
- [mgmt - BeeGFS HA Management](#mgmt---beegfs-ha-management)

<a name="basic-information-about-the-configuration-settings"></a>
## Basic Information About the Configuration Settings
------------
There are several configuration files that contain the settings needed for the BeeGFS cluster to operate. The BeeGFS HA 
role is required to set several of the configuration settings with default values to bring up the cluster. However, 
those are default values and so users may override any of the settings in the configuration files to optimize
the cluster even further.

Refer to BeeGFS documentation for more information on the different configuration settings and files used by the 
cluster.

The locations of each configuration files (management, metadata, storage) are denoted using the below variables in
`beegfs_ha_7_2/defaults/main.yml`:
- `beegfs_ha_beegfs_mgmtd_conf_path`
- `beegfs_ha_beegfs_meta_conf_path`
- `beegfs_ha_beegfs_storage_conf_path`

The default values set can be found under the below variables:
- `beegfs_ha_beegfs_mgmtd_conf_default_options`
- `beegfs_ha_beegfs_meta_conf_default_options`
- `beegfs_ha_beegfs_storage_conf_default_options`

<br>

<a name="how-to-override-beegfs-configuration-defaults"></a>
## How to Override BeeGFS Configuration Defaults
--------------------------
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

<br>

### Resource Group Options Examples:
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

<br>

### HA Group Options Examples
- Parameters parameters are typically provided in `group_vars/ha_cluster.yml`:
  ```
  # mgmt - BeeGFS HA Management 
  beegfs_ha_beegfs_mgmtd_conf_ha_group_options:
    logStdFile: <log_path>
  beegfs_ha_beegfs_meta_conf_ha_group_options:
    logStdFile: <log_path>
  beegfs_ha_beegfs_storage_conf_ha_group_options:
    logStdFile: <log_path>