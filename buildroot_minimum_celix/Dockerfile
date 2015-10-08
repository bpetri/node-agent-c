# Version 1.0
FROM inaetics/buildroot_basic 
MAINTAINER Florian GAUVIN "florian.gauvin@nl.thalesgroup.com"

ENV DEBIAN_FRONTEND noninteractive
#ENV http_proxy=http://10.160.64.104:8080
#ENV https_proxy=http://10.160.64.104:8080

#Download all the packages needed
RUN echo 'source "package/celix/Config.in"' >> /usr/buildroot-2015.05/Config.in &&\
        wget https://github.com/apache/celix/archive/develop.tar.gz 

#Add missing packages to the buildroot environment
ADD extra_buildroot_packages/celix /usr/buildroot-2015.05/package/celix

WORKDIR /usr/buildroot-2015.05
ADD inaetics/resources-celix /usr/buildroot-2015.05/output/target/tmp

RUN make celix
RUN make 

WORKDIR /usr/buildroot-2015.05/output/images


RUN mkdir /usr/celix-image && \
    cp rootfs.tar /usr/celix-image/

#RUN echo "cosgi.auto.start.1= /usr/share/celix/bundles/deployment_admin.zip /usr/share/celix/bundles/log_service.zip /usr/share/celix/bundles/log_writer.zip /usr/share/celix/bundles/remote_shell.zip /usr/share/celix/bundles/shell.zip /usr/share/celix/bundles/shell_tui.zip" > /usr/buildroot-2015.05/output/images/usr/bin/config.properties
#Create the app-builder image
#Copy the configuration file of the app-builder in Buildroot and create a small base of the future image with buildroot and decompress it
#ADD buildroot-configure-app-builder/.config /usr/buildroot-2015.05/
#WORKDIR /usr/buildroot-2015.05

#RUN make

#WORKDIR /usr/buildroot-2015.05/output/images
#RUN mkdir /usr/app-builder-image && \
#    cp rootfs.tar /usr/app-builder-image/

#When the builder image is launch, it creates the docker images automatically that you will be able to see by running the command : docker images

#ENTRYPOINT for i in `seq 0 100`; do sudo mknod -m0660 /dev/loop$i b 7 $i; done && \
#	/bin/bash
#	/bin/bash inaetics/entrypoint.sh
#
#service docker start && \
#	docker import - inaetics/celix-agent < /usr/celix-image/rootfs.tar &&\
#	/bin/bash 


#ENV http_proxy=""
#ENV https_proxy=""
