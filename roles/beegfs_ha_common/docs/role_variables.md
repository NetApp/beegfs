<a name="role-variables"></a>
# Role Variables

The BeeGFS HA role has a set of variables to perform BeeGFS HA install, uninstall, performance tuning, and NTP settings.

There are different locations where the variables and their defaults are defined. Any variables can be overridden by
the user by specifying the variables in one of the user's inventory files.

<a name="table-of-contents"></a>
## Table of Contents

- [Role Variables](#role-variables)
  - [Table of Contents](#table-of-contents)
  - [BeeGFS Main Variables and Defaults](#beegfs-main-variables-and-defaults)
  - [BeeGFS OS Specific Variables and Defaults](#beegfs-os-specific-variables-and-defaults)
  - [Order of Precedence for Variables](#order-of-precedence-for-variables)

<a name="beegfs-main-variables-and-defaults"></a>
## BeeGFS Main Variables and Defaults

The variables in [BeeGFS HA Defaults](../defaults/main.yml) are for OS-agnostic settings. Review the file for the list
of variables and their details.

<a name="beegfs-os-specific-variables-and-defaults"></a>
## BeeGFS OS Specific Variables and Defaults

The variables in `beegfs_ha_common/vars/*` are OS-specific variables. Review the applicable OS files for the list of variables and 
their details.

The OS files have inheritance setup so there will be multiple files that need to be viewed. As such, not only the 
OS distribution file (i.e., centos_8.yml) will be applied but also the distribution's OS family file (redhat.yml) will 
be used.

Note that the variables in the OS distribution files have the prefix `default_`. The prefix is specially used by the 
role, so when those variables are to be overridden in the user's inventory file(s), the prefix should be removed. 
For example, use `beegfs_ha_management_tool` instead of `default_beegfs_ha_management_tool`.

<a name="order-of-precedence-for-variables"></a>
## Order of Precedence for Variables

Variables in the different files have order of precedence. Below is the order of precedence which the variables have
during a play (from highest to lowest):

    1. Variables in user's inventory
    2. Vars/OS distribution version
    3. Vars/OS family
    4. Defaults/main
