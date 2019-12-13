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

CONFIGURE_TOWER_LDAP="false"
TOWER_LDAP_DOMAIN_REALM="EXAMPLE.COM"
TOWER_LDAP_SERVER_URI="ldaps://idm.example.com:636"
TOWER_LDAP_BIND_DN="cn=Directory Manager"
TOWER_LDAP_BIND_PASSWORD=""
TOWER_LDAP_USER_ATTR_MAP='{"first_name": "givenName", "last_name": "sn", "email": "mail"}'
TOWER_LDAP_GROUP_TYPE="NestedMemberDNGroupType"
TOWER_LDAP_GROUP_TYPE_PARAMS='{"name_attr": "cn", "member_attr": "member"}'

## Do not edit past this line

INTERACTIVE="false"

if [ $OCP_AUTH_TYPE == "userpass" ]; then
    OCP_AUTH="-u $OCP_USERNAME -p $OCP_PASSWORD"
fi
if [ $OCP_AUTH_TYPE == "token" ]; then
    OCP_AUTH="--token=$OCP_TOKEN"
fi

TOWER_LDAP_DC_BASE=$(returnDC $TOWER_LDAP_DOMAIN_REALM)
TOWER_LDAP_USER_SEARCH="[\"cn=groups,"$(echo $TOWER_LDAP_DC_BASE)"\", \"SCOPE_SUBTREE\", \"(uid=%(user)s)\"]"
TOWER_LDAP_USER_DN_TEMPLATE="uid=%(user)s,cn=users,cn=accounts,${TOWER_LDAP_DC_BASE}"
TOWER_LDAP_GROUP_SEARCH="[\"cn=groups,cn=accounts,"$(echo $TOWER_LDAP_DC_BASE)"\", \"SCOPE_SUBTREE\", \"(objectClass=groupOfNames)\"]"
TOWER_LDAP_USER_FLAGS_BY_GROUP="{ \"is_superuser\": [ \"cn=admins,cn=groups,cn=accounts,"$(echo $TOWER_LDAP_DC_BASE)"\" ] }"
TOWER_LDAP_ORGANIZATION_MAP="{ \"Default\": { \"users\": \"cn=ipausers,cn=groups,cn=accounts,"$(echo $TOWER_LDAP_DC_BASE)"\", \"admins\": \"cn=admins,cn=groups,cn=accounts,"$(echo $TOWER_LDAP_DC_BASE)"\", \"remove_users\": false, \"remove_admins\": false } }"