# Vault OSS v0.8.1

cluster_name = "${cluster_name }"

storage "consul" {
  address = "${consul_address}:8500"
  path = "vault/"
  disable_clustering = "${disable_clustering}"
  service_tags = "${service_tags}"
}

listener "tcp" {
  address = "${address}"
  tls_disable = "${tls_disable}"
}

# Default TTL values
default_lease_ttl = "168h" # 7 days
max_lease_ttl = "50000h"   # 2083 days

# Plugin path
plugin_directory  = "/vault/plugins"
