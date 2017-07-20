
     __  __                     ___    __
    /\ \/\ \                   /\_ \  /\ \__
    \ \ \ \ \     __     __  __\//\ \ \ \ ,_\  _ __   ___     ___
     \ \ \ \ \  /'__`\  /\ \/\ \ \ \ \ \ \ \/ /\`'__\/ __`\ /' _ `\
      \ \ \_/ \/\ \L\.\_\ \ \_\ \ \_\ \_\ \ \_\ \ \//\ \L\ \/\ \/\ \
       \ `\___/\ \__/.\_\\ \____/ /\____\\ \__\\ \_\\ \____/\ \_\ \_\
        `\/__/  \/__/\/_/ \/___/  \/____/ \/__/ \/_/ \/___/  \/_/\/_/


## What?

Vaultron uses [Terraform](https://www.terraform.io/) to build a
[Consul](https://www.consul.io/) backed [Vault](https://www.vaultproject.io/)
server for development, evaluation, and issue reproduction on Docker for Mac.

## Why?

A reasonably useful Vault environment on your Mac in about 60 seconds...

## How?

Terraform assembles individual pieces to form Vaultron from the official
Consul and Vault Docker images.

### Quick Start

Make sure that you have first installed the macOS binaries for Consul, Vault,
Terraform, and Docker for Mac. After doing so, it's just 3 steps to forming
your own Vaultron:

1. Clone this repository
2. `cd vaultron`
3. `source ./form`

### What's Next?

After Vaultron is formed, some immediate next steps are available to you:


1. Execute `./vault_kitchen_sink` to initialize Vault, unseal it, and
   enable several authentication and secret backends
2. Use the `vault` CLI on your Mac to interact with your new Vault server
3. Use the [Vault HTTP API](https://www.vaultproject.io/api/index.html)
4. When done having fun, disassemble Vaultron with `./unform`

If you are familiar with Terraform you can skip the `form` and `unform`
commands and use Terraform commands instead, but you'll need to manually
specify the `CONSUL_HTTP_ADDR` and `VAULT_ADDR` environment variables:

```
export CONSUL_HTTP_ADDR="localhost:8500"
export VAULT_ADDR="http://localhost:8200"
```

## Notes and Resources

### Regarding Vault Best Practices

Please note that while this project connects the Vault instance directly to
a Consul server for the sake of simplicity, the best approach in production
is to always connect each Vault instance to a local Consul agent in
_client mode_ which in turn joins the cluster of Consul servers.

While Vault functions as expected in this configuration, the built in Vault
health checks for Consul do not work, so Vault does not register itself
into Consul as a service.

This will be addressed with a configuration that more closely matches
a best practices production setup in an upcoming release.

### Where's My Data?

Vault data is kept in Consul's key/value store, which in turn is written into
the `consul/oss_*/data` directory for each of the three Consul servers. Here
is the tree showing the first server's directory structure:

```
├── consul
│   ├── oss_one
│   │   ├── README.md
│   │   ├── config
│   │   └── data
│   │       ├── checkpoint-signature
│   │       ├── node-id
│   │       ├── raft
│   │       │   ├── peers.info
│   │       │   ├── raft.db
│   │       │   └── snapshots
│   │       └── serf
│   │           ├── local.snapshot
│   │           └── remote.snapshot
```


### Handy Links

Here are some links to the websites for technologies used in this project:

1. [Vault Docker repository](https://hub.docker.com/_/vault/)
3. [Consul Docker repository](https://hub.docker.com/_/consul/)
3. [Official Consul Docker Image blog post](https://www.hashicorp.com/blog/official-consul-docker-image/)
4. [Terraform](https://www.terraform.io/)
5. [Consul](https://www.consul.io/)
6. [Vault](https://www.vaultproject.io/)
7. [Docker for Mac](https://www.docker.com/docker-mac)

## Who?

- [Brian Shumate](http://brianshumate.com/)
