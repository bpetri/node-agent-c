# Version 1.0
FROM ubuntu:14.04
MAINTAINER Florian GAUVIN "florian.gauvin@nl.thalesgroup.com"

ENV DEBIAN_FRONTEND noninteractive

#Download all the packages needed

RUN apt-get -qq update && apt-get -qq install \
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
	cmake \
 	apparmor \
	aufs-tools \
	cgroup-lite \
	iptables \
	libapparmor-perl \
	libnfnetlink0 \
	libxtables10 \
        && apt-get -qq clean 

# Update CMAKE
#RUN mkdir /cmake && cd /cmake && wget -nv http://www.cmake.org/files/v3.2/cmake-3.2.2.tar.gz && tar xf cmake-3.2.2.tar.gz && cd cmake-3.2.2 && ./configure --prefix=/usr && make && make install

#Download and install the latest version of Docker (You need to be the same version to use this Dockerfile)
RUN wget -qO- https://get.docker.com/ | sh

#Prepare the usr directory by downloading in it : Buildroot, the configuration files of Buildroot, Apache Celix, Apache Felix and Apache Ace

WORKDIR /usr

RUN wget -nv http://git.buildroot.net/buildroot/snapshot/buildroot-2015.05.tar.gz && \
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

ADD buildroot-configure-app-builder/.config /usr/buildroot-2015.05/
WORKDIR /usr/buildroot-2015.05

RUN make -j 8 --silent > /dev/null
