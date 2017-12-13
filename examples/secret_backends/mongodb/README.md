# Using the MongoDB Database Secret Backend with Vaultron

The following mini-guide shows how to set up Vaultron with a MongoDB Docker container to use the Vault MongoDB secret backend.

The guide presumes that you have formed Vaultron, initialized and unsealed your Vault, and logged in with the initial root token.

## Run MongoDB Docker Container

Use the official MongoDB Docker container:

```
$ docker run -p 27017:27017 --name mongodb_vaultron -d mongo
```

Determine the MongoDB Docker container's internal IP address:

```
$ docker inspect \
  --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' \
  mongodb_vaultron
172.17.0.12
```

## Configure Vault

Mount Vault database backend:

```
$ vault mount database
Successfully mounted 'database' at 'database'!
```

Configure the MongoDB connection

```
$ vault write database/config/mongodb \
    plugin_name=mongodb-database-plugin \
    allowed_roles="mongodb-readonly" \
    connection_url="mongodb://172.17.0.12:27017/admin?ssl=false"
```

Add a read only user role:

```
$ vault write database/roles/mongodb-readonly \
    db_name=mongodb \
    creation_statements='{ "db": "admin", "roles": [{ "role": "readWrite" }, {"role": "read", "db": "foo"}] }' \
    default_ttl="1h" \
    max_ttl="24h"
```

Retrieve a read only MongoDB database credential:

```
$ vault read database/creds/mongodb-readonly
```
