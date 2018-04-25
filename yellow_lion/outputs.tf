output "statsd_graphite_ip" {
  value = "${docker_container.statsd_graphite.*.ip_address}"
}
