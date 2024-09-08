#!/bin/bash

# imports  
. scripts/envVar.sh

CHANNEL_NAME="$1"
DELAY="$2"
MAX_RETRY="$3"
VERBOSE="$4"
BFT="$5"
: ${CHANNEL_NAME:="bloodchannel1"}
: ${DELAY:="3"}
: ${MAX_RETRY:="5"}
: ${VERBOSE:="false"}
: ${BFT:=0}

: ${CONTAINER_CLI:="docker"}
if command -v ${CONTAINER_CLI}-compose > /dev/null 2>&1; then
    : ${CONTAINER_CLI_COMPOSE:="${CONTAINER_CLI}-compose"}
else
    : ${CONTAINER_CLI_COMPOSE:="${CONTAINER_CLI} compose"}
fi
infoln "Using ${CONTAINER_CLI} and ${CONTAINER_CLI_COMPOSE}"

if [ ! -d "channel-artifacts" ]; then
	mkdir channel-artifacts
fi

createChannelGenesisBlock() {
  setGlobals 1
	which configtxgen
	if [ "$?" -ne 0 ]; then
		fatalln "configtxgen tool not found."
	fi
	local bft_true=$1
	set -x

	if [ $bft_true -eq 1 ]; then
		configtxgen -profile ChannelUsingBFT -outputBlock ./channel-artifacts/${CHANNEL_NAME}.block -channelID $CHANNEL_NAME
	else
		configtxgen -profile ChannelUsingRaft -outputBlock ./channel-artifacts/${CHANNEL_NAME}.block -channelID $CHANNEL_NAME
	fi
	res=$?
	{ set +x; } 2>/dev/null
  verifyResult $res "Failed to generate channel configuration transaction..."
}

createChannelTx() {
  local CHANNEL_NAME=$1
  infoln "Generating channel configuration transaction '${CHANNEL_NAME}.tx'"
  configtxgen -profile ${CHANNEL_NAME} -outputCreateChannelTx ./channel-artifacts/${CHANNEL_NAME}.tx -channelID $CHANNEL_NAME
  verifyResult $? "Failed to generate channel configuration transaction..."
}

createChannelBlock() {
  local CHANNEL_NAME=$1
  infoln "Creating channel genesis block '${CHANNEL_NAME}.block'"
  setGlobals 1
  set -x
  peer channel create -o localhost:7050 -c $CHANNEL_NAME -f ./channel-artifacts/${CHANNEL_NAME}.tx --outputBlock ./channel-artifacts/${CHANNEL_NAME}.block --tls --cafile $ORDERER_CA >&log.txt
  res=$?
  { set +x; } 2>/dev/null
  verifyResult $res "Channel creation failed"
}

createChannel() {
  # Create and join BloodChannel1
  CHANNEL_NAME="bloodchannel1"
  infoln "Creating channel $CHANNEL_NAME"
  createChannelTx $CHANNEL_NAME
  createChannelBlock $CHANNEL_NAME
  joinChannel $CHANNEL_NAME "BloodCollection" "BloodProcessing" "BloodBank"

  # Create and join BloodChannel2
  CHANNEL2_NAME="bloodchannel2"
  infoln "Creating channel $CHANNEL2_NAME"
  createChannelTx $CHANNEL2_NAME
  createChannelBlock $CHANNEL2_NAME
  joinChannel $CHANNEL2_NAME "BloodBank" "Hospitals" "Transportation"
}

joinChannel() {
  CHANNEL=$1
  shift
  ORGS=("$@")
  for ORG in "${ORGS[@]}"; do
    for PEER in 0 1; do  # Iterate over peer0 and peer1
      joinChannelWithRetry $PEER $CHANNEL $ORG
      infoln "Peer${PEER}.${ORG} joined channel '$CHANNEL'"
      sleep $DELAY
    done
  done
}

joinChannelWithRetry() {
  PEER=$1
  CHANNEL=$2
  ORG=$3
  setGlobals $PEER $ORG

  set -x
  peer channel join -b ./channel-artifacts/${CHANNEL}.block >&log.txt
  res=$?
  { set +x; } 2>/dev/null
  if [ $res -ne 0 ]; then
    if [ $COUNTER -lt $MAX_RETRY ]; then
      COUNTER=$(expr $COUNTER + 1)
      infoln "PEER$PEER.${ORG} failed to join the channel, Retry after $DELAY seconds"
      sleep $DELAY
      joinChannelWithRetry $PEER $CHANNEL $ORG
    else
      fatalln "After $MAX_RETRY attempts, PEER$PEER.${ORG} has failed to join channel '$CHANNEL' "
    fi
  fi
  COUNTER=1
}

setAnchorPeer() {
  ORG=$1
  CHANNEL_NAME=$2
  infoln "Setting anchor peer for org${ORG} in channel ${CHANNEL_NAME}"
  setGlobals 0 $ORG
  peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c $CHANNEL_NAME -f ./channel-artifacts/${ORG}MSPanchors.tx --tls --cafile $ORDERER_CA >&log.txt
  verifyResult $? "Anchor peer update failed"
  successln "Anchor peer set for org${ORG} in channel ${CHANNEL_NAME}"
}

## Start the channel creation and joining process
createChannel

successln "All channels created and peers joined successfully"

