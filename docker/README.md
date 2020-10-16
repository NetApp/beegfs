Overview
--------

The Dockerfile and supporting files in this directory are used to create a containerized Ansible 2.9+ control node with the SANtricity Ansible collection (pulled from an internal repo mirror or external GitHub repo), and the BeeGFS Ansible collection copied from the root of this repository. This allows users to quickly create a runtime environment with all requirements needed to run roles in the BeeGFS Ansible collection.

Prerequisites
-------------
- A server with Docker installed and password-less SSH setup to all servers being managed by Ansible.
    - Note the Dockerfile was tested with Docker version 19.03.5 running on RedHat 7.6 though alternate configurations are expected to work.
    
Getting Started
---------------

#### Building the nar_eseries_ansible Docker image:

1) If you haven't already, clone the BeeGFS Ansible collection's repository to the host you'll be using to run Docker, then checkout the desired branch (if needed).

- `git clone <url>`
- `git checkout <branch>`

2) Next you'll need to build and tag the Docker image. With the current/working directory set to the root of the BeeGFS collection's repository run:

- `docker build -f docker/Dockerfile . -t nar_eseries_ansible`
 
Important: 
- Being in the correct current/working directory is important because we need Docker to copy the entire BeeGFS Ansible collection into the Docker image, so the build context needs to be the repository's root.
- If you make changes to the BeeGFS collection you will need to re-run the `docker build` command for the changes to be included in the Docker image.
- After initially building the Docker image if you need to update the SANtricity Ansible collection or force a change between internal/external repos without updating the repomirror* files you'll need to run `docker build` with  `--no-cache=true`.
    - This is due to how Docker caching works when we use a script (`repo_check.sh`) to detect if we're in an air-gapped environment.

#### Running the nar_eseries_ansible Docker image:

Once you have the nar_eseries_ansible Docker image created, to run the containerized Ansible control node change the current/working directory to the one containing your inventory, playbook, and any other group_vars/host_vars files/subdirectories before running:

- `docker run --rm -it -v "/root/.ssh:/root/.ssh" -v "$(pwd):/ansible/playbooks" nar_eseries_ansible -i inventory.yml playbook.yml`
 
Additional Notes:
- If your inventory and/or playbook files aren't named `inventory.yml` and/or `playbook.yml`, modify the filenames used in the command as needed.
- If you're using a user other than root on the server running Docker, simply substitute the `/root/.ssh` path before the colon in `-v "/root/.ssh:/root/.ssh"` with the desired path. For example if the username is "admin" use `-v "/home/admin/.ssh:/root/.ssh"`. The latter half should always stay the same unless you're also planning to change the user in the container, which is outside the scope of this README.
- Instead of using `-v $(pwd):/ansible/playbooks` you can specify an absolute path for `$(pwd)`, allowing you to run the container without first changing the current/working directory. For example `-v /home/admin/website_01:/ansible/playbooks`.

FAQs
----
- I'm wanting to build/run the Docker container in an air-gapped environment (e.g. no internet access), how can I use the files in this directory?
    - Provided you have repository mirrors setup in the air-gapped environment for both Ubuntu and PIP, there are two files in the docker/ directory that can be updated to point at your internal repository mirror URLs. Update repomirror_sources.list with the URL(s) for Ubuntu, and repomirror_pip.conf with the URL to a pip mirror containing the following packages (minimum versions): 
        ```    
            /public_html/pip_mirror> tree
            .
            ├── ansible
            │   └── ansible-2.9.2.tar.gz
            ├── certifi
            │   └── certifi-2020.6.20.tar.gz
            ├── chardet
            │   └── chardet-3.0.4.tar.gz
            ├── docker
            │   └── docker-4.2.2.tar.gz
            ├── ipaddr
            │   └── ipaddr-2.2.0.tar.gz
            ├── jinja2
            │   ├── Jinja2-2.10.3.tar.gz
            │   └── Jinja2-2.11.2.tar.gz
            ├── markupsafe
            │   └── MarkupSafe-1.1.1.tar.gz
            ├── netaddr
            │   └── netaddr-0.7.19.tar.gz
            ├── pyyaml
            │   └── PyYAML-5.3b1.tar.gz
            ├── requests
            │   └── requests-2.24.0.tar.gz
            ├── urllib3
            │   └── urllib3-1.25.10.tar.gz
            └── websocket-client
                └── websocket-client-0.57.0.tar.gz
        ```

    - Lastly you will need an internal Git repository containing the NetApp E-Series SANtricity and Host collections available at https://github.com/netappeseries/santricity and https://github.com/netappeseries/host. When you build the Docker image specify the URL to this repo as a Docker build arg: `docker build -f docker/Dockerfile . -t nar_eseries_ansible --build-arg internal_santricity_collection_url=<URL> --build-arg internal_host_collection_url=<URL>`

Advanced Configuration
----------------------

#### SSH:

The above recommends "piggybacking" on the SSH configuration of the server running Docker by simply mapping in the .ssh configuration of an existing user. Alternate/manual configurations are certainly possible by adjusting the `-v "/root/.ssh:/root/.ssh"` portion of the `docker run` command. Just keep in mind whatever file you use for `.ssh/id_rsa.pub` must have a corresponding entry in the `.ssh/authorized_keys` file on all servers being managed by this Ansible control node. You also need to ensure whatever file you use for `.ssh/known_hosts` has an entry for each of the servers being managed by Ansible.