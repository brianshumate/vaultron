# Using the MSSQL Database Secrets Engine with Vaultron

The following mini-guide shows how to set up Vaultron with a SQL Server 2017 Docker container to use the Vault MSSQL secrets engine.

The guide presumes that you have formed Vaultron, initialized and unsealed your Vault, and logged in with the initial root token.

## Run a SQL Server 2017 Docker Container

First pull the official SQL Server 2017 Docker container image:


```
$ docker pull microsoft/mssql-server-linux:2017-latest
```

Now run a container:

```
$ docker run \
    -e 'ACCEPT_EULA=Y' \
    -e 'MSSQL_SA_PASSWORD=v4u1tr0n_in_the_h@use' \
    -e 'MSSQL_PID=Developer' \
    -p 1401:1433 \
    --name vaultron_mssql \
    -d microsoft/mssql-server-linux:2017-latest
```

Protip: The example `MSSQL_SA_PASSWORD` meets requirements and you should be certain that your chosen value does as well, or you'll be seeing this in `docker logs vaultron_mssql`:

```
ERROR: Unable to set system administrator password: Password validation failed. The password does not meet SQL Server password policy requirements because it is not complex enough. The password must be at least 8 characters long and contain characters from three of the following four sets: Uppercase letters, Lowercase letters, Base 10 digits, and Symbols..
```

### Change System Administrator Password

The SA password specified when running the container can be determine in the environment variable on the container; if this is a concern, you should change the System Administrator (SA) account password like this:

```
$ docker exec \
    -it vaultron_mssql /opt/mssql-tools/bin/sqlcmd \
    -S localhost -U SA -P '$CURRENT_SA_PASSWORD' \
    -Q 'ALTER LOGIN SA WITH PASSWORD="$NEW_SA_PASSWORD"'
```

where `$CURRENT_SA_PASSWORD` should be replaced by the _current_ SA password (`v4u1tr0n` in the above example run command) and `$NEW_SA_PASSWORD` should be replaced by the desired SA account password.

Determine the SQL Server 2017 Docker container's internal IP address:

```
$ docker inspect \
    --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' \
    vaultron_mssql
172.17.0.2
```

## Configure Vault

Vaultron enables the database secrets engine at `vaultron_database` if using `blazing sword`; if you set up manually, you'll need to enable it:

```
$ vault secrets enable -path=vaultron_database database
```

Next, configure the MS-SQL connection:

```
$ vault write vaultron_database/config/mssql \
    plugin_name=mssql-database-plugin \
    connection_url='sqlserver://sa:$NEW_SA_PASSWORD@172.17.0.2:1433' \
    allowed_roles="mssql_readonly"
The following warnings were returned from the Vault server:
* Read access to this endpoint should be controlled via ACLs as it will return the connection details as is, including passwords, if any.
```

Add the read only role:

```
$ vault write vaultron_database/roles/mssql_readonly \
    db_name=mssql \
    creation_statements="CREATE LOGIN [{{name}}] WITH PASSWORD = '{{password}}';\
        CREATE USER [{{name}}] FOR LOGIN [{{name}}];\
        GRANT SELECT ON SCHEMA::dbo TO [{{name}}];" \
    default_ttl="1h" \
    max_ttl="24h"
Success! Data written to: database/roles/mssql_readonly
```

Retrieve a read only MSSQL database credential:


```
$ vault read vaultron_database/creds/mssql_readonly
Key             Value
---             -----
lease_id        database/creds/readonly/46b34bb1-3e1c-6605-0bc2-f86ee6bbf548
lease_duration  1h0m0s
lease_renewable true
password        A1a-3r3rqsuv6x2t964z
username        v-root-readonly-rr9yx33pt2pzsx0rw04u-1508164793
```

## Resources

1. [Databases](https://www.vaultproject.io/docs/secrets/databases/index.html)
2. [MSSQL Database Plugin](https://www.vaultproject.io/docs/secrets/databases/mssql.html)
3. [Run the SQL Server 2017 container image with Docker](https://docs.microsoft.com/en-us/sql/linux/quickstart-install-connect-docker)
