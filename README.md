NetApp E-Series BeeGFS Collection
=================================
NetApp has [partnered with ThinkParQ](https://blog.netapp.com/solution-support-for-beegfs-and-e-series/) (the company behind [BeeGFS](https://blog.netapp.com/beegfs-for-beginners/)) to deliver high performing, highly scalable, yet cost effective storage solutions. The Ansible roles in this collection automate deploying BeeGFS on E-Series as described in NetApp's deployment guides and technical reports. This enables delivery of end-to-end storage solutions using Infrastructure as Code (IaC). 

The roles in this collection make it easy to get started [automating BeeGFS and E-Series](https://blog.netapp.com/deploying-beegfs-eseries), providing copy-and-update example inventory files and playbooks. Roles are designed and developed for specific BeeGFS major releases and either a high availability (HA) or non-HA mode of operation. If support is added for a new version of BeeGFS it will be implemented as a new role to avoid backwards compatibility issues.

Getting Started
---------------
Each role is used independently to deploy the desired version of BeeGFS in the desired mode of operation. The following roles are currently available:

* [BeeGFS Client](https://github.com/netappeseries/beegfs/blob/master/roles/beegfs_client/README.md): Installs the BeeGFS Client and optionally mounts one or more BeeGFS file systems, or the same BeeGFS file system multiple times. The role can also unmount one or more BeeGFS file systems if requested.

* [BeeGFS 7.3 with High-Availability (HA)](https://github.com/netappeseries/beegfs/blob/master/roles/beegfs_ha_7_3/README.md): End-to-end deployment of the NetApp E-Series BeeGFS 7.3 HA solution including provisioning and mapping E-Series storage, creating a Linux HA cluster using Pacemaker and Corosync, deploying BeeGFS into the cluster, and configuring clients.

* [BeeGFS 7.2 with High-Availability (HA) (Deprecated)](https://github.com/netappeseries/beegfs/blob/master/roles/beegfs_ha_7_2/README.md): End-to-end deployment of the NetApp E-Series BeeGFS 7.2 HA solution including provisioning and mapping E-Series storage, creating a Linux HA cluster using Pacemaker and Corosync, deploying BeeGFS into the cluster, and configuring clients. This role has been deprecated and will be removed from future releases.

Submitting Questions and Feedback
---------------------------------
If you have any questions, feature requests, or would like to report an issue please submit them at https://github.com/netappeseries/beegfs/issues.

License
-------
BSD-3-Clause

Maintainer Information
------------------
- Nathan Swartz (@ndswartz)
- Joe McCormick (@iamjoemccormick)
- Tracy Cummins (@tracycummins)