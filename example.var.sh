#!/usr/bin/env bash

OCP_HOST=""

OCP_AUTH_TYPE="userpass"
OC_ARG_OPTIONS=""

OCP_USERNAME=""
OCP_PASSWORD=""
OCP_TOKEN=""

OCP_CREATE_PROJECT="true"
OCP_PROJECT_NAME="automation-ansible-tower"

ANSIBLE_TOWER_ADMIN_USERNAME="towerAdmin"
ANSIBLE_TOWER_ADMIN_PASSWORD=""

ANSIBLE_TOWER_PERFORM_CONFIGURATION="true"

TMP_WORKING_DIR="/tmp/oc-tower-deployer"
ANSIBLE_TOWER_SECRET_KEY=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

POSTGRES_USERNAME="towerpg"
POSTGRES_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
POSTGRES_DATABASE="tower"

RABBITMQ_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
RABBITMQ_ERLANG_COOKIE=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

## Do not edit past this line

INTERACTIVE="false"

if [ $OCP_AUTH_TYPE == "userpass" ]; then
    OCP_AUTH="-u $OCP_USERNAME -p $OCP_PASSWORD"
fi
if [ $OCP_AUTH_TYPE == "token" ]; then
    OCP_AUTH="--token=$OCP_TOKEN"
fi