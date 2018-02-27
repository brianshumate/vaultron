# Vaultron CUSTOM

cluster_name = "${cluster_name }"

storage "consul" {
  address = "${consul_address}:8500"
  path = "vault/"
  disable_clustering = "${disable_clustering}"
}

listener "tcp" {
  address = "${address}"
  tls_disable = "${tls_disable}"
}

# Default TTL values
default_lease_ttl = "168h" # 7 days
max_lease_ttl = "23976h"   # 999 days

# Plugin path
plugin_directory  = "/vault/plugins"

# Telemetry
telemetry {
  dogstatsd_addr  = "172.17.0.2:8125"
  dogstatsd_tags  = [ "datacenter:arus"]
}

# API Address
# api_addr = "http://${address}"
