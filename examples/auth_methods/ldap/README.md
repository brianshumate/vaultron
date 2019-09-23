# Vaultron with LDAP

This is a quick up and running for Vaultron with OpenLDAP and the Vault LDAP auth method. The following resources are useful to familiarize yourself with while using this guide:

- [osixia/openldap Docker container image](https://github.com/osixia/docker-openldap)
- `ldapsearch -h`
- `man ldapsearch`

> **NOTE**: This guide presumes that you are issuing the example commands from within the directory containing this README.md. For the LDAP Auth Method, that would be `$VAULTRON_ROOT/examples/auth_methods/ldap` where `$VAULTRON_ROOT` represents the `vaultron` repository root.

## Start a Container

Instantiate an OpenLDAP container with some initial settings:

```
$ docker run \
  --detach \
  --rm \
  --env LDAP_ORGANISATION="Vaultron" \
  --env LDAP_DOMAIN="vaultron.waves" \
  --env LDAP_ADMIN_PASSWORD="vaultron" \
  --ip 10.10.42.221 \
  --name vaultron-openldap \
  --network vaultron-network \
  -p 389:389 \
  -p 636:636 \
  osixia/openldap:latest
```

This will start the container with both insecure and LDAPS ports exposed to the host.

> **NOTE**: Unfortunately we cannot yet use TLS/LDAPS with the OpenLDAP container because of an incompatibility between our Vault-generate TLS certificate and key and GNUTLS used by the OpenLDAP container.

See also: https://github.com/osixia/docker-openldap/issues/28

## Test Search

Let's do a quick initial `ldapsearch` within the container itself to ensure that the container is working:

```
$ docker exec vaultron-openldap \
  ldapsearch -x -H ldap://localhost -b dc=vaultron,dc=waves \
  -D "cn=admin,dc=vaultron,dc=waves" -w vaultron
```

This should result in the dump of an extended LDIF similar to this example:

```
# extended LDIF
#
# LDAPv3
# base <dc=vaultron,dc=waves> with scope subtree
# filter: (objectclass=*)
# requesting: ALL
#

# vaultron.waves
dn: dc=vaultron,dc=waves
objectClass: top
objectClass: dcObject
objectClass: organization
o: Vaultron
dc: vaultron

# admin, vaultron.waves
dn: cn=admin,dc=vaultron,dc=waves
objectClass: simpleSecurityObject
objectClass: organizationalRole
cn: admin
description: LDAP administrator
userPassword:: e1NTSEF9c0lSN2loOGJ3dFU4QnFJZFBCd3NheFZITVQ0MW9Tc2E=

# search result
search: 2
result: 0 Success

# numResponses: 3
# numEntries: 2
```

If you encounter an error, try double checking the container name and ensuring it is running with:

```
$ docker ps -f name=vaultron-openldap --format "table {{.Names}}\t{{.Status}}"
NAMES               STATUS
vaultron-openldap   Up About a minute
```

You should also be able to use `ldapsearch` directly on the host:

```
$ ldapsearch \
  -x \
  -H ldap://localhost \
  -b dc=vaultron,dc=waves \
  -D "cn=admin,dc=vaultron,dc=waves" \
  -w vaultron
```

## Add Basic Configuration

You can add a basic configuration with user and groups from the file `vaultron.ldif`. When prompted, the password is: vaultron

```
$ ldapadd -cxWD "cn=admin,dc=vaultron,dc=waves" -f vaultron.ldif
Enter LDAP Password:
adding new entry "ou=groups,dc=vaultron,dc=waves"

adding new entry "ou=users,dc=vaultron,dc=waves"

adding new entry "cn=dev,ou=groups,dc=vaultron,dc=waves"

adding new entry "cn=akira,ou=users,dc=vaultron,dc=waves"
```

## Configure Vault

If you use `blazing_sword`, Vaultron enables the LDAP auth method as `vaultron-ldap`:

```
$ vault auth list | grep ldap
vaultron-ldap/        ldap        auth_ldap_013a8338        Vaultron example LDAP auth method
```

Configure it using the Docker internal host IP address for the _vaultron-openldap_ container and some initial settings like this:

```
$ vault write auth/vaultron-ldap/config \
  url="ldap://10.10.42.221" \
  userdn="ou=users,dc=vaultron,dc=waves" \
  groupdn="ou=groups,dc=vaultron,dc=waves" \
  groupfilter="(|(memberUid={{.Username}})(member={{.UserDN}})(uniqueMember={{.UserDN}}))" \
  groupattr="cn" \
  starttls=false \
  binddn="cn=admin,dc=vaultron,dc=waves" \
  bindpass="vaultron"
Success! Data written to: auth/vaultron-ldap/config
```

## Group Policy Mapping

Create basic LDAP group -> policy mappings:

```
$ vault write auth/vaultron-ldap/groups/users policies=ldap-user, && \
  vault write auth/vaultron-ldap/groups/dev policies=ldap-dev
Success! Data written to: auth/vaultron-ldap/groups/users
Success! Data written to: auth/vaultron-ldap/groups/dev
```

## Authenticate

Login (the password is: kogane):

```
$ vault login -method=ldap -path=vaultron-ldap username=akira
Password (will be hidden):
Success! You are now authenticated. The token information displayed below
is already stored in the token helper. You do NOT need to run "vault login"
again. Future Vault requests will automatically use this token.

Key                    Value
---                    -----
token                  s.zG8OdMcMR6HIofNqDOFivbpC
token_accessor         CDoy5UpCFPxMjNh2koWvhIOB
token_duration         768h
token_renewable        true
token_policies         ["default" "ldap-dev"]
identity_policies      []
policies               ["default" "ldap-dev"]
token_meta_username    akira
```

## Troubleshoot


### ldap operation failed

If you encounter an error like this:

```
Error authenticating: Error making API request.

URL: PUT https://127.0.0.1:8200/v1/auth/vaultron-ldap/login/akira
Code: 400. Errors:

* ldap operation failed
```

Then be sure that you imported the example `.ldif` as described in the [Add Basic Configuration](#dd_basic_configuration)
### connection refused

If you encounter an error like this:

```
Error writing data to auth/vaultron-ldap/config: Put https://127.0.0.1:8200/v1/auth/vaultron-ldap/config: dial tcp 127.0.0.1:8200: connect: connection refused
```

Be sure that Vaultron is actually formed and the Vault containers are running:

```
$ docker ps -f name=vaultron-vault --format "table {{.Names}}\t{{.Status}}"
NAMES               STATUS
vaultron-vault0     Up 2 minutes (healthy)
vaultron-vault1     Up 2 minutes (healthy)
vaultron-vault2     Up 2 minutes (healthy)
```
