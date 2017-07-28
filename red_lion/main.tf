#############################################################################
## Consul Open Source
#############################################################################

###
### Consul module outputs
###

output "consul_oss_server_1_ip" {
  description = "Consul OSS Server 1 IP address"
  value = "${docker_container.consul_oss_server_1.ip_address}"
}

output "consul_oss_server_2_ip" {
  description = "Consul OSS Server 2 IP address"
  value = "${docker_container.consul_oss_server_2.ip_address}"
}

output "consul_oss_server_3_ip" {
  description = "Consul OSS Server 3 IP address"
  value = "${docker_container.consul_oss_server_3.ip_address}"
}

output "consul_oss_client_2_ip" {
  description = "Consul OSS Server 2 IP address"
  value = "${docker_container.consul_oss_client_2.ip_address}"
}

output "consul_oss_client_3_ip" {
  description = "Consul OSS Client 3 IP address"
  value = "${docker_container.consul_oss_client_3.ip_address}"
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
### Consul Open Source Server 1
###

resource "docker_container" "consul_oss_server_1" {
  name  = "consul_oss_server_1"
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
    host_path = "${path.module}/../../../consul/consul_oss_server_1/config"
    container_path = "/consul/config"
  }
  volumes {
    host_path = "${path.module}/../../../consul/consul_oss_server_1/data"
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
    host_path = "${path.module}/../../../consul/consul_oss_server_2/config"
    container_path = "/consul/config"
  }
  volumes {
    host_path = "${path.module}/../../../consul/consul_oss_server_2/data"
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
    host_path = "${path.module}/../../../consul/consul_oss_server_3/config"
    container_path = "/consul/config"
  }
  volumes {
    host_path = "${path.module}/../../../consul/consul_oss_server_3/data"
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
### Consul Open Source client common configuration
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
    host_path = "${path.module}/../../../consul/consul_oss_client_1/config"
    container_path = "/consul/config"
  }
  volumes {
    host_path = "${path.module}/../../../consul/consul_oss_client_1/data"
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
    host_path = "${path.module}/../../../consul/consul_oss_client_2/config"
    container_path = "/consul/config"
  }
  volumes {
    host_path = "${path.module}/../../../consul/consul_oss_client_2/data"
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
    host_path = "${path.module}/../../../consul/consul_oss_client_3/config"
    container_path = "/consul/config"
  }
  volumes {
    host_path = "${path.module}/../../../consul/consul_oss_client_3/data"
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
