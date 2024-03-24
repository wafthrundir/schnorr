#!/bin/bash

. scripts/colors.sh

docker run -it --rm -v .:/root -v ethereum-local_shared-volume:/var/local/shared --network ethereum-local_node-network ghcr.io/foundry-rs/foundry:latest 'cd /root/scripts && ./foundry.sh'

