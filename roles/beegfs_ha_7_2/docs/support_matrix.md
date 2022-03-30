# Support Matrix
The following matrices show the versions of BeeGFS, operating systems, storage systems, and fence agents the role is
supporting.

<br>

## Table of Contents
------------
- [Support Matrix](#support-matrix)
  - [## Table of Contents](#-table-of-contents)
  - [## Supported BeeGFS and Operating System](#-supported-beegfs-and-operating-system)
    - [Additional Notes](#additional-notes)
  - [## Supported Storage System](#-supported-storage-system)
    - [Additional Notes](#additional-notes-1)
  - [## Supported Fence Agent](#-supported-fence-agent)
    - [Additional Notes](#additional-notes-2)

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
- BeeGFS requires time synchronization:
    - Set the `beegfs_ha_ntp_enabled` (using NTP) or `beegfs_ha_chrony_enabled` (using Chrony) flag. Disable both of
      these flags if this requirement is already handled manually.

<br>

<a name="supported-storage-system"></a>
## Supported Storage System
------------
| Platform     | SANtricity OS version | Protocols                         |
| -------------| --------------------- | --------------------------------- |
| E2800/EF280  | 11.52 or newer        | See netapp_eseries.host collection |
| E5700/EF570  | 11.52 or newer        | See netapp_eseries.host collection |
| EF600        | 11.60 or newer        | See netapp_eseries.host collection |
| EF300        | 11.70 or newer        | See netapp_eseries.host collection |

<br>

### Additional Notes
- Testing was done using E5700/11.70.2/IB-iSER, EF600/11.70.2/NVMe-IB
- The supported SAN protocols are dependent on [netapp_eseries.host collection](https://galaxy.ansible.com/netapp_eseries/host).
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