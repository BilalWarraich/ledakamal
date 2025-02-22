#!/bin/bash

function one_line_pem {
    echo "`awk 'NF {sub(/\\n/, ""); printf "%s\\\\\\\n",$0;}' $1`"
}

function json_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        organizations/ccp-template.json
}

function yaml_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        organizations/ccp-template.yaml | sed -e $'s/\\\\n/\\\n          /g'
}

ORG=1
P0PORT=7051
CAPORT=7054
PEERPEM=organizations/peerOrganizations/bloodcollection.example.com/tlsca/tlsca.bloodcollection.example.com-cert.pem
CAPEM=organizations/peerOrganizations/bloodcollection.example.com/ca/ca.bloodcollection.example.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/bloodcollection.example.com/connection-bloodcollection.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/bloodcollection.example.com/connection-bloodcollection.yaml

ORG=2
P0PORT=9051
CAPORT=8054
PEERPEM=organizations/peerOrganizations/bloodprocessing.example.com/tlsca/tlsca.bloodprocessing.example.com-cert.pem
CAPEM=organizations/peerOrganizations/bloodprocessing.example.com/ca/ca.bloodprocessing.example.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/bloodprocessing.example.com/connection-bloodprocessing.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/bloodprocessing.example.com/connection-bloodprocessing.yaml

ORG=3
P0PORT=10051
CAPORT=8054
PEERPEM=organizations/peerOrganizations/bloodbank.example.com/tlsca/tlsca.bloodbank.example.com-cert.pem
CAPEM=organizations/peerOrganizations/bloodbank.example.com/ca/ca.bloodbank.example.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/bloodbank.example.com/connection-bloodbank.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/bloodbank.example.com/connection-bloodbank.yaml

ORG=4
P0PORT=11051
CAPORT=8054
PEERPEM=organizations/peerOrganizations/hospitals.example.com/tlsca/tlsca.hospitals.example.com-cert.pem
CAPEM=organizations/peerOrganizations/hospitals.example.com/ca/ca.hospitals.example.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/hospitals.example.com/connection-hospitals.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/hospitals.example.com/connection-hospitals.yaml

ORG=5
P0PORT=12051
CAPORT=8054
PEERPEM=organizations/peerOrganizations/transportation.example.com/tlsca/tlsca.transportation.example.com-cert.pem
CAPEM=organizations/peerOrganizations/transportation.example.com/ca/ca.transportation.example.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/transportation.example.com/connection-transportation.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/transportation.example.com/connection-transportation.yaml
