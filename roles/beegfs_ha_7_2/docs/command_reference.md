<a name="command-reference"></a>
# Command Reference

The list is non-exhaustive so use the Linux man pages or command help to see all the options of each tool.

<a name="table-of-contents"></a>
## Table of Contents

- [Command Reference](#command-reference)
  - [Table of Contents](#table-of-contents)
  - [pcs command](#pcs-command)
    - [Cluster Status](#cluster-status)
    - [Cluster Control](#cluster-control)
    - [Resource Migration](#resource-migration)
    - [Resource Cleanup](#resource-cleanup)
    - [Cluster Configuration Backup](#cluster-configuration-backup)

<a name="pcs-command"></a>
## pcs command

This section provides a list of commonly used pcs commands for the BeeGFS HA role.

For more details about any pcs sub-commands just append --help. For example:

    pcs cluster start --help

    Usage: pcs cluster start...
        start [--all | <node>... ] [--wait[=<n>]] [--request-timeout=<seconds>]
            Start a cluster on specified node(s). If no nodes are specified then
            start a cluster on the local node. If --all is specified then start
            a cluster on all nodes. If the cluster has many nodes then the start
            request may time out. In that case you should consider setting
            --request-timeout to a suitable value. If --wait is specified, pcs
            waits up to 'n' seconds for the cluster to get ready to provide
            services after the cluster has successfully started.

<a name="cluster-status"></a>
### Cluster Status

    pcs status      # Get a simple view of the pacemaker setup
    pcs config      # Get full view of the pacemaker setup
    pcs constraint  # View pacemaker constraints

<a name="cluster-control"></a>
### Cluster Control

    pcs cluster start <NODE_NAME>...   # Start the cluster on the specified node(s). Use --all to start all nodes.
    pcs cluster stop <NODE_NAME>...    # Stop the cluster on the specified node(s). Use --all to stop all nodes.

<a name="resource-migration"></a>
### Resource Migration

    pcs resource relocate run                       # Relocate all resources to there preferred nodes.
    pcs resource <enable|disable> <RESOURCE_NAME>   # Enable/disable resource on a node.
    pcs resource ban <RESOURCE_NAME> <NODE_NAME>    # Ban a resource from running on a node (creates temporary constraint)
    pcs resource move <RESOURCE_NAME> <NODE_NAME>   # Move a resource manually (creates temporary constraints)
    pcs resource clear <RESOURCE_NAME> <NODE_NAME>  # Delete pacemaker resource temporary constraints created by ban or move.

<a name="resource-cleanup"></a>
### Resource Cleanup

    pcs resource cleanup <RESOURCE_NAME>                   # Cleanup resource on all nodes.
    pcs resource cleanup node=<NODE_NAME>                  # Cleanup all resources on a node.
    pcs resource cleanup <RESOURCE_NAME> node=<NODE_NAME>  # Cleanup a resource on a node.
    pcs stonith history cleanup <NODE_NAME>                # Clean fencing historical failures on a node

<a name="cluster-configuration-backup"></a>
### Cluster Configuration Backup

    pcs config backup <FILE_NAME>                     # Creates a backup of the current pacemaker cluster configuration.
    pcs config checkpoint                             # List all available configuration checkpoints.
    pcs config checkpoint view <NUMBER>               # Show specified configuration checkpoint
    pcs config checkpoint diff <NUMBER_1> <NUMBER_2>  # Show the difference between two checkpoints
    pcs config checkpoint restore <NUMBER>            # Restore cluster configuration to specified checkpoint.
