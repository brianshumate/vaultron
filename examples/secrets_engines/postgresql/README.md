# Using the PostgreSQL Database Secrets Engine with Vaultron

The following mini-guide shows how to set up Vaultron with a PostgreSQL Docker
container to use the Vault PostgreSQL secrets engine.

The guide presumes that you have formed Vaultron, initialized and unsealed
your Vault, and logged in with the initial root token.


## Run PostgreSQL Docker Container

Use the official PostgreSQL Docker container with TLS configuration from the `certs` folder:

```
$ docker run \
  --rm \
  -p5432:5432 \
  -v $PWD/certs/:/docker-entrypoint-initdb.d/ \
  --name vaultron-postgres \
  -e POSTGRES_PASSWORD=vaultron \
  -d postgres -l
```

Determine the PostgreSQL Docker container's internal IP address:

```
$ docker inspect \
    --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' \
    vaultron-postgres
172.17.0.11
```

## Configure Vault

Enable a database secrets engine mount at `vaultron-database`:

```
$ vault secrets enable -path=vaultron-database database
```

Next, configure a simple PostgreSQL connection without SSL:

```
$ vault write vaultron-database/config/postgresql \
    plugin_name=postgresql-database-plugin \
    allowed_roles="postgresql-readonly" \
    connection_url="postgresql://{{username}}:{{password}}@172.17.0.11:5432/postgres" \
    username="postgres" \
    password="vaultron"

The following warnings were returned from the Vault server:
* Read access to this endpoint should be controlled via ACLs as it will return the connection details as is, including passwords, if any.
```

Write an initial PostgreSQL read only user role:

```
$ vault write vaultron-database/roles/postgresql-readonly \
    db_name=postgresql \
    creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; \
        GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
    default_ttl="1h" \
    max_ttl="24h"
Success! Data written to: database/roles/postgresql-readonly
```

Retrieve a read only PostgreSQL database credential:

```
$ vault read vaultron-database/creds/postgresql-readonly
Key                Value
---                -----
lease_id           vaultron-database/creds/postgresql-readonly/YI3ggiSuDlciDdoERmPzjtqc
lease_duration     1h
lease_renewable    true
password           A1a-jmZWpMUU1KbyXbGg
username           v-root-postgres-XHXdOR7W0d51lmieNdQv-1548174025
```

Log in to PostgreSQL container with read-only credential:

```
$ psql \
  --host=127.0.0.1 \
  --dbname=postgres \
  --username=v-root-postgres-XHXdOR7W0d51lmieNdQv-1548174025 \
  --password

# Use password 'A1a-1p2p9yxwzsp51047' from above
Password for user v-root-readonly-1r9s3w2qwzx3t2r0rzr0-1513092218:
psql (10.1)
Type "help" for help.

postgres=
```
