#!/bin/sh
DIR=/var/local/shared/nodes
bootnode -genkey boot.key
bootnode -nodekey boot.key -addr "172.16.254.100:30305" | tee $DIR/bootnode.txt
