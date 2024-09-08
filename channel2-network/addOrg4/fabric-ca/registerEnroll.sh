#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

function createOrg4 {
	infoln "Enrolling the CA admin"
	mkdir -p ../organizations/peerOrganizations/hospital.example.com/

	export FABRIC_CA_CLIENT_HOME=${PWD}/../organizations/peerOrganizations/hospital.example.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:11054 --caname ca-hospital --tls.certfiles "${PWD}/fabric-ca/hospital/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-hospital.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-hospital.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-hospital.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-hospital.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/../organizations/peerOrganizations/hospital.example.com/msp/config.yaml"

	infoln "Registering peer0"
  set -x
	fabric-ca-client register --caname ca-hospital --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/fabric-ca/hospital/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-hospital --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/fabric-ca/hospital/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-hospital --id.name hospitaladmin --id.secret hospitaladminpw --id.type admin --tls.certfiles "${PWD}/fabric-ca/hospital/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
	fabric-ca-client enroll -u https://peer0:peer0pw@localhost:11054 --caname ca-hospital -M "${PWD}/../organizations/peerOrganizations/hospital.example.com/peers/peer0.hospital.example.com/msp" --tls.certfiles "${PWD}/fabric-ca/hospital/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/../organizations/peerOrganizations/hospital.example.com/msp/config.yaml" "${PWD}/../organizations/peerOrganizations/hospital.example.com/peers/peer0.hospital.example.com/msp/config.yaml"

  infoln "Generating the peer1 msp"
  set -x
	fabric-ca-client enroll -u https://peer1:peer1pw@localhost:11054 --caname ca-hospital -M "${PWD}/../organizations/peerOrganizations/hospital.example.com/peers/peer1.hospital.example.com/msp" --tls.certfiles "${PWD}/fabric-ca/hospital/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/../organizations/peerOrganizations/hospital.example.com/msp/config.yaml" "${PWD}/../organizations/peerOrganizations/hospital.example.com/peers/peer1.hospital.example.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates, use --csr.hosts to specify Subject Alternative Names"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:11054 --caname ca-hospital -M "${PWD}/../organizations/peerOrganizations/hospital.example.com/peers/peer0.hospital.example.com/tls" --enrollment.profile tls --csr.hosts peer0.hospital.example.com --csr.hosts localhost --tls.certfiles "${PWD}/fabric-ca/hospital/tls-cert.pem"
  { set +x; } 2>/dev/null


  cp "${PWD}/../organizations/peerOrganizations/hospital.example.com/peers/peer0.hospital.example.com/tls/tlscacerts/"* "${PWD}/../organizations/peerOrganizations/hospital.example.com/peers/peer0.hospital.example.com/tls/ca.crt"
  cp "${PWD}/../organizations/peerOrganizations/hospital.example.com/peers/peer0.hospital.example.com/tls/signcerts/"* "${PWD}/../organizations/peerOrganizations/hospital.example.com/peers/peer0.hospital.example.com/tls/server.crt"
  cp "${PWD}/../organizations/peerOrganizations/hospital.example.com/peers/peer0.hospital.example.com/tls/keystore/"* "${PWD}/../organizations/peerOrganizations/hospital.example.com/peers/peer0.hospital.example.com/tls/server.key"

  mkdir "${PWD}/../organizations/peerOrganizations/hospital.example.com/msp/tlscacerts"
  cp "${PWD}/../organizations/peerOrganizations/hospital.example.com/peers/peer0.hospital.example.com/tls/tlscacerts/"* "${PWD}/../organizations/peerOrganizations/hospital.example.com/msp/tlscacerts/ca.crt"

  mkdir "${PWD}/../organizations/peerOrganizations/hospital.example.com/tlsca"
  cp "${PWD}/../organizations/peerOrganizations/hospital.example.com/peers/peer0.hospital.example.com/tls/tlscacerts/"* "${PWD}/../organizations/peerOrganizations/hospital.example.com/tlsca/tlsca.hospital.example.com-cert.pem"

  mkdir "${PWD}/../organizations/peerOrganizations/hospital.example.com/ca"
  cp "${PWD}/../organizations/peerOrganizations/hospital.example.com/peers/peer0.hospital.example.com/msp/cacerts/"* "${PWD}/../organizations/peerOrganizations/hospital.example.com/ca/ca.hospital.example.com-cert.pem"

  infoln "Generating the peer1-tls certificates, use --csr.hosts to specify Subject Alternative Names"
  set -x
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:11054 --caname ca-hospital -M "${PWD}/../organizations/peerOrganizations/hospital.example.com/peers/peer1.hospital.example.com/tls" --enrollment.profile tls --csr.hosts peer1.hospital.example.com --csr.hosts localhost --tls.certfiles "${PWD}/fabric-ca/hospital/tls-cert.pem"
  { set +x; } 2>/dev/null


  cp "${PWD}/../organizations/peerOrganizations/hospital.example.com/peers/peer1.hospital.example.com/tls/tlscacerts/"* "${PWD}/../organizations/peerOrganizations/hospital.example.com/peers/peer1.hospital.example.com/tls/ca.crt"
  cp "${PWD}/../organizations/peerOrganizations/hospital.example.com/peers/peer1.hospital.example.com/tls/signcerts/"* "${PWD}/../organizations/peerOrganizations/hospital.example.com/peers/peer1.hospital.example.com/tls/server.crt"
  cp "${PWD}/../organizations/peerOrganizations/hospital.example.com/peers/peer1.hospital.example.com/tls/keystore/"* "${PWD}/../organizations/peerOrganizations/hospital.example.com/peers/peer1.hospital.example.com/tls/server.key"

  mkdir "${PWD}/../organizations/peerOrganizations/hospital.example.com/msp/tlscacerts"
  cp "${PWD}/../organizations/peerOrganizations/hospital.example.com/peers/peer1.hospital.example.com/tls/tlscacerts/"* "${PWD}/../organizations/peerOrganizations/hospital.example.com/msp/tlscacerts/ca.crt"

  mkdir "${PWD}/../organizations/peerOrganizations/hospital.example.com/tlsca"
  cp "${PWD}/../organizations/peerOrganizations/hospital.example.com/peers/peer1.hospital.example.com/tls/tlscacerts/"* "${PWD}/../organizations/peerOrganizations/hospital.example.com/tlsca/tlsca.hospital.example.com-cert.pem"

  mkdir "${PWD}/../organizations/peerOrganizations/hospital.example.com/ca"
  cp "${PWD}/../organizations/peerOrganizations/hospital.example.com/peers/peer1.hospital.example.com/msp/cacerts/"* "${PWD}/../organizations/peerOrganizations/hospital.example.com/ca/ca.hospital.example.com-cert.pem"

  infoln "Generating the user msp"
  set -x
	fabric-ca-client enroll -u https://user1:user1pw@localhost:11054 --caname ca-hospital -M "${PWD}/../organizations/peerOrganizations/hospital.example.com/users/User1@hospital.example.com/msp" --tls.certfiles "${PWD}/fabric-ca/hospital/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/../organizations/peerOrganizations/hospital.example.com/msp/config.yaml" "${PWD}/../organizations/peerOrganizations/hospital.example.com/users/User1@hospital.example.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
	fabric-ca-client enroll -u https://hospitaladmin:hospitaladminpw@localhost:11054 --caname ca-hospital -M "${PWD}/../organizations/peerOrganizations/hospital.example.com/users/Admin@hospital.example.com/msp" --tls.certfiles "${PWD}/fabric-ca/hospital/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/../organizations/peerOrganizations/hospital.example.com/msp/config.yaml" "${PWD}/../organizations/peerOrganizations/hospital.example.com/users/Admin@hospital.example.com/msp/config.yaml"
}
