# Ansible Tower on OpenShift

This repository contains templates and tooling for taking Ansible Tower on OpenShift Container Platform.

## Prerequisites

An Ansible Tower license is required for you to continue past deployment.  Contact [Fierce Software](https://fiercesw.com) for a demo/trial license.

For post-deployment configuration **pip3** will also be required.

##  Deployment - Automated

The deployment script ```./deploy.sh``` can also take preset environmental variables to provision without prompting the user.  To do so, copy over the ```example.vars.sh``` file, set the variables, source and run the deployer.

```bash
$ cp example.vars.sh vars.sh
$ vim vars.sh
$ source ./vars.sh && ./deployer.sh
```

##  Deployment - Interactive

There's a simple deployment script that can either prompt a user for variables or take them set in the Bash script.  As long as you have an OpenShift Cluster and Red Hat RHN then you can simply run:

```bash
$ ./deployer.sh
```

And answer the prompts to deploy the full Ansible Tower on OCP stack.

##  Deployment - Manual

For manual deployment please read the instructions at https://docs.ansible.com/ansible-tower/3.6.1/html/administration/openshift_configuration.html


## Initial Setup


## LDAP Configuration with FreeIPA/Red Hat Identity Management (IDM)

1. From OpenShift, navigate to the exposed route, log in with the Tower Admin account used during deployment
2. Navigate to ***Settings > Authentication*** and click on the ***LDAP*** tab.
3. Integrate LDAP with the following (if using RH IDM/FreeIPA):

  - LDAP Server - Default
  - LDAP Server URI: ```ldaps://idm.example.com:636```
  - LDAP Bind DN: ```uid=admin,cn=users,cn=accounts,dc=example,dc=com```
  - LDAP Bind Password: duh_fill_this_one_out_yourself
  - LDAP User DN Template: ```uid=%(user)s,cn=users,cn=accounts,dc=example,dc=com``
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
      "admins": "cn=admins,cn=groups,cn=accounts,dc=example,dc=com",
      "users": "cn=ipausers,cn=groups,cn=accounts,dc=example,dc=com"
    }
  }
  ```

***NOTE:***  There is currently an issue with LDAP+Tower in a containerized deployment.  Support ticket opened and solution pending.