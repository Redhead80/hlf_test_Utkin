#!/bin/bash

. env.sh

PATH=${PWD}/bin:$PATH

CC_VERSION=${1:-"1"}
CC_SEQUENCE=${2:-1}

export FABRIC_CFG_PATH=${PWD}/config


######################################################################
# ORG 1 and ORG 2
######################################################################

echo
echo "Committing chaincode ${CC_NAME} on channel ${CHANNEL_NAME}"

export CORE_PEER_LOCALMSPID=Org1MSP
export CORE_PEER_ID=peer0.org1.example.com
export CORE_PEER_ADDRESS=localhost:7051
export CORE_PEER_MSPCONFIGPATH=${PEER0_ORG1_MSP}
export CORE_PEER_TLS_ROOTCERT_FILE=${PEER0_ORG1_CA}

PEER_CONN_PARAMS="--peerAddresses localhost:7051 $(eval echo "--tlsRootCertFiles \$PEER0_ORG1_CA") --peerAddresses localhost:9051 $(eval echo "--tlsRootCertFiles \$PEER0_ORG2_CA")"

peer lifecycle chaincode commit -o localhost:7050 --tls --ordererTLSHostnameOverride orderer.example.com --cafile "$ORDERER_CA" --channelID "$CHANNEL_NAME" --name "${CC_NAME}" $PEER_CONN_PARAMS --version "${CC_VERSION}" --sequence "${CC_SEQUENCE}" "${INIT_REQUIRED}" ${CC_END_POLICY}

result=$?
if [ $result -ne 0 ]; then
    echo "Failed installing chaincode on peer0.org1.example.com"
    exit 1
fi

cat log.txt


######################################################################
# ORG 1
######################################################################

echo
echo "Querying committed chaincode on ORG 1"

export CORE_PEER_LOCALMSPID=Org1MSP
export CORE_PEER_ID=peer0.org1.example.com
export CORE_PEER_ADDRESS=localhost:7051
export CORE_PEER_MSPCONFIGPATH=${PEER0_ORG1_MSP}
export CORE_PEER_TLS_ROOTCERT_FILE=${PEER0_ORG1_CA}

peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name ${CC_NAME} >&log.txt
cat log.txt


######################################################################
# ORG 2
######################################################################

echo
echo "Querying committed chaincode on ORG 2"

export CORE_PEER_LOCALMSPID=Org2MSP
export CORE_PEER_ID=peer0.org2.example.com
export CORE_PEER_ADDRESS=localhost:9051
export CORE_PEER_MSPCONFIGPATH=${PEER0_ORG2_MSP}
export CORE_PEER_TLS_ROOTCERT_FILE=${PEER0_ORG2_CA}

peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name ${CC_NAME} >&log.txt
cat log.txt
