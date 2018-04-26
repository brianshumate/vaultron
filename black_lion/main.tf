#############################################################################
# Black Lion
# Vault servers
#   - Standard OSS distribution
#   - Custom binary (allows for custom builds, Enterprise, etc.)
#############################################################################

# Vault related variables

variable "datacenter_name" {}
variable "vault_version" {}
variable "use_vault_oss" {}
variable "vault_ent_id" {}
variable "vault_path" {}
variable "vault_cluster_name" {}
variable "disable_clustering" {}
variable "vault_server_log_level" {}
variable "consul_server_ips" {
  type = "list"
}
variable "consul_client_ips" {
  type = "list"
}
variable "vault_oss_instance_count" {}
variable "vault_custom_instance_count" {}
variable "vault_custom_config_template" {}
variable "statsd_ip" {
  default = "127.0.0.1"
}

variable "vaultron_telemetry_count" {}

# This is the official Vault Docker image that Vaultron uses by default.
# See also: https://hub.docker.com/_/vault/

resource "docker_image" "vault" {
  name         = "vault:${var.vault_version}"
  keep_locally = true
}

# Vault Open Source servers configuration

data "template_file" "vault_oss_server_config" {
  count    = "${var.vault_oss_instance_count}"
  template = "${file("${path.module}/templates/vault_config_${var.vault_version}.tpl")}"

  vars {
    address            = "0.0.0.0:8200"
    consul_address     = "${element(var.consul_client_ips, count.index)}"
    datacenter         = "${var.datacenter_name}"
    vault_path         = "${var.vault_path}"
    cluster_name       = "${var.vault_cluster_name}"
    disable_clustering = "${var.disable_clustering}"
    tls_disable        = false
    service_tags       = "vaultron"
  }
}

# TLS CA Bundle

data "template_file" "ca_bundle" {
  template = "${file("${path.module}/tls/ca-bundle.pem")}"
}

# Vault OSS Server TLS certificates and keys

data "template_file" "vault_oss_server_tls_cert" {
  count    = "${var.vault_oss_instance_count}"
  template = "${file("${path.module}/tls/${format("vault-server-%d.crt", count.index)}")}"
}

data "template_file" "vault_oss_server_tls_key" {
  count    = "${var.vault_oss_instance_count}"
  template = "${file("${path.module}/tls/${format("vault-server-%d.key", count.index)}")}"
}

# Vault telemetry configuration

data "template_file" "telemetry_config" {
  count = "${var.vaultron_telemetry_count ? 1 : 0}"
  template = "${file("${path.module}/templates/${format("vault_telemetry-%d.tpl", count.index)}")}"
  vars {
    statsd_ip = "${var.statsd_ip}"
  }
}

# Vault Open Source servers

resource "docker_container" "vault_oss_server" {
  count = "${var.vault_oss_instance_count}"
  name  = "${format("vault_oss_server_%d", count.index)}"
  image = "${docker_image.vault.latest}"

  upload = {
    content = "${element(data.template_file.vault_oss_server_config.*.rendered, count.index)}"
    file    = "/vault/config/main.hcl"
  }

  upload = {
    content = "${data.template_file.telemetry_config.rendered}"
    file    = "/vault/config/telemetry.hcl"
  }

  upload = {
    content = "${data.template_file.ca_bundle.rendered}"
    file    = "/etc/ssl/certs/ca-bundle.pem"
  }

  upload = {
    content = "${element(data.template_file.vault_oss_server_tls_cert.*.rendered, count.index)}"
    file    = "/etc/ssl/certs/vault-server.crt"
  }

  upload = {
    content = "${element(data.template_file.vault_oss_server_tls_key.*.rendered, count.index)}"
    file    = "/etc/ssl/vault-server.key"
  }

  volumes {
    host_path      = "${path.module}/../../../vault/vault_oss_server_${count.index}/audit_log"
    container_path = "/vault/logs"
  }

  volumes {
    host_path      = "${path.module}/../../../vault/vault_oss_server_${count.index}/config"
    container_path = "/vault/config"
  }

  volumes {
    host_path      = "${path.module}/../../../plugins"
    container_path = "/vault/plugins"
  }

  entrypoint = ["vault", "server", "-log-level=${var.vault_server_log_level}", "-config=/vault/config/main.hcl"]
  dns        = ["${var.consul_server_ips}"]
  dns_search = ["consul"]

  capabilities {
    add = ["IPC_LOCK"]
  }

  must_run = true
  env      = ["VAULT_CLUSTER_INTERFACE=eth0",
              "VAULT_REDIRECT_INTERFACE=eth0"]

  ports {
    internal = "8200"
    # This is mysterious/steps on the default cluster_address port
    # needs more investigation and updating...
    external = "${format("820%d", count.index)}"
    protocol = "tcp"
  }

}

#############################################################################
# Vault Custom build
#############################################################################

# Vault Server TLS certificates and keys

data "template_file" "vault_custom_server_tls_cert" {
  count    = "${var.vault_custom_instance_count}"
  template = "${file("${path.module}/tls/${format("vault-server-%d.crt", count.index)}")}"
}

data "template_file" "vault_custom_server_tls_key" {
  count    = "${var.vault_custom_instance_count}"
  template = "${file("${path.module}/tls/${format("vault-server-%d.key", count.index)}")}"
}

# Vault custom servers configuration
# This data type is for using custom Vault builds

data "template_file" "vault_custom_server_config" {
  count    = "${var.vault_custom_instance_count}"
  template = "${file("${path.module}/templates/${var.vault_custom_config_template}")}"

  vars {
    address            = "0.0.0.0:8200"
    consul_address     = "${element(var.consul_client_ips, count.index)}"
    datacenter         = "${var.datacenter_name}"
    vault_path         = "${var.vault_path}"
    cluster_name       = "${var.vault_cluster_name}"
    disable_clustering = "${var.disable_clustering}"
    statsd_ip          = "${var.statsd_ip}"
    tls_disable        = 1
    tls_cert           = "/vault/config/vault-server.crt"
    tls_key            = "/vault/config/vault-server.key"
    service_tags       = "vaultron"
    ui                 = true
  }
}

# Vault custom servers
# This resource is for installing custom Vault builds

resource "docker_container" "vault_custom_server" {
  count = "${var.vault_custom_instance_count}"
  name  = "${format("vault_custom_server_%d", count.index)}"
  image = "${docker_image.vault.latest}"

  upload = {
    content = "${element(data.template_file.vault_custom_server_config.*.rendered, count.index)}"
    file    = "/vault/config/main.hcl"
  }

  upload = {
    content = "${data.template_file.telemetry_config.rendered}"
    file    = "/vault/config/telemetry.hcl"
  }

  upload = {
    content = "${data.template_file.ca_bundle.rendered}"
    file    = "/etc/ssl/certs/ca-bundle.pem"
  }

   upload = {
     content = "${element(data.template_file.vault_custom_server_tls_cert.*.rendered, count.index)}"
     file    = "/etc/ssl/certs/vault-server.crt"
   }

   upload = {
     content = "${element(data.template_file.vault_custom_server_tls_key.*.rendered, count.index)}"
     file    = "/etc/ssl/vault-server.key"
   }

  volumes {
    host_path      = "${path.module}/../../../custom/"
    container_path = "/vault/custom"
  }

  volumes {
    host_path      = "${path.module}/../../../vault/vault_custom_server_${count.index}/audit_log"
    container_path = "/vault/logs"
  }

  volumes {
    host_path      = "${path.module}/../../../vault/vault_custom_server_${count.index}/config"
    container_path = "/vault/config"
  }

  volumes {
    host_path      = "${path.module}/../../../vault/vault_custom_server_${count.index}/data"
    container_path = "/vault/data"
  }

  volumes {
    host_path      = "${path.module}/../../../plugins"
    container_path = "/vault/plugins"
  }

  entrypoint = ["/vault/custom/vault", "server", "-log-level=${var.vault_server_log_level}", "-config=/vault/config/main.hcl"]
  dns        = ["${var.consul_server_ips}"]
  dns_search = ["consul"]

  capabilities {
    add = ["IPC_LOCK"]
  }

  must_run = true

  ports {
    internal = "8200"
    # This is mysterious + conflicts w/ default cluster_address port
    # needs more investigation and updating when Docker Mac networking better
    external = "${format("820%d", count.index)}"
    protocol = "tcp"
  }

}
