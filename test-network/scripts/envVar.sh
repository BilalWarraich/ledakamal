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
export PEER0_ORG1_CA=${TEST_NETWORK_HOME}/organizations/peerOrganizations/bloodcollection.example.com/tlsca/tlsca.bloodcollection.example.com-cert.pem
export PEER1_ORG1_CA=${TEST_NETWORK_HOME}/organizations/peerOrganizations/bloodcollection.example.com/tlsca/tlsca.bloodcollection.example.com-cert.pem
export PEER0_ORG2_CA=${TEST_NETWORK_HOME}/organizations/peerOrganizations/bloodprocessing.example.com/tlsca/tlsca.bloodprocessing.example.com-cert.pem
export PEER1_ORG2_CA=${TEST_NETWORK_HOME}/organizations/peerOrganizations/bloodprocessing.example.com/tlsca/tlsca.bloodprocessing.example.com-cert.pem
export PEER0_ORG3_CA=${TEST_NETWORK_HOME}/organizations/peerOrganizations/bloodbank.example.com/tlsca/tlsca.bloodbank.example.com-cert.pem
export PEER1_ORG3_CA=${TEST_NETWORK_HOME}/organizations/peerOrganizations/bloodbank.example.com/tlsca/tlsca.bloodbank.example.com-cert.pem
# Set environment variables for the peer org
setGlobals() {
  local ORG=$1
  local PEER=$2

  infoln "Using organization ${ORG} and peer ${PEER}"

  if [ "${ORG}" = "bloodcollection" ]; then
    export CORE_PEER_LOCALMSPID=bloodcollectionMSP
    export CORE_PEER_TLS_ROOTCERT_FILE=${TEST_NETWORK_HOME}/organizations/peerOrganizations/bloodcollection.example.com/peers/${PEER}.bloodcollection.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${TEST_NETWORK_HOME}/organizations/peerOrganizations/bloodcollection.example.com/users/Admin@bloodcollection.example.com/msp
    if [ "${PEER}" = "peer0" ]; then
      export CORE_PEER_ADDRESS=localhost:7051
    elif [ "${PEER}" = "peer1" ]; then
      export CORE_PEER_ADDRESS=localhost:8051
    else
      errorln "PEER Unknown"
    fi
  elif [ "${ORG}" = "bloodprocessing" ]; then
    export CORE_PEER_LOCALMSPID=bloodprocessingMSP
    export CORE_PEER_TLS_ROOTCERT_FILE=${TEST_NETWORK_HOME}/organizations/peerOrganizations/bloodprocessing.example.com/peers/${PEER}.bloodprocessing.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${TEST_NETWORK_HOME}/organizations/peerOrganizations/bloodprocessing.example.com/users/Admin@bloodprocessing.example.com/msp
    if [ "${PEER}" = "peer0" ]; then
      export CORE_PEER_ADDRESS=localhost:9051
    elif [ "${PEER}" = "peer1" ]; then
      export CORE_PEER_ADDRESS=localhost:10051
    else
      errorln "PEER Unknown"
    fi
  elif [ "${ORG}" = "bloodbank" ]; then
    export CORE_PEER_LOCALMSPID=bloodbankMSP
    export CORE_PEER_TLS_ROOTCERT_FILE=${TEST_NETWORK_HOME}/organizations/peerOrganizations/bloodbank.example.com/peers/${PEER}.bloodbank.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${TEST_NETWORK_HOME}/organizations/peerOrganizations/bloodbank.example.com/users/Admin@bloodbank.example.com/msp
    if [ "${PEER}" = "peer0" ]; then
      export CORE_PEER_ADDRESS=localhost:11051
    elif [ "${PEER}" = "peer1" ]; then
      export CORE_PEER_ADDRESS=localhost:12051
    else
      errorln "PEER Unknown"
    fi  
  else
    errorln "ORG Unknown"
  fi

  if [ "$VERBOSE" = "true" ]; then
    env | grep CORE
  fi
}

# parsePeerConnectionParameters $@
# Helper function that sets the peer connection parameters for a chaincode
# operation
parsePeerConnectionParameters() {
  PEER_CONN_PARMS=()
  PEERS=""
  while [ "$#" -gt 0 ]; do
    setGlobals $1 $2
    PEER="peer$2.$1"
    ## Set peer addresses
    if [ -z "$PEERS" ]; then
      PEERS="$PEER"
    else
      PEERS="$PEERS $PEER"
    fi
    PEER_CONN_PARMS=("${PEER_CONN_PARMS[@]}" --peerAddresses $CORE_PEER_ADDRESS)
    ## Set path to TLS certificate
    CA=PEER$2_ORG$1_CA
    TLSINFO=(--tlsRootCertFiles "${!CA}")
    PEER_CONN_PARMS=("${PEER_CONN_PARMS[@]}" "${TLSINFO[@]}")
    shift 2
  done
}

verifyResult() {
  if [ $1 -ne 0 ]; then
    fatalln "$2"
  fi
}
