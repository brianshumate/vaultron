output "consul_oss_server_1_ip" {
  description = "Consul OSS Server 1 IP address"
  value = "${docker_container.consul_oss_server_one.ip_address}"
}

output "vault_oss_server_1_ip" {
  description = "Vault OSS Server 1 IP address"
  value = "${docker_container.vault_oss_one.ip_address}"
}

output "vault_oss_one_config_file" {
  description = "Vault Configuration"
  value = "${data.template_file.vault_oss_one_config.rendered}"
}
