# Audit Devices: Socket

Vault can log [audit device](https://www.vaultproject.io/docs/audit/index.html) messages to a [socket](https://www.vaultproject.io/docs/audit/socket.html) based device.

With Vaultron, you can readily spin up a listening socket container with netcat, like so:

## Start Netcat Container

```
$ docker run \
  --detach \
  --rm \
  -t \
  --ip 10.10.42.111 \
  --network=vaultron-network \
  --name=vaultron-netcat \
  subfuzion/netcat -vl 7474
```

## Configure Vault

Once that is running, you can add the socket based audit device to Vault like so:

```
$ vault audit enable \
  socket \
  address=10.10.42.111:7474 \
  socket_type=tcp
```

## Observe Logs

Check the audit device output from the netcat container (ideally in another terminal) with:

```
$ docker logs --follow vaultron-netcat
```

Then generate some activity:

```
$ ./examples/tests/gen_kv_secrets -c=10 -p=vaultron-kv
```

## Trouble?

If you observe this when attempting to start the netcat container:

```
docker: Error response from daemon: network vaultron-network not found.
```

This just means you need to spin up Vaultron, thereby creating its internal network `vaultron-network` to which the netcat container attempts to join.

## Resources

1. [audit device](https://www.vaultproject.io/docs/audit/index.html)
2. [socket](https://www.vaultproject.io/docs/audit/socket.html)
3. [netcat Docker image](https://github.com/subfuzion/docker-netcat)
