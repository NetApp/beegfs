# NTP Configuration
Time synchronization is required for BeeGFS to function properly. As a convenience, the BeeGFS HA role provides the 
ability to configure the ntpd service on all BeeGFS nodes.

There are two types of NTP services used by Linux (ntpd daemon or Chrony) but ntpd daemon is no longer available on the 
latest Linux systems. To supports older Linux versions, `beegfs_ha_chrony_enabled` and `beegfs_ha_ntp_enabled` variables
are provided to enable the appropriate services depending on the OS distribution. The two variables are mutually exclusive.

<br>

## Table of Contents
------------
- [NTP Configuration](#ntp-configuration)
  - [## Table of Contents](#-table-of-contents)
  - [## How to Configure Chrony Service](#-how-to-configure-chrony-service)
  - [## How to Configure ntpd Service](#-how-to-configure-ntpd-service)
  - [## General Notes](#-general-notes)

<br>

<a name="how-to-configure-chrony-service"></a>
## How to Configure Chrony Service
------------
The `beegfs_ha_chrony_enabled` variable is used to configure the Chrony service. The variable is set to true by default
for the operating systems that support it, otherwise it is set to false. See the OS specific defaults under the `vars` 
folder (i.e., centos_8.yml).

The template used to generate the /etc/chrony.keys file can be found at `roles/beegfs_ha_7_2/templates/common/chrony_conf.j2`.
Depending on the security policies of your organization, you way wish to adjust the default configuration by overriding 
the template (`chrony_conf.j2`). See [Override Default Templates](override_default_templates.md) for instructions.

If there is an existing NTP configuration that is in place, ensure `beegfs_ha_chrony_enabled` is set
to false in an inventory file (typically in `ha_cluster.yml`) to avoid conflicts.

<br>

<a name="how-to-configure-ntpd-service"></a>
## How to Configure ntpd Service
------------
The `beegfs_ha_ntp_enabled` variable is used to configure the ntpd service. The variable is set to true by default 
for the operating systems that support it, otherwise it is set to false. See the OS specific defaults under the `vars`
folder (i.e., centos_7.yml).

The template used to generate the /etc/ntp.conf file can be found at `roles/beegfs_ha_7_2/templates/common/ntp_conf.j2`.
Depending on the security policies of your organization, you way wish to adjust the default configuration by overriding
the template (`ntp_conf.j2`). See [Override Default Templates](override_default_templates.md) for instructions.

If there is an existing NTP configuration that is in place, ensure `beegfs_ha_ntp_enabled` is set
to false in an inventory file (typically in `ha_cluster.yml`) to avoid conflicts.

If the variable is set to `true`, any existing Chrony installations will be removed as they would conflict with 
ntpd daemon.

<br>

<a name="general-notes"></a>
## General Notes
------------
* Some Linux installations may be setup to have the DHCP client periodically update the /etc/ntp.conf file with NTP 
  servers from the DHCP server. This can be determined by seeing the text like below being appended to the bottom of 
  `/etc/ntp.conf`.
    ```
    server <IP_ADDR>  # added by /sbin/dhclient-script
    ```
    As a result, the NTP related Ansible tasks will be marked as changed whenever the role is re-ran even though no
    NTP configuration has changed.
* If you're wanting to manage the NTP configuration outside of Ansible and prevent the role from configuring NTP, then
  ensure the `beegfs_ha_ntp_enabled` and `beegfs_ha_chrony_enabled` variables are set to false.