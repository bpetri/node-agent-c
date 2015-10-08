#!/bin/bash

if [[$# == 0 ]]; then
    cat /inaetics/cagent
    exit 0
fi

if [[ -n $BUILDER_UID ]] && [[ -n $BUILDER_GID ]]; then
    BUILDER_USER=inaetics-user
    BUILDER_GROUP=inaetics-group

    groupadd -o -g $BUILDER_GID $BUILDER_GROUP 2> /dev/null
    useradd -o -g $BUILDER_GID -u $BUILDER_UID $BUILDER_USER 2> /dev/null
    exec chpst -u :$BUILDER_UID:$BUILDER_GID "$@"
else
    exec "$@"
fi
