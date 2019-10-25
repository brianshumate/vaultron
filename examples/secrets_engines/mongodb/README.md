# Using the MongoDB Database Secrets Engine with Vaultron

The following mini-guide shows how to set up Vaultron with a MongoDB Docker container to use the Vault [MongoDB secrets engine](https://www.vaultproject.io/docs/secrets/databases/mongodb.html).

The guide presumes that you have formed Vaultron, initialized and unsealed your Vault, and logged in with the initial root token.

> **NOTE**: This guide presumes that you are issuing the example commands from within the directory containing this README.md. For the MongoDB Database Secrets Engine, that would be `$VAULTRON_ROOT/examples/secrets_engines/mongodb` where `$VAULTRON_ROOT` represents the `vaultron` repository root.

## Run MongoDB Docker Container

Start the official MongoDB Docker container with TLS support:

```
$ docker run \
  --detach \
  --rm \
  --ip 10.10.42.222 \
  --name vaultron-mongodb \
  --network vaultron-network \
  -p 27017:27017 \
  --volume $PWD/tls:/etc/ssl/ \
  mongo --sslMode requireSSL --sslPEMKeyFile /etc/ssl/mongodb.pem
```

## Configure Vault

Vaultron enables a Database Secrets Engine at `vaultron-database` if using `blazing sword`; if you set up manually, you might need to enable it:

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

Next, configure the Secrets Engine MongoDB connection:

```
$ vault write vaultron-database/config/mongodb \
  plugin_name=mongodb-database-plugin \
  allowed_roles="mongodb-readonly" \
  connection_url="mongodb://10.10.42.222:27017/admin?ssl=true"
```

Add a read-only user role:

```
$ vault write vaultron-database/roles/mongodb-readonly \
  db_name=mongodb \
  creation_statements='{ "db": "admin", "roles": [{ "role": "readWrite" }, {"role": "read", "db": "foo"}] }' \
  default_ttl="1h" \
  max_ttl="24h"
Success! Data written to: vaultron-database/roles/mongodb-readonly
```

Retrieve a read-only MongoDB database credential:

```
$ vault read vaultron-database/creds/vaultron-role
Key                Value
---                -----
lease_id           vaultron-database/creds/mongodb-readonly/oJ7Me3gsNTzE25GVFu76nwyp
lease_duration     1h
lease_renewable    true
password           A1a-O5vOhIWDs3vMjB56
username           v-root-mongodb-readonl-6QO4IgSkgtkxOPHiKtD3-1568912320
```
