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

HOST_IP=$2
MAX_RETRY_ETCD_REPO=60
RETRY_ETCD_REPO_INTERVAL=5
DISCOVERY_PATH="org.apache.celix.discovery.etcd"

etcd &
ETCD_PID=$!
sleep 1

mkdir -p /tmp/celix-workdir
cp /tmp/config.properties.base /tmp/celix-workdir/config.properties

DEPLOYMENT_ID=$(hostname)
echo "deployment_admin_identification=${DEPLOYMENT_ID}" >> /tmp/celix-workdir/config.properties

echo "Retrieving provisioning server url from etcd"
PROVISIONING_ETCD_PATH=""
PROVISIONING_ETCD_PATH_FOUND=0
RETRY=1
while [ $RETRY -le $MAX_RETRY_ETCD_REPO ] && [ $PROVISIONING_ETCD_PATH_FOUND -eq 0 ]
do

    PROVISIONING_ETCD_PATH=$(etcdctl ls /inaetics/node-provisioning-service | head -n 1; exit ${PIPESTATUS[0]})

    if [ $? -ne 0 ]; then
        echo "Tentative $RETRY of retrieving Provisioning Server from etcd failed. Retrying..."
        ((RETRY+=1))
        sleep $RETRY_ETCD_REPO_INTERVAL
    else
        echo "Found valid Provisioning Server Repository in etcd: ${PROVISIONING_ETCD_PATH}"
        PROVISIONING_ETCD_PATH_FOUND=1
    fi
done

if [ $PROVISIONING_ETCD_PATH_FOUND -eq 1 ]; then
    PROVISIONING_URL=$(etcdctl get ${PROVISIONING_ETCD_PATH})
else 
    echo "Cannot find dir /inaetics/node-provisioning-service in etcd"
fi

if [ -z "${PROVISIONING_URL}" ] 
then
	echo "Cannot find provisioning server in the etcd dir /inaetics/node-provisioning-service"
	echo "Using default ace server provisioning:8080"
	echo "deployment_admin_url=http://provisioning:8080" >> /tmp/celix-workdir/config.properties
else 
	echo "Using provisioning server ${PROVISIONING_URL}"
	echo "deployment_admin_url=${PROVISIONING_URL}" >> /tmp/celix-workdir/config.properties
fi 

# needed for discovery_etcd
echo "RSA_IP=$HOST_IP" >> /tmp/celix-workdir/config.properties
echo "DISCOVERY_ETCD_ROOT_PATH=inaetics/discovery"  >> /tmp/celix-workdir/config.properties
echo "DISCOVERY_ETCD_SERVER_IP=`echo $ETCDCTL_PEERS | cut -d ':' -f 1`" >> /tmp/celix-workdir/config.properties
echo "DISCOVERY_ETCD_SERVER_PORT=`echo $ETCDCTL_PEERS | cut -d ':' -f 2`" >> /tmp/celix-workdir/config.properties
echo "DISCOVERY_CFG_SERVER_IP=$HOST_IP" >> /tmp/celix-workdir/config.properties

cd /tmp/celix-workdir
celix
