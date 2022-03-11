# Support Matrix
The following matrices show the versions of BeeGFS, Operating Systems, Storage Systems, and fence agents the role is
supporting.

<br>

## Table of Contents
------------
1. [BeeGFS and Operating System](#supported-beegfs-and-operating-system)
2. [Storage System](#supported-storage-system)
3. [Fence Agent](#supported-fence-agent)

<br>

<a name="supported-beegfs-and-operating-system"></a>
## Supported BeeGFS and Operating System
------------
| BeeGFS Component       | BeeGFS Version | Operating System                                 |
| ---------------------- |----------------|--------------------------------------------------|
| BeeGFS Server services | 7.2.6          | RedHat 8.4 (kernel 4.18.0-305.25.1.el8_4.x86_64) |

<br>

### Additional Notes
- BeeGFS Server services include BeeGFS management, metadata and storage services
- Pacemaker's crm_X tools are used even though the HAE package comes with a crm tool
- BeeGFS requires time synchronization:
    - Set the `beegfs_ha_ntp_enabled` (using NTP) or `beegfs_ha_chrony_enabled` (using Chrony) flag. Disable both of
      these flags if this requirement is already handled manually.
- SLES 15 and Ubuntu should work but was not tested, therefore, deployment using the OSes are not supported.
- SLES 12 SP4 (non-HAE) with Pacemaker and Corosync was used for limited testing and no problems were observed.
  However, deployment using the OS is not supported.

<br>

<a name="supported-storage-system"></a>
## Supported Storage System
------------
| Platform     | SANtricity OS version | Protocols                         |
| -------------| --------------------- | --------------------------------- |
| E2800/EF280  | 11.52 or newer        | See netappeseries.host collection |
| E5700/EF570  | 11.52 or newer        | See netappeseries.host collection |
| EF600        | 11.60 or newer        | See netappeseries.host collection |
| EF300        | 11.70 or newer        | See netappeseries.host collection |

<br>

### Additional Notes
- Testing was done using E5700/11.70.2/IB-iSER, EF600/11.70.2/NVMe-IB
- The supported SAN protocols are dependent on [netappeseries.host collection](https://galaxy.ansible.com/netapp_eseries/host).
  Check that collection for the list of supported protocols.

<br>

<a name="supported-fence-agent"></a>
## Supported Fence Agent
------------
The following fencing agent has been tested and is supported with this role:
- APC
- redfish

<br>

### Additional Notes
- Fence agents details can be found at [GitHub fence-agents](https://github.com/ClusterLabs/fence-agents).