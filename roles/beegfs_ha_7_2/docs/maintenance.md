# Maintenance
There may be a need to perform maintenance actions on the BeeGFS cluster. This page is only describing
some common maintenance operations as a guide for users.

<br>

## Table of Content
------------
1. [Maintenance a BeeGFS Node/Cluster](#maintenance-a-beegfs-nodecluster)
2. [Handle an Unexpected Failed BeeGFS Node](#handle-an-unexpected-failed-beegfs-node)
3. [Replacing a Node in the Cluster](#replacing-a-node-in-the-cluster)
4. [Adding a Building Block to the Cluster](#adding-a-building-block-to-the-cluster)
5. [Retiring a Building Block from the Cluster](#retiring-a-building-block-from-the-cluster)

<br>

<a name="maintenance-a-beegfs-nodecluster"></a>
## Maintenance a BeeGFS Node/Cluster
------------
In the case where a BeeGFS node needs to be serviced such as replacing a HBA card, the resources running on the node
should to be moved to other node(s) in the cluster gracefully for high availability.

To do this, place the node in standby mode using:
    
    pcs node standby <node_name>

In the case where then entire BeeGFS cluster needs to be serviced, all nodes in the cluster can be gracefully put into 
service mode.

    pcs node standby --all

Once services to the nodes have completed and they ready to be added back to the BeeGFS HA cluster, run the
installation playbook using `beegfs_ha_move_all_to_preferred` tag to restore the nodes.

    ansible-playbook -i <inventory>.yml --beegfs_ha_move_all_to_preferred <playbook>.yml

<br>

<a name="handle-an-unexpected-failed-beegfs-node"></a>
## Handle an Unexpected Failed BeeGFS Node
------------
In the case where a BeeGFS node failed unexpectedly, the node should be fenced automatically if a fencing agent is 
configured. Which all resources owned by the node should already be moved to other nodes for high availability.

To restore the failed node, first bring the node online if it was powered off. This action will not automatically add
the node back into the cluster.

Diagnose, troubleshoot the cause of the failure, and resolve the failure.

Once the node is returned to its healthy state with no failures and communications between the nodes are optimal, 
run the installation playbook using `beegfs_ha_move_all_to_preferred` tag to restore the node.

    ansible-playbook -i <inventory>.yml --beegfs_ha_move_all_to_preferred <playbook>.yml

<br>

<a name="replacing-a-node-in-the-cluster"></a>
## Replacing a Node in the Cluster
------------
To replace a node in the cluster, perform the following steps:

1. Create a new inventory file (under host_vars/) for the new node being added.

   This file would typically be created as `host_vars/<hostname>.yml`:
   ```
   ansible_host: “<MANAGEMENT_IP>”
   eseries_nvme_ib_interfaces:
     - name: i1a
       address: 192.168.1.10/24
       configure: true
     - name: i2a
       address: 192.168.3.10/24
       configure: true
     - name: i3a
       address: 192.168.5.10/24
       configure: true
     - name: i4a
       address: 192.168.7.10/24
       configure: true
   ```
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

<br>

<a name="adding-a-building-block-to-the-cluster"></a>
## Adding a Building Block to the Cluster
------------

When adding a building block to your cluster, you will need to create the `host_vars` files for each of the new hosts and 
eseries arrays. The names of these hosts need to be added to the inventory, along with the new resources that are to be
created. The corresponding `group_vars` files will need to be created for each new resource. 

After creating the correct files, all that is needed is to rerun the automation using the command 
`ansible-playbook -i <inventory>.yml <playbook>.yml`.

<br>