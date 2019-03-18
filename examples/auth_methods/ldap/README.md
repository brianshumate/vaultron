# Vaultron with LDAP

This is a quick up and running for Vaultron with OpenLDAP and the Vault LDAP auth method. The following resources are useful to familiarize yourself with while using this guide:

- [osixia/openldap Docker container image](https://github.com/osixia/docker-openldap)
- `ldapsearch -h`
- `man ldapsearch`

## Start a Container

Instantiate an OpenLDAP container with some initial settings:

```
$ docker run \
-p 389:389 \
-p 636:636 \
--name vaultron-openldap \
--env LDAP_ORGANISATION="Vaultron" \
--env LDAP_DOMAIN="vaultron.waves" \
--env LDAP_ADMIN_PASSWORD="vaultron" \
--detach osixia/openldap:latest
```

This will start an OpenLDAP container with both the standard and secure LDAP ports exposed to the host.

Use this command to obtain the internal IP address that Vault will use to connect to the running container.

```
$ docker inspect \
  --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' \
  vaultron-openldap
172.17.0.13
```

## Test Search

Let's do a quick initial `ldapsearch` within the container itself to ensure that the container is working:

```
$ docker exec vaultron-openldap \
  ldapsearch -x -H ldap://localhost -b dc=vaultron,dc=waves \
  -D "cn=admin,dc=vaultron,dc=waves" -w vaultron
```

This should result in the dump of an extended LDIF similar to this one:

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
userPassword:: e1NTSEF9OEoya2N4RmVzN3Y5dXJwaEdvWCt5VUxuajcrSW1DVEQ=

# search result
search: 2
result: 0 Success

# numResponses: 3
# numEntries: 2
```

If you get an error, then double check the container name, and ensure it is running with `docker ps -a`.

You should also be able to use `ldapsearch` directly on the host:

```
$ ldapsearch \
-x \
-H ldap://localhost \
-b dc=vaultron,dc=waves \
-D "cn=admin,dc=vaultron,dc=waves" \
-w vaultron
```

## Add Basic Config

You can add a basic configuration with user and groups from the file `vaultron.ldif`:

```
$ ldapadd -cxWD "cn=admin,dc=vaultron,dc=waves" \
  -f examples/auth_methods/ldap/vaultron.ldif
Enter LDAP Password: # it's: vaultron
adding new entry "ou=groups,dc=vaultron,dc=waves"

adding new entry "ou=users,dc=vaultron,dc=waves"

adding new entry "cn=dev,ou=groups,dc=vaultron,dc=waves"

adding new entry "cn=vaultron,ou=users,dc=vaultron,dc=waves"
```

## Configure Vault

Vaultron already enables the LDAP auth method as `vaultron-ldap`:

```
$ vault auth list
Path                  Type        Accessor                  Description
----                  ----        --------                  -----------
token/                token       auth_token_43d79f4c       token based credentials
vaultron-approle/     approle     auth_approle_b27b182f     Vaultron example AppRole auth method
vaultron-cert/        cert        auth_cert_241a03ca        Vaultron example X.509 certificate auth method
vaultron-ldap/        ldap        auth_ldap_bdb558f7        Vaultron example LDAP auth method
vaultron-userpass/    userpass    auth_userpass_c48213b7    Vaultron example Username and password auth method
```

Configure it like this:

```
$ vault write auth/vaultron-ldap/config \
  url="ldap://172.17.0.13" \
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
$ vault write auth/vaultron-ldap/groups/users policies=ldap-user && \
  vault write auth/vaultron-ldap/groups/dev policies=ldap-dev
Success! Data written to: auth/vaultron-ldap/groups/users
Success! Data written to: auth/vaultron-ldap/groups/dev
```

## Authenticate

Login:

$ vault login -method=ldap -path=vaultron-ldap username=vaultron
Password (will be hidden):
Success! You are now authenticated. The token information displayed below
is already stored in the token helper. You do NOT need to run "vault login"
again. Future Vault requests will automatically use this token.

Key                    Value
---                    -----
token                  s.8OGe9X2XqXXyJI99el886Cm5
token_accessor         FV9nfhzTg6z2DyOmCFVAw8xu
token_duration         50000h
token_renewable        true
token_policies         ["default" "ldap-dev"]
identity_policies      []
policies               ["default" "ldap-dev"]
token_meta_username    vaultron
```

