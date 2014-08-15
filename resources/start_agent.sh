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

cp /tmp/config.properties.base /tmp/celix-workdir/config.properties

DEPLOYMENT_ID=$(hostname)
echo "deployment_admin_identification=${DEPLOYMENT_ID}" >> /tmp/celix-workdir/config.properties

echo "Retreiving provisioning server url from etcd"
PROVISIONING_ETCD_PATH=$(etcdctl ls /inaetics/node-provisioning-service | head -n 1)
if [ $? -eq 0 ] 
then 
	PROVISIONING_URL=$(etcdctl get ${PROVISIONING_ETCD_PATH})
else 
	echo "Cannot find dir /inaetics/node-provisioning-service in etcd"
fi

if [ -z "${PROVISIONING_URL}" ] 
then
	echo "Cannot find provisioning server in the etcd dir /inaetics/node-provisioning-service"
	echo "Using default ace server localhost:8080"
	echo "deployment_admin_url=http://localhost:8080" >> /tmp/celix-workdir/config.properties
else 
	echo "Using provisioning server ${PROVISIONING_URL}"
	echo "deployment_admin_url=${PROVISIONING_URL}" >> /tmp/celix-workdir/config.properties
fi 

cd /tmp/celix-workdir
celix &
CELIX_PID=$!
wait ${CELIX_PID}
