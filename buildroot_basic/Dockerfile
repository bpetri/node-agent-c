# Version 1.0
FROM ubuntu:14.04
MAINTAINER Florian GAUVIN "florian.gauvin@nl.thalesgroup.com"

ENV DEBIAN_FRONTEND noninteractive
#ENV http_proxy=http://10.160.64.104:8080
#ENV https_proxy=http://10.160.64.104:8080

#Download all the packages needed

RUN apt-get update && apt-get install -y \
	build-essential \
	cmake \
	git \
	python \
	wget \
	unzip \
	bc\
	language-pack-en \
	curl \
	uuid-dev \
    	libjansson-dev \
    	libxml2-dev \
    	libcurl4-openssl-dev \
	mercurial \
	zip \
	openjdk-7-jdk \
	libcups2-dev \
	libfreetype6-dev \
	libasound2-dev\
	libffi-dev \
	libX11-dev \
	libxext-dev \
	libxrender-dev \
	libxtst-dev \
	libxt-dev \
        runit \
        && apt-get clean 
# Update CMAKE
RUN mkdir /cmake && cd /cmake && wget http://www.cmake.org/files/v3.2/cmake-3.2.2.tar.gz && tar xf cmake-3.2.2.tar.gz && cd cmake-3.2.2 && ./configure --prefix=/usr && make && make install

#Download and install the latest version of Docker (You need to be the same version to use this Dockerfile)
RUN wget -qO- https://get.docker.com/ | sh

#Prepare the usr directory by downloading in it : Buildroot, the configuration files of Buildroot, Apache Celix, Apache Felix and Apache Ace

WORKDIR /usr

RUN wget http://git.buildroot.net/buildroot/snapshot/buildroot-2015.05.tar.gz && \
	tar -xf buildroot-2015.05.tar.gz && \
        echo "HOST_FAKEROOT_CONF_OPTS += --with-ipc=tcp" >> /usr/buildroot-2015.05/package/fakeroot/fakeroot.mk && \
        echo 'source "package/etcd/Config.in"' >> /usr/buildroot-2015.05/Config.in

#Add missing packages to the buildroot environment
ADD extra_buildroot_packages/etcd /usr/buildroot-2015.05/package/etcd
 
 
#&& \
#	wget http://www.eu.apache.org/dist/felix/org.apache.felix.main.distribution-5.2.0.tar.gz  && \
#	tar -xf org.apache.felix.main.distribution-5.2.0.tar.gz && \
#	wget http://www.eu.apache.org/dist/ace/apache-ace-2.0.1/apache-ace-2.0.1-bin.zip && \
#	unzip apache-ace-2.0.1-bin.zip 

#ZEROMQ 3.2.5 has to be used instead of the default 4.x
RUN sed -i -e 's/ZEROMQ_VERSION.*/ZEROMQ_VERSION = 3.2.5/' /usr/buildroot-2015.05/package/zeromq/zeromq.mk && rm -f /usr/buildroot-2015.05/package/zeromq/zeromq.hash && rm -f /usr/buildroot-2015.05/package/zeromq/*patch

#Let's begin with Apache Celix

#Copy the configuration file of Apache Celix in Buildroot and create a small base of the future image with buildroot and decompress it

#RUN make

#WORKDIR /usr/buildroot-2015.05/output/images
#RUN mkdir /usr/celix-image && \
#    cp rootfs.tar /usr/celix-image/

#RUN echo "cosgi.auto.start.1= /usr/share/celix/bundles/deployment_admin.zip /usr/share/celix/bundles/log_service.zip /usr/share/celix/bundles/log_writer.zip /usr/share/celix/bundles/remote_shell.zip /usr/share/celix/bundles/shell.zip /usr/share/celix/bundles/shell_tui.zip" > /usr/buildroot-2015.05/output/images/usr/bin/config.properties
#Create the app-builder image
#Copy the configuration file of the app-builder in Buildroot and create a small base of the future image with buildroot and decompress it
ADD buildroot-configure-app-builder/.config /usr/buildroot-2015.05/
WORKDIR /usr/buildroot-2015.05

RUN make

#WORKDIR /usr/buildroot-2015.05/output/images
#RUN mkdir /usr/app-builder-image && \
#    cp rootfs.tar /usr/app-builder-image/

#When the builder image is launch, it creates the docker images automatically that you will be able to see by running the command : docker images

#ENTRYPOINT for i in `seq 0 100`; do sudo mknod -m0660 /dev/loop$i b 7 $i; done && \
#	/bin/bash inaetics/entrypoint.sh
#
#service docker start && \
#	docker import - inaetics/celix-agent < /usr/celix-image/rootfs.tar &&\
#	/bin/bash 


#ENV http_proxy=""
#ENV https_proxy=""
