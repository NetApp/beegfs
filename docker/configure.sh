#!/bin/sh

echo "[configure.sh] Install required packages."
if apk update; then
  apk add $env_required_apk_packages
  pip install $env_required_pip_packages

  # Install local collection
  if [ $env_use_local_collection = "true" ]; then
      ansible-galaxy collection install git+file:///tmp/local_collection
  fi

  # Install netapp_eseries collection
  ansible-galaxy collection install $env_external_santricity_collection_url
  ansible-galaxy collection install $env_external_host_collection_url
  ansible-galaxy collection install $env_external_beegfs_collection_url

else
  echo "[configure.sh] External package sources are not available! Attempting to use internal sources."

  # Configure APK sources and install packages
  echo "${env_internal_apk_url}/main" > /etc/apk/repositories
  echo "${env_internal_apk_url}/community" >> /etc/apk/repositories
  apk update
  apk add $env_required_apk_packages

  # Configure PIP source and install packages
  pip_url=${env_internal_pip_url#*://}
  trusted_host=${pip_url%%/*}
  pip config set global.index-url $env_internal_pip_url
  pip config set global.trusted-host $trusted_host
  pip install $env_required_pip_packages

  # Install local collection
  if [ $env_use_local_collection = "true" ]; then
      ansible-galaxy collection install git+file:///tmp/local_collection --no-deps
  fi

  # Install dependent collections
  if env GIT_SSL_NO_VERIFY=false git clone $env_internal_collection_dependencies_url /tmp/dependencies; then
    for collection in /tmp/dependencies/*.tar.gz; do
      ansible-galaxy collection install $collection --no-deps
    done
  fi

  # Install netapp_eseries collection
  if env GIT_SSL_NO_VERIFY=false git clone $env_internal_santricity_collection_url /tmp/santricity; then
    ansible-galaxy collection install git+file:///tmp/santricity --no-deps
  fi
  if env GIT_SSL_NO_VERIFY=false git clone $env_internal_host_collection_url /tmp/host; then
    ansible-galaxy collection install git+file:///tmp/host --no-deps
  fi
  if env GIT_SSL_NO_VERIFY=false git clone $env_internal_beegfs_collection_url /tmp/beegfs; then
    ansible-galaxy collection install git+file:///tmp/beegfs --no-deps
  fi

  rm -rf /tmp/*
fi

ln -s /usr/bin/python3 /usr/bin/python
exit 0