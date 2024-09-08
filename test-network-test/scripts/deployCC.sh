#!/bin/bash

source scripts/utils.sh

CHANNEL_NAME=${1:-"mychannel"}
CC_NAME=${2}
CC_SRC_PATH=${3}
CC_SRC_LANGUAGE=${4}
CC_VERSION=${5:-"1.0"}
CC_SEQUENCE=${6:-"1"}
CC_INIT_FCN=${7:-"NA"}
CC_END_POLICY=${8:-"NA"}
CC_COLL_CONFIG=${9:-"NA"}
DELAY=${10:-"3"}
MAX_RETRY=${11:-"5"}
VERBOSE=${12:-"false"}

println "executing with the following"
println "- CHANNEL_NAME: ${C_GREEN}${CHANNEL_NAME}${C_RESET}"
println "- CC_NAME: ${C_GREEN}${CC_NAME}${C_RESET}"
println "- CC_SRC_PATH: ${C_GREEN}${CC_SRC_PATH}${C_RESET}"
println "- CC_SRC_LANGUAGE: ${C_GREEN}${CC_SRC_LANGUAGE}${C_RESET}"
println "- CC_VERSION: ${C_GREEN}${CC_VERSION}${C_RESET}"
println "- CC_SEQUENCE: ${C_GREEN}${CC_SEQUENCE}${C_RESET}"
println "- CC_END_POLICY: ${C_GREEN}${CC_END_POLICY}${C_RESET}"
println "- CC_COLL_CONFIG: ${C_GREEN}${CC_COLL_CONFIG}${C_RESET}"
println "- CC_INIT_FCN: ${C_GREEN}${CC_INIT_FCN}${C_RESET}"
println "- DELAY: ${C_GREEN}${DELAY}${C_RESET}"
println "- MAX_RETRY: ${C_GREEN}${MAX_RETRY}${C_RESET}"
println "- VERBOSE: ${C_GREEN}${VERBOSE}${C_RESET}"

INIT_REQUIRED="--init-required"
# check if the init fcn should be called
if [ "$CC_INIT_FCN" = "NA" ]; then
  INIT_REQUIRED=""
fi

if [ "$CC_END_POLICY" = "NA" ]; then
  CC_END_POLICY=""
else
  CC_END_POLICY="--signature-policy $CC_END_POLICY"
fi

if [ "$CC_COLL_CONFIG" = "NA" ]; then
  CC_COLL_CONFIG=""
else
  CC_COLL_CONFIG="--collections-config $CC_COLL_CONFIG"
fi

FABRIC_CFG_PATH=$PWD/../config/

# import utils
. scripts/envVar.sh
. scripts/ccutils.sh

function checkPrereqs() {
  jq --version > /dev/null 2>&1

  if [[ $? -ne 0 ]]; then
    errorln "jq command not found..."
    errorln
    errorln "Follow the instructions in the Fabric docs to install the prereqs"
    errorln "https://hyperledger-fabric.readthedocs.io/en/latest/prereqs.html"
    exit 1
  fi
}

# Check for prerequisites
checkPrereqs

# Define deployCC function to handle different channels and organizations
deployCC() {
  CHANNEL_NAME=$1
  infoln "Deploying chaincode on channel '$CHANNEL_NAME'"

  if [ "$CHANNEL_NAME" == "bloodchannel1" ]; then
    ORGS=("BloodCollection" "BloodProcessing" "BloodBank")
  elif [ "$CHANNEL_NAME" == "bloodchannel2" ]; then
    ORGS=("BloodBank" "Hospitals" "Transportation")
  else
    errorln "Unknown channel: $CHANNEL_NAME"
    exit 1
  fi

  for ORG in "${ORGS[@]}"; do
    infoln "Packaging chaincode for ${ORG}..."
    ./scripts/packageCC.sh $CC_NAME $CC_SRC_PATH $CC_SRC_LANGUAGE $CC_VERSION

    infoln "Installing chaincode on $ORG..."
    installChaincode $ORG

    infoln "Querying whether the chaincode is installed on $ORG..."
    queryInstalled $ORG

    infoln "Approving chaincode definition for $ORG..."
    approveForMyOrg $ORG

    infoln "Checking commit readiness for $ORG..."
    checkCommitReadiness $ORG "\"${ORG}MSP\": true"
  done

  infoln "Committing chaincode definition on ${CHANNEL_NAME}..."
  commitChaincodeDefinition "${ORGS[@]}"

  for ORG in "${ORGS[@]}"; do
    infoln "Querying committed chaincode on $ORG..."
    queryCommitted $ORG
  done

  # Invoke the chaincode if necessary
  if [ "$CC_INIT_FCN" != "NA" ]; then
    infoln "Initializing chaincode on ${CHANNEL_NAME}..."
    chaincodeInvokeInit "${ORGS[@]}"
  else
    infoln "Chaincode initialization is not required"
  fi
}

# Deploy the chaincode on the specified channel
deployCC $CHANNEL_NAME

exit 0

