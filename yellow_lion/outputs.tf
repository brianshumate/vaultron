# statsd / graphite container IP

output "statsd_ip" {
  value = element(
    concat(docker_container.statsd_graphite.*.ip_address, [""]),
    0,
  )
}

