# Command Reference
This page provides a list of commonly used pcs commands for the BeeGFS HA role.

The list is non-exhaustive so use the Linux man pages to see all the options of each tool.

<br>

## Table of Contents
------------
- [Command Reference](#command-reference)
  - [## Table of Contents](#-table-of-contents)
  - [## Cluster Status](#-cluster-status)
  - [## Resource Migration](#-resource-migration)
  - [## Resource Cleanup](#-resource-cleanup)
  - [Cluster Configuration Backup](#cluster-configuration-backup)

<br>

<a name="cluster-status"></a>
## Cluster Status
-----------
    pcs status      # Get a simple view of the pacemaker setup
    pcs config      # Get full view of the pacemaker setup
    pcs constraint  # View pacemaker constraints

<br>

<a name="resource-migration"></a>
## Resource Migration
-----------
    pcs resource relocate run                       # Relocate all resources to there preferred nodes.
    pcs resource <enable|disable> <RESOURCE_NAME>   # Enable/disable resource on a node.
    pcs resource ban <RESOURCE_NAME> <NODE_NAME>    # Ban a resource from running on a node (creates temporary constraint)
    pcs resource move <RESOURCE_NAME> <NODE_NAME>   # Move a resource manually (creates temporary constraints)
    pcs resource clear <RESOURCE_NAME> <NODE_NAME>  # Delete pacemaker resource temporary constraints created by ban or move.

<br>

<a name="resource-cleanup"></a>
## Resource Cleanup
-----------
    pcs resource cleanup <RESOURCE_NAME>                   # Cleanup resource on all nodes.
    pcs resource cleanup node=<NODE_NAME>                  # Cleanup all resources on a node.
    pcs resource cleanup <RESOURCE_NAME> node=<NODE_NAME>  # Cleanup a resource on a node.
    pcs stonith history cleanup <NODE_NAME>                # Clean fencing historical failures on a node

<br>

<a name="cluster-configuration-backup"></a>
## Cluster Configuration Backup
    pcs config backup <FILE_NAME>                     # Creates a backup of the current pacemaker cluster configuration.
    pcs config checkpoint                             # List all available configuration checkpoints.
    pcs config checkpoint view <NUMBER>               # Show specified configuration checkpoint
    pcs config checkpoint diff <NUMBER_1> <NUMBER_2>  # Show the difference between two checkpoints
    pcs config checkpoint restore <NUMBER>            # Restore cluster configuration to specified checkpoint.
