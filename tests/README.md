Overview
--------

The files in this directory support CI testing of the BeeGFS collection using Jenkins. For the most part this CI testing is meant to validate the BeeGFS collection works as expected with all operating systems and protocols listed on the BeeGFS Ansible collection's support matrix. Also see https://docs.ansible.com/ansible/latest/reference_appendices/test_strategies.html.

Requirements
------------
- Then Jenkins build executor/slave node used for CI testing must be setup with passwordless SSH to all nodes used in the `inventory.yml` files.
- Any playbooks must use the `any_errors_fatal: true` option to just abort the whole play (and subsequently build) if anything goes wrong.
```yaml
- hosts: eseries_beegfs_hosts
  any_errors_fatal: true
  collections:
    - netapp_eseries.beegfs
  tasks:
    - name: Import nar_santricity_beegfs_7_1 role.
      import_role:
        name: nar_santricity_beegfs_7_1
```

#### Setting up new CI Nodes:

- All hosts used for CI testing should have vanilla installations of the desired operating systems, as the PXE images used by engineering can already have some configuration in place that needs to be accounted for in externally released automation.
- Network interfaces used for management/Ansible connections must be configured. 
- As we want to test with a non-root user, an "ansible" user with permissions to run commands using sudo without requiring a password needs to be configured:

```
    # On each SLES + RHEL CI server:
    useradd -m ansible
    passwd ansible # enter password
    visudo #make edits to give the ansible user the ability to use sudo without a password.
    usermod -aG wheel ansible
    
    # On Ubuntu server: 
    sudo adduser ansible #Then follow the prompts. Note "useradd -m" didn't seem to create all required configuration.
    sudo passwd ansible # enter password
    sudo visudo #make edits - had to add this line to allow no password to the sudo group as ubuntu doesn't use wheel. 
    ```
    ## Same thing without a password
    %wsudo ALL=(ALL) NOPASSWD: ALL
    ```
    sudo usermod -aG sudo ansible
```
- Lastly configure the Jenkins node to have passwordless SSH using the ansible user:

```
    # On solutions_automation_jenkins_01 for each CI server:
    ssh-copy-id ansible@<ci_server_ip>
    ssh ansible@<ci_server_ip>
    sudo whoami #verify output is root.  
```

Pipeline Summary
----------------
Whenever a pull request is created Jenkins will take that branch and clone it down on a Jenkins node with the label `solutions_automation`. To avoid concurrent attempts to test the collection on the CI config, currently there is a single Jenkins node labeled `solutions_automation`. The Jenkins node will use Docker to create an Ansible control node with the version of the BeeGFS collection contained in that branch as a Docker image. Jenkins will then verify the CI testbed is setup (optionally skipped), then use the containerized Ansible control node to deploy BeeGFS in a number of predetermined configurations. Each stage is covered with more detail below.

Note as the full pipeline takes awhile to run, we have intentionally configured Jenkins to only trigger a build whenever a pull request (PR) is submitted. This was accomplished by removing the "Discover branches" behavior from under the "Branch Sources" on the job's configuration in Jenkins. This behavior is included by default when creating a new Jenkins job based on most of our existing templates.

Pipeline Stages
----------------

#### Build Docker Image

This stage uses the `docker/` directory included in the repository to build an Ansible control node that will be used by subsequent stages to run Ansible. The Docker image will be tagged ` nar_eseries_ansible:${BRANCH_NAME}_${BUILD_ID}` and used by subsequent stages to run Ansible.

#### Execute/Verify Initial Setup Tasks

This stage uses the `inventory_ci_testbed.yml` and `playbook_ci_testbed.yml` files to drive initial setup tasks for the CI testbed. The playbook includes setting up InfiniBand/RDMA, establishing iSER connections to E-Series storage system(s) and configuring the E-Series storage. To reduce the normal runtime of the pipeline, most tasks are not performed unless the variable `ci_run_initial_setup_tasks` is set to `True` in `inventory_ci_testbed.yml`.

#### Deploy/Test/Remove CI Config X

These stages deploy BeeGFS in various configurations as described by the `inventory_config_X.yml` files in the tests/ directory. We will use the same `playbook_beegfs.yml` file with each of the inventory files to deploy BeeGFS and perform any testing common to all configs. As needed different `playbook_test_config_X.yml` playbooks will be used to perform any config specific testing. Regardless of the result of the deployment/testing we will always attempt to remove BeeGFS to cleanup the CI testbed.

#### Post / Always Tasks

Regardless of the result of the pipeline, we will always remove the Docker image created by the build stage (`nar_eseries_ansible:${BRANCH_NAME}_${BUILD_ID}`) from the Jenkins node and clean up the build directory.

Defining Configurations
-----------------------

Some config specific variables such as the BeeGFS Management IP may need to be overridden in each config's `inventory.yml` file. Where possible define common variables in the group_vars/host_vars files. 