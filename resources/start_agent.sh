#!/bin/bash

cleanup() {
	if [ -n "${ETCD_PID}" ] 
	then
		kill ${ETCD_PID}
	fi
	if [ -n "${CELIX_PID}" ] 
	then
		kill ${CELIX_PID}
	fi
}

trap cleanup SIGHUP SIGINT SIGTERM

etcd &
ETCD_PID=$!
sleep 1

echo "Retreiving provisioning server url from etcd"
provisioning_path=$(etcdctl ls /inaetics/node-provisioning-service | head -n 1)
if [ $? -eq 0 ] 
then 
	provisioning_url=$(etcdctl get ${provisioning_url})
else 
	echo "Cannot find dir /inaetics/node-provisioning-service in etcd"
fi

if [ -z "${provisioning_url}" ] 
then
	echo "Cannot find provisioning server in the etcd dir /inaetics/node-provisioning-service"
	echo "Using default ace server localhost:8080"
	echo "deployment_admin_url=http://localhost:8080" >> /tmp/celix-workdir/config.properties
else 
	echo "Using provisioning server ${provisioning_url}"
	echo "deployment_admin_url=${provisioning_url}" >> /tmp/celix-workdir/config.properties
fi 

cd /tmp/celix-workdir
celix &
CELIX_PID=$!
wait ${CELIX_PID}
