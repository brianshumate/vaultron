
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

Terraform assembles the individual pieces to form Vaultron from the official
Consul and Vault Docker images.

### Quick Start

Make sure to first install Terraform and Docker for Mac, then:

1. Clone this repository
2. `cd vaultron`
3. `make vaultron`

### What's Next?

After Vaultron is formed, some immediate next steps are available to you:

1. Browse the Consul UI at [http://localhost:8500](http://localhost:8500)
2. Execute `./bin/vault_kitchen_sink` to enable several authentication and
   secret backends
3. Use Vault and Consul on your Mac!
4. Disassemble Vaultron with `make clean`

Of course, if you are familiar with Terraform you can skip the `make` commands
and use `terraform plan`, `terraform apply`, and `terraform destroy` instead.

The Consul data is available under the `consul` directory.

## Notes and Resources

### Regarding Best Practices

Please note that while this project connects the Vault instance directly to
a Consul server for the sake of simplicity, the best approach in production
is to always connect each Vault instance to a local Consul agent which joins
the cluster of Consul servers.

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
