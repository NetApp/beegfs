#!/bin/bash
set -euo pipefail
echo "[repo_check.sh] Attempting to run apt-get update and apt-get install git to check if we're in an air-gapped environment."
if apt-get update && apt-get install -y git;
then
    echo "[repo_check.sh] Successfully installed git, leaving default Ubuntu repositories in place. Cloning external SANtricity and Host Ansible Collections."
    git clone https://github.com/netapp-eseries/santricity.git /root/.ansible/collections/ansible_collections/netapp_eseries/santricity
    git clone https://github.com/netapp-eseries/host.git /root/.ansible/collections/ansible_collections/netapp_eseries/host
    exit 0
fi

echo "[repo_check.sh] Unable to reach default Ubuntu repositories, updating source.list and pip.conf with repomirrors."
cp repomirror_sources.list /etc/apt/sources.list
mkdir ~/.pip/ && cp repomirror_pip.conf ~/.pip/pip.conf

echo "[repo_check.sh] Attempting to run apt-get update and apt-get install git to confirm connectivity to repomirrors."
if apt-get update && apt-get install -y git;
then
    echo "[repo_check.sh] Successfully installed git, confirmed repomirror connectivity. Cloning internal SANtricity Ansible Collection repository."
    if [ "$env_internal_santricity_collection_url" != "0" ];
    then
        if [ "$env_internal_host_collection_url" != "0" ];
        then
            echo "[repo_check.sh] Variable internal_host_collection_url was set, attempting to include the host collection."
            mkdir /root/.ansible/collections/ansible_collections/netapp_eseries/host
            env GIT_SSL_NO_VERIFY=True git clone $env_internal_host_collection_url /root/.ansible/collections/ansible_collections/netapp_eseries/host
        fi
        git clone $env_internal_santricity_collection_url /root/.ansible/collections/ansible_collections/netapp_eseries/santricity
        exit 0
    else
        echo "[repo_check.sh] Required variable 'internal_santricity_collection_url' is not set. Please specify a URL for this variable in the docker build command using --build-arg."
        exit 1
    fi
else
    echo "[repo_check.sh] Unable to install git from repomirrors. Are the URLs specified in repomirror_sources.list correct for your environment?"
    exit 1
fi