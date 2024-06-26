# netappeseries.beegfs.client Role

Installs the BeeGFS Client and optionally mounts one or more BeeGFS file systems, or the same BeeGFS file system multiple times. The role can also unmount one or more BeeGFS file systems if requested.


## Requirements

* The BeeGFS client [does not currently support SELinux](https://doc.beegfs.io/latest/trouble_shooting/general.html#access-denied-error-on-the-client-even-with-correct-permissions) so it must be disabled before running the role.
* The firewall ports used by the BeeGFS client for communication must not be blocked. The default TCP/UDP ports [can be found here](https://doc.beegfs.io/latest/advanced_topics/network_tuning.html#firewalls-network-address-translation-nat), and optionally overridden as part of mounting BeeGFS using this role (see beegfs_client_config below).
* When installing the BeeGFS client to Ubuntu, the ca-certificates package must be installed, or an error like the following will occur when attempting to add the BeeGFS repository using apt: `Certificate verification failed: The certificate is NOT trusted. The certificate chain uses expired certificate.  Could not handshake: Error in the certificate verification. [IP: 178.254.21.65 443]`. If you still get this error with ca-certificates installed try updating the package.

IMPORTANT: If you are using this role in conjunction with the BeeGFS high availability solution deployed by the other role(s) in this collection, please see the notes below for additional [requirements when mounting BeeGFS with HA enabled](#requirements-when-mounting-beegfs-with-ha-enabled).


## Support Matrix

| Component              | BeeGFS Version | Operating System          | Client Protocols  |
| ---------------------- |----------------| ------------------------- | ----------------- |
| BeeGFS Client Services | 7.2.6          | RedHat 8.3, Ubuntu 20.04  | TCP/UDP and RDMA  |
| BeeGFS Client Services | 7.4.3          | Ubuntu 22.04 LTS          | TCP/UDP and RDMA  |


## Supported Tags

* beegfs_client_install
* beegfs_client_mount


## Variables


### Required

None.


### Optional

The following variables control how the BeeGFS client is installed and kernel module built:

* Specify if the Mellanox OFED driver should be used instead of the inbox drivers (default: False):
  * `beegfs_client_ofed_enable: False`
* To use the InfiniBand kernel modules from the OpenFabrics OFED, you must specify the header include path:
  * `beegfs_client_ofed_include_path: "/usr/src/ofa_kernel/default/include"`
* Create a BeeGFS client udev rule to override attributes in `/sys/class/bdi/beegfs-*` when BeeGFS is mounted (default: True):
  * `beegfs_client_udev_rule_install: True`
* Adjust attributes in `/sys/class/bdi/beegfs-*` tuned by the BeeGFS client udev rule:
  * `beegfs_client_udev_rule_attributes['read_ahead_kb']=4096`
  * Note: Adding additional attributes beyond `read_ahead_kb` or changing the value to anything other than 4096 has NOT been tested extensively, and may result in performance or stability issues.

* Experimental - Specify if the DKMS or traditional BeeGFS client should be installed (default: False):
  * `beegfs_client_dkms_install: False`
  * Note: Currently installing the beegfs-client-dkms package using this role is an experimental feature. In particular changes to enable/disable the OFED driver will not automatically rebuild/reload the BeeGFS kernel module.

Mounting one or more BeeGFS file systems is possible by specifying the following (at minimum):
```
beegfs_client_mounts:
  - sysMgmtdHost: <BeeGFS Management Server IP or Hostname>
    mount_point: /mnt/beegfs

  - sysMgmtdHost: <BeeGFS Management Server IP or Hostname>
    mount_point: /mnt/beegfs_2
```

A connInterfacesFile will be created/populated by specifying `connInterfaces` and any parameters in the beegfs-client.conf file (except `sysMgmtdHost`) can be overridden by adding a `beegfs_client_config` section:
```
  - sysMgmtdHost: <BeeGFS Management Server IP or Hostname>
    mount_point: /mnt/beegfs
    connInterfaces:
      - ibs4f1
      - ibs1f1
    beegfs_client_config:
      connMaxInternodeNum: 128
      connMaxConcurrentAttempts: 0
```

Mounting the same BeeGFS file system multiple times is possible by providing different mount points and specifying different `connClientPortUDP` values:

```
beegfs_client_mounts:
  - sysMgmtdHost: <BeeGFS Management Server IP or Hostname>
    mount_point: /mnt/beegfs
    connInterfaces:
      - ibs4f1
      - ibs1f1
    beegfs_client_config:
      connClientPortUDP: 8004

  - sysMgmtdHost: <BeeGFS Management Server IP or Hostname>
    mount_point: /mnt/beegfs_2
    connInterfaces:
      - ibs1f1
      - ibs4f1
    beegfs_client_config:
      connClientPortUDP: 8005
```

Unmounting BeeGFS is possible by setting `mounted: False` on individual entries:
```
beegfs_client_mounts:
  - sysMgmtdHost: <BeeGFS Management Server IP or Hostname>
    mount_point: /mnt/beegfs
    mounted: False
```

Add Multirail support:
  * All BeeGFS services are required to be accessible from the same network.
  * BeeGFS client interfaces must be multi-homed.

        When multi-rail support is enabled it's important for the RDMA interfaces to be contained within the same
        subnet; this requires the RDMA interfaces to be multi-homed. When configuring IP interfaces using one of the
        netapp_eseries.host roles simply add '99-multihoming.j2' to the list of hook_templates for the interfaces.
        Otherwise, see the [beegfs guide for configuring client multi-rail support](https://doc.beegfs.io/latest/advanced_topics/rdma_support.html#client-multi-rail-support).

  * Update the mounts defined in beegfs_client_mounts list in the client's inventory.

        connRDMAInterfaces:
          - <Interface 1>
          - <Interface N>

Add NVIDIA GPUDirect storage support:
  * Install nvidia.nvidia_driver role

        ansible-galaxy install nvidia.nvidia_driver

  * Add nvidia.nvidia_driver role to the client playbook.

        - name: Install and configure BeeGFS clients.
          hosts: beegfs_clients
          roles:
            - nvidia.nvidia_driver

  * Update the client's inventory variables.

        beegfs_client_gds_support: true
        nvidia_driver_ubuntu_install_from_cuda_repo: true
        nvidia_driver_branch: "<NVIDIA_GPU_DRIVER_BRANCH>"

  * For more information visit, https://doc.beegfs.io/7.3.2/advanced_topics/gds_support.html.
  * For more information regarding which NVIDIA GPU driver branch to use visit,
    https://www.nvidia.com/download/index.aspx?lang=en-us. Note that the driver branch dictates which version of CUDA
    that can be used.


Notes:
* Specifying `sysMgmtdHost` in `beegfs_client_config` is not supported since it is has to be configured elsewhere.
* Specifying `connInterfacesFile` in `beegfs_client_config` is supported, though unnecessary as specifying `connInterfaces` will generate a file and populate this automatically.
  * If both `connInterfaces` and `connInterfacesFile` are specified then any existing `connInterfacesFile` will be overwritten to reflect `connInterfaces`.
* By default the role will attempt to mount all BeeGFS filesystems listed in `beegfs_client_mounts` every time it runs unless `mounted: False`, in which case it will ensure that file system is unmounted.

<a name="requirements-when-mounting-beegfs-with-ha-enabled"></a>
## Requirements when mounting BeeGFS with HA enabled

If you are using the BeeGFS client role to mount a BeeGFS filesystem backed by NetApp's shared-disk high availability solution, to prevent clients reporting "remote I/O" errors when a storage service crashes and is restarted on another node, [`sysSessionChecksEnabled`](https://git.beegfs.com/pub/v7/-/blob/master/client_module/build/dist/etc/beegfs-client.conf#L312) must be set to false in the `beegfs_client_config` for each mount point:
```
beegfs_client_mounts:
  - sysMgmtdHost: <BeeGFS Management Server IP or Hostname>
    mount_point: /mnt/beegfs
    beegfs_client_config:
      sysSessionChecksEnabled: false
```
IMPORTANT: To prevent silent data corruption `sysSessionChecksEnabled: false` must only be set when the underlying ext4/xfs filesystems used for the BeeGFS management, metadata and storage targets are mounted using the "sync" option. Mounting the targets in "sync" mode is the default configuration provided by the beegfs_ha* roles provided in this collection, but could be overridden.


## Configuring BeeGFS connection authentication

If your BeeGFS filesystem requires connection authentication then the shared secret must be provided to all the clients.
BeeGFS versions released after 7.3.1 will require this by default.

Notes:
 * The beegfs_ha roles from BeeGFS Collection 3.1.0 or newer will have connection authentication enabled by default and
will generate <playbook_dir>/files/beegfs/<mgmt_ip>_connAuthFile to be shared with its clients. This file will be used
when `beegfs_client_connAuthFile_enabled: true`, which is its default.

Providing a source file for a mount's connection authentication:
```
beegfs_client_mounts:
  - sysMgmtdHost: <BeeGFS Management Server IP or Hostname>
    connAuthFile_src: files/beegfs/connAuthFile  # Relative path will start in the playbook's directory.
```

Providing a secret for a mount's connection authentication:
```
beegfs_client_mounts:
  - sysMgmtdHost: <BeeGFS Management Server IP or Hostname>
    connAuthFile_secret: <Shared BeeGFS Secret>
```

Skipping a mount's connection authentication:
```
beegfs_client_mounts:
  - sysMgmtdHost: <BeeGFS Management Server IP or Hostname>
    connAuthFile_enabled: false
```


## Tuning recommendations when mounting BeeGFS

While the default parameters provided in beegfs-client.conf provide reasonable performance, adjusting the following `beegfs_client_config` parameters has been seen to improve performance with many workloads:

```
beegfs_client_mounts:
  - sysMgmtdHost: <BeeGFS Management Server IP or Hostname>
    mount_point: /mnt/beegfs
    beegfs_client_config:
      connMaxInternodeNum: 128 # Maximum number of simultaneous connections to the same node (BeeGFS Client Default: 12).
      connRDMABufNum: 36 # Allocates the number of buffers for transferring IO (BeeGFS Client Default: 70).
      connRDMABufSize: 65536 # Size of each allocated RDMA buffer (BeeGFS Client Default: 8192).
```


## BeeGFS commands

    beegfs-check-servers -p <MOUNT_PATH>   # Checks connectivity for all BeeGFS servers.
    beegfs-net                             # Shows established connections to BeeGFS servers.
    beegfs-df -p <MOUNT_PATH>              # Shows available capacity information.
    beegfs-ctl                             # Comprehensive command-line tool for BeeGFS (see beegfs-ctl --help for more details)


## Limitations

* When using the non-DKMS client, to allow support for mounting the same BeeGFS file system multiple times or mounting multiple BeeGFS file systems, mounting BeeGFS using the default BeeGFS mount point in combination with the default BeeGFS client conf file is not supported (`/mnt/beegfs /etc/beegfs/beegfs-client.conf`). The role will automatically remove this default entry from beegfs-mounts.conf.


## Maintainer Information

- Christian Whiteside (@mcwhiteside)
- Vu Tran (@VuTran007)