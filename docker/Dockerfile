FROM ubuntu:18.04
ARG DEBIAN_FRONTEND=noninteractive
ARG internal_santricity_collection_url="0"
ENV env_internal_santricity_collection_url=$internal_santricity_collection_url
ARG internal_host_collection_url="0"
ENV env_internal_host_collection_url=$internal_host_collection_url
RUN mkdir -p /root/.ansible/collections/ansible_collections/netapp_eseries/santricity \
    mkdir -p /root/.ansible/collections/ansible_collections/netapp_eseries/beegfs
COPY docker/repomirror_sources.list /repomirror_sources.list
COPY docker/repomirror_pip.conf /repomirror_pip.conf
COPY docker/repo_check.sh /repo_check.sh
RUN chmod +x repo_check.sh
RUN ./repo_check.sh
RUN apt-get remove git -y
RUN apt-get update && apt-get install python3 python3-pip -y && rm -rf /var/lib/apt/lists/*
RUN pip3 install 'ansible>=2.9'
COPY ./ /root/.ansible/collections/ansible_collections/netapp_eseries/beegfs
WORKDIR /ansible/playbooks
ENTRYPOINT ["ansible-playbook"]