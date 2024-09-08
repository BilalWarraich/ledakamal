#!/bin/bash

# Exit on first error
set -e

# Set the environment variables
export PATH=${PWD}/bin:$PATH
export FABRIC_CFG_PATH=${PWD}/config/
export ORDERER_CFG_PATH=${PWD}/../config/    # Path to custom orderer.yaml
export CORE_PEER_MSPCONFIGPATH=${PWD}/../config/    # Path to custom core.yaml
export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem

# Clean up previous crypto material and config transactions
rm -rf config/*
rm -rf crypto-config/*

# Generate crypto materials for organizations
cryptogen generate --config=./crypto-config.yaml

# Generate genesis block for orderer
configtxgen -profile TwoOrgsOrdererGenesis -channelID system-channel -outputBlock ./config/genesis.block

# Generate channel configuration transactions
configtxgen -profile Channel1 -outputCreateChannelTx ./config/channel1.tx -channelID channel1
configtxgen -profile Channel2 -outputCreateChannelTx ./config/channel2.tx -channelID channel2

# Generate anchor peer transactions
configtxgen -profile Channel1 -outputAnchorPeersUpdate ./config/BloodCollectionMSPanchors.tx -channelID channel1 -asOrg BloodCollectionMSP
configtxgen -profile Channel1 -outputAnchorPeersUpdate ./config/BloodProcessingMSPanchors.tx -channelID channel1 -asOrg BloodProcessingMSP
configtxgen -profile Channel1 -outputAnchorPeersUpdate ./config/BloodBankMSPanchors.tx -channelID channel1 -asOrg BloodBankMSP

configtxgen -profile Channel2 -outputAnchorPeersUpdate ./config/BloodBankMSPanchors.tx -channelID channel2 -asOrg BloodBankMSP
configtxgen -profile Channel2 -outputAnchorPeersUpdate ./config/HospitalsMSPanchors.tx -channelID channel2 -asOrg HospitalsMSP
configtxgen -profile Channel2 -outputAnchorPeersUpdate ./config/TransportationMSPanchors.tx -channelID channel2 -asOrg TransportationMSP

# Create docker containers and network
docker-compose -f docker-compose-cli.yaml up -d

# Create channels with custom orderer.yaml
docker exec cli peer channel create -o orderer.example.com:7050  -c channel1 -f /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/channel1.tx --outputBlock /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/channel1.block  --tls --cafile $ORDERER_CA
docker exec cli peer channel create -o orderer.example.com:7050 -c channel2 -f /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/channel2.tx --outputBlock /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/channel2.block  --tls --cafile $ORDERER_CA

# Join peers to channel1 with custom core.yaml
docker exec -e CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH cli peer channel join -b /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/channel1.block 
docker exec -e CORE_PEER_ADDRESS=peer1.BloodProcessing.example.com:7051 -e CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH cli peer channel join -b /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/channel1.block
docker exec -e CORE_PEER_ADDRESS=peer0.BloodBank.example.com:7051 -e CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH cli peer channel join -b /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/channel1.block

# Join peers to channel2 with custom core.yaml
docker exec -e CORE_PEER_ADDRESS=peer0.BloodBank.example.com:7051 -e CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH cli peer channel join -b /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/channel2.block
docker exec -e CORE_PEER_ADDRESS=peer0.Hospitals.example.com:7051 -e CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH cli peer channel join -b /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/channel2.block
docker exec -e CORE_PEER_ADDRESS=peer0.Transportation.example.com:7051 -e CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH cli peer channel join -b /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/channel2.block

# Update anchor peers with custom core.yaml
docker exec -e CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH cli peer channel update -o orderer.example.com:7050 -c channel1 -f /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/BloodCollectionMSPanchors.tx --tls --cafile $ORDERER_CA
docker exec -e CORE_PEER_ADDRESS=peer1.BloodProcessing.example.com:7051 -e CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH cli peer channel update -o orderer.example.com:7050 -c channel1 -f /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/BloodProcessingMSPanchors.tx --tls --cafile $ORDERER_CA
docker exec -e CORE_PEER_ADDRESS=peer0.BloodBank.example.com:7051 -e CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH cli peer channel update -o orderer.example.com:7050 -c channel1 -f /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/BloodBankMSPanchors.tx --tls --cafile $ORDERER_CA

docker exec -e CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH cli peer channel update -o orderer.example.com:7050 -c channel2 -f /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/BloodBankMSPanchors.tx --tls --cafile $ORDERER_CA
docker exec -e CORE_PEER_ADDRESS=peer0.Hospitals.example.com:7051 -e CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH cli peer channel update -o orderer.example.com:7050 -c channel2 -f /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/HospitalsMSPanchors.tx --tls --cafile $ORDERER_CA
docker exec -e CORE_PEER_ADDRESS=peer0.Transportation.example.com:7051 -e CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH cli peer channel update -o orderer.example.com:7050 -c channel2 -f /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/TransportationMSPanchors.tx --tls --cafile $ORDERER_CA

echo "Network setup is complete."

# To stop and remove the network
function network_down {
  docker-compose -f docker-compose-cli.yaml down --volumes --remove-orphans
  docker rm -f $(docker ps -aq)
  docker rmi -f $(docker images -aq)
  sudo rm -rf config/*
  sudo rm -rf crypto-config/*
}

if [ "$1" == "down" ]; then
    network_down
fi

