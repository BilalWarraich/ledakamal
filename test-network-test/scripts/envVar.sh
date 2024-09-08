#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

# This is a collection of bash functions used by different scripts

# imports
# test network home var targets to test-network folder
# the reason we use a var here is to accommodate scenarios
# where execution occurs from folders outside of default as $PWD, such as the test-network/addOrg3 folder.
# For setting environment variables, simple relative paths like ".." could lead to unintended references
# due to how they interact with FABRIC_CFG_PATH. It's advised to specify paths more explicitly,
# such as using "../${PWD}", to ensure that Fabric's environment variables are pointing to the correct paths.
TEST_NETWORK_HOME=${TEST_NETWORK_HOME:-${PWD}}
. ${TEST_NETWORK_HOME}/scripts/utils.sh

export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${TEST_NETWORK_HOME}/organizations/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem

export PEER0_BLOODCOLLECTION_CA=${TEST_NETWORK_HOME}/organizations/peerOrganizations/bloodcollection.example.com/tlsca/tlsca.bloodcollection.example.com-cert.pem
export PEER0_BLOODPROCESSING_CA=${TEST_NETWORK_HOME}/organizations/peerOrganizations/bloodprocessing.example.com/tlsca/tlsca.bloodprocessing.example.com-cert.pem
export PEER0_BLOODBANK_CA=${TEST_NETWORK_HOME}/organizations/peerOrganizations/bloodbank.example.com/tlsca/tlsca.bloodbank.example.com-cert.pem
export PEER0_HOSPITALS_CA=${TEST_NETWORK_HOME}/organizations/peerOrganizations/hospitals.example.com/tlsca/tlsca.hospitals.example.com-cert.pem
export PEER0_TRANSPORTATION_CA=${TEST_NETWORK_HOME}/organizations/peerOrganizations/transportation.example.com/tlsca/tlsca.transportation.example.com-cert.pem

# Set environment variables for the peer org
setGlobals() {
  local USING_ORG=""
  if [ -z "$OVERRIDE_ORG" ]; then
    USING_ORG=$1
  else
    USING_ORG="${OVERRIDE_ORG}"
  fi
  infoln "Using organization ${USING_ORG}"
  
  case $USING_ORG in
    "BloodCollection")
      export CORE_PEER_LOCALMSPID=BloodCollectionMSP
      export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_BLOODCOLLECTION_CA
      export CORE_PEER_MSPCONFIGPATH=${TEST_NETWORK_HOME}/organizations/peerOrganizations/bloodcollection.example.com/users/Admin@bloodcollection.example.com/msp
      export CORE_PEER_ADDRESS=localhost:7051
      ;;
    "BloodProcessing")
      export CORE_PEER_LOCALMSPID=BloodProcessingMSP
      export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_BLOODPROCESSING_CA
      export CORE_PEER_MSPCONFIGPATH=${TEST_NETWORK_HOME}/organizations/peerOrganizations/bloodprocessing.example.com/users/Admin@bloodprocessing.example.com/msp
      export CORE_PEER_ADDRESS=localhost:8051
      ;;
    "BloodBank")
      export CORE_PEER_LOCALMSPID=BloodBankMSP
      export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_BLOODBANK_CA
      export CORE_PEER_MSPCONFIGPATH=${TEST_NETWORK_HOME}/organizations/peerOrganizations/bloodbank.example.com/users/Admin@bloodbank.example.com/msp
      export CORE_PEER_ADDRESS=localhost:9051
      ;;
    "Hospitals")
      export CORE_PEER_LOCALMSPID=HospitalsMSP
      export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_HOSPITALS_CA
      export CORE_PEER_MSPCONFIGPATH=${TEST_NETWORK_HOME}/organizations/peerOrganizations/hospitals.example.com/users/Admin@hospitals.example.com/msp
      export CORE_PEER_ADDRESS=localhost:10051
      ;;
    "Transportation")
      export CORE_PEER_LOCALMSPID=TransportationMSP
      export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_TRANSPORTATION_CA
      export CORE_PEER_MSPCONFIGPATH=${TEST_NETWORK_HOME}/organizations/peerOrganizations/transportation.example.com/users/Admin@transportation.example.com/msp
      export CORE_PEER_ADDRESS=localhost:11051
      ;;
    *)
      errorln "ORG Unknown"
      ;;
  esac

  if [ "$VERBOSE" = "true" ]; then
    env | grep CORE
  fi
}

# parsePeerConnectionParameters $@
# Helper function that sets the peer connection parameters for a chaincode operation
parsePeerConnectionParameters() {
  PEER_CONN_PARMS=()
  PEERS=""
  while [ "$#" -gt 0 ]; do
    setGlobals $1
    PEER="peer0.$1"
    ## Set peer addresses
    if [ -z "$PEERS" ]; then
      PEERS="$PEER"
    else
      PEERS="$PEERS $PEER"
    fi
    PEER_CONN_PARMS=("${PEER_CONN_PARMS[@]}" --peerAddresses $CORE_PEER_ADDRESS)
    ## Set path to TLS certificate
    CA=PEER0_$(echo $1 | tr '[:lower:]' '[:upper:]')_CA
    TLSINFO=(--tlsRootCertFiles "${!CA}")
    PEER_CONN_PARMS=("${PEER_CONN_PARMS[@]}" "${TLSINFO[@]}")
    # shift by one to get to the next organization
    shift
  done
}

verifyResult() {
  if [ $1 -ne 0 ]; then
    fatalln "$2"
  fi
}

