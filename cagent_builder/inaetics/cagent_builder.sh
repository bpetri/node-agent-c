#!/bin/bash
# Thanks to docker-raspberry-pi-cross-compiler "RPXC"

INPUT=$@

# Helpers
err() {
    echo -e >&2 ERROR: $@\\n
}

die() {
    err $@
    exit 1
}

has() {
    local kind=$1
    local name=$2
    
     type -t $kind:$name | grep -q function
}

create_jar_from_bundles() {
    for singleBundle in `find . -name \*.zip`
    do
        echo ${singleBundle}
        mkdir t
        unzip ${singleBundle} -d t
        cd t
        symbolicName=`cat META-INF/MANIFEST.MF | grep 'Bundle-Symbolic' | cut -d' ' -f2 | tr -d '\n' | tr -d '\r'`
        version=`cat META-INF/MANIFEST.MF | grep 'Bundle-Version' | cut -d' ' -f2 | tr -d '\n' | tr -d '\r'`
        bundleFile="${symbolicName}-${version}.jar"
        echo "BUNDLEFILE is ${bundleFile}"
        jar cfm ../${bundleFile} META-INF/MANIFEST.MF lib*.so
        cd ..
        rm -rf t
    done
}

add_user_in_container() {
    BUILDER_USER=inaetics-user
    BUILDER_GROUP=inaetics-group

    groupadd -o -g $BUILDER_GID $BUILDER_GROUP 2> /dev/null
    useradd -o -g $BUILDER_GID -u $BUILDER_UID $BUILDER_USER 2> /dev/null

}

# Command handlers
command:help() {
    if [[ $# != 0 ]]; then
        if ! has command $1; then
            err \"$1\" is not a supported command
            command:help
        elif ! has help $1; then
            err No help found for \"$1\"
        else
            help:$1
        fi
    else
        cat >&2 <<ENDHELP
usage: docker run inaetics/cagent_builder <command> <args> or
       cagent_build.sh <command> <args>

Built-in commands cagent_builder.sh:
     make_bundles	     - builds all bundles from the current directory
     make_celix_agent        - builds a minimum celix docker image
     make_node_agent_bundles - builds set of bundles needed in every celix agent

Built-in commands for "docker run inaetics/cagent_builder":
     build_bundles           - compiles all bundles in directory and subdirectories
     build_script            - create cagent_builder.sh (Actually the only command that should
                               be called by the user)
     build_agent_bundles     - compiles all bundles in internal Celix source dir
     <cmd>                   - all other commands are executed inside the cagent_builder container
ENDHELP
    fi 
}

# The following commands are running on the host, so outside the cagent_builder container
command:make_celix_agent() {
# Create the celix-agent, following should work but gives an unexpected EOF error in the docker daemon
#docker run --name minimum_celix inaetics/buildroot_minimum_celix 
#docker export minimum_celix | tar x usr/celix-image/rootfs.tar | docker import - inaetics/celix-agent 
# So alternative solution
    mkdir -p /tmp/minimum_celix 
#    docker run --rm -v /tmp/minimum_celix:/build ${USER_IDS} inaetics/buildroot_minimum_celix /bin/bash -c "cp /usr/celix-image/rootfs.tar /build"
    docker run --rm -v /tmp/minimum_celix:/build inaetics/buildroot_minimum_celix chpst -u :$BUILDER_UID:$BUILDER_GID cp /usr/celix-image/rootfs.tar /build
     cat /tmp/minimum_celix/rootfs.tar | docker import - inaetics/celix-agent
#    rm -rf /tmp/minimum_celix
}

#command:build() {
#    docker run -v /tmp/cagent:/build $FINAL_IMAGE /bin/bash -c "cp /usr/celix-image/rootfs.tar /build/."
#    docker import - inaetics/celix-agent < /tmp/cagent/rootfs.tar
##    service docker start
##    docker import - inaetics/celix-agent < /usr/celix-image/rootfs.tar
#}

help:make_bundles() {
    echo "Command has to be run in top-level bundle directory"
    echo "This directory has to contain a CMakeLists.txt"
}

command:make_bundles() {
    # check if current directory contains CMakeLists.txt
    if [ ! -f ./CMakeLists.txt ]; then
        err Missing CMakeLists.txt
        help:make_bundles
        exit 
    fi
    # backup CMakeFiles.txt
    mkdir -p build
    cd build 
    # add SYSROOT statements to it
    echo "set(CMAKE_SYSROOT \"/usr/buildroot-2015.05/output/host/usr/x86_64-buildroot-linux-gnu/sysroot\")" >> ./toolchain.cmake
    echo "set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} \"/usr/buildroot-2015.05/output/host/usr/x86_64-buildroot-linux-gnu/sysroot/usr/share/celix/cmake/modules\")" >> ./toolchain.cmake
    echo "include(/usr/buildroot-2015.05/output/host/usr/share/buildroot/toolchainfile.cmake)" >> ./toolchain.cmake
    # Start docker run inaetics/cagent_builder with command to run cmake
    cd ..
    docker run --rm -v $PWD:/build ${USER_IDS} $FINAL_IMAGE build_bundles
    # Copy the resulting bundles to ...
    cd build
    create_jar_from_bundles
    cd ..
    mkdir -p deploy
    cp build/*.jar deploy/.
}

command:make_node_agent_bundles() {
    rm -rf /tmp/celix_bundles
    mkdir -p /tmp/celix_bundles
#    docker run -v /tmp/celix_bundles:/build ${USER_IDS} ${FINAL_IMAGE} /bin/bash -c "cp /usr/buildroot-2015.05/output/target/usr/share/celix/bundles/*.zip /build/."
    docker run --rm -v /tmp/celix_bundles:/build ${USER_IDS} ${FINAL_IMAGE} build_agent_bundles 
    cd /tmp/celix_bundles
    create_jar_from_bundles
    cd ${CURRENT_DIR}
    mkdir -p deploy
    cp /tmp/celix_bundles/*.jar deploy/.
    rm -rf /tmp/celix_bundles
}

# Following commands run in the cagent_builder container
command:build_bundles() {
    add_user_in_container
    cd /build/build
    chpst -u :$BUILDER_UID:$BUILDER_GID cmake -DCMAKE_TOOLCHAIN_FILE=./toolchain.cmake -DCELIX_DIR=/usr/buildroot-2015.05/output/target/usr ..
    chpst -u :$BUILDER_UID:$BUILDER_GID make
}

command:build_script() {
    cat /usr/inaetics/cagent_builder.sh
    exit 0
}

command:build_agent_bundles() {
    add_user_in_container
    exec chpst -u :$BUILDER_UID:$BUILDER_GID cp /usr/buildroot-2015.05/output/target/usr/share/celix/bundles/*.zip /build/.

}


FINAL_IMAGE="inaetics/cagent_builder"
BUILDER_UID=$( id -u )
BUILDER_GID=$( id -g )
USER_IDS="-e BUILDER_UID=$( id -u ) -e BUILDER_GID=$( id -g )"

CURRENT_DIR=$PWD


# Command-line processing
if [[ $# == 0 ]]; then
    command:help
    exit 1 
fi

case $1 in
    --)
       shift;
       ;;
    
    *)
      if has command $1; then
          command:$1 "${@:2}" # skip first element array
          exit $?
      else
          docker run --rm -i -t -v $PWD:/build --entrypoint=$1 inaetics/cagent_builder ${@:2}
      fi
      ;;
esac

