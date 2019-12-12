#!/usr/bin/env bash

OCP_HOST=""

OCP_AUTH_TYPE="userpass"

OCP_USERNAME=""
OCP_PASSWORD=""
OCP_TOKEN=""

OCP_CREATE_PROJECT="true"
OCP_PROJECT_NAME="automation-ansible-tower"

TOWER_DEPLOY_EXAMPLE_CONFIG="true"

TMP_WORKING_DIR="/tmp/oc-tower-deployer"



ROCKET_CHAT_ROUTE=""
ROCKET_CHAT_ROUTE_EDGE_TLS="true"
RH_RHN=""
RH_EMAIL=""
RH_PASSWORD=""
RC_ADMIN_USERNAME="rcadmin"
RC_ADMIN_PASS="sup3rs3cr3t"
RC_ADMIN_EMAIL="you@example.com"

## Do not edit past this line

INTERACTIVE="false"

if [ $OCP_AUTH_TYPE == "userpass" ]; then
    OCP_AUTH="-u $OCP_USERNAME -p $OCP_PASSWORD"
fi
if [ $OCP_AUTH_TYPE == "token" ]; then
    OCP_AUTH="--token=$OCP_TOKEN"
fi