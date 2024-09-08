#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

function createOrg3 {
	infoln "Enrolling the CA admin"
	mkdir -p ../organizations/peerOrganizations/bloodbank.example.com/

	export FABRIC_CA_CLIENT_HOME=${PWD}/../organizations/peerOrganizations/bloodbank.example.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:11054 --caname ca-bloodbank --tls.certfiles "${PWD}/fabric-ca/bloodbank/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-bloodbank.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-bloodbank.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-bloodbank.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-bloodbank.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/../organizations/peerOrganizations/bloodbank.example.com/msp/config.yaml"

	infoln "Registering peer0"
  set -x
	fabric-ca-client register --caname ca-bloodbank --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/fabric-ca/bloodbank/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-bloodbank --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/fabric-ca/bloodbank/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-bloodbank --id.name bloodbankadmin --id.secret bloodbankadminpw --id.type admin --tls.certfiles "${PWD}/fabric-ca/bloodbank/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
	fabric-ca-client enroll -u https://peer0:peer0pw@localhost:11054 --caname ca-bloodbank -M "${PWD}/../organizations/peerOrganizations/bloodbank.example.com/peers/peer0.bloodbank.example.com/msp" --tls.certfiles "${PWD}/fabric-ca/bloodbank/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/../organizations/peerOrganizations/bloodbank.example.com/msp/config.yaml" "${PWD}/../organizations/peerOrganizations/bloodbank.example.com/peers/peer0.bloodbank.example.com/msp/config.yaml"

  infoln "Generating the peer1 msp"
  set -x
	fabric-ca-client enroll -u https://peer1:peer1pw@localhost:11054 --caname ca-bloodbank -M "${PWD}/../organizations/peerOrganizations/bloodbank.example.com/peers/peer1.bloodbank.example.com/msp" --tls.certfiles "${PWD}/fabric-ca/bloodbank/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/../organizations/peerOrganizations/bloodbank.example.com/msp/config.yaml" "${PWD}/../organizations/peerOrganizations/bloodbank.example.com/peers/peer1.bloodbank.example.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates, use --csr.hosts to specify Subject Alternative Names"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:11054 --caname ca-bloodbank -M "${PWD}/../organizations/peerOrganizations/bloodbank.example.com/peers/peer0.bloodbank.example.com/tls" --enrollment.profile tls --csr.hosts peer0.bloodbank.example.com --csr.hosts localhost --tls.certfiles "${PWD}/fabric-ca/bloodbank/tls-cert.pem"
  { set +x; } 2>/dev/null


  cp "${PWD}/../organizations/peerOrganizations/bloodbank.example.com/peers/peer0.bloodbank.example.com/tls/tlscacerts/"* "${PWD}/../organizations/peerOrganizations/bloodbank.example.com/peers/peer0.bloodbank.example.com/tls/ca.crt"
  cp "${PWD}/../organizations/peerOrganizations/bloodbank.example.com/peers/peer0.bloodbank.example.com/tls/signcerts/"* "${PWD}/../organizations/peerOrganizations/bloodbank.example.com/peers/peer0.bloodbank.example.com/tls/server.crt"
  cp "${PWD}/../organizations/peerOrganizations/bloodbank.example.com/peers/peer0.bloodbank.example.com/tls/keystore/"* "${PWD}/../organizations/peerOrganizations/bloodbank.example.com/peers/peer0.bloodbank.example.com/tls/server.key"

  mkdir "${PWD}/../organizations/peerOrganizations/bloodbank.example.com/msp/tlscacerts"
  cp "${PWD}/../organizations/peerOrganizations/bloodbank.example.com/peers/peer0.bloodbank.example.com/tls/tlscacerts/"* "${PWD}/../organizations/peerOrganizations/bloodbank.example.com/msp/tlscacerts/ca.crt"

  mkdir "${PWD}/../organizations/peerOrganizations/bloodbank.example.com/tlsca"
  cp "${PWD}/../organizations/peerOrganizations/bloodbank.example.com/peers/peer0.bloodbank.example.com/tls/tlscacerts/"* "${PWD}/../organizations/peerOrganizations/bloodbank.example.com/tlsca/tlsca.bloodbank.example.com-cert.pem"

  mkdir "${PWD}/../organizations/peerOrganizations/bloodbank.example.com/ca"
  cp "${PWD}/../organizations/peerOrganizations/bloodbank.example.com/peers/peer0.bloodbank.example.com/msp/cacerts/"* "${PWD}/../organizations/peerOrganizations/bloodbank.example.com/ca/ca.bloodbank.example.com-cert.pem"

  infoln "Generating the peer1-tls certificates, use --csr.hosts to specify Subject Alternative Names"
  set -x
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:11054 --caname ca-bloodbank -M "${PWD}/../organizations/peerOrganizations/bloodbank.example.com/peers/peer1.bloodbank.example.com/tls" --enrollment.profile tls --csr.hosts peer1.bloodbank.example.com --csr.hosts localhost --tls.certfiles "${PWD}/fabric-ca/bloodbank/tls-cert.pem"
  { set +x; } 2>/dev/null


  cp "${PWD}/../organizations/peerOrganizations/bloodbank.example.com/peers/peer1.bloodbank.example.com/tls/tlscacerts/"* "${PWD}/../organizations/peerOrganizations/bloodbank.example.com/peers/peer1.bloodbank.example.com/tls/ca.crt"
  cp "${PWD}/../organizations/peerOrganizations/bloodbank.example.com/peers/peer1.bloodbank.example.com/tls/signcerts/"* "${PWD}/../organizations/peerOrganizations/bloodbank.example.com/peers/peer1.bloodbank.example.com/tls/server.crt"
  cp "${PWD}/../organizations/peerOrganizations/bloodbank.example.com/peers/peer1.bloodbank.example.com/tls/keystore/"* "${PWD}/../organizations/peerOrganizations/bloodbank.example.com/peers/peer1.bloodbank.example.com/tls/server.key"

  mkdir "${PWD}/../organizations/peerOrganizations/bloodbank.example.com/msp/tlscacerts"
  cp "${PWD}/../organizations/peerOrganizations/bloodbank.example.com/peers/peer1.bloodbank.example.com/tls/tlscacerts/"* "${PWD}/../organizations/peerOrganizations/bloodbank.example.com/msp/tlscacerts/ca.crt"

  mkdir "${PWD}/../organizations/peerOrganizations/bloodbank.example.com/tlsca"
  cp "${PWD}/../organizations/peerOrganizations/bloodbank.example.com/peers/peer1.bloodbank.example.com/tls/tlscacerts/"* "${PWD}/../organizations/peerOrganizations/bloodbank.example.com/tlsca/tlsca.bloodbank.example.com-cert.pem"

  mkdir "${PWD}/../organizations/peerOrganizations/bloodbank.example.com/ca"
  cp "${PWD}/../organizations/peerOrganizations/bloodbank.example.com/peers/peer1.bloodbank.example.com/msp/cacerts/"* "${PWD}/../organizations/peerOrganizations/bloodbank.example.com/ca/ca.bloodbank.example.com-cert.pem"

  infoln "Generating the user msp"
  set -x
	fabric-ca-client enroll -u https://user1:user1pw@localhost:11054 --caname ca-bloodbank -M "${PWD}/../organizations/peerOrganizations/bloodbank.example.com/users/User1@bloodbank.example.com/msp" --tls.certfiles "${PWD}/fabric-ca/bloodbank/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/../organizations/peerOrganizations/bloodbank.example.com/msp/config.yaml" "${PWD}/../organizations/peerOrganizations/bloodbank.example.com/users/User1@bloodbank.example.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
	fabric-ca-client enroll -u https://bloodbankadmin:bloodbankadminpw@localhost:11054 --caname ca-bloodbank -M "${PWD}/../organizations/peerOrganizations/bloodbank.example.com/users/Admin@bloodbank.example.com/msp" --tls.certfiles "${PWD}/fabric-ca/bloodbank/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/../organizations/peerOrganizations/bloodbank.example.com/msp/config.yaml" "${PWD}/../organizations/peerOrganizations/bloodbank.example.com/users/Admin@bloodbank.example.com/msp/config.yaml"
}
