#!/bin/sh

DIR=/var/local/shared/nodes
ACCOUNT1=$(cat $DIR/account1.txt)
ACCOUNT2=$(cat $DIR/account2.txt)
RPC_URL=http://172.16.254.101:8545
COMPILER_VERSION=0.8.19
SECRET_KEY="0xB7E151628AED2A6ABF7158809CF4F3C762E7160F38B4DA56A784D9045190CFEF"
AUX_RAND="0xC87AA53824B4D7AE2EB035A2B5BBBCCC080E76CDC6D1692C4B0B62D798E6D906"
STRING="Hi!"
STRING_BYTES="0x486921"

. colors.sh

blue "Account1: $ACCOUNT1"
blue "Account2: $ACCOUNT2"
blue "RPC url: $RPC_URL"
blue "Compiler version: $COMPILER_VERSION"
blue "Secret key: $SECRET_KEY"
blue "Aux rand: $AUX_RAND"
blue "String: $STRING"
blue "String as bytes: $STRING_BYTES"

yellow "Running tests..."
any_key

cd /root/project
forge test --use $COMPILER_VERSION

yellow "Deploying smart contracts..."
yellow "Deploying Schnorr..."
any_key
forge create --rpc-url $RPC_URL src/Schnorr.sol:Schnorr --use $COMPILER_VERSION --unlocked --from $ACCOUNT1 | tee /tmp/transaction-schnorr.log

SCHNORR_ADRESS=$(cat /tmp/transaction-schnorr.log | grep '^Deployed to:' | sed -e 's/Deployed to: //g')
blue "Schnorr address: $SCHNORR_ADRESS"

yellow "Deploying StringInput..."
yellow "  Address of Schnorr contract is send as constructor argument."
any_key
forge create --rpc-url $RPC_URL src/StringInput.sol:StringInput --use $COMPILER_VERSION --unlocked --from $ACCOUNT1 --constructor-args $SCHNORR_ADRESS | tee /tmp/transaction-string-input.log
STRING_INPUT_ADRESS=$(cat /tmp/transaction-string-input.log | grep '^Deployed to:' | sed -e 's/Deployed to: //g')
blue "StringInput address: $STRING_INPUT_ADRESS"

yellow "Running deployed contracts..."

yellow "Calling pubkey_gen(bytes32)(bytes32)"
yellow "  We are generating a public key from our secret key $SECRET_KEY."
any_key
cast call --rpc-url $RPC_URL $SCHNORR_ADRESS --from $ACCOUNT1 'pubkey_gen(bytes32)(bytes32)' "$SECRET_KEY" | tee /tmp/call-result
PUBLIC_KEY=$(cat /tmp/call-result)
blue "Public key: $PUBLIC_KEY"

yellow "Calling schnorr_sign(bytes, bytes, bytes32)(bytes)"
yellow "  We are signing our message '$STRING' with secret key $SECRET_KEY"
any_key
cast call --rpc-url $RPC_URL $SCHNORR_ADRESS --from $ACCOUNT1 'schnorr_sign(bytes, bytes, bytes32)(bytes)' "$STRING_BYTES" "$SECRET_KEY" "$AUX_RAND" | tee /tmp/call-result
SIGNATURE=$(cat /tmp/call-result)
blue "Signature: $SIGNATURE"

yellow "Calling schnorr_verify(bytes, bytes32, bytes)(bool)"
yellow "  Now we can verify the signature using public key $PUBLIC_KEY"
any_key
cast call --rpc-url $RPC_URL $SCHNORR_ADRESS --from $ACCOUNT1 'schnorr_verify(bytes, bytes32, bytes)(bool)' "$STRING_BYTES" "$PUBLIC_KEY" "$SIGNATURE" | tee /tmp/call-result

yellow "Calling get()(string[])"
yellow "  We are done with Schnorr, now we will call methods of the other contract, StringInput"
yellow "  First we will check if the array of strings owned by Account1 $ACCOUNT1 is empty"
any_key
cast call --rpc-url $RPC_URL $STRING_INPUT_ADRESS --from $ACCOUNT1 'get()(string[])' | tee /tmp/call-result

yellow "Calling length()(uint)"
yellow "  And if the length of array is 0"
any_key
cast call --rpc-url $RPC_URL $STRING_INPUT_ADRESS --from $ACCOUNT1 'length()(uint)' | tee /tmp/call-result

yellow "Sending push(string, bytes32, bytes)"
yellow "  Now we will push our string $STRING, which has been signed before."
yellow "  We pass the public key $PUBLIC_KEY and the signature $SIGNATURE"
any_key
cast send --rpc-url $RPC_URL $STRING_INPUT_ADRESS --from $ACCOUNT1 --unlocked 'push(string, bytes32, bytes) (address)' "$STRING" "$PUBLIC_KEY" "$SIGNATURE" | tee /tmp/call-result

yellow "Calling length()(uint)"
yellow "  Now the length of array is 1"
any_key
cast call --rpc-url $RPC_URL $STRING_INPUT_ADRESS --from $ACCOUNT1 'length()(uint)' | tee /tmp/call-result

yellow "Calling get()(string[])"
yellow "  And the array contains the string."
any_key
cast call --rpc-url $RPC_URL $STRING_INPUT_ADRESS --from $ACCOUNT1 'get()(string[])' | tee /tmp/call-result

yellow "Calling get(uint)(string)"
yellow "  And finally the string is at index 0 of the array."
any_key
cast call --rpc-url $RPC_URL $STRING_INPUT_ADRESS --from $ACCOUNT1 'get(uint)(string)' '0' | tee /tmp/call-result

yellow "Calling length()(uint)"
yellow "  However, for another account $ACCOUNT2 the length is still 0"
any_key
cast call --rpc-url $RPC_URL $STRING_INPUT_ADRESS --from $ACCOUNT2 'length()(uint)' | tee /tmp/call-result

yellow "Calling get()(string[])"
yellow "  And the array is empty for another account $ACCOUNT2"
any_key
cast call --rpc-url $RPC_URL $STRING_INPUT_ADRESS --from $ACCOUNT2 'get()(string[])' | tee /tmp/call-result



