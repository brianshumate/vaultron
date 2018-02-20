# Vaultron CUSTOM

cluster_name = "${cluster_name }"
ui = true

# Listener

listener "tcp" {
  address = "${address}"
  tls_disable = "${tls_disable}"
}

# Default TTL values

default_lease_ttl = "14400h" # 600 days
max_lease_ttl = "23976h"     # 365 days

# Plugin path

plugin_directory  = "/vault/plugins"

# Storage

storage "consul" {
  address = "${consul_address}:8500"
  path = "vault/"
  disable_clustering = "${disable_clustering}"
  service_tags = "${service_tags}"
}

# Telemetry

telemetry {
  statsd_address = "172.17.0.2:8125"
}

# API Address
"api_addr" = "https://${address}"
