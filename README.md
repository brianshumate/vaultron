
     __  __                     ___    __
    /\ \/\ \                   /\_ \  /\ \__
    \ \ \ \ \     __     __  __\//\ \ \ \ ,_\  _ __   ___     ___
     \ \ \ \ \  /'__`\  /\ \/\ \ \ \ \ \ \ \/ /\`'__\/ __`\ /' _ `\
      \ \ \_/ \/\ \L\.\_\ \ \_\ \ \_\ \_\ \ \_\ \ \//\ \L\ \/\ \/\ \
       \ `\___/\ \__/.\_\\ \____/ /\____\\ \__\\ \_\\ \____/\ \_\ \_\
        `\/__/  \/__/\/_/ \/___/  \/____/ \/__/ \/_/ \/___/  \/_/\/_/
          ================================--------------------• • • •

> From days of long ago, from uncharted regions of the universe, comes a
> legend; the legend of Voltron, Defender of the Universe, a mighty robot,
> loved by good, feared by evil.
>
> — Voltron: Defender of the Universe

## What?

Vaultron is a toy project that uses [Terraform](https://www.terraform.io/) to build a tiny cluster of [Consul](https://www.consul.io/)-backed and highly-available [Vault](https://www.vaultproject.io/) servers for development, evaluation, and issue reproduction on [Docker](https://www.docker.com/).

## Why?

It's a reasonably cool and useful Vault environment on your macOS or Linux computer in less than 1 minute.

## How?

Terraform assembles individual pieces to form Vaultron from the official [Vault Docker image](https://hub.docker.com/_/vault/) and [Consul Docker image](https://hub.docker.com/_/consul/).

### Quick Start

Make sure that you have first installed the binaries for Consul, Vault, Terraform, and have Docker installed and configured for your system.

After doing so, it's just 3 steps to forming your own Vaultron:

1. `$ git clone https://github.com/brianshumate/vaultron.git`
2. `$ cd vaultron`
3. `$ ./form`

Note the completion message about setting important environment variables before executing the `vault` and `consul` CLI commands. You'll want these environment variables in your shell before trying to use the CLI tools with Vaultron:

```
$ export CONSUL_HTTP_ADDR="localhost:8500"
$ export VAULT_ADDR="http://localhost:8200"
```

### What's Next?

If you are new to Vault, then using Vaultron is a nice way to get quickly acquainted! Please begin by checking out the official [Vault Getting Started documentation](https://www.vaultproject.io/intro/getting-started/install.html).

You can follow along from the [Your First Secret](https://www.vaultproject.io/intro/getting-started/first-secret.html) page onwards after initializing and unsealing your Vault.

Speaking of which, here are some things you can do after Vaultron is formed:

1. Initialize Vault with `vault init`
2. Unseal Vault with `vault unseal` using 3 of the 5 unseal keys presented when you initialized Vault
3. Authenticate to Vault with the initial root token presented during initialization
4. Use your local `consul` and `vault` binaries in CLI mdoe to interact with Vault servers
5. Use the Consul web UI at [http://localhost:8500](http://localhost:8500)
6. Use the [Vault HTTP API](https://www.vaultproject.io/api/index.html)
7. When done having fun, disassemble Vaultron and clean up with `./unform`

**NOTE: `./unform` REMOVES ALMOST EVERYTHING including the existing Vault data, logs, and Terraform state — be careful!**

Note that the Terraform provider modules are not removed to save resources and time on re-downloading them.

If you want to tear down the containers, but preserve data, logs, and state, use `terraform destroy` instead:

```
$ terraform destroy -state=./tfstate/terraform.tfstate
```

If you are already familiar with Vault and would like to save time by rapidly initializing, unsealing, and enabling a wide range of authentication and secret backends, execute `./blazing_sword` to do all of this for you.

**NOTE**: This will persist the unseal keys and initial root authentication token in a file in the `vault` directory named like `./vault/vault_1500766014.tmp`.

If you are familiar with Terraform you can also use Terraform commands instead, but you'll need to manually specify the `CONSUL_HTTP_ADDR` and `VAULT_ADDR` environment variables before you can access either the Consul or Vault instances:

```
$ export CONSUL_HTTP_ADDR="localhost:8500"
$ export VAULT_ADDR="http://localhost:8200"
```

## What's in the Box?

Vaultron technical specifications quick reference card:

```
=============================================================================
-----------------------------------------------------------------------------
Name:          Vaultron
Type:          Secret Management Unit V (defaults to latest Vault software)
Builder:       Terraform
Blueprints:    vaultron.tf
Datacenter:    arus
Infra-cell:    Distributed storage cell (defaults to latest Consul software)
Universe:      Docker
Agility:       ★★★★
Damage:        ★★★
Mass:          ★★
Speed:         ★★★★★
-----------------------------------------------------------------------------
=============================================================================
```

Here are some slightly more serious notes and questions about what Vaultron is and how it can work for you.

### Basic Architecture Overview

Note that Vaultron has to work around some current networking quirks of Docker for Mac to do its thing and is only currently tested on Linux and macOS, but here is basically what you are getting:

```
+---------------+   +---------------+   +---------------+
|               |   |               |   |               |  vault_oss_server_0
|    Vault 0    |   |    Vault 1    |   |    Vault 2    |  vault_oss_server_1
|               |   |               |   |               |  vault_oss_server_2
+-------+-------+   +-------+-------+   +-------+-------+
        |                   |                   |
        |                   |                   |
        |                   |                   |
+-------v-------+   +-------v-------+   +-------v-------+
|               |   |               |   |               |  consul_oss_client_0
| Consul Client |   | Consul Client |   | Consul Client |  consul_oss_client_1
|               |   |               |   |               |  consul_oss_client_2
|               |   |               |   |               |
+-------+-------+   +-------+-------+   +-------+-------+
        |                   |                   |
        |                   |                   |
        |                   |                   |
+-------v-------+   +-------v-------+   +-------v-------+
|               |   |               |   |               |  consul_oss_server_0
| Consul Server |<->| Consul Server |<->| Consul Server |  consul_oss_server_1
|               |   |               |   |               |  consul_oss_server_2
|               |   |               |   |               |
+---------------+   +---------------+   +---------------+
```

Vaultron consists of 3 Vault server containers, 3 Consul client containers, and 3 Consul server containers. Vault servers connect directly to the Consul clients, which in turn connect to the Consul server cluster.

Note that each Vault instance is available to the local computer, but via Docker's published ports scheme only, so the addresses of the Vault servers are:

- localhost:8200
- localhost:8201
- localhost:8202

### Changing Vault and Consul Versions

Vaultron runs the `:latest` official Vault container image, but if you would prefer a prior version, you can export the `TF_VAR_vault_version` environment variable to override:

```
$ export TF_VAR_vault_version=0.6.5
$ ./form
$ ./blazing_sword
...
Version: 0.6.5
...
```

To run a different version of the Consul container, set the `TF_VAR_consul_version` environment variable like this:

```
$ export TF_VAR_consul_version=0.7.5
$ ./form
$ consul members
Node                 Address          Status  Type    Build  Protocol  DC
consul_oss_client_0  172.17.0.6:8301  alive   client  0.7.5  2         arus
consul_oss_client_1  172.17.0.7:8301  alive   client  0.7.5  2         arus
consul_oss_client_2  172.17.0.5:8301  alive   client  0.7.5  2         arus
consul_oss_server_0  172.17.0.2:8301  alive   server  0.7.5  2         arus
consul_oss_server_1  172.17.0.3:8301  alive   server  0.7.5  2         arus
consul_oss_server_2  172.17.0.4:8301  alive   server  0.7.5  2         arus
```

Be sure to always use the same versions of Consul and Vault for both  the CLI binaries and container image.

### Consul DNS

The 3 Consul servers have DNS exposed to port 53 of their internal container addresses, and the Consul clients and Vault sever containers are configured to use the Consul servers for DNS as well.

Additionally Consul DNS API is also published from the first Consul server at `localhost:8600`, so you can query services and nodes using DNS like so:

```
$ dig -p 8600 @localhost consul.service.consul
...
;; ANSWER SECTION:
consul.service.consul.  0 IN  A 172.17.0.3
consul.service.consul.  0 IN  A 172.17.0.2
consul.service.consul.  0 IN  A 172.17.0.4
```

or

```
$ dig -p 8600 @localhost active.vault.service.consul
;; ANSWER SECTION:
active.vault.service.consul. 0  IN  A 172.17.0.5
```

or

```
$ dig -p 8600 @localhost vault.service.consul SRV
;; ANSWER SECTION:
vault.service.consul. 0 IN  SRV 1 1 8200 consul_oss_client_0.node.arus.consul.
vault.service.consul. 0 IN  SRV 1 1 8200 consul_oss_client_2.node.arus.consul.
vault.service.consul. 0 IN  SRV 1 1 8200 consul_oss_client_1.node.arus.consul.
```

or

```
$ dig -p 8600 @localhost consul_oss_server_0.node.consul
...
;; ANSWER SECTION:
consul_oss_server_0.node.consul. 0 IN A 172.17.0.2
```

### Security Configuration?

Given the intended use cases for this project, the working solution that results when Vaultron is formed is essentially a blank canvas that emphasizes immediate usability over security.

There are no in-depth changes to configuration from the perspective of security by enabling Consul ACLs, end-to-end TLS, etc. In fact for Consul versions >= 0.8.0, ACLs have been explicitly opt-out via `acl_enforce_version_8` set to `false`.

Enabling ACLs and encryption is left to the user for their own specific use cases. That said, here are some resources to help you in configuring those sorts of things:

- [Consul ACL System guide](https://www.consul.io/docs/guides/acl.html)
- [Consul Encryption documentation](https://www.consul.io/docs/agent/encryption.html)
- [Vault TCP Listener documentation](https://www.vaultproject.io/docs/configuration/listener/tcp.html)

### Where's My Vault Data?

Vault data is kept in Consul's key/value store, which in turn is written into the `consul/oss_server_*/data` directories for each of the three Consul servers. Here is the tree showing the directory structure for a Consul server:

```
└── consul
    └── consul_oss_server_0
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

The Docker containers are named as shown in the [Basic Architecture Overview](#basic-architecture-overview).

You can view operational logs for any container with `docker logs` like so:

```
docker logs vault_oss_server_0
```

The Vault audit logs for each _active server_ are available as:

- `./vault/vault_oss_server_0/audit_log/audit.log`
- `./vault/vault_oss_server_1/audit_log/audit.log`
- `./vault/vault_oss_server_2/audit_log/audit.log`

### A note about custom Binaries

Vaultron installs the official open source Vault binaries, but if you'd prefer to use recent source builds or some other Vault binary, just drop `vault` into `custom/` and set these environment variables:

```
export TF_VAR_vault_oss_instance_count=0 \
       TF_VAR_vault_custom_instance_count=3
```

## Basic Troubleshooting Questions

### I Typed `vault status` and got an Error!

```
vault status
Error checking seal status: Get https://127.0.0.1:8200/v1/sys/seal-status: http: server gave HTTP response to HTTPS client
```

If your Vaultron successfully formed, then this is likely due to not exporting the environment variables shown at the conclusion of `./form`:

```
export CONSUL_HTTP_ADDR="localhost:8500"
export VAULT_ADDR="http://localhost:8200"
```

Once you execute the above, you should be good to go!

### Vault is Orange/Failing in the Consul Web UI

If you have not yet unsealed Vault, it is expected to appear as failing in the Consul UI. Unsealing Vault should solve that.

### Something Something HA Problem!

High Availability mode has been shown to work as expected, however because of the current published ports method for exposing the Vault servers, you must be sure to point your client to the correct Vault server with `VAULT_ADDR` once that server becomes the new active server.

Here is simple method to watch HA mode in action using two terminal sessions:

```
Terminal 1                              Terminal 2
+-----------------------------------+   +------------------------------------+
| VAULT_ADDR=http://localhost:8201 \|   | docker stop vault_oss_server_0     |
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

1. In Terminal 1, set `VAULT_ADDR` to one of the two Vault standby containers and use `watch` to keep an eye on the output of `vault status` while noting the values of `Mode:` and `Leader:`
2. In Terminal 2, stop the *active* Vault instance with `docker stop`
3. You should notice that the value of `Leader:` changes instantly and if the second standby Vault is elected the new active, the value of `Mode:` will also reflect that instantly as well

### Vaultron Does Not Form — Halp!

Instead of seeing the glorious interlocks activated, dyna-therms connected, infra-cells up, and mega-thrusters going, Vaultron fails to form and I get:

```
🚫  Vaultron cannot form! Check terraform apply output.
```

or this:

```
🚫  Vaultron cannot form! Check terraform plan output.
```

This means that Vaultron had problems durring the `terraform plan` or `terraform apply` steps. You can run those commands manually and inspect their output to troubleshoot the issue.

Other red and equally frightening errors could occur, and these are usually accompanied by an explanation from Terraform regarding the nature of the problem.

### Unsupported Versions?

If you try exporting `TF_VAR_consul_version` or `TF_VAR_vault_version` to a specific version, but get this error when you attempt to form Vaultron:

```
🚫  Sorry, Vaultron does not support Consul version: 0.6.4
```

or:

```
🚫  Sorry, Vaultron does not support Vault version: 0.6.0
```

You are specifying either a non-existent version (maybe a typo?) or you are specifying a version for which no Docker images exists. This second case is not a problem with Vaultron, there are some versions of Consul and Vault which were released as binaries, but not available as Docker images.

## Resources

Here are some links to resources for the technologies used in this project:

1. [Vault Docker Hub repository](https://hub.docker.com/_/vault/)
2. [hashicorp/docker-consul](https://github.com/hashicorp/docker-consul)
3. [Consul Docker Hub repository](https://hub.docker.com/_/consul/)
4. [hashicorp/docker-vault](https://github.com/hashicorp/docker-vault)
5. [Consul ACL System guide](https://www.consul.io/docs/guides/acl.html)
6. [Consul Encryption documentation](https://www.consul.io/docs/agent/encryption.html)
7. [Official Consul Docker Image blog post](https://www.hashicorp.com/blog/official-consul-docker-image/)
8. [Terraform](https://www.terraform.io/)
9. [Consul](https://www.consul.io/)
10. [Vault](https://www.vaultproject.io/)
11. [Vault TCP Listener documentation](https://www.vaultproject.io/docs/configuration/listener/tcp.html)
12. [Docker](https://www.docker.com/)

## Who?

Vaultron was created by [Brian Shumate](https://github.com/brianshumate) and made possible through the generous time of the good people named in [CONTRIBUTORS.md](https://github.com/brianshumate/vaultron/blob/master/CONTRIBUTORS.md)
