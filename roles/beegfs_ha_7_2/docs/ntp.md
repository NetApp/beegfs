## Table of Contents
1. NTP (#ntp)

## NTP (`beegfs_ha_ntp_enabled: true`)
-----------------------------------
Time synchronization is required for BeeGFS to function properly. As a convenience to users the BeeGFS role provides functionality that can configure the ntpd service on all BeeGFS nodes by setting `beegfs_ha_ntp_enabled: True`. By default this variable is set to `False` to avoid conflicts with any existing NTP configuration that might be in place. If this variable is set to `True` please note any existing Chrony installations will be removed as they would conflict with ntpd.

The template used to generate the /etc/ntp.conf file can be found at `roles/beegfs_ha_7_2/templates/common/ntp_conf.j2`. Depending on the security policies of your organization, you way wish to adjust the default configuration.

* Some Linux installations may be setup to have the DHCP client periodically update /etc/ntp.conf with NTP servers from the DHCP server. You can tell this is happening if text like the following is appended to the bottom of /etc/ntp.conf:
    ```
    server <IP_ADDR>  # added by /sbin/dhclient-script
    ```
    As a result the NTP related Ansible tasks will be marked as changed whenever the role is reapplied. If you're wanting to manage the NTP configuration outside Ansible simply set `beegfs_ha_ntp_enabled: False` to prevent the role from configuring NTP.

