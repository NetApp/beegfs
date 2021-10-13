# Mainenance

## Table of Content
1. [Failover](#failover)
2. [Failback](#failback)
3. [Following a Planned Outage](#following-a-planned-outage)
4. [Replacing a Node in the Cluster](#replacing-a-node-in-the-cluster)
5. [Adding a Building Block to the cluster](#adding-a-building-block-to-the-cluster)
6. [Retiring a Building Block from the Cluster](#retiring-a-building-block-from-the-cluster)


## Failover
------------
There may be a need to manually failover a specific node, this could be due to server maintenance. Here are a list of commands and examples of how to failover a particular service using pcs.
    `pcs resource move <resource_group> < destination_node>`

Run `pcs status` to verify the resource group failed over to the desired node.

## Failback
------------
Provided customers followed our deployment recommendations when setting up the cluster, the default `resource-stickiness` is set to a high value ensuring resources do not automatically failback when an offline node is booted. This ensures we can boot the failed node and verify it's health before failing back resources to their original node.

  - Before booting the offline node run the following commands and confirm the `resource-stickiness` is higher than the resource scores.
    ```
    [root@nodeMM1 ~]# pcs resource defaults
    resource-stickiness: 15000
  
    [root@nodeMM1 ~]# pcs constraint
    Location Constraints:
    Resource: meta1-group
      Enabled on: nodeMM1 (score:200)
      Enabled on: nodeMM2 (score:0)
    Resource: meta2-group
      Enabled on: nodeMM1 (score:0)
      Enabled on: nodeMM2 (score:200)
    ```
    - If needed the default resource stickiness can be configured with `pcs resource defaults resource-stickiness=15000`
  - Boot the offline node and verify it is healthy before continuing.
  - Once the node is healthy run one of the following commands to relocate services:
    - Relocate all resources with `pcs resource relocate run`.
    - Relocate a specific resource with `pcs resource relocate <resource-group>`
  - Run `pcs status` and verify all resources have been relocated to the appropriate nodes

## Following a Planned Outage
To restore the cluster to an optimal state the ansible playbook can be reran to set the config to a known good state.

If you used `pcs resource move` a temporary location constraint with a score of INFINITY would have been added to force the resource group to move to the desired node, this can be verified with `pcs constraint`:

    [root@nodeMM1 ~]# pcs constraint
    Location Constraints:
    Resource: meta1-group
        Enabled on: nodeMM1 (score:200)
        Enabled on: nodeMM2 (score:0)
    Resource: meta2-group
        Enabled on: nodeMM1 (score:0)
        Enabled on: nodeMM2 (score:200)
        Enabled on: nodeMM1 (score:INFINITY) (role: Started)

The temporary constraint can be cleared by running `pcs resource clear <resource-group>`

    pcs resource clear meta2-group
    [root@nodeMM1 ~]# pcs constraint
    Location Constraints:
    Resource: meta1-group
        Enabled on: nodeMM1 (score:200)
        Enabled on: nodeMM2 (score:0)
    Resource: meta2-group
        Enabled on: nodeMM1 (score:0)
        Enabled on: nodeMM2 (score:200)

Provided default resource-stickiness was configured per our deployment recommendations, the resource group(s) will not automatically be relocated back to the preferred nodes. This can be done with one of the following commands (see the unplanned section for examples):
    Relocate all resource groups with `pcs resource relocate run`
    Relocate a specific resource group with `pcs resource relocate run <resource-group>`

## Replacing a Node in the Cluster
Start by creating a new Host inventory File for the new node being added.

This file would typically be created as `host_vars/<hostname>.yml`:

    ansible_host: 192.168.1.10
    ansible_ssh_user: admin
    ansible_become_password: adminpass

    eseries_iscsi_iqn: iqn.1994-05.com.redhat:node_mm1
    eseries_iscsi_interfaces:
    - name: eth1
        address: 192.168.2.226/24
    - name: eth2
        address: 192.168.3.226/24
  
In the ansible inventory replace the old node with the new node name.
Finally Rerun the ansible playbook with the updated ansible inventory.

## Adding a Building Block to the Cluster
Start by Creating a new Host Inventory File for each new node in the building block
### Example
  This file would typically be created as `host_vars/<hostname>.yml`:

    ansible_host: 192.168.1.10
    ansible_ssh_user: admin
    ansible_become_password: adminpass

    eseries_iscsi_iqn: iqn.1994-05.com.redhat:node_mm1
    eseries_iscsi_interfaces:
        - name: eth1
          address: 192.168.2.226/24
        - name: eth2
          address: 192.168.3.226/24

Add the resource groups that will be running on the new Building block like show below to the Inventory file. NOTE: The vars can go in a separate group vars file, typically this would be under `group_vars/<resource_name>.yml`.
### Example

    stor_0x:    # Storage resource names must end with and underscore followed by the nodeNumID that is designated for the service resource.
              hosts:
                node_ss1:
                node_ss2:
              vars:
                port: 8012
                floating_ips:
                  - "eth1:192.168.2.236/24"
                  - "eth2:192.168.3.237/24"
                beegfs_service: storage
                beegfs_targets:
                  eseries_storage_system_01:
                    eseries_storage_pool_configuration:
                      - raid_level: raid6
                        criteria_drive_count: 10
                        volumes:
                          - size: 2048
                          - size: 2048
                          - size: 2048
                          - size: 2048
                      - raid_level: raid6
                        criteria_drive_count: 10
                        volumes:
                          - size: 2048
                          - size: 2048
                          - size: 2048
                          - size: 2048

Once you have the building block added the only thing left to do is rerun the ansible playbook with your updated inventory.

## Retiring a Building Block from the Cluster
  - Removing a building block is similar to adding one, just in reverse.
  - In your inventory file, remove the storage resources associated with the building block that is getting removed.
  - Rerun your playbook with the 




  NOT COMPLETE YET

