FROM alpine:3.13

ARG use_local_collection=true
ARG required_apk_packages="ansible git sshpass openssh py-pip"
ARG required_pip_packages="ipaddr netaddr pyopenssl"
ARG internal_apk_url="http://repomirror-rtp.eng.netapp.com/alpine-linux/v3.13"
ARG internal_pip_url="http://repoproxy-rtp.eng.netapp.com:8081/artifactory/api/pypi/python-package-index/simple"
ARG external_santricity_collection_url="netapp_eseries.santricity"
ARG external_host_collection_url="netapp_eseries.host"
ARG external_beegfs_collection_url="netapp_eseries.beegfs"
ARG internal_santricity_collection_url=""
ARG internal_host_collection_url=""
ARG internal_beegfs_collection_url=""
ARG internal_collection_dependencies_url=""

ENV env_use_local_collection=$use_local_collection
ENV env_required_apk_packages=$required_apk_packages
ENV env_required_pip_packages=$required_pip_packages
ENV env_internal_apk_url=$internal_apk_url
ENV env_internal_pip_url=$internal_pip_url
ENV env_external_santricity_collection_url=$external_santricity_collection_url
ENV env_external_host_collection_url=$external_host_collection_url
ENV env_external_beegfs_collection_url=$external_beegfs_collection_url
ENV env_internal_santricity_collection_url=$internal_santricity_collection_url
ENV env_internal_host_collection_url=$internal_host_collection_url
ENV env_internal_beegfs_collection_url=$internal_beegfs_collection_url
ENV env_internal_collection_dependencies_url=$internal_collection_dependencies_url

COPY . /tmp/local_collection
COPY docker/configure.sh /configure.sh
RUN chmod +x /configure.sh && /configure.sh

WORKDIR /ansible/playbooks
ENTRYPOINT ["ansible-playbook"]
