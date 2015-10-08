#############################################################
#
## CELIX
#
##############################################################
CELIX_VERSION = Latest 
CELIX_SOURCE = develop.tar.gz 
CELIX_SITE = https://github.com/apache/celix/archive/
CELIX_INSTALL_STAGING = YES
CELIX_INSTALL_TARGET = YES
CELIX_CONF_OPTS = -DWITH_APR=OFF -DCMAKE_EXE_LINKER_FLAGS="-ldl -lpthread" -DBUILD_DEPLOYMENT_ADMIN=ON -DBUILD_SHELL=ON -DBUILD_SHELL_TUI=ON -DBUILD_REMOTE_SHELL=ON -DBUILD_LOG_SERVICE=ON -DBUILD_LOG_WRITER_SYSLOG=ON -DBUILD_DEVICE_ACCESS=ON 
CELIX_DEPENDENCIES = libcurl zlib e2fsprogs

$(eval $(cmake-package))

