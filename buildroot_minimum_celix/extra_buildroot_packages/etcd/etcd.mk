#############################################################
#
## ETCD
#
##############################################################
ETCD_VERSION=v0.4.6

#define ETCD_EXTRACT_CMDS
#	unzip $(DL_DIR)/$(ETCD_SOURCE) -d $(@D)
#	mv $(@D)/etcd-master/* $(@D)
#	rm -rf $(@D)/etcd-master
#endef

define ETCD_BUILD_CMDS
	echo BUILD `pwd`
#	do nothing, binary contained in tgz	
endef

define ETCD_INSTALL_STAGING_CMDS
	echo STAGING `pwd`
	cp $(@D)/etcd $(STAGING_DIR)/bin/ && cp $(@D)/etcdctl $(STAGING_DIR)/bin/ 
endef

define ETCD_INSTALL_TARGET_CMDS
	echo INSTALL `pwd`
	cp $(@D)/etcd $(TARGET_DIR)/bin/ && cp $(@D)/etcdctl $(TARGET_DIR)/bin/ 
endef
ETCD_SOURCE = etcd-$(ETCD_VERSION)-linux-amd64.tar.gz
ETCD_SITE = https://github.com/coreos/etcd/releases/download/$(ETCD_VERSION)
ETCD_INSTALL_STAGING = YES
ETCD_INSTALL_TARGET = YES
#ETCD_CONF_OPTS = -DWITH_APR=OFF -DCMAKE_EXE_LINKER_FLAGS="-ldl -lpthread" -DBUILD_DEPLOYMENT_ADMIN=ON -DBUILD_SHELL=ON -DBUILD_SHELL_TUI=ON -DBUILD_REMOTE_SHELL=ON
#ETCD_DEPENDENCIES = libcurl zlib e2fsprogs
$(eval $(generic-package))

