# Dockerfile for inaetics/celix-node-agent-service
FROM ubuntu:14.04
MAINTAINER Pepijn Noltes <pepijnnoltes@gmail.com> 

##APT_PROXY - allow builder to inject a proxy dynamically

# Generic update & tooling
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get upgrade -yq && apt-get install -yq --no-install-recommends \
  build-essential \
  golang \
  curl \
  libapr1-dev \
  libaprutil1-dev \
  subversion \
  libjansson-dev \
  libcurl4-openssl-dev \
  libxml2-dev \
  cmake \ 
  socat \
  screen \
  gdb  \
  git && apt-get clean

##ETCDCTL_INSTALL - instruct builder to install etcdctl
#RUN cd /tmp && git config --global http.sslVerify false && git clone https://github.com/coreos/etcd && cd etcd && ./build
RUN cd /tmp && curl -k -L https://github.com/coreos/etcd/releases/download/v0.4.6/etcd-v0.4.6-linux-amd64.tar.gz | tar xzf - && \
	cp etcd-v0.4.6-linux-amd64/etcd /bin/ && cp etcd-v0.4.6-linux-amd64/etcdctl /bin/ 

#Install celix
RUN cd /tmp && svn co --trust-server-cert --non-interactive -r 1628441 https://svn.apache.org/repos/asf/celix/trunk celix && svn co --trust-server-cert --non-interactive -r 1628260  https://svn.apache.org/repos/asf/celix/trunk/deployment_admin/private/src celix/deployment_admin/private/src && \
	mkdir celix/build && cd celix/build && \ 
	cmake -DBUILD_DEPLOYMENT_ADMIN:BOOL=ON -DBUILD_REMOTE_SERVICE_ADMIN:BOOL=ON -DBUILD_RSA_BUNDLES_DISCOVERY_BONJOUR:BOOL=OFF -DBUILD_RSA_BUNDLES_DISCOVERY_SLP:BOOL=OFF -DCMAKE_INSTALL_PREFIX:PATH=/usr .. && \ 
	make all install-all && \
	cd /tmp && rm -fr celix

# set permissions for screen
RUN chmod 777 /var/run/screen

# Node agent resources
ADD resources /tmp
