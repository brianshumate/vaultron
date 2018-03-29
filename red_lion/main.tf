#############################################################################
# Consul Open Source
#############################################################################

# Consul module outputs

output "consul_oss_server_ips" {
  description = "Consul OSS Server IP addresses"

  value = [
    "${docker_container.consul_oss_server_0.*.ip_address}",
    "${docker_container.consul_oss_server_1.*.ip_address}",
    "${docker_container.consul_oss_server_2.*.ip_address}",
  ]
}

output "consul_oss_client_ips" {
  description = "Consul OSS Client IP addresses"
  value       = ["${docker_container.consul_oss_client.*.ip_address}"]
}

# Consul related variables

variable "consul_log_level" {}
variable "datacenter_name" {}
variable "consul_version" {}
variable "use_consul_oss" {}
variable "consul_ent_id" {}
variable "consul_recursor_1" {}
variable "consul_recursor_2" {}
variable "consul_acl_datacenter" {}
variable "consul_data_dir" {}
variable "consul_custom" {}
variable "consul_custom_instance_count" {}
variable "consul_oss" {}
variable "consul_oss_instance_count" {}

# This is the official Consul Docker image that Vaultron uses by default.
# See also: https://hub.docker.com/_/consul/

resource "docker_image" "consul" {
  name         = "consul:${var.consul_version}"
  keep_locally = true
}

# Consul Open Source server common configuration

data "template_file" "consul_oss_server_common_config" {
  count    = "${var.consul_oss}"
  template = "${file("${path.module}/templates/consul_oss_server_config_${var.consul_version}.tpl")}"

  vars {
    log_level        = "${var.consul_log_level}"
    acl_datacenter   = "arus"
    bootstrap_expect = 3
    datacenter       = "${var.datacenter_name}"
    data_dir         = "${var.consul_data_dir}"
    client           = "0.0.0.0"
    recursor1        = "${var.consul_recursor_1}"
    recursor2        = "${var.consul_recursor_2}"
    ui               = "true"
  }
}

# Consul Server TLS CA Bundle

#data "template_file" "consul_ca_bundle" {
#  template = "${file("${path.module}/tls/ca-bundle.crt")}"
#}

# Consul Server TLS certificates and keys

#data "template_file" "consul_server_0_tls_cert" {
#  template = "${file("${path.module}/tls/consul-server-0.crt")}"
#}
#
#data "template_file" "consul_server_1_tls_cert" {
#  template = "${file("${path.module}/tls/consul-server-1.crt")}"
#}
#
#data "template_file" "consul_server_2_tls_cert" {
#  template = "${file("${path.module}/tls/consul-server-2.crt")}"
#}
#
#data "template_file" "consul_server_0_tls_key" {
#  template = "${file("${path.module}/tls/consul-server-0.key")}"
#}
#
#data "template_file" "consul_server_1_tls_key" {
#  template = "${file("${path.module}/tls/consul-server-1.key")}"
#}
#
#data "template_file" "consul_server_2_tls_key" {
#  template = "${file("${path.module}/tls/consul-server-2.key")}"
#}
#
# Consul Open Source Server 1

resource "docker_container" "consul_oss_server_0" {
  count = "${var.consul_oss}"
  name  = "consul_oss_server_0"
  env   = ["CONSUL_ALLOW_PRIVILEGED_PORTS="]
  image = "${docker_image.consul.latest}"

  # TODO: make GELF logging a conditional thing
  # log_driver = "gelf"
  # log_opts = {
  #   gelf-address = "udp://${var.log_server_ip}:5114"
  # }

  upload = {
    content = "${data.template_file.consul_oss_server_common_config.rendered}"
    file    = "/consul/config/common_config.json"
  }

#  upload = {
#    content = "${data.template_file.consul_ca_bundle.rendered}"
#    file    = "/consul/config/ca-bundle.crt"
#  }
#
#  upload = {
#    content = "${data.template_file.consul_server_0_tls_cert.rendered}"
#    file    = "/consul/config/consul-server.crt"
#  }
#
#  upload = {
#    content = "${data.template_file.consul_server_0_tls_key.rendered}"
#    file    = "/consul/config/consul-server.key"
#  }

  volumes {
    host_path      = "${path.module}/../../../consul/consul_oss_server_0/config"
    container_path = "/consul/config"
  }

  volumes {
    host_path      = "${path.module}/../../../consul/consul_oss_server_0/data"
    container_path = "/consul/data"
  }

  entrypoint = ["consul",
    "agent",
    "-server",
    "-config-dir=/consul/config",
    "-node=consul_oss_server_0",
    "-client=0.0.0.0",
    "-dns-port=53",
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

# Consul Open Source Server 2

resource "docker_container" "consul_oss_server_1" {
  count = "${var.consul_oss}"
  name  = "consul_oss_server_1"
  image = "${docker_image.consul.latest}"

  # TODO: make GELF logging a conditional thing
  # log_driver = "gelf"
  # log_opts = {
  #   gelf-address = "udp://${var.log_server_ip}:5114"
  # }
  upload = {
    content = "${data.template_file.consul_oss_server_common_config.rendered}"
    file    = "/consul/config/common_config.json"
  }

#  upload = {
#    content = "${data.template_file.consul_ca_bundle.rendered}"
#    file    = "/consul/config/ca-bundle.crt"
#  }
#
#  upload = {
#    content = "${data.template_file.consul_server_1_tls_cert.rendered}"
#    file    = "/consul/config/consul-server.crt"
#  }
#
#  upload = {
#    content = "${data.template_file.consul_server_1_tls_key.rendered}"
#    file    = "/consul/config/consul-server.key"
#  }

  volumes {
    host_path      = "${path.module}/../../../consul/consul_oss_server_1/config"
    container_path = "/consul/config"
  }

  volumes {
    host_path      = "${path.module}/../../../consul/consul_oss_server_1/data"
    container_path = "/consul/data"
  }

  entrypoint = ["consul",
    "agent",
    "-server",
    "-config-dir=/consul/config",
    "-node=consul_oss_server_1",
    "-retry-join=${docker_container.consul_oss_server_0.ip_address}",
    "-dns-port=53",
  ]

  must_run = true
}

# Consul Open Source Server 3

resource "docker_container" "consul_oss_server_2" {
  count = "${var.consul_oss}"
  name  = "consul_oss_server_2"
  image = "${docker_image.consul.latest}"

  # TODO: make GELF logging a conditional thing
  # log_driver = "gelf"
  # log_opts = {
  #   gelf-address = "udp://${var.log_server_ip}:5114"
  # }
  upload = {
    content = "${data.template_file.consul_oss_server_common_config.rendered}"
    file    = "/consul/config/common_config.json"
  }

#  upload = {
#    content = "${data.template_file.consul_ca_bundle.rendered}"
#    file    = "/consul/config/ca-bundle.crt"
#  }
#
#  upload = {
#    content = "${data.template_file.consul_server_2_tls_cert.rendered}"
#    file    = "/consul/config/consul-server.crt"
#  }
#
#  upload = {
#    content = "${data.template_file.consul_server_2_tls_key.rendered}"
#    file    = "/consul/config/consul-server.key"
#  }

  volumes {
    host_path      = "${path.module}/../../../consul/consul_oss_server_2/config"
    container_path = "/consul/config"
  }

  volumes {
    host_path      = "${path.module}/../../../consul/consul_oss_server_2/data"
    container_path = "/consul/data"
  }

  entrypoint = ["consul",
    "agent",
    "-server",
    "-config-dir=/consul/config",
    "-node=consul_oss_server_2",
    "-retry-join=${docker_container.consul_oss_server_0.ip_address}",
    "-dns-port=53",
  ]

  must_run = true
}

# Consul Open Source client common configuration

data "template_file" "consul_oss_client_common_config" {
  count    = "${var.consul_oss}"
  template = "${file("${path.module}/templates/consul_oss_client_config_${var.consul_version}.tpl")}"

  vars {
    common_configuration = "true"
  }
}

# Consul Open Source Clients

# Consul Client TLS certificates and keys

#data "template_file" "consul_client_tls_cert" {
#  template = "${file("${path.module}/tls/consul-client-0.crt")}"
#}
#
#data "template_file" "consul_client_tls_key" {
#  template = "${file("${path.module}/tls/consul-client-0.key")}"
#}

resource "docker_container" "consul_oss_client" {
  count = "${var.consul_oss_instance_count}"
  name  = "${format("consul_oss_client_%d", count.index)}"
  image = "${docker_image.consul.latest}"

  upload = {
    content = "${data.template_file.consul_oss_client_common_config.rendered}"
    file    = "/consul/config/common_config.json"
  }

#  upload = {
#    content = "${data.template_file.consul_ca_bundle.rendered}"
#    file    = "/consul/config/ca-bundle.crt"
#  }
#
#  upload = {
#    content = "${data.template_file.consul_client_tls_cert.rendered}"
#    file    = "/consul/config/consul-client.crt"
#  }
#
#  upload = {
#    content = "${data.template_file.consul_client_tls_key.rendered}"
#    file    = "/consul/config/consul-client.key"
#  }

  volumes {
    host_path      = "${path.module}/../../../consul/consul_oss_client_${count.index}/config"
    container_path = "/consul/config"
  }

  volumes {
    host_path      = "${path.module}/../../../consul/consul_oss_client_${count.index}/data"
    container_path = "/consul/data"
  }

  entrypoint = ["${list("consul",
                     "agent",
                     "-config-dir=/consul/config",
                     "-client=0.0.0.0",
                     "-data-dir=/consul/data",
                     "-node=consul_oss_client_${count.index}",
                     "-datacenter=${var.datacenter_name}",
                     "-retry-join=${docker_container.consul_oss_server_2.ip_address}",
                     "-retry-join=${docker_container.consul_oss_server_1.ip_address}",
                     "-retry-join=${docker_container.consul_oss_server_0.ip_address}"
                     )}"]

  dns        = ["${docker_container.consul_oss_server_0.ip_address}", "${docker_container.consul_oss_server_1.ip_address}", "${docker_container.consul_oss_server_2.ip_address}"]
  dns_search = ["consul"]
  must_run   = true
}
