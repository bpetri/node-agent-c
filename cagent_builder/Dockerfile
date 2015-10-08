# Version 1.0
FROM inaetics/buildroot_minimum_celix 
MAINTAINER Gerrit Binnenmars "gerrit.binnenmars@nl.thalesgroup.com"

ENV DEBIAN_FRONTEND noninteractive
#ENV http_proxy=http://10.160.64.104:8080
#ENV https_proxy=http://10.160.64.104:8080

#Download all the packages needed

#Add missing packages to the buildroot environment
ADD extra_buildroot_packages/celix /usr/buildroot-2015.05/package/celix

WORKDIR /usr/buildroot-2015.05

RUN rm -rf output/build/celix-Latest; make celix

ADD inaetics /usr/inaetics

ENTRYPOINT ["/usr/inaetics/cagent_builder.sh"]

#ENV http_proxy=""
#ENV https_proxy=""
