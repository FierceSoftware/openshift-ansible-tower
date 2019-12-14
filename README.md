# Ansible Tower on OpenShift

This repository contains templates and tooling for taking Ansible Tower on OpenShift Container Platform.

## Prerequisites

An Ansible Tower license is required for you to continue past deployment.  Contact [Fierce Software](https://fiercesw.com) for a demo/trial license.

For post-deployment configuration **jq** and **pip3** will also be required.

##  Deployment - Automated

The deployment script ```./deploy.sh``` can also take preset environmental variables to provision without prompting the user.  To do so, copy over the ```example.vars.sh``` file, set the variables, run the deployer which will automatically source the ```./vars.sh``` file.

```bash
$ cp example.vars.sh vars.sh
$ vim vars.sh
$ ./deployer.sh
```

##  Deployment - Interactive

There's a simple deployment script that can either prompt a user for variables or take them set in the Bash script.  As long as you have an OpenShift Cluster and Red Hat RHN then you can simply run:

```bash
$ ./deployer.sh
```

And answer the prompts to deploy the full Ansible Tower on OCP stack.

##  Deployment - Manual

For manual deployment please read the instructions at https://docs.ansible.com/ansible-tower/3.6.1/html/administration/openshift_configuration.html

## LDAP Configuration with FreeIPA/Red Hat Identity Management (IDM)

1. From OpenShift, navigate to the exposed route, log in with the Tower Admin account used during deployment
2. Navigate to ***Settings > Authentication*** and click on the ***LDAP*** tab.
3. Integrate LDAP with the following (if using RH IDM/FreeIPA):

  - LDAP Server - Default
  - LDAP Server URI: ```ldaps://idm.example.com:636```
  - LDAP Bind DN: ```cn=Directory Manager```
  - LDAP Bind Password: duh_fill_this_one_out_yourself
  - LDAP User DN Template: ```uid=%(user)s,cn=users,cn=accounts,dc=example,dc=com```
  - LDAP Group Type: ```NestedMemberDNGroupType```
  - LDAP Require Group *(optional)*: ```cn=ipausers,cn=groups,cn=accounts,dc=example,dc=com```
  - LDAP User Search:
  ```
  [
    "cn=groups,dc=example,dc=com",
    "SCOPE_SUBTREE",
    "(uid=%(user)s)"
  ]
  ```
  - LDAP Group Search:
  ```
  [
    "cn=groups,cn=accounts,dc=example,dc=com",
    "SCOPE_SUBTREE",
    "(objectClass=groupOfNames)"
  ]
  ```
  - LDAP User Attribute Map:
  ```
  {
    "first_name": "givenName",
    "last_name": "sn",
    "email": "mail"
  }
  ```
  - LDAP Group Type Parameters:
  ```
  {
    "name_attr": "cn",
    "member_attr": "member"
  }
  ```
  - LDAP User Flags by Group:
  ```
  {
    "is_superuser": [
      "cn=admins,cn=groups,cn=accounts,dc=example,dc=com"
    ]
  }
  ```
  - LDAP Organization Map (for the Default organization) *(optional)*:
  ```
  {
    "Default": {
      "remove_admins": false,
      "remove_users": false,
      "admins": "cn=admins,cn=groups,cn=accounts,dc=example,dc=com",
      "users": "cn=ipausers,cn=groups,cn=accounts,dc=example,dc=com"
    }
  }
  ```

4. ***NOTE:***  If you use RH IDM/FreeIPA with a self-signed CA then you'll need to also set additional LDAP Connection Options via the API.  The following is an example of how to do it via cURL and jq:

```bash
$ export MODIFIEDJSON=$(curl -f -k -H 'Content-Type: application/json' -XGET --user towerAdmin:aVerySecurePassword https://ansible-tower.ocp.example.com/api/v2/settings/ldap/  | jq '.AUTH_LDAP_CONNECTION_OPTIONS = { "OPT_X_TLS_REQUIRE_CERT": 0, "OPT_NETWORK_TIMEOUT": 30, "OPT_X_TLS_NEWCTX": 0, "OPT_REFERRALS": 0 }')
$ curl -f -k -H 'Content-Type: application/json' -XPUT -d $MODIFIEDJSON --user towerAdmin:aVerySecurePassword https://ansible-tower.ocp.example.com/api/v2/settings/ldap/
```

