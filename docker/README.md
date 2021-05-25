Overview
--------

The Dockerfile and supporting files in this directory are used to create a containerized Ansible 2.10 control node with the NetApp E-Series Ansible collections (externally from Ansible Galaxy or from an internal repository), and, optionally, a local collection for development purposes. This allows users to quickly create a runtime environment with all requirements needed to utilize any NetApp E-Series Ansible content such the BeeGFS HA role.

Prerequisites
-------------
- A server with Docker installed and password-less SSH setup to all servers to be managed by Ansible.
    - Note the Dockerfile was tested with Docker version 20.10.2 running on Ubuntu 18.04 LTS though alternate configurations are expected to work.
    
Getting Started
---------------
#### Build eseries_ansible Docker image:

1) If you haven't already, clone the BeeGFS Ansible collection's repository to the host you'll use as an Ansible control node then checkout the desired branch (if needed).

- `git clone <url>`
- `git checkout <branch>`

2) Next you'll need to build and tag the Docker image. With the current/working directory set to the root of the BeeGFS collection's repository run:

- `docker build -f docker/Dockerfile . -t eseries_ansible`
 
Important: 
- When importing the local BeeGFS collection it is important to be in the repository's root directory since the entire collection will be copied into the Docker image.
- If you intend to make changes to the BeeGFS collection you will need to re-run the `docker build` command for the changes to be included in the Docker image.
    - Alternatively, you can add `-v <PATH TO BEEGFS REPO>:/root/.ansible/collections/ansible_collections/netapp_eseries/beegfs` to the run command which will create a bind mount within container that can be edited externally.
- If working with an air-gapped environment (e.g. no internet access) then you'll need to run `docker build` with `--no-cache=true` to update any of the remote collections.

#### Running the eseries_ansible Docker image:

Once the eseries_ansible Docker image is created, you can run the containerized Ansible control node by changing the current/working directory to the one containing your inventory, playbook, and any other group_vars/host_vars files/subdirectories before running:

- `docker run --rm -it -v "${HOME}/.ssh:/root/.ssh" -v "${PWD}:/ansible/playbooks" eseries_ansible -i inventory.yml playbook.yml`
 
Additional Notes:
- If your inventory and/or playbook files aren't named `inventory.yml` and/or `playbook.yml`, modify the filenames used in the command as needed.
- If you're using a user other than root on the server running Docker, simply substitute the `/root/.ssh` path before the colon in `-v "/root/.ssh:/root/.ssh"` with the desired path. For example if the username is "admin" use `-v "/home/admin/.ssh:/root/.ssh"`. The latter half should always stay the same unless you're also planning to change the user in the container, which is outside the scope of this README.
- All Ansible commands (ansible, ansible-inventory, ansible-galaxy, ansible-doc) are available by specifying the command --entrypoint otherwise the run command will execute the ansible-playbook.
    - (TIP) create aliases for your commands. For example, `alias ansible-doc="docker run -it --entrypoint <ANY_ANSIBLE_COMMAND> -v ${HOME}/.ssh:/root/.ssh -v ${PWD}:/ansible/playbooks eseries_ansible`
- Instead of using the shell variables, $HOME and $PWD, you can specify absolute paths which, for example, allows you to run playbooks from the container without changing the current/working directory. For example `-v "/home/admin/.ssh:/root/.ssh" -v /home/admin/website_01:/ansible/playbooks`.

FAQs
----
- I'm wanting to build/run the Docker container in an air-gapped environment (e.g. no internet access), what do I do?
    - Provided you have a repository for the air-gapped environment for APK and PIP, override the source urls for APK and PIP. So, when you build the Docker image specify the URLs as Docker --build-args: `docker build -f docker/Dockerfile . -t eseries_ansible --build-arg internal_apk_url=<URL> --build-arg internal_pip_url=<URL>`
    - You will also need internal GIT repositories for netapp_eseries collections specifying the --build-args for internal_santricity_collection_url, internal_host_collection_url, internal_beegfs_collection_url, and internal_collection_dependencies_url. Alternatively, just define internal_collection_dependencies_url with not only netapp_eseries collection dependencies but also the collections themselves. To collect all collection dependencies (ie tar.gz files) run the following commands on a system with access to https://galaxy.ansible.com/ with Ansible 2.10 installed, `ansible-galaxy collection download netapp_eseries.{santricity,host,beegfs}`. 
    - Lastly, when you build the Docker image specify the URL to these repositories as Docker --build-args: `--build-arg internal_santricity_collection_url=<URL> --build-arg internal_host_collection_url=<URL> --build-arg internal_beegfs_collection_url=<URL> --build-arg internal_collection_dependencies_url=<URL>` or, if you're using a single repository with the collections and the dependencies from Ansible-Galaxy: `--build-arg internal_collection_dependencies_url=<URL>`

Advanced Configuration
----------------------

#### SSH:

The above recommends "piggybacking" on the SSH configuration of the server running Docker by simply mapping in the .ssh configuration of an existing user. Alternate/manual configurations are certainly possible by adjusting the `-v "/root/.ssh:/root/.ssh"` portion of the `docker run` command. Just keep in mind whatever file you use for `.ssh/id_rsa.pub` must have a corresponding entry in the `.ssh/authorized_keys` file on all servers being managed by this Ansible control node. You also need to ensure whatever file you use for `.ssh/known_hosts` has an entry for each of the servers being managed by Ansible.