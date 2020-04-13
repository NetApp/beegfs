# Changelog
Notable changes to the BeeGFS collection will be documented in this file.

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