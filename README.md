# Buildroot INAETICS node-agent-celix
This project builds three docker images:
* buildroot_basic: 
  a ubuntu image that has a buildroot develop environment
* buildroot_minimum_celix: 
  a ubuntu image with the above buildroot development environment and the 
  latest Celix development branch. It is used to build the 
  inaetics/celix-agent node that only contains a deployment_admin bundle 
  and log_services.
* cagent_builder: 
  the above image, but now build with all the necessary bundles needed to 
  run applications on inaetics. It is controlled by a separate script to 
  support building application bundles against this buildroot and Celix environment.

##############################################################################
The necessary build steps are supported by the included build.sh script.

## Build basic buildroot environment
To build the buildroot_basic image:

    docker build -t inaetics/buildroot_basic buildroot_basic

This build takes a long time to retrieve the buildroot environment from the Internet and then build it inside the ubuntu based docker image. At the moment it is based on the buildroot 2015.05 tag.

Note: there is no need to run this docker image directly.

## Add latest celix to buildroot environment
To build the target inaetics/buildroot_minimum_celix image:

    docker build -t inaetics/buildroot_minimum_celix buildroot_minimum_celix

Note: there is no need to run this docker image directly.

## Build the celix agent builder
The celix agent builder is a shell script (cagent_builder.sh) that can be used to:
- build the inaetics/celix-agent
- build the set of bundles that every celix-agent needs. 
  We want don't want to include these in the celix-agent, but want to provide 
  these to the celix-agent with the INAETICS provisioning server (Apache ACE)
- build your application bundles 

The shell script uses an inaetics/cagent_builder image that can be generated 
with the following command:
	
	docker build -t inaetics/cagent_builder cagent_builde

The nice part is that this cagent_builder image is also used to generate the 
needed shell script. Use the following commands to generate the shell script:

        docker run inaetics/cagent_builder build_script > cagent_builder.sh
        chmod +x cagent_builder.sh

##############################################################################
The cagent_builder.sh can be invoked with the following commands:
	
	./cagent_builder.sh make_celix_agent (Generates inaetics/celix-agent)

        ./cagent_builder.sh make_node_agent_bundles (Generates bundles every celix-agent needs. 
->      Note: The result (bundles with ACE naming convention) are stored in a subdirectory deploy.

	./cagent_builder.sh make_bundles (Generates application bundles. 
        The script is supposed to be called from the application directory that 
        contains the top-level CMakeLists.txt. 
->      The result (bundles with ACE naming convention) are stored in a subdirectory deploy.

Finally, besides these built-in commands the cagent_builder also supports 
the "normal" docker behaviour that any command can be executed inside 
the docker image, be careful in this case the current directory is mounted 
on /build in the docker container. As examples:
	
	./cagent_builder.sh /bin/bash : starts docker image with interactive shell
	./cagent_builder.sh ls -la    : shows listing of files inside docker image    

