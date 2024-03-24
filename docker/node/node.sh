#!/bin/sh
NETWORKID=$1
NODEID=$2
IP=$3
DIR=/var/local/shared/nodes
ENODE=$(cat $DIR/bootnode.txt | grep "^enode:")
ACCOUNT=$(cat $DIR/account${NODEID}.txt)

mkdir /root/.ethereum

geth init $DIR/genesis.json
cp -a $DIR/keystore/* /root/.ethereum/keystore

if [ "$NODEID" = "1" ]
then
  MINE="--mine --miner.etherbase $ACCOUNT"
else
  MINE=""
fi

echo "****************************************************************"
cat $DIR/bootnode.txt
echo "****************************************************************"

geth \
  --port 30306 \
  --networkid $NETWORKID \
  --unlock $ACCOUNT \
  --password $DIR/password.txt \
  --nat "extip:$IP" \
  --netrestrict="172.16.254.0/24" \
  --bootnodes "$ENODE" \
  --http --http.addr $IP --http.corsdomain="*" --http.api "web3,eth,debug,personal,net" --vmdebug --allow-insecure-unlock \
  --miner.gaslimit 90000000000 \
  --rpc.gascap 0 \
  $MINE


