#!/bin/sh
PASSWORD=$1
NETWORKID=$2
DIR=/var/local/shared/nodes
rm -fr $DIR
mkdir $DIR
echo "$PASSWORD" > $DIR/password.txt
geth account new --password $DIR/password.txt | grep "Public address of the key:" | cut -d ":" -f 2 | cut -d 'x' -f 2  > $DIR/account1.txt
geth account new --password $DIR/password.txt | grep "Public address of the key:" | cut -d ":" -f 2 | cut -d 'x' -f 2  > $DIR/account2.txt
cat $DIR/account1.txt
cat $DIR/account2.txt
ls /root/.ethereum/keystore
cp -a /root/.ethereum/keystore $DIR
sed -i -e "s/ACCOUNT1/$(cat $DIR/account1.txt)/g" genesis.json 
sed -i -e "s/ACCOUNT2/$(cat $DIR/account2.txt)/g" genesis.json 
sed -i -e "s/NETWORKID/$NETWORKID/g" genesis.json
cp genesis.json $DIR

