# Using the PostgreSQL Database Secrets Engine with Vaultron

The following mini-guide shows how to set up Vaultron with a PostgreSQL Docker
container to use the Vault PostgreSQL secrets engine.

The guide presumes that you have formed Vaultron, initialized and unsealed
your Vault, and logged in with the initial root token.

> **NOTE**: This guide presumes that you are issuing the example commands from within the directory containing this README.md. For the PostgreSQL database Secrets Engine, that would be `$VAULTRON_ROOT/examples/secrets_engines/postgresql` where `$VAULTRON_ROOT` represents the `vaultron` repository root.

## Run PostgreSQL Docker Container

Use the official PostgreSQL Docker container with TLS configuration from the `tls` folder:

```
$ docker run \
  --detach \
  --rm \
  --env POSTGRES_PASSWORD=vaultron \
  --ip 10.10.42.224 \
  --name vaultron-postgres \
  --network vaultron-network \
  -p 5432:5432 \
  --volume $PWD/tls/:/docker-entrypoint-initdb.d/ \
  postgres -l
```

## Configure Vault

If necessary, enable a database Secrets Engine at `vaultron-database`:

```
$ vault secrets enable -path=vaultron-database database
```

If you encounter an error like:

```
Error enabling: Error making API request.

URL: POST https://127.0.0.1:8200/v1/sys/mounts/vaultron-database
Code: 400. Errors:

* path is already in use at vaultron-database/
```

Then most likely the `vaultron-database` Secrets Engine was already enabled, and it is fine to continue.

Next, configure a simple PostgreSQL connection with basic SSL support:

```
$ vault write vaultron-database/config/postgresql \
    plugin_name=postgresql-database-plugin \
    allowed_roles="postgresql-readonly" \
    connection_url="postgresql://{{username}}:{{password}}@10.10.42.224:5432/postgres?sslmode=require" \
    username="postgres" \
    password="vaultron"
```

If this doesn't succeed and instead, you encounter an error like:

```
Error writing data to vaultron-database/config/postgresql: Error making API request.

URL: PUT https://127.0.0.1:8200/v1/vaultron-database/config/postgresql
Code: 400. Errors:

* error creating database object: error verifying connection: dial tcp 10.10.42.224:5432: connect: no route to host
```

Ensure that the _vaultron_postgresql_ container is running:

```
$ docker ps -f name=vaultron-postgres --format "table {{.Names}}\t{{.Status}}"
NAMES               STATUS
vaultron-postgres   Up About a minute
```

With the container running, and the Vault configuration written, the next step is to rotate the PostgreSQL root user credential:

```
$ vault write -force vaultron-database/rotate-root/postgresql
Success! Data written to: vaultron-database/rotate-root/postgresql
```

> *NOTE*: Now the PostgreSQL root password is no longer _vaultron_ and instead now a new value that is known only to Vault.

Write an initial PostgreSQL read only user role:

```
$ vault write vaultron-database/roles/postgresql-readonly \
    db_name=postgresql \
    creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; \
        GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
    default_ttl="1h" \
    max_ttl="24h"
Success! Data written to: vaultron-database/roles/postgresql-readonly
```

Read a read only PostgreSQL database credential:

```
$ vault read vaultron-database/creds/postgresql-readonly
Key                Value
---                -----
lease_id           vaultron-database/creds/postgresql-readonly/EnI2wdFEVa5n5szFA6QqHoRf
lease_duration     1h
lease_renewable    true
password           A1a-W5AmwwV5H6IH3bi2
username           v-root-postgres-1LEJnHjFKlq7XDjYBLRh-1569253995
```

Log in to PostgreSQL container with read-only credential:

```
$ psql \
  --host=127.0.0.1 \
  --dbname=postgres \
  --username=v-root-postgres-1LEJnHjFKlq7XDjYBLRh-1569253995 \
  --password

# Use password 'A1a-1p2p9yxwzsp51047' from above
Password for user v-root-readonly-1r9s3w2qwzx3t2r0rzr0-1513092218:
psql (11.3, server 11.5 (Debian 11.5-1.pgdg90+1))
SSL connection (protocol: TLSv1.2, cipher: ECDHE-RSA-AES256-GCM-SHA384, bits: 256, compression: off)
Type "help" for help.

postgres=>
```
