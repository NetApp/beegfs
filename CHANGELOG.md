# Changelog
Notable changes to the BeeGFS collection will be documented in this file.

[2.0.0] - 2020-08-16
--------------------
### Added
- The focus of this release was adding a beegfs_ha_7_1 role to deploy [NetApp's High Availability solution for BeeGFS](https://blog.netapp.com/high-availability-beegfs) to RedHat and CentOS hosts along with supporting documentation.
- An interactive example that expedites getting started with the beegfs_ha_7_1 role by generating a full skeleton inventory through an interactive playbook (see: `examples/beegfs_ha_7_1/README.md`).   

### Changed
- Building the Docker image now includes the new E-Series Host collection and additional dependencies. Added a .dockerignore file to help reduce final image size.
- Documentation for each role is now being maintained under the respective roles. The README in the base of the project provides links to the documentation for all currently supported roles.   
- Role specific changes: nar_santricity_beegfs_7_1
  - Added a note to the README under Known Issues/Limitations with observed behavior when regularly deploying/wiping/redeploying BeeGFS using the yum package manager.
  - Changed how the uninstall mode detects what services need to be removed from each node improving the ability to handle certain edge cases. Related refactoring to how the tasks in the uninstall mode are organized.
  - This role can now discover/use volumes when the user_friendly_names multipath option is enabled.

### Fixed
- Role specific fixes: nar_santricity_beegfs_7_1
  - Added additional rescans required to detect newly mapped E-Series volumes attached through iSCSI/iSER without a reboot.  
  - Updated the role to work with both new and legacy versions of the SANtricity collection.
  
[1.1.0] - 2020-04-10
--------------------

### Added
- Support for using E-Series volumes presented over NVMe-oF protocols as BeeGFS storage/metadata targets.
- Support for defining multiple BeeGFS file systems in the same inventory file. 
- Post-deployment check to verify the BeeGFS deployment(s) described in the inventory match the output of `beegfs-check-servers`.

### Changed
- Updates to the provided examples.
- Required version of the netapp_eseries.santricity collection in galaxy.yml.

[1.0.0] - 2020-03-19
--------------------
- Initial release.