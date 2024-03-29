#!/bin/bash

. scripts/colors.sh

docker run --add-host=host.docker.internal:host-gateway -it --rm -v .:/root -v ethereum-local_shared-volume:/var/local/shared --network ethereum-local_node-network ghcr.io/foundry-rs/foundry:latest 'cd /root/scripts && ./foundry-precompiled.sh'

