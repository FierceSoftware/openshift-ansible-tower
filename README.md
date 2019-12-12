# Ansible Tower on OpenShift

This repository contains templates and tooling for taking Ansible Tower on OpenShift Container Platform.

## Prerequisites

An Ansible Tower license is required for you to continue past deployment.  Contact [Fierce Software](https://fiercesw.com) for a demo/trial license.

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

1. Navigate to the exposed route, set Admin credentials if needed (default is rcadmin/sup3rs3cr3t), complete initial Setup
2. Create a new public #devsecops-workshop channel
3. In Administration > Accounts, set **Registration Form** to ```Disabled```
4. Integrate LDAP with the following (if using RH IDM/FreeIPA):

  - LDAP General - Enable: True
  - LDAP General - Login Fallback: True
  - LDAP General - Find user after login: True
  - LDAP General - Host: idm.example.com
  - LDAP General - Port: 636
  - LDAP General - Reconnect: True
  - LDAP General - Encryption: SSL/LDAPS
  - LDAP General - Regect Unauthorized: False
  - LDAP General - Base DN: cn=accounts,dc=example,dc=com
  - LDAP Authentication - Enable: True
  - LDAP Authentication - User DN: cn=Directory Manager
  - LDAP Authentication - Password: duh_fill_this_one_out_yourself
  - LDAP Sync/Import - Username Field: uid
  - LDAP Sync/Import - Unique Identifier Field: uid
  - LDAP Sync/Import - Default Domain: example.com
  - LDAP Sync/Import - Sync User Data: True
  - LDAP Sync/Import - User Data Field Map: ```{"cn":"name", "mail":"email"}```
  - LDAP Sync/Import - Background Sync Now: _CLICK ONCE ALL SAVED_
  - LDAP User Search - Filter: (objectclass=*)
  - LDAP User Search - Scope: sub
  - LDAP User Search - Search Field: uid

- You'll also probably want to create a user (in LDAP) for Jenkins to interact with Rocketchat, if using this as part of a ChatOps implementation with a build pipeline.  Something like "rc-jenkins" maybe, I dunno, call it whatever you'd like.
- You have the option of manually inviting all the LDAP synced users to the #devsecops-workshop channel, or just get em to ```/join #devsecops-workshop```.  For some reason setting the Room to a Default and setting it to Auto Join doesn't work.

