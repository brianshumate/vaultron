# Using the MySQL Database Secret Backend with Vaultron

The following mini-guide shows how to set up Vaultron with a MySQL Docker
container to use the Vault MySQL secret backend.

The guide presumes that you have formed Vaultron, initialized and unsealed
your Vault, and logged in with the initial root token.

If you'd prefer to automate the MySQL secret backend setup process, run this:

```
$ ./eye_beams_mysql
```

## Run MySQL Docker Container

Use the official MySQL Docker container:

```
$ docker run --name mysql_vaultron \
    -e MYSQL_ROOT_PASSWORD=vaultron \
    -p 3306:3306 \
    -d mysql:latest
```

Determine the MySQL Docker container's internal IP address:

```
$ docker inspect \
    --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' \
    mysql_vaultron
172.17.0.2
```

## Configure Vault

Mount the Vault database secret backend:

```
$ vault mount database
Successfully mounted 'database' at 'database'!
```

Write the MySQL secret backend configuration:

```
vault write database/config/mysql \
    plugin_name=mysql-database-plugin \
    connection_url="root:vaultron@tcp(172.17.0.2:3306)/" \
    allowed_roles="readonly"

The following warnings were returned from the Vault server:
* Read access to this endpoint should be controlled via ACLs as it will return the connection details as is, including passwords, if any.
```

Write an initial MySQL read only user role:

```
$ vault write database/roles/readonly \
    db_name=mysql \
    creation_statements="CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT SELECT ON *.* TO '{{name}}'@'%';" \
    default_ttl="1h" \
    max_ttl="24h"
Success! Data written to: database/roles/readonly
```

Retrieve a read only MySQL database credential:

```
$ vault read database/creds/readonly
Key             Value
---             -----
lease_id        database/creds/readonly/95fad695-3be2-fa7f-0f9d-d3cbc8ce75b1
lease_duration  1h0m0s
lease_renewable true
password        a7f40e23-2764-d3da-0676-0acff64d112b
username        v-root-readonly-rVj9wig0itNm3YgI
```

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
