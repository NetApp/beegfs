# Role Variables
The BeeGFS HA role has a set of variables to perform BeeGFS HA install, uninstall, performance tuning, and NTP settings.

There are different locations where the variables and their defaults are defined. Any variables can be overridden by
the user by specifying the variables in one of the user's inventory files.

<br>

## Table of Contents:
------------
1. [BeeGFS Main Defaults](#beegfs-main-variables-and-defaults)
2. [BeeGFS OS Specific Defaults](#beegfs-os-specific-variables-and-defaults)
3. [Order of Precedence for Variables](#order-of-precedence-for-variables)

<br>

<a name="beegfs-main-variables-and-defaults"></a>
## BeeGFS Main Variables and Defaults
------------
The variables in [BeeGFS HA Defaults](../defaults/main.yml) are for OS-agnostic settings. Review the file for the list
of variables and their details.

<br>

<a name="beegfs-os-specific-variables-and-defaults"></a>
## BeeGFS OS Specific Variables and Defaults
------------
The variables in `beegfs_ha_7_2/vars/*` are OS specifics. Review the applicable OS files for the list of variables and 
their details.

The OS files have inheritance setup so there will be multiple files that need to be viewed. As such, not only the 
OS distribution file (i.e., centos_8.yml) will be applied but also the distribution's OS family file (redhat.yml) will 
be used.

Note that the variables in the OS distribution files have the prefix `default_`. The prefix is specially used by the 
role, so when those variables are to be overridden in the user's inventory file(s), the prefix should be removed. 
For example, use `beegfs_ha_management_tool` instead of `default_beegfs_ha_management_tool`.

<br>

<a name="order-of-precedence-for-variables"></a>
## Order of Precedence for Variables
------------
Variables in the different files have order of precedence. Below is the order of precedence which the variables have
during a play (from highest to lowest):

1. Variables in user's inventory
2. vars/OS distribution version
3. vars/OS family
4. defaults/main
