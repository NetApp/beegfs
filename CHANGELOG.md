# Changelog
Notable changes to the BeeGFS collection will be documented in this file.

[3.2.0] - 2024-03-30
--------------------
### Added
- Add beegfs_ha_7_4 role to support BeeGFS 7.4.2 with RHEL/Rocky 9.

### Deprecated
- Remove deprecated beegfs_ha_7_2 role.

[3.1.0] - 2023-01-30
--------------------
### Added
- Add beegfs_ha_7_3 and beegfs_ha_common roles. Both beegfs_ha_7_2 and beegfs_ha_7_3 utilize beegfs_ha_common using their own defaults.
- Update collection to use the latest BeeGFS versions (7.2.8/7.3.2)
- Add support for online BeeGFS version upgrades
- Add support for BeeGFS connection authentication
- Improve the process for restoring the BeeGFS HA resources.
  - Add probe to ensure resources are started correctly
  - Simplify the resource relocation process when previously failover.
  - Improve code supportability and reusability
- Improve BeeGFS client role
  - Add template for beegfs-mounts.conf to avoid issues with mounts not defined in the inventory.
  - Complete the client restart handler process (i.e. stop client, remove mounts, unload beegfs module, stop helperd, start helperd, start client)
- Add support for multi-rail communications
- Add support for NVIDIA GPUDirect (GDS)
- Add support for Rocky Linux

### Deprecated
- Deprecated the beegfs_ha_7_2 role and will be removed in a future release.

[3.0.1] - 2022-08-15
--------------------
### Added
- Added beegfs_ha_firewall_configure variable to control whether the firewall is configured.
- Increase default threshold for IP neighbor garbage collection.
- Improve uninstall task ordering and make reboot asynchronous with storage system tasks.
- Increase Ansible version requirement to 2.10 or later.
- Add control variable to skip firewall configuration.

### Fixed
- Increase beegfs-monitor timeout to 120 seconds to allow monitor operation to complete under extremely high loads.
- Allow automation to continue after maintenance mode fails to be set which resolves issues such as when deployments
  were stopped before configuring corosync.
- Handle scenarios where the node running the BeeGFS management service is not listed first in the inventory file and
  used as the preferred management node for the cluster.

[3.0.0] - 2022-04-05
--------------------
 ### Added
- A role (beegfs_ha_7_2) to deploy BeeGFS 7.2 into a Linux High Availability cluster backed by NetApp E-Series
  shared-storage that includes:
  - The ability to deploy BeeGFS with and without HA, eliminating the need to ship/maintain separate roles, and allow
    switching between HA/non-HA BeeGFS file systems post-deployment.
  - A custom OCF resource agent for BeeGFS health monitoring that allows for more fine grained monitoring of BeeGFS
    services and dependent resources than built-in Pacemaker resource agents. Among other benefits this allows the
    cluster to be more intelligent about what failure conditions prompt a full node failover, reducing the performance
    impact of many failures.
  - Support for configuring multiple network interfaces in the same IP subnet (multihoming) using a custom BeeGFS IP
    address OCF resource. This allows multiple BeeGFS services to run on the same physical server using
    different/isolated network interfaces. One benefit is the ability to minimize rack space required for BeeGFS
    deployments by enabling use of fewer higher performance servers reducing overall cost.
  - A custom OCF file system resource (BeeGFS target) that optimizes remounting BeeGFS targets after a node failover
    occurs. This helps reduce time to restore BeeGFS services on a secondary node minimizing disruption to client I/O.
  - Support for configuring cluster IP addresses on the same interfaces used for BeeGFS data traffic. This provides more
    flexibility in how redundant cluster networks can be established without the need to purchase additional network
    hardware.
  - Expanded the range of available performance tuning options. These now cover underlying block devices, virtual
    memory, CPU performance, PCIe request sizes, BeeGFS server settings, and more. All default values are tested by
    NetApp to help maximize performance especially when combined with NetApp verified architectures.
  - The ability to combine multiple standalone Linux HA clusters into a single BeeGFS file system. This enables BeeGFS
    file systems to scale independently of Pacemaker/Corosync limits on the number of resources/nodes in a cluster.
- A role (beegfs_client) that includes:
  - The ability to install and configure the BeeGFS client kernel module, including building with support for inbox or
    Mellanox OFED drivers.
  - Mounting one or more BeeGFS file systems (and/or the same file system multiple times) and specifying custom
    configuration.
  - Automatic tuning of kernel read ahead settings for BeeGFS mounts improving sequential read performance and greatly
    improving reread performance when using the Linux kernel page cache (tuneFileCacheType=native). This has been shown
    to have a significant impact on certain workloads such as deep learning.
- An interactive example to expedite getting started with the BeeGFS 7.2 HA role.

### Known Issues and Restrictions
- (ESOLA-115) When BeeGFS client/server RDMA connections are disrupted unexpectedly, either through loss off the primary
  interface (as defined in `connInterfacesFile`) or a BeeGFS server failing, active client I/O can hang for up to ten
  minutes before resuming. This issue does not occur when BeeGFS nodes are gracefully placed in and out of standby for
  planned maintenance.
  - Impact: Applications will not observe an I/O error, and only applications that implement timeouts around file I/O
    operations (open, close, read, write, etc.) are expected to see any impact due to this issue.
  - Workaround: Disabling use of RDMA on BeeGFS clients (connUseRDMA=False) and only using TCP will prevent this issue
    from occurring. Note disabling RDMA will likely have a negative impact on performance.
  - Technical Details: This is due to the current connection response timeout in BeeGFS. While currently this timeout is
    not user configurable, work is underway to decrease this timeout in the future.

### Removed
- Legacy roles for deploying BeeGFS 7.1. Note BeeGFS can be cleanly upgraded from 7.1 to 7.2.
  - IMPORTANT: Please open a support ticket for assistance migrating 7.1 BeeGFS Ansible inventories to the new 7.2
    format.
- A Dockerfile that built an Ansible Control Node containing the NetApp E-Series collections.
  - Note: At this time Ansible Galaxy will be the primary distribution/installation mechanism for this and other
    collections it depends on.

[2.0.0] - 2020-08-16
--------------------
### Added
- The focus of this release was adding a beegfs_ha_7_1 role to deploy [NetApp's High Availability solution for
  BeeGFS](https://blog.netapp.com/high-availability-beegfs) to RedHat and CentOS hosts along with supporting
  documentation.
- An interactive example that expedites getting started with the beegfs_ha_7_1 role by generating a full skeleton
  inventory through an interactive playbook (see: `examples/beegfs_ha_7_1/README.md`).

### Changed
- Building the Docker image now includes the new E-Series Host collection and additional dependencies. Added a
  .dockerignore file to help reduce final image size.
- Documentation for each role is now being maintained under the respective roles. The README in the base of the project
  provides links to the documentation for all currently supported roles.
- Role specific changes: nar_santricity_beegfs_7_1
  - Added a note to the README under Known Issues/Limitations with observed behavior when regularly
    deploying/wiping/redeploying BeeGFS using the yum package manager.
  - Changed how the uninstall mode detects what services need to be removed from each node improving the ability to
    handle certain edge cases. Related refactoring to how the tasks in the uninstall mode are organized.
  - This role can now discover/use volumes when the user_friendly_names multipath option is enabled.

### Fixed
- Role specific fixes: nar_santricity_beegfs_7_1
  - Added additional rescans required to detect newly mapped E-Series volumes attached through iSCSI/iSER without a
    reboot.
  - Updated the role to work with both new and legacy versions of the SANtricity collection.

[1.1.0] - 2020-04-10
--------------------

### Added
- Support for using E-Series volumes presented over NVMe-oF protocols as BeeGFS storage/metadata targets.
- Support for defining multiple BeeGFS file systems in the same inventory file.
- Post-deployment check to verify the BeeGFS deployment(s) described in the inventory match the output of
  `beegfs-check-servers`.

### Changed
- Updates to the provided examples.
- Required version of the netapp_eseries.santricity collection in galaxy.yml.

[1.0.0] - 2020-03-19
--------------------
- Initial release.
