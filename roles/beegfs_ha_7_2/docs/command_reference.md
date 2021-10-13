# Command Reference

## Table of Contents
1. PCS Commands(#pcs-commands)
2. CRM Commands(#crm-commands)
3. Useful BeeGFS Commands(#useful-beegfs-commands)
4. General Commands(#general-commands)

## PCS Commands
pcs status                                          # Get a simple view of the pacemaker setup

pcs config                                          # Get full view of the pacemaker setup

pcs constraint                                      # View pacemaker constraints

pcs resource [enable/disable] <RESOURCE_NAME>       # Enable/Disable a particular resource from running on any node in the cluster

pcs resource ban <RESOURCE_NAME> <NODE_NAME>        # Ban a resource from running on a node (Temporary constraint)

pcs resource clear <RESOURCE_NAME> <NODE_NAME>      # Delete pacemaker resource constraints

pcs resource delete <RESOURCE_NAME>                 # Delete pacemaker resource

pcs resource show <resource-id>                     # Show the details of the configured resource

pcs resource update <RESOURCE_NAME> <OPTION_NAME=NEW_OPTION_VALUE> # Update the details of the configured resource

pcs resource describe <RESOURCE_NAME>               # Show the details of any resource

pcs constraint list --full                          # List resource constraints with IDs

pcs resource move <RESOURCE_NAME> <node>            # Move a resource manually (Temporary constraint)

pcs resource clear <RESOURCE_ID> <node>             # Clear a pcs ban/move temporary constraint on a node

pcs resource cleanup <RESOURCE_NAME> --node nodeMM1 # Clear pacemaker failures

pcs resource create storage-service sysemd:beegfs-storage op monitor interval=13s meta-01-service resource-stickiness=1500    # Add stickiness to individaul resources

pcs resource update <RESOURCE_NAME> resource-stickiness=1500 # Update resource to have stickiness

pcs stonith                                         # List STONITH agents that are configured

pcs stonith delete <STONITH_NAME>                   # Delete STONITH agent

pcs stonith stonith_admin --cleanup --history=nodeMM1 # Clean fencing historical failures

pcs config                                          # List out the current configuration

pcs property set <PROPERTY_NAME>=<PROPERTY_NEW_VALUE> # Set pcs configuration peroperty

pcs -f <FILE_NAME> property set <PROPERTY_NAME>=<PROPERTY_NEW_VALUE> # Set the property for a particular configuration file

pcs cluster cib-push stonith_cfg                    # Push the configuration file to the main

pcs cluster cib <filename>                          # save CIB configuration file

pcs config checkpoint                               # List (all) available configuration checkpoints.

pcs config checkpoint view <CHECKPOINT_NUMBER>      # Show specified configuration checkpoint

pcs config checkpoint diff <CHECKPOINT_NUMBER> <CHECKPOINT_NUMBER2>   # Show the difference between two checkpoints

pcs config checkpoint restore <CHECKPOINT_NUMBER>   # Restore cluster configuration to specified checkpoint.

pcs cluster sync                                    # Sync cluster settings to all successfully authenticated nodes in the cluster

## CRM Commands

crm verify -L                                       # Verify the current configuration

crm verify -f <file>                                # Verify the conifguration file

## Useful BeeGFS commands
# TODO: add good beegfs commands here 

## General Commands

