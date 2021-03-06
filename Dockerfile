# Dockerfile for inaetics/celix-node-agent-service
FROM ubuntu:14.04
MAINTAINER Pepijn Noltes <pepijnnoltes@gmail.com> 

##APT_PROXY - allow builder to inject a proxy dynamically

# Generic update & tooling
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get upgrade -yq && apt-get install -yq --no-install-recommends \
  build-essential \
  curl \
  libapr1-dev \
  libaprutil1-dev \
  subversion \
  libjansson-dev \
  libcurl4-openssl-dev \
  libxml2-dev \
  cmake \ 
  gdb  \
  git \
  && apt-get clean

RUN cd /tmp && curl -k -L https://github.com/coreos/etcd/releases/download/v2.0.12/etcd-v2.0.12-linux-amd64.tar.gz | tar xzf - && \
	cp etcd-v2.0.12-linux-amd64/etcd /bin/ && cp etcd-v2.0.12-linux-amd64/etcdctl /bin/ 

#Install celix
ENV GIT_SSL_NO_VERIFY=true
RUN cd /tmp && git clone https://github.com/apache/celix.git && cd celix && git reset --hard e2598c11ab41c401fb4187a49fc77cf55a9976e6 && \
	mkdir build && cd build && \ 
	cmake -DBUILD_DEPLOYMENT_ADMIN:BOOL=ON -DCMAKE_INSTALL_PREFIX:PATH=/usr .. && \ 
	make all install-all && \
	cd /tmp && rm -fr celix

RUN apt-get remove -yq --purge \
  "^build-essential.*" \
  "^subversion.*" \
  "^cmake.*" \
  "^gdb.*"  && apt-get autoremove -yq && apt-get clean

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/

ADD resources /tmp

