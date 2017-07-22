
     __  __                     ___    __
    /\ \/\ \                   /\_ \  /\ \__
    \ \ \ \ \     __     __  __\//\ \ \ \ ,_\  _ __   ___     ___
     \ \ \ \ \  /'__`\  /\ \/\ \ \ \ \ \ \ \/ /\`'__\/ __`\ /' _ `\
      \ \ \_/ \/\ \L\.\_\ \ \_\ \ \_\ \_\ \ \_\ \ \//\ \L\ \/\ \/\ \
       \ `\___/\ \__/.\_\\ \____/ /\____\\ \__\\ \_\\ \____/\ \_\ \_\
        `\/__/  \/__/\/_/ \/___/  \/____/ \/__/ \/_/ \/___/  \/_/\/_/


> From days of long ago, from uncharted regions of the universe, comes a
> legend; the legend of Voltron, Defender of the Universe, a mighty robot,
> loved by good, feared by evil.
>
> — Voltron: Defender of the Universe

## What?

Vaultron is a toy project that uses [Terraform](https://www.terraform.io/)
to build a tiny cluster of [Consul](https://www.consul.io/) backed
[Vault](https://www.vaultproject.io/) servers for development, evaluation,
and issue reproduction on [Docker for Mac](https://www.docker.com/docker-mac).

## Why?

A reasonably cool and useful Vault environment on macOS in about 60 seconds...

## How?

Terraform assembles individual pieces to form Vaultron from the official
[Consul Docker image](https://hub.docker.com/_/consul/) and
[Vault Docker image](https://hub.docker.com/_/vault/).

### Quick Start

Make sure that you have first installed the macOS binaries for Consul, Vault,
Terraform, and Docker for Mac. After doing so, it's just 3 steps to forming
your own Vaultron:

1. Clone this repository
2. `cd vaultron`
3. `source ./form`

### What's Next?

If you are new to Vault, then using Vaultron is a nice way to get quickly
acquainted! Be sure to also check out the official [Vault
Getting Started documentation](https://www.vaultproject.io/intro/getting-started/install.html) as well.

You can follow along from the [Your First Secret](https://www.vaultproject.io/intro/getting-started/first-secret.html) page onwards after initializing and
unsealing your Vault.

Speaking of which, here are some things you can do after Vaultron is formed:

1. Initialize Vault with `vault init`
2. Unseal Vault with `vault unseal` using 3 of the 5 unseal keys presented
   when you initialized Vault
3. Authenticate to Vault with the initial root token presented during
   initialization
4. Use the `vault` CLI on your Mac to interact with your new Vault servers
5. Use the Consul web UI at [http://localhost:8500](http://localhost:8500)
6. Use the [Vault HTTP API](https://www.vaultproject.io/api/index.html)
7. When done having fun, disassemble Vaultron and clean up with `./unform`

<Warning>
**NOTE: `./unform` removes the existing Vault data — be careful!**
</Warning>

If you are already familiar with Vault and would like to save time by
rapidly initializing, unsealing, and enabling a wide range of authentication
and secret backends, execute `./blazing_sword` to do all of this for you.

If you are familiar with Terraform you also can skip the `form` and `unform`
commands and just use Terraform commands instead, but you'll need to manually
specify the `CONSUL_HTTP_ADDR` and `VAULT_ADDR` environment variables
before you can access either the Consul or Vault instances, however:

```
export CONSUL_HTTP_ADDR="localhost:8500"
export VAULT_ADDR="http://localhost:8200"
```

## What's in the Box?

Here are some notes and questions about what Vaultron is and how it works.

### Basic Architecture Overview

Vaultron has to work around some quirks of Docker on Mac to do its thing, but
here is basically what you are getting:

```
+---------------+ +---------------+ +---------------+
|               | |               | |               |
|   Vault One   | |   Vault Two   | |  Vault Three  |
|               | |               | |               |
+-------+-------+ +-------+-------+ +-------+-------+
        |                 |                 |
        |                 |                 |
        |                 |                 |
+-------v-------+ +-------v-------+ +-------v-------+
|               | |               | |               |
| Consul Client | | Consul Client | | Consul Client |
|     One       | |     Two       | |    Three      |
|               | |               | |               |
+-------+-------+ +-------+-------+ +-------+-------+
        |                 |                 |
        |                 |                 |
        |                 |                 |
+-------v-------+ +-------v-------+ +-------v-------+
|               | |               | |               |
| Consul Server | | Consul Server | | Consul Server |
|     One       | |     Two       | |    Three      |
|               | |               | |               |
+---------------+ +---------------+ +---------------+
```

Vaultron consists of three Vault server containers, three Consul client
containers, and three Consul server containers. Vault servers connect
directly to the Consul clients, and the Consul clients connect to the
Consul server cluster.

Note that each Vault instance is available to the Mac locally, but via
published ports scheme only, so the addresses of the Vault servers are:

- localhost:8200
- localhost:8201
- localhost:8202

When you `source ./form` Vaultron, `VAULT_ADDR` will be set to
`http://localhost:8200`.

### Where's the Data?

Vault data is kept in Consul's key/value store, which in turn is written into
the `consul/oss_*/data` directory for each of the three Consul servers. Here
is the tree showing the first server's directory structure:

```
├── consul
│   ├── oss_server_one
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

### What About Logs?

The Docker containers are named as follows:

- vault_oss_server_1
- vault_oss_server_2
- vault_oss_server_3
- consul_oss_client_1
- consul_oss_client_2
- consul_oss_client_3
- consul_oss_server_1
- consul_oss_server_2
- consul_oss_server_3

You can view operational logs for any container with `docker logs` like so:

```
docker logs vault_oss_server_1
```

The Vault audit logs for each server are available as:

- `./vault/oss_one/audit_log/audit.log`
- `./vault/oss_two/audit_log/audit.log`
- `./vault/oss_three/audit_log/audit.log`

## Basic Troubleshooting Questions

### Vault is Orange/Failing in the Consul Web UI

If you have not yet unsealed Vault, it will appear as failing in the Consul
UI, but simply unsealing it should solve that.

### Something Something HA Problem!

High Availability mode has not been well tested, and no promises can currently
be made about HA functionality at this time. It does work as expected, however
you must be sure to point your client to the correct Vault server
with `VAULT_ADDR` once that server is the new active server.

## Resources

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
