# =======================================================================
# Red Lion
# Consul servers and client agents
# =======================================================================

terraform {
  required_version = ">= 0.12"
}

# Consul module outputs

output "consul_oss_server_ips" {
  description = "Consul OSS Server IP addresses"

  value = [
    docker_container.consuls0.network_data[0].ip_address,
    docker_container.consuls1.network_data[0].ip_address,
    docker_container.consuls2.network_data[0].ip_address,
  ]
}

output "consul_client_ips" {
  description = "Consul OSS Client IP addresses"
  value       = docker_container.consul_oss_client.*.ip_address
}

# -----------------------------------------------------------------------
# Consul variables
# -----------------------------------------------------------------------

variable "consul_log_level" {
}

variable "datacenter_name" {
}

variable "consul_version" {
}

variable "use_consul_oss" {
}

variable "consul_ent_id" {
}

variable "consul_recursor_1" {
}

variable "consul_recursor_2" {
}

variable "consul_acl_datacenter" {
}

variable "consul_data_dir" {
}

variable "consul_custom" {
}

variable "consul_custom_instance_count" {
}

variable "consul_oss" {
}

variable "consul_oss_instance_count" {
}

# This is the official Consul Docker image that Vaultron uses by default.
# See also: https://hub.docker.com/_/consul/

resource "docker_image" "consul" {
  name         = "consul:${var.consul_version}"
  keep_locally = true
}

# -----------------------------------------------------------------------
# Consul Open Source server common configuration
# -----------------------------------------------------------------------

data "template_file" "consul_oss_server_common_config" {
  # XXX: why is count needed here?
  #
  # count    = "${var.consul_oss}"
  template = file(
    "${path.module}/templates/oss/consul_oss_server_config_${var.consul_version}.hcl",
  )

  vars = {
    log_level        = var.consul_log_level
    acl_datacenter   = "arus"
    bootstrap_expect = 3
    datacenter       = var.datacenter_name
    data_dir         = var.consul_data_dir
    client           = "0.0.0.0"
    recursor1        = var.consul_recursor_1
    recursor2        = var.consul_recursor_2
    ui               = "true"
  }
}

# -----------------------------------------------------------------------
# TLS configuration
# -----------------------------------------------------------------------

data "template_file" "ca_bundle" {
  template = file("${path.module}/tls/ca.pem")
}

data "template_file" "consuls0_tls_cert" {
  template = file("${path.module}/tls/consul-server-0.crt")
}

data "template_file" "consuls1_tls_cert" {
  template = file("${path.module}/tls/consul-server-1.crt")
}

data "template_file" "consuls2_tls_cert" {
  template = file("${path.module}/tls/consul-server-2.crt")
}

data "template_file" "consuls0_tls_key" {
  template = file("${path.module}/tls/consul-server-0.key")
}

data "template_file" "consuls1_tls_key" {
  template = file("${path.module}/tls/consul-server-1.key")
}

data "template_file" "consuls2_tls_key" {
  template = file("${path.module}/tls/consul-server-2.key")
}

# -----------------------------------------------------------------------
# Consul OSS server 1
# -----------------------------------------------------------------------

resource "docker_container" "consuls0" {
  # XXX: Singleton resource / why count?
  # count = "${var.consul_oss}"
  image = docker_image.consul.latest

  entrypoint = [
    "consul",
    "agent",
    "-server",
    "-node-id=c0ffee74-a33e-4200-99ae-12dc45a4a6ae",
    "-config-dir=/consul/config",
    "-node=consuls0",
    "-client=0.0.0.0",
    "-dns-port=53",
  ]

  env = ["CONSUL_ALLOW_PRIVILEGED_PORTS=", "CONSUL_HTTP_SSL=true"]

  must_run   = true
  name       = "vaultron-consuls0"
  hostname   = "consuls0"
  domainname = "consul"
  dns_search = ["consul"]

  capabilities {
    add = ["NET_ADMIN", "SYS_ADMIN", "SYS_PTRACE", "SYSLOG"]
  }

  healthcheck {
    test         = ["CMD", "consul", "info"]
    interval     = "10s"
    timeout      = "2s"
    start_period = "10s"
    retries      = 2
  }

  networks_advanced {
    name         = "vaultron-network"
    ipv4_address = "10.10.42.100"
  }

  volumes {
    host_path      = "${path.cwd}/consul/consuls0/config"
    container_path = "/consul/config"
  }

  volumes {
    host_path      = "${path.cwd}/consul/consuls0/data"
    container_path = "/consul/data"
  }

  upload {
    content = data.template_file.consul_oss_server_common_config.rendered
    file    = "/consul/config/common_config.json"
  }

  upload {
    content = data.template_file.ca_bundle.rendered
    file    = "/etc/ssl/certs/ca.pem"
  }

  upload {
    content = data.template_file.consuls0_tls_cert.rendered
    file    = "/etc/ssl/certs/consul-server.crt"
  }

  upload {
    content = data.template_file.consuls0_tls_key.rendered
    file    = "/etc/ssl/consul-server.key"
  }

  # Define some published ports here for the purpose of ingress/egress
  # with the cluster from the Docker host:
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
    internal = "8555"
    external = "8555"
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

# -----------------------------------------------------------------------
# Consul OSS server 2
# -----------------------------------------------------------------------

resource "docker_container" "consuls1" {
  # XXX: Singleton resource / why count?
  # count = "${var.consul_oss}"
  image = docker_image.consul.latest

  entrypoint = [
    "consul",
    "agent",
    "-server",
    "-node-id=c0ffee74-77f0-44ea-849a-4bfeef9b07c4",
    "-config-dir=/consul/config",
    "-node=consuls1",
    "-client=0.0.0.0",
    "-dns-port=53",
  ]

  env = ["CONSUL_ALLOW_PRIVILEGED_PORTS=", "CONSUL_HTTP_SSL=true"]

  must_run   = true
  name       = "vaultron-consuls1"
  hostname   = "consuls1"
  domainname = "consul"
  dns_search = ["consul"]

  capabilities {
    add = ["NET_ADMIN", "SYS_ADMIN", "SYS_PTRACE", "SYSLOG"]
  }

  healthcheck {
    test         = ["CMD", "consul", "info"]
    interval     = "10s"
    timeout      = "2s"
    start_period = "10s"
    retries      = 2
  }

  networks_advanced {
    name         = "vaultron-network"
    ipv4_address = "10.10.42.101"
  }

  volumes {
    host_path      = "${path.cwd}/consul/consuls1/config"
    container_path = "/consul/config"
  }

  volumes {
    host_path      = "${path.cwd}/consul/consuls1/data"
    container_path = "/consul/data"
  }

  upload {
    content = data.template_file.consul_oss_server_common_config.rendered
    file    = "/consul/config/common_config.json"
  }

  upload {
    content = data.template_file.ca_bundle.rendered
    file    = "/etc/ssl/certs/ca.pem"
  }

  upload {
    content = data.template_file.consuls1_tls_cert.rendered
    file    = "/etc/ssl/certs/consul-server.crt"
  }

  upload {
    content = data.template_file.consuls1_tls_key.rendered
    file    = "/etc/ssl/consul-server.key"
  }
}

# -----------------------------------------------------------------------
# Consul OSS server 3
# -----------------------------------------------------------------------

resource "docker_container" "consuls2" {
  # XXX: Singleton resource / why count?
  # count = "${var.consul_oss}"
  image = docker_image.consul.latest

  entrypoint = [
    "consul",
    "agent",
    "-server",
    "-node-id=c0ffee74-cb59-4bec-9eba-ca4a3fe56646",
    "-config-dir=/consul/config",
    "-node=consuls2",
    "-client=0.0.0.0",
    "-dns-port=53",
  ]

  env = ["CONSUL_ALLOW_PRIVILEGED_PORTS=", "CONSUL_HTTP_SSL=true"]

  must_run   = true
  name       = "vaultron-consuls2"
  hostname   = "consuls2"
  domainname = "consul"
  dns_search = ["consul"]

  capabilities {
    add = ["NET_ADMIN", "SYS_ADMIN", "SYS_PTRACE", "SYSLOG"]
  }

  healthcheck {
    test         = ["CMD", "consul", "info"]
    interval     = "10s"
    timeout      = "2s"
    start_period = "10s"
    retries      = 2
  }

  networks_advanced {
    name         = "vaultron-network"
    ipv4_address = "10.10.42.102"
  }

  volumes {
    host_path      = "${path.cwd}/consul/consuls2/config"
    container_path = "/consul/config"
  }

  volumes {
    host_path      = "${path.cwd}/consul/consuls2/data"
    container_path = "/consul/data"
  }

  upload {
    content = data.template_file.consul_oss_server_common_config.rendered
    file    = "/consul/config/common_config.json"
  }

  upload {
    content = data.template_file.ca_bundle.rendered
    file    = "/etc/ssl/certs/ca.pem"
  }

  upload {
    content = data.template_file.consuls2_tls_cert.rendered
    file    = "/etc/ssl/certs/consul-server.crt"
  }

  upload {
    content = data.template_file.consuls2_tls_key.rendered
    file    = "/etc/ssl/consul-server.key"
  }
}

# -----------------------------------------------------------------------
# Consul OSS client common configuration
# -----------------------------------------------------------------------

resource "random_id" "agent_node_id" {
  count       = var.consul_oss_instance_count
  byte_length = 16
}

data "template_file" "consulc_common_config" {
  count = var.consul_oss_instance_count
  template = file(
    "${path.module}/templates/oss/consul_oss_client_config_${var.consul_version}.hcl",
  )

  vars = {
    common_configuration = "true"
    agent_node_id        = uuid()
  }
}

# -----------------------------------------------------------------------
# Consul OSS client TLS configuration
# -----------------------------------------------------------------------

data "template_file" "consul_client_tls_cert" {
  count = var.consul_oss_instance_count
  template = file(
    "${path.module}/tls/${format("consul-client-%d.crt", count.index)}",
  )
}

data "template_file" "consul_client_tls_key" {
  count = var.consul_oss_instance_count
  template = file(
    "${path.module}/tls/${format("consul-client-%d.key", count.index)}",
  )
}

# Consul Open Source Client agents

resource "docker_container" "consul_oss_client" {
  count      = var.consul_oss_instance_count
  name       = "vaultron-${format("consulc%d", count.index)}"
  hostname   = format("consulc%d", count.index)
  domainname = "consul"

  dns = [
    docker_container.consuls0.ip_address,
    docker_container.consuls1.ip_address,
    docker_container.consuls2.ip_address,
  ]

  dns_search = ["consul"]
  image      = docker_image.consul.latest

  entrypoint = [
    "consul",
    "agent",
    "-config-dir=/consul/config",
    "-client=0.0.0.0",
    "-advertise=${format("10.10.42.4%d", count.index)}",
    "-data-dir=/consul/data",
    "-datacenter=${var.datacenter_name}",
    "-join=${docker_container.consuls2.ip_address}",
    "-join=${docker_container.consuls1.ip_address}",
    "-join=${docker_container.consuls0.ip_address}",
  ]

  env = ["CONSUL_ALLOW_PRIVILEGED_PORTS=", "CONSUL_HTTP_SSL=true"]

  must_run = true

  capabilities {
    add = ["NET_ADMIN", "SYS_ADMIN", "SYS_PTRACE", "SYSLOG"]
  }

  healthcheck {
    test         = ["CMD", "consul", "info"]
    interval     = "10s"
    timeout      = "2s"
    start_period = "10s"
    retries      = 2
  }

  networks_advanced {
    name         = "vaultron-network"
    ipv4_address = format("10.10.42.4%d", count.index)
  }

  upload {
    content = data.template_file.consulc_common_config[count.index].rendered
    file    = "/consul/config/common_config.json"
  }

  upload {
    content = data.template_file.ca_bundle.rendered
    file    = "/etc/ssl/certs/ca.pem"
  }

  upload {
    content = element(
      data.template_file.consul_client_tls_cert.*.rendered,
      count.index,
    )
    file = "/etc/ssl/certs/consul-client.crt"
  }

  upload {
    content = element(
      data.template_file.consul_client_tls_key.*.rendered,
      count.index,
    )
    file = "/etc/ssl/consul-client.key"
  }

  volumes {
    host_path      = "${path.cwd}/consul/consulc${count.index}/config"
    container_path = "/consul/config"
  }

  volumes {
    host_path      = "${path.cwd}/consul/consulc${count.index}/data"
    container_path = "/consul/data"
  }
}
