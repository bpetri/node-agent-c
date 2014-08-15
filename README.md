# Celix Node Agent Service

Run an INAETICS Node Agent as a CoreOS/Docker service.

##Run on localhost

    Install Git, Docker & Etcd
    Clone this repository
    RUN docker build -t inaetics/celix-node-agent celix-node-agent-service
    RUN docker run -d inaetics/celix-node-agent



#TODO

* the config.properties in resources/celix-workspaces should be updated with a correct dynamic and unique deployment_id
* The ace url to be used should be discovered by etcd or set in the config.properties
