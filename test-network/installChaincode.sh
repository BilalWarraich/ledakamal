#!/bin/bash

export PATH=${PWD}/../bin:$PATH

export FABRIC_CFG_PATH=$PWD/../config/

export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="bloodcollectionMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/bloodcollection.example.com/peers/peer0.bloodcollection.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/bloodcollection.example.com/users/Admin@bloodcollection.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051

peer lifecycle chaincode package bloodchaincode7.tar.gz --path ../chaincode/blockchain/chaincode/ --lang golang --label bloodchaincode7
peer lifecycle chaincode install bloodchaincode7.tar.gz

export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="bloodcollectionMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/bloodcollection.example.com/peers/peer1.bloodcollection.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/bloodcollection.example.com/users/Admin@bloodcollection.example.com/msp
export CORE_PEER_ADDRESS=localhost:8051

peer lifecycle chaincode install bloodchaincode7.tar.gz

export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="bloodprocessingMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/bloodprocessing.example.com/peers/peer0.bloodprocessing.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/bloodprocessing.example.com/users/Admin@bloodprocessing.example.com/msp
export CORE_PEER_ADDRESS=localhost:9051
peer lifecycle chaincode install bloodchaincode7.tar.gz

export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="bloodprocessingMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/bloodprocessing.example.com/peers/peer1.bloodprocessing.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/bloodprocessing.example.com/users/Admin@bloodprocessing.example.com/msp
export CORE_PEER_ADDRESS=localhost:10051
peer lifecycle chaincode install bloodchaincode7.tar.gz

export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="bloodbankMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/bloodbank.example.com/peers/peer0.bloodbank.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/bloodbank.example.com/users/Admin@bloodbank.example.com/msp
export CORE_PEER_ADDRESS=localhost:11051

peer lifecycle chaincode install bloodchaincode7.tar.gz

export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="bloodbankMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/bloodbank.example.com/peers/peer1.bloodbank.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/bloodbank.example.com/users/Admin@bloodbank.example.com/msp
export CORE_PEER_ADDRESS=localhost:12051



peer lifecycle chaincode install bloodchaincode7.tar.gz





peer lifecycle chaincode queryinstalled

export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="bloodcollectionMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/bloodcollection.example.com/peers/peer0.bloodcollection.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/bloodcollection.example.com/users/Admin@bloodcollection.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051



