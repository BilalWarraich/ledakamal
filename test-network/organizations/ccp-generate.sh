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

ORG=bloodcollection
P0PORT=7051
CAPORT=7054
PEERPEM=organizations/peerOrganizations/bloodcollection.example.com/tlsca/tlsca.bloodcollection.example.com-cert.pem
CAPEM=organizations/peerOrganizations/bloodcollection.example.com/ca/ca.bloodcollection.example.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/bloodcollection.example.com/connection-bloodcollection.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/bloodcollection.example.com/connection-bloodcollection.yaml

ORG=bloodprocessing
P0PORT=9051
CAPORT=8054
PEERPEM=organizations/peerOrganizations/bloodprocessing.example.com/tlsca/tlsca.bloodprocessing.example.com-cert.pem
CAPEM=organizations/peerOrganizations/bloodprocessing.example.com/ca/ca.bloodprocessing.example.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/bloodprocessing.example.com/connection-bloodprocessing.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/bloodprocessing.example.com/connection-bloodprocessing.yaml
