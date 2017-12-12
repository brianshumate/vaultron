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
lease_id        database/creds/readonly/ddc27039-ef66-a22b-c2f4-61fbfbbefd8a
lease_duration  1h0m0s
lease_renewable true
password        A1a-1p2p9yxwzsp51047
username        v-root-readonly-1r9s3w2qwzx3t2r0rzr0-1513092218
```

Log in to PostgreSQL container with read-only credential:

```
$ psql \
  --host=127.0.0.1 \
  --dbname=postgres \
  --username=v-root-readonly-1r9s3w2qwzx3t2r0rzr0-1513092218 \
  --password

# Use password 'A1a-1p2p9yxwzsp51047' from above
Password for user v-root-readonly-1r9s3w2qwzx3t2r0rzr0-1513092218:
psql (10.1)
Type "help" for help.

postgres=
```
