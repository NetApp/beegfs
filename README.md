# NetApp E-Series BeeGFS Collection

NetApp has [partnered with ThinkParQ](https://www.netapp.com/blog/solution-support-for-beegfs-and-e-series/) (the
company behind [BeeGFS](https://blog.netapp.com/beegfs-for-beginners/)) to deliver high performing, highly scalable, yet
cost effective storage solutions. The `netapp_eseries.beegfs` collection contains roles and playbooks to automate
deploying BeeGFS on NetApp E-Series, as described in NetApp's
[deployment guides and technical reports](https://docs.netapp.com/us-en/beegfs/). This approach enables the delivery of
end-to-end storage solutions using Infrastructure as Code (IaC).

This collection supports both NetApp Verified Architectures (NVAs) and Custom Architectures. NVA designs are thoroughly
tested and provide customers with reference configurations and sizing guidance to minimize deployment risk and
accelerate time to market. NetApp also supports custom BeeGFS architectures running on NetApp hardware, giving customers
and partners flexibility designing file systems to meet a wide range of requirements. Both approaches leverage Ansible
for deployment, providing an appliance-like approach managing BeeGFS at any scale across a flexible range of hardware.
Additional information about the collection architectures can be found in:
- [NetApp Verified Architectures (NVA)](https://docs.netapp.com/us-en/beegfs/beegfs-solution-overview.html)
- [Custom Architectures](https://docs.netapp.com/us-en/beegfs/custom-architectures-overview.html)

The roles in this collection make it easy to start automating BeeGFS and E-Series, providing copy-and-update example
inventory files and playbooks. The roles are designed and developed for specific BeeGFS major releases in either a high
availability (HA) or non-HA mode of operation.


## Compatibility

This collection version has been tested with Ansible core **2.16**.

### Tested BeeGFS Configuration

| BeeGFS Service | BeeGFS Version | Operating System |
| -------------- | -------------- | ---------------- |
| beegfs-mgmtd   | 7.4.3          | RedHat 9.3       |
| beegfs-meta    | 7.4.3          | RedHat 9.3       |
| beegfs-storage | 7.4.3          | RedHat 9.3       |
| beegfs-helperd | 7.4.3          | Ubuntu 22.04 LTS |
| beegfs-client  | 7.4.3          | Ubuntu 22.04 LTS |

### Tested Block Node Configuration

| Platform     | SANtricity OS version | Protocol |
| -------------| --------------------- | --------- |
| EF600        | 11.80 or newer        | NVMe/IB   |

Additional information about tested configurations can be found in the [test matrix](docs/beegfs_ha/test_matrix.md).

## Requirements

- The Ansible control node must have the following installed:
  - Python 3.9 or later
  - Python3 pip
  - NetApp E-Series Ansible Collections:
    - [netapp_eseries.santricity](https://galaxy.ansible.com/ui/repo/published/netapp_eseries/santricity/) 1.4.0 or
    later.
    - [netapp_eseries.host](https://galaxy.ansible.com/ui/repo/published/netapp_eseries/host/) 1.3.2 or later.
  - The following Python packages must be installed via pip:
    - ipaddr
    - netaddr
    - cryptography
- Passwordless SSH must be configured from the Ansible control node to all BeeGFS HA nodes and client nodes. Do not set
up passwordless SSH to the block nodes. This is neither supported nor required. To set up passwordless SSH, follow these
steps:
    1. On the Ansible control node, if needed, generate a pair of public keys using `ssh-keygen`
    2. Set up passwordless SSH to each of the file/client nodes using `ssh-copy-id <ip_or_hostname>`.
- The BeeGFS HA nodes must have the following configured:
  - HA repositories containing the necessary packages (pacemaker, corosync, fence-agents-all, resource-agents, pcs) are
  enabled via package manager.
    - Enable command example: `subscription-manager repo-override repo=rhel-9-for-x86_64-highavailability-rpms --add=enabled:1`

## Getting Started with this Collection

Install the collection to your Ansible control node using the `ansible-galaxy` cli:

```
ansible-galaxy collection install netapp_eseries.beegfs
```

The `netapp_eseries.beegfs` collection will automatically install the following collection dependencies:
- `netapp_eseries.santricity`
- `netapp_eseries.host`
  - `ansible.posix`
  - `ansible.utils`
  - `ansible.windows`
  - `community.general`

After installing the collection, build the inventory and playbook files according to your BeeGFS cluster requirements
using the instructions in the [getting started README](getting_started/README.md) document.

## Submitting Questions and Feedback

For questions, feature requests, or to report an issue, submit them at https://github.com/netappeseries/beegfs/issues.

## License

BSD-3-Clause

## Maintainer Information

- Christian Whiteside (@mcwhiteside)
- Vu Tran (@VuTran007)
