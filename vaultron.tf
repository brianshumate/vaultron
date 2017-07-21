#############################################################################
## This is Vaultron: A Consul backed Vault server on Docker for macOS
#############################################################################

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

variable "datacenter" {
  default ="dc1"
}

variable "use_consul_oss" {
  default = "1"
}

variable "use_vault_oss" {
  default = "1"
}

# Set TF_VAR_consul_ent_id to set this
variable "consul_ent_id" {
  default = ""
}

# Set TF_VAR_vault_ent_id to set this
variable "vault_ent_id" {
  default = ""
}

#############################################################################
## Consul Open Source
#############################################################################

resource "docker_container" "consul_oss_server_one" {
  name  = "consul_oss_server_1"
  env = ["CONSUL_ALLOW_PRIVILEGED_PORTS="]
  image = "${docker_image.consul.latest}"
  volumes {
    host_path = "${path.module}/consul/oss_server_one/config"
    container_path = "/consul/config"
  }
  volumes {
    host_path = "${path.module}/consul/oss_server_one/data"
    container_path = "/consul/data"
  }
  entrypoint = ["consul",
             "agent",
             "-server",
             "-bootstrap-expect=3",
             "-node=consul1",
             "-client=0.0.0.0",
             "-recursor=84.200.69.80",
             "-recursor=84.200.70.40",
             "-data-dir=/consul/data",
             "-ui"
             ]
  must_run = true
  # TODO: Network mode host will work when the Docker macOS networking
  #      features become more than an experimental feature.
  #      See: https://github.com/docker/for-mac/issues/155
  #
  # network_mode = "host"
  #
  # We define some exposed ports here for the purpose of connecting into
  # the cluster from the host system:
  ports {
    internal = "8300"
    external = "8300"
    protocol = "tcp"
  }
  ports {
    internal = "8301"
    external = "8301"
    protocol = "tcp"
  }
  ports {
    internal = "8301"
    external = "8301"
    protocol = "udp"
  }
  ports {
    internal = "8302"
    external = "8302"
    protocol = "tcp"
  }
  ports {
    internal = "8302"
    external = "8302"
    protocol = "udp"
  }
  ports {
    internal = "8500"
    external = "8500"
    protocol = "tcp"
  }
}

resource "docker_container" "consul_oss_server_two" {
  name  = "consul_oss_server_2"
  image = "${docker_image.consul.latest}"
  volumes {
    host_path = "${path.module}/consul/oss_server_two/config"
    container_path = "/consul/config"
  }
  volumes {
    host_path = "${path.module}/consul/oss_server_two/data"
    container_path = "/consul/data"
  }
  entrypoint = ["consul",
             "agent",
             "-server",
             "-node=consul2",
             "-retry-join=${docker_container.consul_oss_server_one.ip_address}",
             "-data-dir=/consul/data"
             ]
  must_run = true
  # TODO: Network mode host will work when the Docker macOS networking
  #      features become more than an experimental feature.
  #      See: https://github.com/docker/for-mac/issues/155
  #
  # network_mode = "host"
}

resource "docker_container" "consul_oss_server_three" {
  name  = "consul_oss_server_3"
  image = "${docker_image.consul.latest}"
  volumes {
    host_path = "${path.module}/consul/oss_server_three/config"
    container_path = "/consul/config"
  }
  volumes {
    host_path = "${path.module}/consul/oss_server_three/data"
    container_path = "/consul/data"
  }
  entrypoint = ["consul",
                "agent",
                "-server",
                "-node=consul3",
                "-retry-join=${docker_container.consul_oss_server_one.ip_address}",
                "-data-dir=/consul/data"
                ]
  must_run = true
  # TODO: Network mode host will work when the Docker macOS networking
  #      features become more than an experimental feature.
  #      See: https://github.com/docker/for-mac/issues/155
  #
  # network_mode = "host"
}

resource "docker_container" "consul_oss_client_one" {
  name  = "consul_oss_client_1"
  image = "${docker_image.consul.latest}"
  volumes {
    host_path = "${path.module}/consul/oss_client_one/config"
    container_path = "/consul/config"
  }
  volumes {
    host_path = "${path.module}/consul/oss_client_one/data"
    container_path = "/consul/data"
  }
  entrypoint = ["consul",
                "agent",
                "-client=0.0.0.0",
                "-node=consul4",
                "-retry-join=${docker_container.consul_oss_server_one.ip_address}",
                "-data-dir=/consul/data"
                ]
  must_run = true
  # TODO: Network mode host will work when the Docker macOS networking
  #      features become more than an experimental feature.
  #      See: https://github.com/docker/for-mac/issues/155
  #
  # network_mode = "host"
}

resource "docker_container" "consul_oss_client_two" {
  name  = "consul_oss_client_2"
  image = "${docker_image.consul.latest}"
  volumes {
    host_path = "${path.module}/consul/oss_client_two/config"
    container_path = "/consul/config"
  }
  volumes {
    host_path = "${path.module}/consul/oss_client_two/data"
    container_path = "/consul/data"
  }
  entrypoint = ["consul",
                "agent",
                "-client=0.0.0.0",
                "-node=consul5",
                "-retry-join=${docker_container.consul_oss_server_one.ip_address}",
                "-data-dir=/consul/data"
                ]
  must_run = true
  # TODO: Network mode host will work when the Docker macOS networking
  #      features become more than an experimental feature.
  #      See: https://github.com/docker/for-mac/issues/155
  #
  # network_mode = "host"
}

resource "docker_container" "consul_oss_client_three" {
  name  = "consul_oss_client_3"
  image = "${docker_image.consul.latest}"
  volumes {
    host_path = "${path.module}/consul/oss_client_three/config"
    container_path = "/consul/config"
  }
  volumes {
    host_path = "${path.module}/consul/oss_client_three/data"
    container_path = "/consul/data"
  }
  entrypoint = ["consul",
                "agent",
                "-client=0.0.0.0",
                "-node=consul6",
                "-retry-join=${docker_container.consul_oss_server_one.ip_address}",
                "-data-dir=/consul/data"
                ]
  must_run = true
  # TODO: Network mode host will work when the Docker macOS networking
  #      features become more than an experimental feature.
  #      See: https://github.com/docker/for-mac/issues/155
  #
  # network_mode = "host"
}

#############################################################################
## Consul Enterprise
#############################################################################

# TODO: Get this going next
#
#resource "docker_container" "consul_enterprise_one" {
#  name  = "consul_enterprise_server_1"
#  image = "${var.consul_ent_id}"
#  env = ["CONSUL_ALLOW_PRIVILEGED_PORTS="]
#    entrypoint = ["consul",
#             "agent",
#             "-server",
#             "-bootstrap-expect=3",
#             "-node=consul1",
#             "-client=0.0.0.0",
#             #"-bind=0.0.0.0",
#             # "-dns-port=53",
#             "-recursor=84.200.69.80",
#             "-recursor=84.200.70.40",
#             "-data-dir=/consul/data",
#             "-ui"
#             ]
#  must_run = true
#  # TODO: Network mode host will work when the Docker macOS networking
#  #      features become more than an experimental feature.
#  #      See: https://github.com/docker/for-mac/issues/155
#  #
#  # network_mode = "host"
#  #
#  # We define some exposed ports here for the purpose of connecting into
#  # the cluster from the host system:
#  ports {
#    internal = "8300"
#    external = "8300"
#    protocol = "tcp"
#  }
#  ports {
#    internal = "8301"
#    external = "8301"
#    protocol = "tcp"
#  }
#  ports {
#    internal = "8301"
#    external = "8301"
#    protocol = "udp"
#  }
#  ports {
#    internal = "8302"
#    external = "8302"
#    protocol = "tcp"
#  }
#  ports {
#    internal = "8302"
#    external = "8302"
#    protocol = "udp"
#  }
#  ports {
#    internal = "8500"
#    external = "8500"
#    protocol = "tcp"
#  }
#}

resource "docker_image" "consul" {
  name = "consul"
}

#############################################################################
## Vault Open Source
#############################################################################
#

# Set TF_VAR_vault_path to set this
variable "vault_path" {
  default = "vault"
}

# Set TF_VAR_vault_cluster_name to set this
variable "vault_cluster_name" {
  default = "vaultron"
}

# Set TF_VAR_vault_plus_one_port to set this
variable "vault_plus_one_port" {
  default = "8301"
}

# Set TF_VAR_disable_clustering to set this
variable "disable_clustering" {
  default = "true"
}

data "template_file" "vault_oss_one_config" {
  template = "${file("${path.module}/templates/vault_config.tpl")}"
  vars {
    address = "0.0.0.0:8200"
    consul_address = "${docker_container.consul_oss_client_one.ip_address}"
    datacenter = "${var.datacenter}"
    vault_path = "${var.vault_path}"
    cluster_name = "${var.vault_cluster_name}"
    disable_clustering = "${var.disable_clustering}"
    tls_disable = 1
  }
}

resource "docker_container" "vault_oss_one" {
  name  = "vault_oss_server_1"
  image = "${docker_image.vault.latest}"
  upload = {
    content = "${data.template_file.vault_oss_one_config.rendered}"
    file = "/vault/config/main.hcl"
  }
  volumes {
    host_path = "${path.module}/vault/config"
    container_path = "/vault/config"
  }
  #
  # TODO: Investigate
  #
  # dns = ["${docker_container.consul_oss_server_one.ip_address}"]
  # dns_search = ["consul"]
  #
  entrypoint = ["vault", "server", "-config=/vault/config/main.hcl"]
  capabilities {
    add = ["IPC_LOCK"]
  }
  must_run = true
  # TODO: Network mode host will work when the Docker macOS networking
  #      features become more than an experimental feature.
  #      See: https://github.com/docker/for-mac/issues/155
  #
  # network_mode = "host"
    ports {
    internal = "8200"
    external = "8200"
    protocol = "tcp"
  }
}

#############################################################################
## Vault Enterprise
#############################################################################

# TODO: Get this going next
#
#resource "docker_container" "vault_enterprise_one" {
#  name  = "vault_ent_server_1"
#  image = "${vault_ent_id}"
#  provisioner "remote-exec" {
#    inline = [
#      "echo 'Check for Consul here'"
#    ]
#  }
#  capabilities {
#    add = ["IP_LOCK"]
#  }
#    must_run = true
#  # TODO: Network mode host will work when the Docker macOS networking
#  #      features become more than an experimental feature.
#  #      See: https://github.com/docker/for-mac/issues/155
#  #
#  # network_mode = "host"
#    ports {
#    internal = "8200"
#    external = "8200"
#    protocol = "tcp"
#  }
#}

resource "docker_image" "vault" {
  name = "vault"
}
