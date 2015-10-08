#!/bin/bash


######## MAIN ####################################################################
# Create a basic buildroot environment
docker build -t inaetics/buildroot_basic buildroot_basic
# Add the latest Celix development release as package to it
docker build -t inaetics/buildroot_minimum_celix buildroot_minimum_celix
# Create the cagent_builder to build the inaetics celix-agent and 
# to build application bundles that can run in this celix-agent
docker build -t inaetics/cagent_builder cagent_builder 
# Create script to build bundles
docker run inaetics/cagent_builder build_script > cagent_builder.sh
chmod +x cagent_builder.sh

# Create celix-agent
./cagent_builder.sh make_celix_agent
# Create "default" node-agent bundles
./cagent_builder.sh make_node_agent_bundles

# Create node-wiring bundles
git clone https:/github.com/inaetics/node-wiring-c
cd node-wiring-c; ../cagent_builder.sh make_bundles
# Example how to create a bundle
cd example_bundle; ../cagent_builder.sh make_bundles
