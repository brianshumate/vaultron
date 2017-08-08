#############################################################################
## Consul Open Source
#############################################################################

###
### Consul module outputs
###

output "consul_oss_server_ips" {
  description = "Consul OSS Server IP addresses"
  value = ["${docker_container.consul_oss_server.*.ip_address}"]
}

output "consul_oss_client_ips" {
  description = "Consul OSS Client IP addresses"
  value = ["${docker_container.consul_oss_client.*.ip_address}"]
}

###
### Consul related variables
###

variable "datacenter_name" { }
variable "consul_version" { }
variable "use_consul_oss" { }
variable "consul_ent_id" { }
variable "consul_recursor_1" { }
variable "consul_recursor_2" { }
variable "consul_acl_datacenter" { }
variable "consul_data_dir" { }

###
### This is the official Consul Docker image that Vaultron uses by default.
### See also: https://hub.docker.com/_/consul/
###

resource "docker_image" "consul" {
  name = "consul:${var.consul_version}"
  keep_locally  = true
}

###
### Consul Open Source server common configuration
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
### Consul Open Source Servers
###

resource "docker_container" "consul_oss_server" {
  count = "3"
  name  = "${format("consul_oss_server_%d", count.index)}"
  env = ["CONSUL_ALLOW_PRIVILEGED_PORTS="]
  image = "${docker_image.consul.latest}"
  # TODO: make GELF logging a conditional thing
  # log_driver = "gelf"
  # log_opts = {
  #   gelf-address = "udp://${var.log_server_ip}:5114"
  # }
  upload = {
    content = "${data.template_file.consul_oss_server_common_config.rendered}"
    file = "/consul/config/common_config.json"
  }
  volumes {
    host_path = "${path.module}/../../../consul/consul_oss_server_${count.index}/config"
    container_path = "/consul/config"
  }
  volumes {
    host_path = "${path.module}/../../../consul/consul_oss_server_${count.index}/data"
    container_path = "/consul/data"
  }
  entrypoint = ["${concat(list("consul",
														 "agent",
														 "-server",
														 "-config-dir=/consul/config",
														 "-dns-port=53",
                             "-node=consul_oss_server_${count.index}",
														 "count.index != 0 ? -retry-join=${docker_container.consul_oss_server.0.ip_address} : --"
                             )
                        )}"]
  must_run = true
  # Define some published ports here for the purpose of connecting into
  # the cluster from the host system:
  ports {
    internal = "8300"
    external = "${format("83%d0", count.index)}"
    protocol = "tcp"
  }
  ports {
    internal = "8301"
    external = "${format("83%d1", count.index)}"
    protocol = "tcp"
  }
  ports {
    internal = "8301"
    external = "${format("83%d1", count.index)}"
    protocol = "udp"
  }
  ports {
    internal = "8302"
    external = "${format("83%d2", count.index)}"
    protocol = "tcp"
  }
  ports {
    internal = "8302"
    external = "${format("83%d2", count.index)}"
    protocol = "udp"
  }
  ports {
    internal = "8500"
    external = "${format("85%d0", count.index)}"
    protocol = "tcp"
  }
  ports {
    internal = "53"
    external = "${format("86%d0", count.index)}"
    protocol = "tcp"
  }
  ports {
    internal = "53"
    external = "${format("86%d0", count.index)}"
    protocol = "udp"
  }
}

###
### Consul Open Source client common configuration
###

data "template_file" "consul_oss_client_common_config" {
  template = "${file("${path.module}/templates/consul_oss_client_config_${var.consul_version}.tpl")}"
  vars {
    common_configuration = "true"
  }
}

###
### Consul Open Source Clients
###

resource "docker_container" "consul_oss_client" {
  count = "3"
  name  = "${format("consul_oss_client_%d", count.index)}"
  image = "${docker_image.consul.latest}"
  upload = {
    content = "${data.template_file.consul_oss_client_common_config.rendered}"
    file = "/consul/config/common_config.json"
  }
  volumes {
    host_path = "${path.module}/../../../consul/consul_oss_client_${count.index}/config"
    container_path = "/consul/config"
  }
  volumes {
    host_path = "${path.module}/../../../consul/consul_oss_client_${count.index}/data"
    container_path = "/consul/data"
  }
  entrypoint = ["${list("consul",
											"agent",
											"-config-dir=/consul/config",
											"-client=0.0.0.0",
											"-data-dir=/consul/data",
											"-node=consul_oss_client_${count.index}",
											"-datacenter=${var.datacenter_name}",
											"-retry-join=${element(docker_container.consul_oss_server.*.ip_address, count.index)}"
                      )}"]
  dns = ["${docker_container.consul_oss_server.*.ip_address}"],
  dns_search = ["consul"],
  must_run = true
}

