<a name="maintenance"></a>
# Maintenance

There may be a need to perform maintenance actions on the BeeGFS cluster. This page is only describing
some common maintenance operations as a guide for users.

<a name="table-of-contents"></a>
## Table of Contents

- [Maintenance](#maintenance)
  - [Table of Contents](#table-of-contents)
  - [Maintenance a BeeGFS Node/Cluster](#maintenance-a-beegfs-nodecluster)
  - [Handle an Unexpected Failed BeeGFS Node](#handle-an-unexpected-failed-beegfs-node)
  - [Replacing a Node in the Cluster](#replacing-a-node-in-the-cluster)
  - [Adding a Building Block to the Cluster](#adding-a-building-block-to-the-cluster)

<a name="maintenance-a-beegfs-nodecluster"></a>
## Maintenance a BeeGFS Node/Cluster

In the case where a BeeGFS node needs to be serviced such as replacing a HBA card, the resources running on the node
should to be moved to other node(s) in the cluster gracefully for high availability.

To do this, place the node in standby mode using:
    
    pcs node standby <NODE_NAME>


After service to the node has completed and it is ready to be added back to the BeeGFS HA cluster, run the
following commands to restore the resources back to their preferred node.

    pcs node unstandby <NODE_NAME>  # Removes node from standby.
    pcs resource relocate run       # Relocates all resource to their preferred nodes.

<a name="handle-an-unexpected-failed-beegfs-node"></a>
## Handle an Unexpected Failed BeeGFS Node

In the case where a BeeGFS node failed unexpectedly, the node should be fenced automatically. All resources owned by
the node will be moved to another for high availability.

To restore the failed node, first power on the fenced node. This action will not automatically add the node back into the cluster.

Before proceeding be sure the cause of the failure has been resolved.

    pcs cluster start <NODE_NAME>             # Bring the cluster node online
    pcs resource cleanup node=<NODE_NAME>     # Cleanup an resource failures associated with the node.
    pcs stonith history cleanup <NODE_NAME>   # Cleanup the node's fencing history.
    pcs resource relocate run                 # Relocate all failed over resources back to the node.

<a name="replacing-a-node-in-the-cluster"></a>
## Replacing a Node in the Cluster

To replace a node in the cluster, perform the following steps:

1. Create a new node inventory file (host_vars/<NEW_NODE>.yml) for the new node being added. See [example node inventory file](getting_started.md#example-beegfs-ha-node-inventory-file) for details.

2. In the ansible inventory file (i.e., inventory.yml), replace the old node's name with the new node name.

   Example:
   ```
   all:
      ...
      children:
        ha_cluster:
          children:
            mgmt:
              hosts:
                node_h1_new:   # Replaced "node_h1" with "node_h1_new" 
                node_h2:
   ```

3. Rerun the installation ansible playbook.
   ```
   ansible-playbook -i <inventory>.yml <playbook>.yml
   ```

<a name="adding-a-building-block-to-the-cluster"></a>
## Adding a Building Block to the Cluster

When adding a building block to your cluster, you will need to create the `host_vars` files for each of the new hosts and 
eseries arrays. The names of these hosts need to be added to the inventory, along with the new resources that are to be
created. The corresponding `group_vars` files will need to be created for each new resource. See [getting_started](getting_started.md) for details.

After creating the correct files, all that is needed is to rerun the automation using the command 
`ansible-playbook -i <inventory>.yml <playbook>.yml`.
