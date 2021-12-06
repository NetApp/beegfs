## Table of Contents

1. Support Matrix(#support-matrix)
## TODO: TRACY TO UPDATE
## Support Matrix
--------------
The BeeGFS role has been tested with the following BeeGFS versions, operating systems, and backend/frontend protocols:

| Component              | BeeGFS Version | Operating System        | Storage Protocols             | Client Protocols  |
| ---------------------- | -------------- | ----------------------- | ----------------------------- | ----------------- |
| BeeGFS Client service  | 7.2            | RedHat 7.8              | N/A                           | TCP/UDP and RDMA  |
| BeeGFS Server services | 7.2            | RedHat 7.8              | IB-iSER, iSCSI                | N/A               |

Notes:
- BeeGFS Server services include BeeGFS management, metadata and storage services.
- While not explicitly tested, it is reasonable to expect implicit support for the following:
  - Versions of BeeGFS within the same major/minor release family (i.e. BeeGFS 7.2.X).
- SLES 12 SP4 has been tested with the Pacemaker and Corosync packages but not the SLES HAE package that may be required for a SUSE support subscription. The crm tool that comes with the HAE package has not been added to the automation so the crm_X tools that come with pacemaker will need to be used in its stead.
- BeeGFS requires time synchronization. NTP or Chrony can be configured using `beegfs_ha_ntp_enabled` or `beegfs_ha_chrony_enabled` respectively. Disable both of these flags if this requirement is already handled.

The BeeGFS role has been tested with the following E-Series storage systems and protocols:

| Platform | Firmware | Protocols                   |
| -------- | -------- | --------------------------- |
| E5700    | 11.52    | FC, iSCSI, IB-iSER, NVMe-IB |

Notes:
- While not explicitly included in testing, other firmware versions and storage systems including the E2800, EF570, and EF600 (iSER only).
- Other SAN protocols including InfiniBand SRP, Fibre Channel, NVMe over IB, NVMe over FC, and NVMe over RoCE are expected to work when [netappeseries.host collection](https://galaxy.ansible.com/netapp_eseries/host) implements them. At the time of writing only iSCSI and InfiniBand iSER have been implemented.