NetApp E-Series BeeGFS Collection
=================================
    NetApp has partnered with ThinkParQ's BeeGFS file system. Together, NetApp E-Series and ThinkParQ presents a high performance parallel files system solution that is flexible and will scale with you as your needs grow. We know how important automation is to our HPC customers, so we have developed simple and easy to use Ansible collection for deploying the BeeGFS file systems which is based on the available NetApp E-Series BeeGFS technical reports. Each role provides a copy-and-update example inventory files and playbook to get start.

    Roles:
        - beegfs_ha_7_1: Complete end-to-end deployment of NetApp E-Series BeeGFS 7.1 HA (high-availability) solution which provisions and maps E-Series storage and deploys BeeGFS 7.1 with HA on your BeeGFS cluster nodes and configures its clients.
        - nar_santricity_beegfs_7_1: Deploys BeeGFS 7.1 on your BeeGFS cluster nodes and configures its clients.

Getting Started
---------------
Visit the following links for details on the individual NetApp E-Series BeeGFS roles.
    [For BeeGFS 7.1 with HA (High-Availability)](https://github.com/netappeseries/beegfs/blob/master/roles/beegfs_ha_7_1/README.md)
    [For BeeGFS 7.1](https://github.com/netappeseries/beegfs/blob/master/roles/nar_santricity_beegfs_7_1/README.md)

Submitting Questions and Feedback
---------------------------------
If you have any questions, feature requests, or would like to report an issue please submit them at https://github.com/netappeseries/beegfs/issues.

License
-------
BSD-3-Clause

Author Information
------------------
- Christopher Seirer (@CSeirer)
- Janey Le (@janeyle)
- Joe McCormick (@iamjoemccormick)
- Nathan Swartz (@ndswartz)
