BeeGFS Client Role 
------------------

Installs the BeeGFS Client and optionally mounts one or more BeeGFS file systems, or the same BeeGFS file system multiple times. The role can also unmount one or more BeeGFS file systems if requested.

Prerequisites
-------------

* When installing the BeeGFS client to Ubuntu, the ca-certificates package must be installed, or an error like the following will occur when attempting to add the BeeGFS repository using apt: `Certificate verification failed: The certificate is NOT trusted. The certificate chain uses expired certificate.  Could not handshake: Error in the certificate verification. [IP: 178.254.21.65 443]`. If you still get this error with ca-certificates installed try updating the package. 

Supported Tags
--------------

* beegfs_client_install
* beegfs_client_mount

Variables
---------

### Required

None.

### Optional 

The following variables control how the BeeGFS client is installed and kernel module built: 

* Specify if the Mellanox OFED driver should be used instead of the inbox drivers (default: False):
  * `beegfs_client_ofed_enable: False`
* To use the InfiniBand kernel modules from the OpenFabrics OFED, you must specify the header include path: 
  * `beegfs_client_ofed_include_path: "/usr/src/ofa_kernel/default/include"`
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
  - sysMgmtdHost: mgmt
    mount_point: /mnt/beegfs
    connInterfaces:
      - ibs4f1
      - ibs1f1
    beegfs_client_config:
      connClientPortUDP: 8004

  - sysMgmtdHost: mgmt
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
  - sysMgmtdHost: mgmt
    mount_point: /mnt/beegfs
    mounted: False
```    

Notes: 
* Specifying `sysMgmtdHost` in `beegfs_client_config` is not supported since it is has to be configured elsewhere.
* Specifying `connInterfacesFile` in `beegfs_client_config` is supported, though unnecessary as specifying `connInterfaces` will generate a file and populate this automatically.
* By default the role will attempt to mount all BeeGFS filesystems listed in `beegfs_client_mounts` every time it runs unless `mounted: False`, in which case it will ensure that file system is unmounted.

Tuning recommendations when mounting BeeGFS
-------------------------------------------

While the default parameters provided in beegfs-client.conf provide reasonable performance, adjusting the following `beegfs_client_config` parameters has been seen to improve performance with many workloads: 

```
beegfs_client_mounts:
  - sysMgmtdHost: mgmt
    mount_point: /mnt/beegfs   
    beegfs_client_config:
      connMaxInternodeNum: 128 # Maximum number of simultaneous connections to the same node (BeeGFS Client Default: 12).
      connRDMABufNum: 36 # Allocates the number of buffers for transferring IO (BeeGFS Client Default: 8192).
      connRDMABufSize: 65536 # Size of each allocated RDMA buffer (BeeGFS Client Default: 70).
```

Limitations
-----------

* When using the non-DKMS client, to allow support for mounting the same BeeGFS file system multiple times or mounting multiple BeeGFS file systems, mounting BeeGFS using the default BeeGFS mount point in combination with the default BeeGFS client conf file is not supported (`/mnt/beegfs /etc/beegfs/beegfs-client.conf`). The role will automatically remove this default entry from beegfs-mounts.conf. 