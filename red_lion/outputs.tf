# individual Consul servers

output "consuls0_ip" {
  value = docker_container.consuls0.*.ip_address
}

output "consuls1_ip" {
  value = docker_container.consuls1.*.ip_address
}

output "consuls2_ip" {
  value = docker_container.consuls2.*.ip_address
}

