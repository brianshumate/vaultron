#############################################################################
## Vault Open Source
#############################################################################

###
### Vault related variables
###

output "vault_oss_server_1_ip" {
  description = "Vault OSS Server 1 IP address"
  value = "${docker_container.vault_oss_server_1.ip_address}"
}

output "vault_oss_server_1_config_file" {
  description = "Vault Configuration"
  value = "${data.template_file.vault_oss_server_1_config.rendered}"
}

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
variable "consul_server_1_ip" { }
variable "consul_server_2_ip" { }
variable "consul_server_3_ip" { }
variable "consul_client_2_ip" { }
variable "consul_client_3_ip" { }

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
    consul_address = "${var.consul_server_1_ip}"
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
    consul_address = "${var.consul_client_2_ip}"
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
    consul_address = "${var.consul_client_3_ip}"
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
    host_path = "${path.module}/../../../vault/vault_oss_server_1/audit_log"
    container_path = "/vault/logs"
  }
  volumes {
    host_path = "${path.module}/../../../vault/vault_oss_server_1/config"
    container_path = "/vault/config"
  }
  entrypoint = ["vault", "server", "-config=/vault/config/main.hcl"],
  dns = ["${var.consul_server_1_ip}", "${var.consul_server_2_ip}", "${var.consul_server_3_ip}"],
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
    host_path = "${path.module}/../../../vault/vault_oss_server_2/audit_log"
    container_path = "/vault/logs"
  }
  volumes {
    host_path = "${path.module}/../../../vault/vault_oss_server_2/config"
    container_path = "/vault/config"
  }
  entrypoint = ["vault", "server", "-config=/vault/config/main.hcl"],
  dns = ["${var.consul_server_1_ip}", "${var.consul_server_2_ip}", "${var.consul_server_3_ip}"],
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
    host_path = "${path.module}/../../../vault/vault_oss_server_3/audit_log"
    container_path = "/vault/logs"
  }
  volumes {
    host_path = "${path.module}/../../../vault/vault_oss_server_3/config"
    container_path = "/vault/config"
  }
  entrypoint = ["vault", "server", "-config=/vault/config/main.hcl"],
  dns = ["${var.consul_server_1_ip}", "${var.consul_server_2_ip}", "${var.consul_server_3_ip}"],
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
