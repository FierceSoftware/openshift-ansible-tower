#!/bin/bash

## set -x	## Uncomment for debugging


function checkForProgram() {
  command -v $1
  if [[ $? -eq 0 ]]; then
    printf '%-72s %-7s\n' $1 "PASSED!";
  else
    printf '%-72s %-7s\n' $1 "FAILED!";
    exit 1
  fi
}

function returnDC() {
    TOWER_LDAP_DC=""
    for i in $(echo $1 | tr "." "\n")
    do
        TOWER_LDAP_DC="${TOWER_LDAP_DC},dc=$i"
    done
    echo ${TOWER_LDAP_DC#?}
}

FILE=./vars.sh
if [ -f "$FILE" ]; then
    source ./vars.sh
fi

## Default variables to use
export INTERACTIVE=${INTERACTIVE:="true"}
export OCP_HOST=${OCP_HOST:=""}
## userpass or token
export OCP_AUTH_TYPE=${OCP_AUTH_TYPE:="userpass"}
export OCP_USERNAME=${OCP_USERNAME:=""}
export OCP_PASSWORD=${OCP_PASSWORD:=""}
export OCP_TOKEN=${OCP_TOKEN:=""}
export OCP_AUTH=${OCP_AUTH:=""}
export OC_ARG_OPTIONS=${OC_ARG_OPTIONS:=""}

export OCP_CREATE_PROJECT=${OCP_CREATE_PROJECT:="true"}
export OCP_PROJECT_NAME=${OCP_PROJECT_NAME:="automation-ansible-tower"}

export ANSIBLE_TOWER_ADMIN_USERNAME=${ANSIBLE_TOWER_ADMIN_USERNAME:="towerAdmin"}
export ANSIBLE_TOWER_ADMIN_PASSWORD=${ANSIBLE_TOWER_ADMIN_PASSWORD:=""}
export ANSIBLE_TOWER_PERFORM_CONFIGURATION=${ANSIBLE_TOWER_PERFORM_CONFIGURATION:="true"}

export TMP_WORKING_DIR=${TMP_WORKING_DIR:="/tmp/oc-tower-deployer"}
export ANSIBLE_TOWER_SECRET_KEY=${ANSIBLE_TOWER_SECRET_KEY:=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)}

export POSTGRES_USERNAME=${POSTGRES_USERNAME:="towerpg"}
export POSTGRES_PASSWORD=${POSTGRES_PASSWORD:=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)}
export POSTGRES_DATABASE=${POSTGRES_DATABASE:="tower"}

export RABBITMQ_PASSWORD=${RABBITMQ_PASSWORD:=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)}
export RABBITMQ_ERLANG_COOKIE=${RABBITMQ_ERLANG_COOKIE:=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)}

export CONFIGURE_TOWER_LDAP=${CONFIGURE_TOWER_LDAP:="false"}
export TOWER_LDAP_DOMAIN_REALM=${TOWER_LDAP_DOMAIN_REALM:="EXAMPLE.COM"}
export TOWER_LDAP_SERVER_URI=${TOWER_LDAP_SERVER_URI:="ldaps://idm.example.com:636"}
export TOWER_LDAP_BIND_DN=${TOWER_LDAP_BIND_DN:="cn=Directory Manager"}
export TOWER_LDAP_BIND_PASSWORD=${TOWER_LDAP_BIND_PASSWORD:=""}
export TOWER_LDAP_USER_ATTR_MAP=${TOWER_LDAP_USER_ATTR_MAP:='{"first_name": "givenName", "last_name": "sn", "email": "mail"}'}
export TOWER_LDAP_GROUP_TYPE=${TOWER_LDAP_GROUP_TYPE:="NestedMemberDNGroupType"}
export TOWER_LDAP_GROUP_TYPE_PARAMS=${TOWER_LDAP_GROUP_TYPE_PARAMS:='{"name_attr": "cn", "member_attr": "member"}'}

echo -e "\n\n================================================================================"
echo -e "Starting Ansible Tower on Red Hat OpenShift Deployer...\n"
echo -e "\n\n================================================================================"
echo -e "Checking prerequisites...\n"

checkForProgram ansible
checkForProgram ansible-playbook
checkForProgram curl
checkForProgram jq
checkForProgram oc
checkForProgram pip3

echo -e "\n\n"

## Make the script interactive to set the variables
if [ "$INTERACTIVE" == "true" ]; then
	read -rp "OpenShift Cluster Host http(s)://ocp.example.com: ($OCP_HOST): " choice;
	if [ "$choice" != "" ] ; then
		export OCP_HOST="$choice";
	fi

	read -rp "OpenShift Auth Type [userpass or token]: ($OCP_AUTH_TYPE): " choice;
	if [ "$choice" != "" ] ; then
		export OCP_AUTH_TYPE="$choice";
	fi

    if [ "$OCP_AUTH_TYPE" = "userpass" ]; then

        read -rp "OpenShift Username: ($OCP_USERNAME): " choice;
        if [ "$choice" != "" ] ; then
            export OCP_USERNAME="$choice";
        fi

        read -rsp "OpenShift Password: " choice;
        if [ "$choice" != "" ] ; then
            export OCP_PASSWORD="$choice";
        fi
        echo -e ""

        OCP_AUTH="-u $OCP_USERNAME -p $OCP_PASSWORD"

    fi

    if [ "$OCP_AUTH_TYPE" = "token" ]; then

        read -rp "OpenShift Token: ($OCP_TOKEN): " choice;
        if [ "$choice" != "" ] ; then
            export OCP_TOKEN="$choice";
        fi

        OCP_AUTH="--token=$OCP_TOKEN"

    fi

	read -rp "Create OpenShift Project? (true/false) ($OCP_CREATE_PROJECT): " choice;
	if [ "$choice" != "" ] ; then
		export OCP_CREATE_PROJECT="$choice";
	fi

	read -rp "OpenShift Project Name ($OCP_PROJECT_NAME): " choice;
	if [ "$choice" != "" ] ; then
		export OCP_PROJECT_NAME="$choice";
	fi

    read -rp "Ansible Tower Admin Username: ($ANSIBLE_TOWER_ADMIN_USERNAME): " choice;
    if [ "$choice" != "" ] ; then
        export ANSIBLE_TOWER_ADMIN_USERNAME="$choice";
    fi

    read -rsp "Ansible Tower Admin Password: " choice;
    if [ "$choice" != "" ] ; then
        export ANSIBLE_TOWER_ADMIN_PASSWORD="$choice";
    fi
    echo -e ""

	read -rp "Perform Tower Configuration? (true/false) ($ANSIBLE_TOWER_PERFORM_CONFIGURATION): " choice;
	if [ "$choice" != "" ] ; then
		export ANSIBLE_TOWER_PERFORM_CONFIGURATION="$choice";
	fi

	read -rp "Configure LDAP? (true/false) ($CONFIGURE_TOWER_LDAP): " choice;
	if [ "$choice" != "" ] ; then
		export CONFIGURE_TOWER_LDAP="$choice";
	fi

    if [ "$CONFIGURE_TOWER_LDAP" = "true" ]; then

        read -rp "LDAP Domain Realm ($TOWER_LDAP_DOMAIN_REALM): " choice;
        if [ "$choice" != "" ] ; then
            export TOWER_LDAP_DOMAIN_REALM="$choice";
        fi

        read -rp "LDAP Server URI ($TOWER_LDAP_SERVER_URI): " choice;
        if [ "$choice" != "" ] ; then
            export TOWER_LDAP_SERVER_URI="$choice";
        fi

        read -rp "LDAP Bind DN ($TOWER_LDAP_BIND_DN): " choice;
        if [ "$choice" != "" ] ; then
            export TOWER_LDAP_BIND_DN="$choice";
        fi

        read -rsp "LDAP Bind DN Password ($TOWER_LDAP_BIND_PASSWORD): " choice;
        if [ "$choice" != "" ] ; then
            export TOWER_LDAP_BIND_PASSWORD="$choice";
        fi
        echo -e ""

        export TOWER_LDAP_DC_BASE=${TOWER_LDAP_DC_BASE:=$(returnDC $TOWER_LDAP_DOMAIN_REALM)}
        export TOWER_LDAP_USER_SEARCH=${TOWER_LDAP_USER_SEARCH:="[\"cn=groups,"$(echo $TOWER_LDAP_DC_BASE)"\", \"SCOPE_SUBTREE\", \"(uid=%(user)s)\"]"}
        export TOWER_LDAP_USER_DN_TEMPLATE=${TOWER_LDAP_USER_DN_TEMPLATE:="uid=%(user)s,cn=users,cn=accounts,${TOWER_LDAP_DC_BASE}"}
        export TOWER_LDAP_GROUP_SEARCH=${TOWER_LDAP_GROUP_SEARCH:="[\"cn=groups,cn=accounts,"$(echo $TOWER_LDAP_DC_BASE)"\", \"SCOPE_SUBTREE\", \"(objectClass=groupOfNames)\"]"}
        export TOWER_LDAP_USER_FLAGS_BY_GROUP=${TOWER_LDAP_USER_FLAGS_BY_GROUP:="{ \"is_superuser\": [ \"cn=admins,cn=groups,cn=accounts,"$(echo $TOWER_LDAP_DC_BASE)"\" ] }"}
        export TOWER_LDAP_ORGANIZATION_MAP=${TOWER_LDAP_ORGANIZATION_MAP:="{ \"Default\": { \"users\": \"cn=ipausers,cn=groups,cn=accounts,"$(echo $TOWER_LDAP_DC_BASE)"\", \"admins\": \"cn=admins,cn=groups,cn=accounts,"$(echo $TOWER_LDAP_DC_BASE)"\", \"remove_users\": false, \"remove_admins\": false } }"}

    fi
fi

## Log in
echo -e "\n\n================================================================================"
echo -e "Log in to OpenShift...\n"
oc $OC_ARG_OPTIONS login $OCP_HOST $OCP_AUTH

## Create/Use Project
echo -e "\n================================================================================"
echo -e "Create/Set Project...\n"
if [ "$OCP_CREATE_PROJECT" = "true" ]; then
    oc $OC_ARG_OPTIONS new-project $OCP_PROJECT_NAME --description="Automation with Red Hat Ansible Tower" --display-name="[Shared] Ansible Tower"
fi
if [ "$OCP_CREATE_PROJECT" = "false" ]; then
    oc $OC_ARG_OPTIONS project $OCP_PROJECT_NAME
fi

## Create temp dir
echo -e "\n\n================================================================================"
echo -e "\n Creating temporary working environment..."
rm -rf $TMP_WORKING_DIR
mkdir -p $TMP_WORKING_DIR
cd $TMP_WORKING_DIR

## Download latest Tower package
echo -e "\n================================================================================"
echo -e "Downloading latest Ansible Tower package...\n"
curl -L -sS -o "$TMP_WORKING_DIR/ansible-tower-openshift-setup-latest.tar.gz" "https://releases.ansible.com/ansible-tower/setup_openshift/ansible-tower-openshift-setup-latest.tar.gz"

## Extract package
echo -e "\n================================================================================"
echo -e "Extracting...\n"
tar zxf ansible-tower-openshift-setup-latest.tar.gz

## Remove package
echo -e "\n================================================================================"
echo -e "Deleting tar file...\n"
rm ansible-tower-openshift-setup-latest.tar.gz

## Change directory
echo -e "\n================================================================================"
echo -e "Entering directory...\n"
cd ansible-tower-openshift-setup-*/


if [ "$OCP_AUTH_TYPE" = "userpass" ]; then
    ## Deploy Tower
    echo -e "\n================================================================================"
    echo -e "Deploying Ansible Tower with User/Pass...\n"
    ./setup_openshift.sh -e openshift_host=$OCP_HOST -e openshift_project=$OCP_PROJECT_NAME -e openshift_user=$OCP_USERNAME -e openshift_password=$OCP_PASSWORD -e openshift_pg_emptydir=true -e admin_user=$ANSIBLE_TOWER_ADMIN_USERNAME -e admin_password=$ANSIBLE_TOWER_ADMIN_PASSWORD -e secret_key=$ANSIBLE_TOWER_SECRET_KEY -e pg_username=$POSTGRES_USERNAME -e pg_password=$POSTGRES_PASSWORD -e pg_database=$POSTGRES_DATABASE -e rabbitmq_password=$RABBITMQ_PASSWORD -e rabbitmq_erlang_cookie=$RABBITMQ_ERLANG_COOKIE
fi

if [ "$OCP_AUTH_TYPE" = "token" ]; then
    ## Deploy Tower
    echo -e "\n================================================================================"
    echo -e "Deploying Ansible Tower with User/Pass...\n"
    ./setup_openshift.sh -e openshift_host=$OCP_HOST -e openshift_project=$OCP_PROJECT_NAME -e openshift_token=$OCP_TOKEN -e openshift_pg_emptydir=true -e admin_user=$ANSIBLE_TOWER_ADMIN_USERNAME -e admin_password=$ANSIBLE_TOWER_ADMIN_PASSWORD -e secret_key=$ANSIBLE_TOWER_SECRET_KEY -e pg_username=$POSTGRES_USERNAME -e pg_password=$POSTGRES_PASSWORD -e pg_database=$POSTGRES_DATABASE -e rabbitmq_password=$RABBITMQ_PASSWORD -e rabbitmq_erlang_cookie=$RABBITMQ_ERLANG_COOKIE
fi

if [ "$ANSIBLE_TOWER_PERFORM_CONFIGURATION" = "true" ]; then
    ## Wait for tower to come up
    echo -e "\n================================================================================"
    echo -e "Waiting for Tower to be available, sleeping 60s...\n"
    sleep 60

    ## Configuring Ansible Tower
    echo -e "\n================================================================================"
    echo -e "Configuring Ansible Tower...\n"
    
    ## Get Tower Route
    echo -e "\n================================================================================"
    echo -e "Getting Ansible Tower Route from oc...\n"
    export TOWER_ROUTE=$(oc get route ansible-tower-web-svc -o jsonpath='{.spec.host}')
    echo $TOWER_ROUTE
    echo -e "\n"
    
    ## Install ansible-tower-cli
    echo -e "\n================================================================================"
    echo -e "Installing ansible-tower-cli from pip...\n"
    pip3 install --user https://releases.ansible.com/ansible-tower/cli/ansible-tower-cli-latest.tar.gz
    
    ## Set ansible-tower-cli config
    echo -e "\n================================================================================"
    echo -e "Configuring ansible-tower-cli...\n"
    export AWX_CLI_CONF="--conf.host https://$TOWER_ROUTE --conf.username $ANSIBLE_TOWER_ADMIN_USERNAME --conf.password $ANSIBLE_TOWER_ADMIN_PASSWORD -k"
    awx $(echo $AWX_CLI_CONF) login
    
    ## Create organization
    echo -e "\n================================================================================"
    echo -e "Create Workshops Organization...\n"
    awx $(echo $AWX_CLI_CONF) organizations create --name Workshops --description "Organization for Workshop users"
    
    ## Patch LDAP SSL Cert Chain Checks
    echo -e "\n================================================================================"
    echo -e "Patch LDAP SSL CA Cert Chain check...\n"
        
    export API_CURL_OPT=(-f -sS -k -H 'Content-Type: application/json' --user ${ANSIBLE_TOWER_ADMIN_USERNAME}:${ANSIBLE_TOWER_ADMIN_PASSWORD})

    export MODIFIEDJSON=$(curl "${API_CURL_OPT[@]}" -XGET https://$TOWER_ROUTE/api/v2/settings/ldap/  | jq '.AUTH_LDAP_CONNECTION_OPTIONS = { "OPT_X_TLS_REQUIRE_CERT": 0, "OPT_NETWORK_TIMEOUT": 30, "OPT_X_TLS_NEWCTX": 0, "OPT_REFERRALS": 0 }')

    curl "${API_CURL_OPT[@]}" -X PUT -d ''"$MODIFIEDJSON"'' https://$TOWER_ROUTE/api/v2/settings/ldap/

    if [ $CONFIGURE_TOWER_LDAP = "true" ]; then

        export LDAPJSON=$(curl "${API_CURL_OPT[@]}" -XGET https://$TOWER_ROUTE/api/v2/settings/ldap/ | jq '.AUTH_LDAP_SERVER_URI = "'"$TOWER_LDAP_SERVER_URI"'" | .AUTH_LDAP_BIND_DN = "'"$TOWER_LDAP_BIND_DN"'" | .AUTH_LDAP_BIND_PASSWORD = "'"$TOWER_LDAP_BIND_PASSWORD"'" | .AUTH_LDAP_USER_SEARCH = '"$TOWER_LDAP_USER_SEARCH"' | .AUTH_LDAP_USER_DN_TEMPLATE = "'"$TOWER_LDAP_USER_DN_TEMPLATE"'" | .AUTH_LDAP_USER_ATTR_MAP = '"$TOWER_LDAP_USER_ATTR_MAP"' | .AUTH_LDAP_GROUP_SEARCH = '"$TOWER_LDAP_GROUP_SEARCH"' | .AUTH_LDAP_GROUP_TYPE = "'"$TOWER_LDAP_GROUP_TYPE"'" | .AUTH_LDAP_GROUP_TYPE_PARAMS = '"$TOWER_LDAP_GROUP_TYPE_PARAMS"' | .AUTH_LDAP_USER_FLAGS_BY_GROUP = '"$TOWER_LDAP_USER_FLAGS_BY_GROUP"' | .AUTH_LDAP_ORGANIZATION_MAP = '"$TOWER_LDAP_ORGANIZATION_MAP"'')

        curl "${API_CURL_OPT[@]}" -XPUT -d ''"$LDAPJSON"'' https://$TOWER_ROUTE/api/v2/settings/ldap/

    fi

fi