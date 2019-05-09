# Using the RabbitMQ Database Secrets Engine with Vaultron

The following mini-guide shows how to set up Vaultron with a RabbitMQ Docker
container to use the Vault RabbitMQ secrets engine.

The guide presumes that you have formed Vaultron, initialized and unsealed
your Vault, and logged in with the initial root token.

## Run MySQL Docker Container

```
$ docker run \
  -d \
  --hostname rabbitmq.consul \
  --name vaultron-rabbitmq \
  rabbitmq:3-management
```

## Configure Vault

First determine the RabbitMQ container IP address:

```
$ docker inspect \
   --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' \
    vaultron-rabbitmq
172.17.0.11
```

Configure the RabbitMQ connection:

It can take a moment for the RabbitMQ container to become available.

You can check with:

```
$ docker logs vaultron-rabbitmq | grep 'Server startup complete'
```

Once RabbitMQ is ready, configure the Vault connection:

```
$ vault write vaultron-rabbitmq/config/connection \
  connection_uri="http://172.17.0.11:15672" \
  username="guest" \
  password="guest"
Success! Data written to: vaultron-rabbitmq/config/connection
```

Create a role:

```
$ vault write vaultron-rabbitmq/roles/my-role \
  vhosts='{"/":{"write": ".*", "read": ".*"}}'
Success! Data written to: vaultron-rabbitmq/roles/my-role
```

## Get a Credential

Get a RabbitMQ credential from Vault:

```
$ vault read vaultron-rabbitmq/creds/my-role
Key                Value
---                -----
lease_id           vaultron-rabbitmq/creds/my-role/UEgV22KksLiKrlGpc7Yl4SPh
lease_duration     50000h
lease_renewable    true
password           d9d33fdd-0f0b-6685-bb31-a95e0f804ad6
username           root-0bf82c35-771a-fd4f-b86c-f7e634a26e16
```
