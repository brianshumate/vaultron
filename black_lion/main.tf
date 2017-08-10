#############################################################################
## Vault Open Source
#############################################################################

###
### Vault related variables
###

variable "datacenter_name" { }
variable "vault_version" { }
variable "use_vault_oss" { }
variable "vault_ent_id" { }
variable "vault_path" { }
variable "vault_cluster_name" { }
variable "vault_plus_one_port" { }
variable "disable_clustering" { }
variable "consul_server_ips" {type="list"}
variable "consul_client_ips" {type="list"}
variable "vault_oss_instance_count" {}
variable "vault_custom_instance_count" {}

###
### This is the official Vault Docker image that Vaultron uses by default.
### See also: https://hub.docker.com/_/vault/
###

resource "docker_image" "vault" {
  name = "vault:${var.vault_version}"
  keep_locally  = true
}

###
### Vault Open Source servers configuration
###

data "template_file" "vault_oss_server_config" {
  count = "${var.vault_oss_instance_count}"
  template = "${file("${path.module}/templates/vault_config_${var.vault_version}.tpl")}"
  vars {
    address = "0.0.0.0:8200"
    # Query Consul DNS to determine Consul client IP
    # doesn't work / racy
    # consul_address = "${format("consul_oss_client_%d.node.consul", count.index)}"
    consul_address = "${element(var.consul_client_ips, count.index)}"
    datacenter = "${var.datacenter_name}"
    vault_path = "${var.vault_path}"
    cluster_name = "${var.vault_cluster_name}"
    disable_clustering = "${var.disable_clustering}"
    tls_disable = 1,
    service_tags = "vaultron"
  }
}

###
### Vault Open Source servers
###

resource "docker_container" "vault_oss_server" {
  count = "${var.vault_oss_instance_count}"
  name  = "${format("vault_oss_server_%d", count.index)}"
  image = "${docker_image.vault.latest}"
  upload = {
    content = "${element(data.template_file.vault_oss_server_config.*.rendered, count.index)}"
    file = "/vault/config/main.hcl"
  }
  volumes {
    host_path = "${path.module}/../../../vault/vault_oss_server_${count.index}/audit_log"
    container_path = "/vault/logs"
  }
  volumes {
    host_path = "${path.module}/../../../vault/vault_oss_server_${count.index}/config"
    container_path = "/vault/config"
  }
  entrypoint = ["vault", "server", "-config=/vault/config/main.hcl"]
  dns = ["${var.consul_server_ips}"]
  dns_search = ["consul"]
  capabilities {
    add = ["IPC_LOCK"]
  }
  must_run = true
  ports {
    internal = "8200"
    external = "${format("820%d", count.index)}"
    protocol = "tcp"
  }
}

#############################################################################
## Vault Custom build
#############################################################################

###
### Vault custom servers configuration
### This data type is for using custom Vault builds
###

data "template_file" "vault_custom_server_config" {
  count = "${var.vault_custom_instance_count}"
  template = "${file("${path.module}/templates/vault_config_custom.tpl")}"
  vars {
    address = "0.0.0.0:8200"
    # Query Consul DNS to determine Consul client IP
    # doesn't work / racy
    # consul_address = "${format("consul_oss_client_%d.node.consul", count.index)}"
    consul_address = "${element(var.consul_client_ips, count.index)}"
    datacenter = "${var.datacenter_name}"
    vault_path = "${var.vault_path}"
    cluster_name = "${var.vault_cluster_name}"
    disable_clustering = "${var.disable_clustering}"
    tls_disable = 1,
    service_tags = "vaultron"
    ui = true
  }
}

###
### Vault custom servers
### This resource is for installing custom Vault builds
###

resource "docker_container" "vault_custom_server" {
  count = "${var.vault_custom_instance_count}"
  name  = "${format("vault_custom_server_%d", count.index)}"
  image = "${docker_image.vault.latest}"
  upload = {
    content = "${element(data.template_file.vault_custom_server_config.*.rendered, count.index)}"
    file = "/vault/config/main.hcl"
  }
  volumes {
    host_path = "${path.module}/../../../custom/"
    container_path = "/vault/custom"
  }
  volumes {
    host_path = "${path.module}/../../../vault/vault_custom_server_${count.index}/audit_log"
    container_path = "/vault/logs"
  }
  volumes {
    host_path = "${path.module}/../../../vault/vault_custom_server_${count.index}/config"
    container_path = "/vault/config"
  }
  entrypoint = ["/vault/custom/vault", "server", "-config=/vault/config/main.hcl"],
  dns = ["${var.consul_server_ips}"],
  dns_search = ["consul"]
  capabilities {
    add = ["IPC_LOCK"]
  }
  must_run = true
  ports {
    internal = "8200"
    external = "${format("820%d", count.index)}"
    protocol = "tcp"
  }
}