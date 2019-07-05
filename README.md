# Vaultron

![](https://github.com/brianshumate/vaultron/blob/master/share/vaultron.png?raw=true)

## What?

**Vaultron** uses [Terraform](https://www.terraform.io/) (version 0.12.0+ required) to build a tiny cluster of [Consul](https://www.consul.io/)-backed and highly-available [Vault](https://www.vaultproject.io/) servers for development, evaluation, and issue reproduction on [Docker](https://www.docker.com/).

> **NOTE**: While every effort is made to document Vaultron here in this file, you should **always consult the [official Vault documentation](https://www.vaultproject.io/docs/)** and **[Learn resources](https://learn.hashicorp.com/vault/) for the latest and complete documentation on using Vault itself**.

## Why?

It's a reasonably useful Vault & Consul environment deployed on your macOS or Linux computer _in a about 1 minute_.

Some of the more popular uses of Vaultron are:

- Getting acquainted with Vault
- Evaluating specific Vault features
- Issue reproduction and troubleshooting
- Testing
- ‼️ **NOT FOR PRODUCTION** ‼️

## How?

Terraform assembles individual pieces to form Vaultron from the official [Vault Docker image](https://hub.docker.com/_/vault/) and [Consul Docker image](https://hub.docker.com/_/consul/).

### Prerequisites

> **NOTE**: **Vaultron only supports Terraform version 0.12.0 and beyond** and is incompatible with previous Terraform versions.

Install the following on the system where you will form Vaultron:

- [Docker CE for Linux](https://docs.docker.com/v17.12/install/#server) **or**
- [Docker Desktop for macOS](https://www.docker.com/products/docker-desktop)
- [Consul](https://www.consul.io/)
  - [OSS consul binaries](https://releases.hashicorp.com/consul/1.5.2/)
- [Terraform](https://www.terraform.io/) (version 0.12.0+ required)
  - [OSS terraform binaries](https://releases.hashicorp.com/terraform/0.12.3/)
- [Vault](https://www.vaultproject.io/)
  - [OSS vault binaries](https://releases.hashicorp.com/vault/1.1.3/)

### Quickest Start for macOS

Once you have the prerequisites installed, you can use the following example to form Vaultron and open the the Vault web UI in your browser on macOS.

You will likely be prompted for your password to add the Vaultron CA certificate to the System Keychain. This will prevent TLS errors about an untrusted CA certificate when using the Consul and Vault web UIs:

```
$ git clone https://github.com/brianshumate/vaultron.git && \
  cd vaultron && \
  ./form && \
  . ./ion_darts && \
  ./blazing_sword && \
  sudo security add-trusted-cert -d -r trustAsRoot \
  -k /Library/Keychains/System.keychain ./etc/tls/ca.pem && \
  open https://localhost:8200
```

> **NOTE**: The `blazing_sword` script persists unseal keys and initial root authentication token to a file in the `vault` folder named like `./vault/vault_1500766014.tmp`. If this behavior makes you feel some type of way, you are welcome at any time to put Vaultron down and pick up another toy project instead.

### Quick Start for Linux or macOS

Vaultron uses the latest Consul and Vault versions by default, so make sure that you have also installed the latest binaries for [Consul](https://releases.hashicorp.com/consul/), [Vault](https://releases.hashicorp.com/vault/), and [Terraform](https://releases.hashicorp.com/terraform/) locally, and that you have have [Docker](https://docs.docker.com/install/) installed as well.

After doing so, it takes just 3 steps to form Vaultron:

1. `$ git clone https://github.com/brianshumate/vaultron.git`
2. `$ cd vaultron`
3. `$ ./form`

When Vaultron is successfully formed, the output looks like this:

```
[vaultron] [=] Form Vaultron! ...
[vaultron] [i] Terraform has been successfully initialized!
[vaultron] [i] Vault OSS version: 1.1.3
[vaultron] [i] Consul OSS version: 1.5.1
[vaultron] [i] Terraform plan: 14 to add, 0 to change, 0 to destroy.
[vaultron] [i] Terraform apply complete! resources: 14 added, 0 changed, 0 destroyed.
[vaultron] [+] Vaultron formed!

You can now visit the Vault web UI at https://localhost:8200

or visit the Consul web UI at https://localhost:8500

You can also interact with vault and consul CLI utilities after
exporting the following environment variables in your shell:

export CONSUL_HTTP_ADDR="127.0.0.1:8500"
export CONSUL_HTTP_SSL=true
export VAULT_ADDR="https://127.0.0.1:8200"
export CONSUL_HTTP_TOKEN="b4c0ffee-3b77-04af-36d6-738b697872e6"

or use this command to do it for you:

. ./ion_darts
```

You are now nearly ready to interact with Vault and Consul using their web user interfaces, command line interfaces, or HTTP APIs.

Take a moment to verify that all of the Vaultron Docker containers are up:

```
$ docker ps -f name=vaultron --format "table {{.Names}}\t{{.Status}}"
NAMES               STATUS
vaultron-vault2     Up 7 minutes
vaultron-vault0     Up 7 minutes
vaultron-vault1     Up 7 minutes
vaultron-consulc2   Up 7 minutes
vaultron-consulc0   Up 7 minutes
vaultron-consulc1   Up 7 minutes
vaultron-consuls1   Up 7 minutes
vaultron-consuls0   Up 7 minutes
vaultron-consuls2   Up 7 minutes
```

Note there is a message from the `form` script about setting important environment variables before executing the `vault` and `consul` CLI commands. You'll want these environment variables in your shell before trying to use the CLI tools with Vaultron:

```
$ export CONSUL_CACERT="$(pwd)/red_lion/tls/ca.pem" \
  CONSUL_HTTP_ADDR="127.0.0.1:8500" \
  CONSUL_HTTP_SSL=true \
  CONSUL_HTTP_TOKEN="b4c0ffee-3b77-04af-36d6-738b697872e6" \
  VAULT_ADDR="https://127.0.0.1:8200" \
  VAULT_CA_CERT="$(pwd)/black_lion/tls/ca.pem"
```

You can instead source the `ion_darts` script to do all of this for you:

```
$ . ./ion_darts
[^] Exported Vaultron environment variables!
```

> **NOTE**: Before accessing the Vault or Consul web UIs you should add the Vaultron Certificate Authority (CA) certificate to your OS trust store. It is located under the root of this project at `etc/tls/ca.pem`.

See the **TLS by Default** section for more details on handling the Vaultron Certificate Authority certificate.

### What's Next?

If you are new to Vault, then using Vaultron is a nice way to quickly get acquainted! Please begin by checking out the official [Vault Getting Started Guide](https://learn.hashicorp.com/vault/?track=getting-started#getting-started).

#### Ten Things You Can do After Vaultron is Formed

1. Initialize Vault with `vault operator init`
2. Unseal Vault with `vault operator unseal` using 3 of the 5 unseal keys presented when you initialized Vault
3. Authenticate to Vault with the initial root token presented during initialization
4. After initializing and unsealing your vault, and then authenticating with the root token, you can follow along with the [Your First Secret](https://learn.hashicorp.com/vault/getting-started/first-secret) page
5. Use your local `consul` and `vault` binaries in CLI mode to interact with Vault servers
6. Use the Vault web UI at [https://localhost:8200](https://localhost:8200)
7. Use the Consul web UI at [https://localhost:8500](https://localhost:8500)
8. Use the [Vault HTTP API](https://www.vaultproject.io/api/index.html)
9. Check out and experiment with the examples in the `examples` folders
10. Clean up or reset: disassemble Vaultron and clean up Vault data with `./unform`

> **NOTE: The `unform` script attempts to remove most data generated while using Vaultron, including the existing Vault data, logs, and Terraform state — be careful!** On Linux, generated data will likely be created as uid 0 which means `unform` will fail and the data in `vault/` and `consul/` subdirectories will need to be manually removed before attempting to `unform` or `form` again; this will be improved in a future release.

The Terraform provider modules _are not removed_ to save on resources and time involved in re-downloading them.

If you want to tear down the containers, but preserve data, logs, and state, you can use `terraform destroy` for that instead:

```
$ terraform destroy -state=./tfstate/terraform.tfstate
```

If you are already familiar with Vault, but would like to save time by rapidly initializing, unsealing, and enabling a wide range of authentication and secret backends, execute the `./blazing_sword` script to do all of this for you. `blazing_sword` uses the additional Terraform configuration in `blazing_sword/main.tf`.

If you are familiar with Terraform you can also use Terraform commands instead, but you'll need to manually specify the `CONSUL_HTTP_ADDR` and `VAULT_ADDR` environment variables before you can access either the Consul or Vault instances:

```
$ export CONSUL_HTTP_ADDR="127.0.0.1:8500"
$ export CONSUL_HTTP_SSL=true
$ export VAULT_ADDR="https://127.0.0.1:8200"
$ export CONSUL_HTTP_TOKEN="b4c0ffee-3b77-04af-36d6-738b697872e6"
```

### Advanced Example

The following is a more advanced example of forming Vaultron; it uses a range of environment variables to define additional configuration and includes the statsd + Graphite + Grafana telemetry stack container to visualize Vault telemetry.

```
export \
  TF_VAR_consul_custom=0 \
  TF_VAR_vault_oss_instance_count=0 \
  TF_VAR_vault_custom_instance_count=3 \
  TF_VAR_vaultron_telemetry_count=1 \
  TF_VAR_vault_server_log_level=trace \
  TF_VAR_consul_log_level=err
```

What this does line by line:

- Enable zero custom Consul instances (custom Consul binary feature not available yet)
- Enable 3 custom binary based Vault instances which use the binary you place into the `custom` folder
- Enable the statsd/Graphite/Grafana telemetry container
- Set Vault log level to _trace_
- Set Consul log level to _err_

## What's in the Box?

Whimsical Vaultron technical specification quick reference card:

```
Name:          Vaultron
Type:          Secret Management Unit (defaults to latest Vault software)
Builder:       Terraform
Blueprints:    vaultron.tf
Modules:       black_lion, red_lion, yellow_lion
Datacenter:    arus
Infra-cell:    Distributed storage cell (defaults to latest Consul software)
Universe:      Docker
Telemetry:     statsd, Graphite, Grafana (optional)
HashiStack:    ★★★
Agility:       ★★★★
Damage:        ★★
Mass:          ★★
Speed:         ★★★★★
```

Here are some slightly more serious notes and questions about what Vaultron is and how it can work for you.

### Basic Architecture Overview

Vaultron has to work around some current networking quirks of Docker for Mac to do its thing and is only currently tested to function on Linux and macOS, but here is basically what you are getting by default:

```
+------------+--------------------------------------------------+------------+
|            |              Yellow Lion (optional)              |            |
| __     __  |    +-----------------------------------------+   |            |
| \ \   / /  |    |                                         |   |            |
|  \ \ / /   |    |            Grafana Dashboard            |   |            |
|   \ V /    |    +-----------------------------------------+   |            |
|    \_/     |    |                                         |   |            |
|            |    |            statsd / Graphite            |   |            |
|            |    +--^-----------------^------------------^-+   |            |
|            +--------------------------------------------------+            |
|                    |                 |                  |                  |
+----------------------------------------------------------------------------+
|  Black Lion        |                 |                  |                  |
|  +-----------------+--+   +----------+---------+   +----+---------------+  |
|  |                    |   |                    |   |                    |  |
|  |  Vault (active)    |   |  Vault (standby)   |   |  Vault (standby)   |  |
|  |                    <---+                    |   |                    |  |
|  |  vaultron-vault0   |   |  vaultron-vault1   |   |  vaultron-vault2   |  |
|  |                    |   |                    |   |                    |  |
|  |                    <----------------------------+                    |  |
|  +---------------+--^-+   +--------------^--+--+   +---------------+--^-+  |
|                  |  |                    |  |                      |  |    |
+----------------------------------------------------------------------------+
|  Red Lion        |  |                    |  |                      |  |    |
|                  |  |                    |  |                      |  |    |
|  +---------------v--+-+   +--------------+--v--+   +---------------v--+-+  |
|  | Consul client      |   | Consul client      |   | Consul client      |  |
|  |                    |   |                    |   |                    |  |
|  | vaultron-consulc0  |   | vaultron-consulc1  |   | vaultron-consulc2  |  |
|  +-------^--+---------+   +-------^--+---------+   +-------^--+---------+  |
|          |  |                     |  |                     |  |            |
|          |  |                     |  |                     |  |            |
|  +-------+--v---------+   +-------+--v---------+   +-------+--v---------+  |
|  | Consul server      +---> Consul server      <---+ Consul server      |  |
|  |                    |   |                    |   |                    |  |
|  | vaultron-consuls0  <---+ vaultron-consuls1  +---> vaultron-consuls2  |  |
|  +--------------------+   +--------------------+   +--------------------+  |
+----------------------------------------------------------------------------+
```

Vaultron consists of 3 Vault server containers, 3 Consul client containers, and 3 Consul server containers.

An optional telemetry gathering and graphing stack (Yellow Lion) can be enabled at runtime via environment variable; see the **Telemetry Notes** section for more details.

Vault servers connect directly to the Consul clients, which in turn connect to the Consul server cluster. In this configuration, Vault is using Consul for both storage and high availability functionality.

### Environment Variables

Vaultron uses environment variables to override Terraform configuration items. You can use these to fine-tune the attributes of your own particular Vaultron.

Here are the names and purposes of each:

#### TF_VAR_vault_version

Vault OSS version to use

> NOTE: Setting this has no effect when the value of `TF_VAR_vault_custom_instance_count` is greater than zero as the custom binary itself then determines the version used.

- Default: latest OSS version

#### TF_VAR_consul_version

Consul OSS version to use; currently Vaultron can use _only_ Consul OSS versions.

- Default: latest OSS version

#### TF_VAR_datacenter_name

Vault datacenter name

- Default: `arus`

#### TF_VAR_use_vault_oss

`1` to use OSS Vault binaries from releases.hashicorp.com or `0` when using custom binaries

- Default: `1`

#### TF_VAR_vault_server_log_level

A valid Vault log level: _trace_, _debug_, _info_, _warning_, or _error_

- Default: `debug`

#### TF_VAR_consul_log_level

A valid Consul log level: _trace_, _debug_, _info_, _warn_, or _err_

- Default: `debug`

#### TF_VAR_vault_path

Set `path` value for storage stanza

- Default: `vault`

#### TF_VAR_vault_cluster_name

Cluster name

- Default: `vaultron`

#### TF_VAR_disable_clustering

Disable Consul HA clustering

- Default `false`

#### TF_VAR_vault_oss_instance_count

Number of Vault OSS containers

- Default: `3`

> NOTE: You must also set `TF_VAR_vault_custom_instance_count=0` when setting this.

#### TF_VAR_vault_custom_instance_count

Number of Vault custom containers

- Default: `0`

> NOTE: You must also set `TF_VAR_vault_oss_instance_count=0` when setting this.

#### TF_VAR_vault_custom_config_template

Specify an alternative configuration file template in `black_lion/templates/custom`

- Default: `vault_config_custom.tpl`

#### TF_VAR_use_consul_oss

- Default: `1`

#### TF_VAR_consul_recursor_1

DNS recursor 1

-Default: `1.1.1.1`


#### TF_VAR_consul_recursor_2

DNS recursor 2

- Default: `1.0.0.1`


#### TF_VAR_consul_acl_datacenter

Consul datacenter name

- Default: `arus`


#### TF_VAR_consul_data_dir

- Default: `/consul/data`


#### TF_VAR_consul_oss

`1` to use OSS Vault binaries from releases.hashicorp.com (currently only option)

- Default: `1`

#### TF_VAR_consul_oss_instance_count

Number of Consul OSS containers

- Default: `3`


#### TF_VAR_consul_oss

- Default: `0`


#### TF_VAR_consul_custom_instance_count

- Default: `0`


### Published Ports

Each Vault instance is available to the local computer, but through Docker's published ports scheme only, so the API addresses of the Vault servers are:

- `https://localhost:8200`
- `https://localhost:8210`
- `https://localhost:8220`

The cluster port (for the Active instance only) is also forwarded to localhost at `https://localhost:8201`

### Changing Vault OSS and Consul OSS Versions

Vaultron runs the `:latest` official Vault Docker container image, but if you would prefer to run a different _OSS version_, you can export the `TF_VAR_vault_version` environment variable to override:

```
$ export TF_VAR_vault_version=0.6.5
$ ./form
...
[vaultron] [i] Vault OSS version: 0.6.5
...
```

Similarly, to run a different version of the Consul container, set the `TF_VAR_consul_version` environment variable like this:

```
$ export TF_VAR_consul_version=0.7.5
$ ./form
# ...
$ consul members
Node      Address          Status  Type    Build  Protocol  DC    Segment
consuls0  172.17.0.2:8301  alive   server  0.7.5  2         arus  <all>
consuls1  172.17.0.3:8301  alive   server  0.7.5  2         arus  <all>
consuls2  172.17.0.4:8301  alive   server  0.7.5  2         arus  <all>
vault0    172.17.0.5:8301  alive   client  0.7.5  2         arus  <default>
vault1    172.17.0.7:8301  alive   client  0.7.5  2         arus  <default>
vault2    172.17.0.6:8301  alive   client  0.7.5  2         arus  <default>
```

> **NOTE**: Be sure to always use the same versions of Consul and Vault binaries on your host system and the container image.

This changes the OSS version only; when using a custom Vault binary, the binary itself determines the version; see the **A note about custom Binaries** section for more details about using custom binaries.

Also note that if the OSS version of Consul or Vault you want to use does not have an official Docker image available, you'll encounter an error.

### Consul DNS

The 3 Consul servers have DNS exposed to port 53 of their internal container addresses, and the Consul clients and Vault sever containers are configured to use those Consul servers for DNS as well.

Additionally Consul DNS API is also published from the first Consul server at `localhost:8600`, so you can query services and nodes using DNS like so:

```
$ dig -p 8600 @localhost consul.service.consul
...
;; ANSWER SECTION:
consul.service.consul.  0   IN  A   172.17.0.4
consul.service.consul.  0   IN  A   172.17.0.3
consul.service.consul.  0   IN  A   172.17.0.2

;; ADDITIONAL SECTION:
consul.service.consul.  0   IN  TXT "consul-network-segment="
consul.service.consul.  0   IN  TXT "consul-network-segment="
consul.service.consul.  0   IN  TXT "consul-network-segment="
...
```

or

```
$ dig -p 8600 @localhost active.vault.service.consul
...
;; ANSWER SECTION:
active.vault.service.consul. 0  IN  A   172.17.0.7

;; ADDITIONAL SECTION:
active.vault.service.consul. 0  IN  TXT "consul-network-segment="
...
```

or

```
$ dig -p 8600 @localhost vault.service.consul SRV
...
;; ANSWER SECTION:
vault.service.consul.   0   IN  SRV 1 1 8200 vault1.node.arus.consul.
vault.service.consul.   0   IN  SRV 1 1 8200 vault2.node.arus.consul.
vault.service.consul.   0   IN  SRV 1 1 8200 vault0.node.arus.consul.

;; ADDITIONAL SECTION:
vault1.node.arus.consul. 0  IN  A   172.17.0.6
vault1.node.arus.consul. 0  IN  TXT "consul-network-segment="
vault2.node.arus.consul. 0  IN  A   172.17.0.5
vault2.node.arus.consul. 0  IN  TXT "consul-network-segment="
vault0.node.arus.consul. 0  IN  A   172.17.0.7
vault0.node.arus.consul. 0  IN  TXT "consul-network-segment="
...
```

or

```
$ dig -p 8600 @localhost consuls0.node.consul
...
;; ANSWER SECTION:
consuls0.node.consul.   0   IN  A   172.17.0.2

;; ADDITIONAL SECTION:
consuls0.node.consul.   0   IN  TXT "consul-network-segment="
...
```

### Security Configuration?

Given the intended use cases for this project, the working solution that results when Vaultron is formed is essentially a blank canvas that emphasizes immediate unhindered usability over security.

#### Consul ACLs by Default

> **Consul ACLs with a **default allow policy** are enabled for Vaultron v1.8.0 (using Vault v0.9.5/Consul v1.0.6) and beyond**

This was chosen to allow for ease of experimentation with ACL policies and the Vault Consul Secrets Engine. It is not the same as a production installation because it makes use of a shared **acl_master_token** for ease of configuration.

The value used for the shared ACL Master Token is:

- `b4c0ffee-3b77-04af-36d6-738b697872e6`

#### TLS by Default

Vaultron uses self-signed certificates for full mutual TLS communication between Vault servers and Consul agents. The certificates and keys were generated from Vault PKI Secrets Backends as described in [examples/tls/README.md](https://github.com/brianshumate/vaultron/blob/master/examples/tls/README.md).

With this in mind, you need to ensure that the certificate authority is recognized by Vault and Consul; you can do this in a number of ways:

1. Import the `black_lion/tls/ca-pundle.pem` into your OS trust store
2. For Vault: use the `VAULT_CACERT` environment variable
3. For Vault: Pass `-ca-cert=` option with path to the `ca-pundle.pem` for all `vault` commands
4. For Consul: use the `CONSUL_CACERT` environment variable
5. For Consul: pass the `-ca-file=` option with path to the `ca-pundle.pem` for all `consul` commands

Here are some additional resources related to configuring ACLs and TLS:

- [Consul ACL System guide](https://www.consul.io/docs/guides/acl.html)
- [Consul Encryption documentation](https://www.consul.io/docs/agent/encryption.html)
- [Vault TCP Listener documentation](https://www.vaultproject.io/docs/configuration/listener/tcp.html)

### Where's My Vault Data?

Vault data are stored in Consul's key/value store, which in turn is written into the `consul/oss_server_*/data` directories for each of the three Consul servers.

Here is a tree showing the folder structure for a Consul server:

```
└── consul
    └── consuls0
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

### What Are The Default TTL Values?

Vaultron tries to be reasonable in accommodating developer use cases, but also wants to keep cruft to a minimum. To that end, the default TTL value is lowered, and the maximum TTL value is raised to these values:

- `default_lease_ttl`: **50000h** (2083 days)
- `max_lease_ttl`: **50000h** (2083 days)

That's 7 days and 999 days respectively.

### What About Logs?

The Docker containers are named as shown in the [Basic Architecture Overview](#basic-architecture-overview).

You can view operational logs for any container with `docker logs` like so:

```
docker logs vaultron-vault0
```

The Vault audit logs for any given _active server_ are available as:

- `./vault/vault0/audit_log/audit.log`
- `./vault/vault1/audit_log/audit.log`
- `./vault/vault2/audit_log/audit.log`

### Telemetry Notes

Vaultron includes a comprehensive telemetry gathering and graphing stack provided by the Yellow Lion module. This module is optional and enabled by an environment variable value.

It provides statsd, Graphite, and Grafana from the addition of two official Grafana container images.

You can enable Yellow Lion by setting the value of the *TF_VAR_vaultron_telemetry_count* environment variable to **1**:

```
$ export TF_VAR_vaultron_telemetry_count=1
```

prior to the execution of `./form`.

Once Vaultron is formed, you can then access Grafana at: http://127.0.0.1:3000/

- username: `admin`
- password: `vaultron`

Once signed in, you can access the example **Vault** dashboard; you'll need to initialize, unseal, and do some work with Vault before metrics begin to appear. Adjusting the time filtering in the Grafana UI to a more recent span can also help.

See the [Visualizing Vault Telemetry](https://github.com/brianshumate/vaultron/blob/master/examples/telemetry/README.md) documentation for more details on this setup.

### A note about custom Binaries

Vaultron installs the official open source Vault binaries through the official Docker container images, but if you'd prefer to use recent source builds or some other Vault binary, just drop `vault` into `custom/` and set these environment variables prior to forming Vaultron:

```
$ export TF_VAR_vault_oss_instance_count=0 \
       TF_VAR_vault_custom_instance_count=3 \
./form
```

> **NOTE**: When using custom binaries in this way the binary must be for Linux/AMD64 as that is the platform for the containers, also Vaultron ignores the value of `TF_VAR_vault_version` since the binary itself determines the version so keep that in mind as well.

## Basic Troubleshooting Questions

### I can access the Consul UI but it states that there are no services to show

Access **Settings** in the navigation and ensure that the ACL master token is present in the text field, then click **Save** or **Close** depending on Consul version.

### Vault is Orange/Failing in the Consul Web UI

Vault is expected to appear as failing in the Consul UI if you have not yet unsealed it.

Unsealing Vault should solve that for you!

### Something, Something — HA Problem!

High Availability mode has been shown to work as expected, however because of the current published ports method for exposing the Vault servers, you must be sure to point your client to the correct Vault server with `VAULT_ADDR` once that server becomes the new active server.

Here is simple method to watch HA mode in action using two terminal sessions:

```
Terminal 1                              Terminal 2
+-----------------------------------+   +------------------------------------+
| VAULT_ADDR=https://localhost:8210\|   | docker stop vaultron-vault0        |
| watch -n 1 vault status           |   |                                    |
|                                   |   |                                    |
| ...                               |   |                                    |
| HA Enabled             true       |   |                                    |
| HA Cluster             https://...|   |                                    |
| HA Mode                standby    |   |                                    |
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
[e] Vaultron cannot form! Check terraform apply output.
```

or this:

```
[e] Vaultron cannot form! Check terraform plan output.
```

This means that Vaultron had problems durring the `terraform plan` or `terraform apply` steps. You can run those commands manually and inspect their output to troubleshoot the issue.

Other red and equally frightening errors could occur, and these are usually accompanied by an explanation from Terraform regarding the nature of the problem.

### Vault Containers with Custom Binary are Exiting

My Vault containers are exiting and the `docker logs vaultron-vault0` output resembles this:

```
Using eth0 for VAULT_REDIRECT_ADDR: http://172.17.0.10:8200
Using eth0 for VAULT_CLUSTER_ADDR: https://172.17.0.10:8201
/vault/custom/vault: line 3: syntax error: unexpected end of file (expecting “)”)
```

This is a symptom of using the incorrect custom binary platform; the containers Vaultron uses are Linux AMD64 based, so you must place a Linux/AMD64 version of the `vault` binary into the `custom` directory to successfully use custom binaries.

### Unsupported Versions?

If you try exporting `TF_VAR_consul_version` or `TF_VAR_vault_version` to a specific version, but get this error when you attempt to form Vaultron:

```
[e] Sorry, Vaultron does not support Consul version: 0.6.4
```

or:

```
[e] Sorry, Vaultron does not support Vault version: 0.6.0
```

You are specifying either a non-existent version (maybe a typo?) or you are specifying a version for which no Docker images exists. This second case is not a problem with Vaultron, there are some versions of Consul and Vault which were released as binaries, but not available as Docker images.

### Some Other Undefined Problem!

Have you tried turning it off an on again?

No, seriously — given the nature of this project, sometimes if you cannot resolve the issue root cause, then the easiest way out of a jam could be the _old nuke it from orbit and start_ over approach.

In this case, when you're stumped and don't mind starting anew, then just `unform` and `form` Vaultron again:

```
$ ./unform
[vaultron] [=] Unform Vaultron ...
[vaultron] [*] Vaultron unformed!
```

```
./form
[vaultron] [=] Form Vaultron! ...
...
```

Other things that can help include:

- Unset all related Vaultron `TF_VAR_*` environment variables
- Closing Terminal session/tarting with a fresh Terminal session
- Using the latest release version from GitHub.

Note that the GitHub Master branch strives to remain relatively stable, but a release is usually preferred.

## Resources

Here are some links to resources for the technologies used in this project:

1. [Vault](https://www.vaultproject.io/)
2. [Consul](https://www.consul.io/)
3. [Terraform](https://www.terraform.io/)
4. [Vault Docker Hub repository](https://hub.docker.com/_/vault/)
5. [hashicorp/docker-vault](https://github.com/hashicorp/docker-vault)
6. [Consul Docker Hub repository](https://hub.docker.com/_/consul/)
7. [hashicorp/docker-consul](https://github.com/hashicorp/docker-consul)
8. [Vault Documentation](https://www.vaultproject.io/docs/)
9. [Learn about secrets management and data protection with HashiCorp Vault](https://learn.hashicorp.com/vault/)
10. [Consul Documentation](https://www.consul.io/docs/index.html)
11. [Consul ACL System guide](https://www.consul.io/docs/guides/acl.html)
12. [Consul Encryption documentation](https://www.consul.io/docs/agent/encryption.html)
13. [Official Consul Docker Image blog post](https://www.hashicorp.com/blog/official-consul-docker-image/)
14. [Terraform CLI Documentation](https://www.terraform.io/docs/cli-index.html)
15. [Vault TCP Listener documentation](https://www.vaultproject.io/docs/configuration/listener/tcp.html)
16. [Docker](https://www.docker.com/)

## Who?

Vaultron was created by [Brian Shumate](https://github.com/brianshumate) and made possible through the generous time of the good people named in [CONTRIBUTORS.md](https://github.com/brianshumate/vaultron/blob/master/CONTRIBUTORS.md)

## Special Thanks

:robot: [Voltron Legendary Defender Theme Song Acapella](https://www.youtube.com/embed/W_yr9KvldZY)
