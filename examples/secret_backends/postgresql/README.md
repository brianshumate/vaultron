# Using the PostgreSQL Database Secret Backend with Vaultron

The following mini-guide shows how to set up Vaultron with a PostgreSQL Docker
container to use the Vault PostgreSQL secret backend.

The guide presumes that you have formed Vaultron, initialized and unsealed
your Vault, and logged in with the initial root token.


## Run PostgreSQL Docker Container

Use the official PostgreSQL Docker container:

```
$ docker run \
  -p5432:5432 \
  --name vaultron-postgres \
  -e POSTGRES_PASSWORD=vaultron \
  -d postgres
```

Determine the PostgreSQL Docker container's internal IP address:

```
$ docker inspect \
    --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' \
    vaultron-postgres
172.17.0.2
```

## Configure Vault

Mount the Vault database secret backend:

```
$ vault mount database
Successfully mounted 'database' at 'database'!
```

Write the PostgreSQL secret backend configuration:

```
$ vault write database/config/postgresql \
    plugin_name=postgresql-database-plugin \
    allowed_roles="readonly" \
    connection_url="postgresql://postgres:vaultron@172.17.0.2:5432?sslmode=disable"
The following warnings were returned from the Vault server:
* Read access to this endpoint should be controlled via ACLs as it will return the connection details as is, including passwords, if any.
```

Write an initial PostgreSQL read only user role:

```
$ vault write database/roles/readonly \
    db_name=postgresql \
    creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; \
        GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
    default_ttl="1h" \
    max_ttl="24h"
Success! Data written to: database/roles/readonly
```

Retrieve a read only PostgreSQL database credential:

```
$ vault read database/creds/readonly
Key             Value
---             -----
lease_id        database/creds/readonly/b26b6243-f6b1-c88d-9184-de136b0db5d0
lease_duration  1h0m0s
lease_renewable true
password        A1a-8r42sz6x005pz9w2
username        v-root-readonly-rup0t2ytrxtr52qq183q-1512771063
```

Log in to PostgreSQL container with read-only credential:

```
$ psql -h 127.0.0.1 -U postgres -W
Password for user postgres: vaultron
psql (10.1)
Type "help" for help.

postgres=#
```
