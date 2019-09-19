# Using the MySQL Database Secrets Engine with Vaultron

The following mini-guide shows how to set up Vaultron with a MySQL Docker
container to use the Vault MySQL secrets engine.

The guide presumes that you have formed Vaultron, initialized and unsealed
your Vault, and logged in with the initial root token.

If you'd prefer to automate setup process, run this:

```
$ ./eye_beams_mysql
```

## Run MySQL Docker Container

Use the official MySQL Docker container:

```
$ docker run \
  --detach \
  --rm \
  --env MYSQL_ROOT_PASSWORD=vaultron \
  --ip 10.10.42.223 \
  --name vaultron-openldap \
  --network vaultron-network \
  -p 3306:3306 \
  mysql:latest
```

## Configure Vault

Vaultron enables the database secrets engine at `vaultron-database` if using `blazing sword`; if you set up manually, you'll need to enable it:

```
$ vault secrets enable -path=vaultron-database database
```

Next, write the MySQL secrets engine configuration:

```
$ vault write vaultron-database/config/mysql \
    plugin_name=mysql-database-plugin \
    connection_url="root:vaultron@tcp(172.17.0.2:3306)/" \
    allowed_roles="mysql-readonly"

The following warnings were returned from the Vault server:
* Read access to this endpoint should be controlled via ACLs as it will return the connection details as is, including passwords, if any.
```

Write an initial MySQL read only user role:

```
$ vault write vaultron-database/roles/mysql-readonly \
    db_name=mysql \
    creation_statements="CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT SELECT ON *.* TO '{{name}}'@'%';" \
    default_ttl="1h" \
    max_ttl="24h"
Success! Data written to: vaultron-database/roles/mysql-readonly
```

## Get a Credential

Retrieve a read only MySQL database credential:

```
$ vault read vaultron-database/creds/mysql-readonly
Key                Value
---                -----
lease_id           vaultron-database/creds/mysql-readonly/0669a169-ea0a-67c3-5c5d-00c4e1beb9d2
lease_duration     1h
lease_renewable    true
password           A1a-2r5u92yx8w8w4sr8
username           v-root-mysql-read-y70xuqw302x3x3
```

## Log in to MySQL

Log in to MySQL container with read-only credential:

```
$ mysql -u v-root-readonly-rVj9wig0itNm3YgI -p -h 127.0.0.1

Enter password: [TYPE in password value from above]

Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 5
Server version: 5.7.19 MySQL Community Server (GPL)

Copyright (c) 2000, 2017, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql>
```
