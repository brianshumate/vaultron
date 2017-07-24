#############################################################################
## Vaultron: A Terraformed, Consul-backed, Vault server on Docker for macOS
#############################################################################

###
### Global variables
###

# "This is fine"
provider "docker" {
  host = "unix:///var/run/docker.sock"
}

# Set TF_VAR_datacenter_name to set this
variable "datacenter_name" {
  default ="arus"
}

###
### Vault related variables
###
# Set TF_VAR_vault_version to set this
variable "vault_version" {
  default = "0.7.3"
}

# Set TF_VAR_use_vault_oss to set this
variable "use_vault_oss" {
  default = "1"
}

# Set TF_VAR_vault_ent_id to set this
variable "vault_ent_id" {
  default = ""
}

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
  default = "false"
}

###
### Consul related variables
###
# Set TF_VAR_consul_version to set this
variable "consul_version" {
  default = "0.9.0"
}

# Set TF_VAR_use_consul_oss to set this
variable "use_consul_oss" {
  default = "1"
}

# Set TF_VAR_consul_ent_id to set this
variable "consul_ent_id" {
  default = ""
}

# Set TF_VAR_consul_recursor_1 to set this
variable "consul_recursor_1" {
  default = "84.200.69.80"
}

# Set TF_VAR_consul_recursor_2 to set this
variable "consul_recursor_2" {
  default = "84.200.70.40"
}

# Set TF_VAR_consul_acl_datacenter to set this
variable "consul_acl_datacenter" {
  default = "arus"
}

# Set TF_VAR_consul_data_dir to set this
variable "consul_data_dir" {
  default = "/consul/data"
}

#############################################################################
## Consul Open Source
#############################################################################

###
### This is the official Consul Docker image that Vaultron uses by default.
### See also: https://hub.docker.com/_/consul/
###
resource "docker_image" "consul" {
  name = "consul:${var.consul_version}"
}

###
### Consul Open Source server extra configuration
###
data "template_file" "consul_oss_server_common_config" {
  template = "${file("${path.module}/templates/consul_oss_server_config_${var.consul_version}.tpl")}"
  vars {
    acl_datacenter = "arus"
    bootstrap_expect = 3
    datacenter = "${var.datacenter_name}"
    data_dir = "${var.consul_data_dir}"
    client = "0.0.0.0"
    recursor1 = "${var.consul_recursor_1}"
    recursor2 = "${var.consul_recursor_2}"
    ui = "true"
  }
}

###
### Consul Open Source Server 1
###
resource "docker_container" "consul_oss_server_1" {
  name  = "consul_oss_server_1"
  env = ["CONSUL_ALLOW_PRIVILEGED_PORTS="]
  image = "${docker_image.consul.latest}"
  upload = {
    content = "${data.template_file.consul_oss_server_common_config.rendered}"
    file = "/consul/config/common_config.json"
  }
  volumes {
    host_path = "${path.module}/consul/consul_oss_server_1/config"
    container_path = "/consul/config"
  }
  volumes {
    host_path = "${path.module}/consul/consul_oss_server_1/data"
    container_path = "/consul/data"
  }
  entrypoint = ["consul",
             "agent",
             "-server",
             "-config-dir=/consul/config",
             "-node=consul_oss_server_1",
             "-client=0.0.0.0",
             "-dns-port=53"
             ]
  must_run = true
  # Define some published ports here for the purpose of connecting into
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
  ports {
    internal = "53"
    external = "8600"
    protocol = "tcp"
  }
  ports {
    internal = "53"
    external = "8600"
    protocol = "udp"
  }
}

###
### Consul Open Source Server 2
###
resource "docker_container" "consul_oss_server_2" {
  name  = "consul_oss_server_2"
  image = "${docker_image.consul.latest}"
  upload = {
    content = "${data.template_file.consul_oss_server_common_config.rendered}"
    file = "/consul/config/common_config.json"
  }
  volumes {
    host_path = "${path.module}/consul/consul_oss_server_2/config"
    container_path = "/consul/config"
  }
  volumes {
    host_path = "${path.module}/consul/consul_oss_server_2/data"
    container_path = "/consul/data"
  }
  entrypoint = ["consul",
             "agent",
             "-server",
             "-config-dir=/consul/config",
             "-node=consul_oss_server_2",
             "-retry-join=${docker_container.consul_oss_server_1.ip_address}",
             "-dns-port=53"
             ]
  must_run = true
}

###
### Consul Open Source Server 3
###
resource "docker_container" "consul_oss_server_3" {
  name  = "consul_oss_server_3"
  image = "${docker_image.consul.latest}"
  upload = {
    content = "${data.template_file.consul_oss_server_common_config.rendered}"
    file = "/consul/config/common_config.json"
  }
  volumes {
    host_path = "${path.module}/consul/consul_oss_server_3/config"
    container_path = "/consul/config"
  }
  volumes {
    host_path = "${path.module}/consul/consul_oss_server_3/data"
    container_path = "/consul/data"
  }
  entrypoint = ["consul",
                "agent",
                "-server",
                "-config-dir=/consul/config",
                "-node=consul_oss_server_3",
                "-retry-join=${docker_container.consul_oss_server_1.ip_address}",
                "-dns-port=53"
                ]
  must_run = true
}

###
### Consul Open Source client extra configuration
###
data "template_file" "consul_oss_client_common_config" {
  template = "${file("${path.module}/templates/consul_oss_client_config_${var.consul_version}.tpl")}"
  vars {
    common_configuration = "true"
  }
}

###
### Consul Open Source Client 1
###
resource "docker_container" "consul_oss_client_1" {
  name  = "consul_oss_client_1"
  image = "${docker_image.consul.latest}"
  upload = {
    content = "${data.template_file.consul_oss_client_common_config.rendered}"
    file = "/consul/config/common_config.json"
  }
  volumes {
    host_path = "${path.module}/consul/consul_oss_client_1/config"
    container_path = "/consul/config"
  }
  volumes {
    host_path = "${path.module}/consul/consul_oss_client_1/data"
    container_path = "/consul/data"
  }
  entrypoint = ["consul",
                "agent",
                "-config-dir=/consul/config",
                "-client=0.0.0.0",
                "-node=consul_oss_client_1",
                "-retry-join=${docker_container.consul_oss_server_1.ip_address}",
                "-datacenter=${var.datacenter_name}",
                "-data-dir=/consul/data",
                ],
  dns = ["${docker_container.consul_oss_server_1.ip_address}", "${docker_container.consul_oss_server_2.ip_address}", "${docker_container.consul_oss_server_3.ip_address}"],
  dns_search = ["consul"],
  must_run = true
}

###
### Consul Open Source Client 2
###
resource "docker_container" "consul_oss_client_2" {
  name  = "consul_oss_client_2"
  image = "${docker_image.consul.latest}"
  upload = {
    content = "${data.template_file.consul_oss_client_common_config.rendered}"
    file = "/consul/config/common_config.json"
  }
  volumes {
    host_path = "${path.module}/consul/consul_oss_client_2/config"
    container_path = "/consul/config"
  }
  volumes {
    host_path = "${path.module}/consul/consul_oss_client_2/data"
    container_path = "/consul/data"
  }
  entrypoint = ["consul",
                "agent",
                "-config-dir=/consul/config",
                "-client=0.0.0.0",
                "-node=consul_oss_client_2",
                "-retry-join=${docker_container.consul_oss_server_2.ip_address}",
                "-datacenter=${var.datacenter_name}",
                "-data-dir=/consul/data",
                ],
  dns = ["${docker_container.consul_oss_server_1.ip_address}", "${docker_container.consul_oss_server_2.ip_address}", "${docker_container.consul_oss_server_3.ip_address}"],
  dns_search = ["consul"],
  must_run = true
}

###
### Consul Open Source Client 3
###
resource "docker_container" "consul_oss_client_3" {
  name  = "consul_oss_client_3"
  image = "${docker_image.consul.latest}"
  upload = {
    content = "${data.template_file.consul_oss_client_common_config.rendered}"
    file = "/consul/config/common_config.json"
  }
  volumes {
    host_path = "${path.module}/consul/consul_oss_client_3/config"
    container_path = "/consul/config"
  }
  volumes {
    host_path = "${path.module}/consul/consul_oss_client_3/data"
    container_path = "/consul/data"
  }
  entrypoint = ["consul",
                "agent",
                "-config-dir=/consul/config",
                "-client=0.0.0.0",
                "-node=consul_oss_client_3",
                "-retry-join=${docker_container.consul_oss_server_3.ip_address}",
                "-datacenter=${var.datacenter_name}",
                "-data-dir=/consul/data",
                ],
  dns = ["${docker_container.consul_oss_server_1.ip_address}", "${docker_container.consul_oss_server_2.ip_address}", "${docker_container.consul_oss_server_3.ip_address}"],
  dns_search = ["consul"],
  must_run = true
}

#############################################################################
## Vault Open Source
#############################################################################

###
### This is the official Vault Docker image that Vaultron uses by default.
### See also: https://hub.docker.com/_/vault/
###
resource "docker_image" "vault" {
  name = "vault:${var.vault_version}"
}

###
### Vault Open Source server 1 configuration
###
data "template_file" "vault_oss_server_1_config" {
  template = "${file("${path.module}/templates/vault_config_${var.vault_version}.tpl")}"
  vars {
    address = "0.0.0.0:8200"
    consul_address = "${docker_container.consul_oss_client_1.ip_address}"
    datacenter = "${var.datacenter_name}"
    vault_path = "${var.vault_path}"
    cluster_name = "${var.vault_cluster_name}"
    disable_clustering = "${var.disable_clustering}"
    tls_disable = 1,
    service_tags = "vaultron"
  }
}

###
### Vault Open Source server 2 configuration
###
data "template_file" "vault_oss_server_2_config" {
  template = "${file("${path.module}/templates/vault_config_${var.vault_version}.tpl")}"
  vars {
    address = "0.0.0.0:8200"
    consul_address = "${docker_container.consul_oss_client_2.ip_address}"
    datacenter = "${var.datacenter_name}"
    vault_path = "${var.vault_path}"
    cluster_name = "${var.vault_cluster_name}"
    disable_clustering = "${var.disable_clustering}"
    tls_disable = 1,
    service_tags = "vaultron"
  }
}

###
### Vault Open Source server 3 configuration
###
data "template_file" "vault_oss_server_3_config" {
  template = "${file("${path.module}/templates/vault_config_${var.vault_version}.tpl")}"
  vars {
    address = "0.0.0.0:8200"
    consul_address = "${docker_container.consul_oss_client_3.ip_address}"
    datacenter = "${var.datacenter_name}"
    vault_path = "${var.vault_path}"
    cluster_name = "${var.vault_cluster_name}"
    disable_clustering = "${var.disable_clustering}"
    tls_disable = 1,
    service_tags = "vaultron"
  }
}

###
### Vault Open Source Server 1
###
resource "docker_container" "vault_oss_server_1" {
  name  = "vault_oss_server_1"
  image = "${docker_image.vault.latest}"
  upload = {
    content = "${data.template_file.vault_oss_server_1_config.rendered}"
    file = "/vault/config/main.hcl"
  }
  volumes {
    host_path = "${path.module}/vault/vault_oss_server_1/audit_log"
    container_path = "/vault/logs"
  }
  volumes {
    host_path = "${path.module}/vault/vault_oss_server_1/config"
    container_path = "/vault/config"
  }
  entrypoint = ["vault", "server", "-config=/vault/config/main.hcl"],
  dns = ["${docker_container.consul_oss_server_1.ip_address}", "${docker_container.consul_oss_server_2.ip_address}", "${docker_container.consul_oss_server_3.ip_address}"],
  dns_search = ["consul"]
  capabilities {
    add = ["IPC_LOCK"]
  }
  must_run = true
  ports {
    internal = "8200"
    external = "8200"
    protocol = "tcp"
  }
}

###
### Vault Open Source Server 2
###
resource "docker_container" "vault_oss_server_2" {
  name  = "vault_oss_server_2"
  image = "${docker_image.vault.latest}"
  upload = {
    content = "${data.template_file.vault_oss_server_2_config.rendered}"
    file = "/vault/config/main.hcl"
  }
  volumes {
    host_path = "${path.module}/vault/vault_oss_server_2/audit_log"
    container_path = "/vault/logs"
  }
  volumes {
    host_path = "${path.module}/vault/vault_oss_server_2/config"
    container_path = "/vault/config"
  }
  entrypoint = ["vault", "server", "-config=/vault/config/main.hcl"],
  dns = ["${docker_container.consul_oss_server_1.ip_address}", "${docker_container.consul_oss_server_2.ip_address}", "${docker_container.consul_oss_server_3.ip_address}"],
  dns_search = ["consul"]
  capabilities {
    add = ["IPC_LOCK"]
  }
  must_run = true
  ports {
    internal = "8200"
    external = "8201"
    protocol = "tcp"
  }
}

###
### Vault Open Source Server 3
###
resource "docker_container" "vault_oss_server_3" {
  name  = "vault_oss_server_3"
  image = "${docker_image.vault.latest}"
  upload = {
    content = "${data.template_file.vault_oss_server_3_config.rendered}"
    file = "/vault/config/main.hcl"
  }
  volumes {
    host_path = "${path.module}/vault/vault_oss_server_3/audit_log"
    container_path = "/vault/logs"
  }
  volumes {
    host_path = "${path.module}/vault/vault_oss_server_3/config"
    container_path = "/vault/config"
  }
  entrypoint = ["vault", "server", "-config=/vault/config/main.hcl"],
  dns = ["${docker_container.consul_oss_server_1.ip_address}", "${docker_container.consul_oss_server_2.ip_address}", "${docker_container.consul_oss_server_3.ip_address}"],
  dns_search = ["consul"]
  capabilities {
    add = ["IPC_LOCK"]
  }
  must_run = true
  ports {
    internal = "8200"
    external = "8202"
    protocol = "tcp"
  }
}
