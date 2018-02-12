# Vaultron with LDAP

This is a quick up and running for Vaultron with OpenLDAP and the Vault LDAP auth method. The following resources are useful to familiarize yourself with while using this guide:

- [osixia/openldap Docker container image](https://github.com/osixia/docker-openldap)
- `/usr/bin/ldapsearch` (macOS)
- `man ldapsearch`

## Start the Container

```
$ docker run \
-p 389:389 \
-p 636:636 \
--name vaultron_openldap \
--env LDAP_ORGANISATION="Vaultron" \
--env LDAP_DOMAIN="vaultron.waves" \
--env LDAP_ADMIN_PASSWORD="vaultron" \
--detach osixia/openldap:latest
```

This will start an OpenLDAP container with the standard and secure LDAP ports exposed to the host.

Use this command to obtain the internal IP address that Vault will use to connect to the running container.

```
$ docker inspect \
  --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' \
  vaultron_openldap
172.17.0.13
```

## Test Search

Let's do a quick initial `ldapsearch` within the container itself to ensure that the container is working:

```
$ docker exec vaultron_openldap ldapsearch -x -H ldap://localhost -b dc=vaultron,dc=waves -D "cn=admin,dc=vaultron,dc=waves" -w vaultron
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

## Configure Vault

Vaultron already enables the LDAP auth method as `vaultron_ldap`:

```
$ vault auth list
Path                  Type        Description
----                  ----        -----------
token/                token       token based credentials
vaultron_approle/     approle     n/a
vaultron_ldap/        ldap        n/a
vaultron_userpass/    userpass    n/a
```

So we need to begin configuring it now:

```
$ vault write auth/vaultron_ldap/config \
    url="ldap://172.17.0.13" \
    userdn="ou=Users,dc=vaultron,dc=waves" \
    groupdn="ou=Users,dc=vaultron,dc=waves" \
    groupfilter="(&(objectClass=person)(uid={{.Username}}))" \
    groupattr="memberOf" \
    binddn="cn=admin,ou=users,dc=vaultron,dc=waves" \
    bindpass='vaultron' \
    insecure_tls=true \
    starttls=false
```

Add a LDAP group to Vault policy mapping:


```
$ vault write auth/vaultron_ldap/groups/users policies=example
```
