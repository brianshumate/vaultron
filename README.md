
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
3. `. ./form`

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


**NOTE: `./unform` REMOVES EVERYTHING including the existing Vault data, logs,
and Terraform state — be careful!**

If you want to tear down the containers, but preserve data, logs, and state,
use `terraform destroy` instead:

```
terraform destroy -state=./tfstate/terraform.tfstate
```

If you are already familiar with Vault and would like to save time by
rapidly initializing, unsealing, and enabling a wide range of authentication
and secret backends, execute `./blazing_sword` to do all of this for you.

**NOTE**: This will persist the unseal keys and initial root authentication
token in a file in the `vault` directory named like
`./vault/vault_1500766014.tmp`.

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
+---------------+   +---------------+   +---------------+
|               |   |               |   |               |  vault_oss_server_1
|   Vault One   |   |   Vault Two   |   |  Vault Three  |  vault_oss_server_2
|               |   |               |   |               |  vault_oss_server_3
+-------+-------+   +-------+-------+   +-------+-------+
        |                   |                   |
        |                   |                   |
        |                   |                   |
+-------v-------+   +-------v-------+   +-------v-------+
|               |   |               |   |               |  consul_oss_client_1
| Consul Client |   | Consul Client |   | Consul Client |  consul_oss_client_2
|     One       |   |     Two       |   |    Three      |  consul_oss_client_3
|               |   |               |   |               |
+-------+-------+   +-------+-------+   +-------+-------+
        |                   |                   |
        |                   |                   |
        |                   |                   |
+-------v-------+   +-------v-------+   +-------v-------+
|               |   |               |   |               |  consul_oss_server_1
| Consul Server |<->| Consul Server |<->| Consul Server |  consul_oss_server_2
|     One       |   |     Two       |   |    Three      |  consul_oss_server_3
|               |   |               |   |               |
+---------------+   +---------------+   +---------------+
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

> NOTE: When you source the `./form` script, it sets `VAULT_ADDR` to `http://localhost:8200` by default.

### Access Control Lists and Transport Layer Security

Given the intended use cases for this project, the working solution is
essentially a blank canvas, so there are no in-depth changes to configuration
from the perspective of Consul ACLs, end-to-end TLS, and so on.

Those kinds of changes are left to configuration as developed by the user for
their own specific use cases. That said, here are some resources for configuring those sorts of things:

- [Consul ACL System guide](https://www.consul.io/docs/guides/acl.html)
- [Consul Encryption documentation](https://www.consul.io/docs/agent/encryption.html)
- [Vault TCP Listener documentation](https://www.vaultproject.io/docs/configuration/listener/tcp.html)

### Where are the Data?

Vault data is kept in Consul's key/value store, which in turn is written into
the `consul/oss_server_*/data` directories for each of the three Consul
servers. Here is the tree showing the directory structure for both a Consul
client and server:

```
└── consul
    ├── consul_oss_client_1
    │   ├── config
    │   │   └── extra_config.hcl
    │   └── data
    │       ├── checkpoint-signature
    │       ├── checks
    │       │   ├── f6c7ee2019ed6055eef2b3e4facb36eb
    │       │   └── state
    │       │       └── f6c7ee2019ed6055eef2b3e4facb36eb
    │       ├── node-id
    │       ├── serf
    │       │   └── local.snapshot
    │       └── services
    │           └── 9d6114573a8a933df24da735fca223cf
    ├...
    └── consul_oss_server_1
        ├── config
        │   └── extra_config.hcl
        └── data
            ├── checkpoint-signature
            ├── node-id
            ├── raft
            │   ├── peers.info
            │   ├── raft.db
            │   └── snapshots
            └── serf
                ├── local.snapshot
                └── remote.snapshot
```

### What About Logs?

The Docker containers are named as shown in the Basic Architecture Overview.

You can view operational logs for any container with `docker logs` like so:

```
docker logs vault_oss_server_1
```

The Vault audit logs for each _active server_ are available as:

- `./vault/vault_oss_server_1/audit_log/audit.log`
- `./vault/vault_oss_server_2/audit_log/audit.log`
- `./vault/vault_oss_server_3/audit_log/audit.log`

## Basic Troubleshooting Questions

### Vault is Orange/Failing in the Consul Web UI

If you have not yet unsealed Vault, it will appear as failing in the Consul
UI, but simply unsealing it should solve that.

### Something Something HA Problem!

High Availability mode has been shown to work as expected, however because
of the current published ports method for exposing the Vault servers,
you must be sure to point your client to the correct Vault server
with `VAULT_ADDR` once that server becomes the new active server.

Here is simple method to watch HA mode in action using two terminal sessions:

```
Terminal 1                              Terminal 2
+-----------------------------------+   +------------------------------------+
| VAULT_ADDR=http://localhost:8201 \|   | docker stop vault_oss_server_1     |
| watch -n 1 vault status           |   |                                    |
|                                   |   |                                    |
| ...                               |   |                                    |
| High-Availability Enabled: true   |   |                                    |
|         Mode: standby             |   |                                    |
|         Leader: http://172.17...  |   |                                    |
| ...                               |   |                                    |
|                                   |   |                                    |
|                                   |   |                                    |
+-----------------------------------+   +------------------------------------+
```

1. In Terminal 1, set `VAULT_ADDR` to one of the two Vault standby containers
   and use `watch` to keep an eye on the output of `vault status`
   while noting the values of `Mode:` and `Leader:`
2. In Terminal 2, stop the *active* Vault instance with `docker stop`
3. You should notice that the value of `Leader:` changes instantly and if
   the second standby Vault is elected the new active, the value of `Mode:`
   will also reflect that instantly as well

### Vaultron Does Not Form, Halp!

Instead of seeing the glorious interlocks activated, dyna-therms connected,
infra-cells up, and mega-thrusters going, Vaultron fails to form and I get:

```
🚫  Vaultron cannot form! Check terraform plan output.
```

or this:

```
🚫  Vaultron cannot form! Check terraform plan output.
```

This means that Vaultron had problems durring the `terraform plan` or
`terraform apply` steps. You can run those commands manually and inspect their
output to troublshoot the issue.

## Resources

Here are some links to the websites for technologies used in this project:

1. [Vault Docker repository](https://hub.docker.com/_/vault/)
2. [Consul Docker repository](https://hub.docker.com/_/consul/)
3. [Consul ACL System guide](https://www.consul.io/docs/guides/acl.html)
4. [Consul Encryption documentation](https://www.consul.io/docs/agent/encryption.html)
5. [Official Consul Docker Image blog post](https://www.hashicorp.com/blog/official-consul-docker-image/)
6. [Terraform](https://www.terraform.io/)
7. [Consul](https://www.consul.io/)
8. [Vault](https://www.vaultproject.io/)
9. [Vault TCP Listener documentation](https://www.vaultproject.io/docs/configuration/listener/tcp.html)
10. [Docker for Mac](https://www.docker.com/docker-mac)

## Who?

- [Brian Shumate](http://brianshumate.com/)
